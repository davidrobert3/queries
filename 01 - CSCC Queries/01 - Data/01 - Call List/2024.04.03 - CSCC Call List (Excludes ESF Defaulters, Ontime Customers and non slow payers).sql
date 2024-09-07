-- CTE to get all sales made with the attached sales agents
WITH sales_details AS (
	-- Select unique sales details along with corresponding sales agents
	SELECT DISTINCT sales.unique_account_id,
		sales.sales_person,
		agent.username,
		agent.sales_agent_bboxx_id,
		agent.sales_agent_name,
		agent.sales_agent_mobile
	FROM kenya.rp_retail_sales AS sales
		LEFT JOIN kenya.sales_agent AS agent ON agent.sales_agent_id = sales.sign_up_sales_agent_id -- Filter to only include sales of type 'install'
	WHERE sales.sale_type = 'install'
		AND sales.sales_order_id = sales.unique_account_id
),
-- CTE to get the last payment date for each account
last_phon AS (
	SELECT p.payg_account_id,
		MAX(p.transaction_date::date) AS date_
	FROM src_odoo13_kenya.account_payment p -- Group by account to get the latest transaction date per account
	GROUP BY p.payg_account_id
),
-- CTE to get the most recent phone number for each account based on payment date
last_phone AS (
	SELECT p.payg_account_id,
		l.date_,
		-- Use LISTAGG to concatenate distinct phone numbers
		LISTAGG(
			DISTINCT(
				CASE
					-- Filter for phone numbers with valid length
					WHEN LENGTH(p.payer_identifier) > 10
					AND LENGTH(p.payer_identifier) < 15 THEN p.payer_identifier
					ELSE NULL
				END
			),
			','
		) AS payer_identifier
	FROM last_phon l
		LEFT JOIN src_odoo13_kenya.account_payment p ON l.payg_account_id = p.payg_account_id -- Match only transactions on the latest payment date
	WHERE l.date_ = p.transaction_date::date
	GROUP BY p.payg_account_id,
		l.date_
),
-- CTE to get the complete customer data along with PAR bucket classification
complete_data AS (
	SELECT today.date_timestamp::date AS activity_date,
		c.unique_account_id,
		details.customer_name,
		sales_details.sales_person,
		details.customer_phone_1,
		details.customer_phone_2,
		l.payer_identifier,
		details.customer_home_address AS nearest_landmark,
		details.home_address_2,
		details.home_address_3,
		details.home_address_5,
		details.home_address_4,
		today.daily_rate,
		filters.shop,
		today.consecutive_late_days,
		-- Classify customers into PAR buckets based on consecutive late days
		CASE
			WHEN today.consecutive_late_days BETWEEN 15 AND 29 THEN '2. PAR 15 - 29'
			WHEN today.consecutive_late_days BETWEEN 30 AND 59 THEN '3. PAR 30 - 59'
			WHEN today.consecutive_late_days BETWEEN 60 AND 119 THEN '4. PAR 60 - 119'
			WHEN today.consecutive_late_days > 119 THEN '5. PAR 120+'
		END AS PAR_bucket,
		-- Assign a row number to identify related accounts
		ROW_NUMBER() OVER (PARTITION BY c.customer_id) AS related_accounts
	FROM kenya.agg_dcs_today AS today
		LEFT JOIN kenya.customer_personal_details AS details ON details.account_id = today.account_id
		LEFT JOIN kenya.customer AS c ON c.account_id = details.account_id
		LEFT JOIN kenya.rp_portfolio_customer_lookup AS filters ON filters.account_id = today.account_id
		LEFT JOIN sales_details AS sales_details ON sales_details.unique_account_id = c.unique_account_id
		LEFT JOIN last_phone AS l ON l.payg_account_id = c.unique_account_id -- Filter customers with late payments between 15 and 119 days
	WHERE today.consecutive_late_days BETWEEN 15 AND 119
),
-- CTE to calculate the last 6 months' UR for each account
last_six_mo_ur AS (
	SELECT account_id,
		payg_account_id,
		-- Calculate days in normal payment status
		SUM(
			CASE
				WHEN payment_status = 'normal' THEN 1
				ELSE 0
			END
		) AS DaysInNormalStatus,
		-- Calculate days in normal status excluding pending statuses
		SUM(
			CASE
				WHEN payment_status = 'normal'
				AND enable_status NOT IN ('pending_enabled', 'pending_disabled') THEN 1
				ELSE 0
			END
		) AS DaysInNormalStatusExcPending,
		-- Calculate days with normal expiry
		SUM(
			CASE
				WHEN expiry_timestamp::DATE >= date_timestamp::DATE THEN 1
				ELSE 0
			END
		) AS DaysInNormalExpiry,
		-- Calculate days with no consecutive late payments
		SUM(
			CASE
				WHEN consecutive_late_days = 0 THEN 1
				ELSE 0
			END
		) AS DaysInNormalConsecDays,
		-- Count total active days
		COUNT(DISTINCT daily_customer_snapshot_id) AS DaysActive
	FROM kenya.daily_customer_snapshot dcs -- Filter data for the last 6 months
	WHERE dcs.date_timestamp::DATE >= CURRENT_DATE - 180
		AND dcs.date_timestamp::DATE <= CURRENT_DATE
	GROUP BY dcs.account_id,
		payg_account_id
),
-- Main query combining complete data and UR calculation for customers
main_data_Set AS (
	SELECT complete_data.activity_date,
		complete_data.unique_account_id,
		complete_data.customer_name,
		complete_data.sales_person,
		complete_data.customer_phone_1,
		complete_data.customer_phone_2,
		complete_data.payer_identifier,
		complete_data.nearest_landmark,
		complete_data.home_address_2,
		complete_data.home_address_3,
		complete_data.home_address_5,
		complete_data.home_address_4,
		complete_data.daily_rate,
		complete_data.shop,
		complete_data.consecutive_late_days,
		complete_data.PAR_bucket,
		last_six_mo_ur.DaysInNormalConsecDays,
		last_six_mo_ur.DaysActive,
		-- Calculate UR ratio for the last 6 months
		last_six_mo_ur.DaysInNormalConsecDays::DOUBLE PRECISION / last_six_mo_ur.DaysActive AS last_6_month_ur
	FROM complete_data
		LEFT JOIN last_six_mo_ur ON last_six_mo_ur.payg_account_id = complete_data.unique_account_id -- Filter customers who made a free on-time payment and are not defaulters
	WHERE free_ontime_payment_made = 1
		AND esf_defaulters = 0
) -- Final query to select data for customers with low UR (< 0.7)
SELECT *
FROM main_data_Set
WHERE last_6_month_ur < 0.7;