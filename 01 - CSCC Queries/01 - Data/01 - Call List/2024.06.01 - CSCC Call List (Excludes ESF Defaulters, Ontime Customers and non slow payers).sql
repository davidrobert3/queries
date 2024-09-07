-- CTE to retrieve all sales made by attached sales agents
WITH sales_details AS (
	-- Select unique sales accounts and corresponding sales agent details
	SELECT DISTINCT sales.unique_account_id,
		-- Unique identifier for each sale
		sales.sales_person,
		-- Salesperson responsible for the sale
		agent.username,
		-- Username of the sales agent
		agent.sales_agent_bboxx_id,
		-- Sales agent ID in the system
		agent.sales_agent_name,
		-- Full name of the sales agent
		agent.sales_agent_mobile -- Sales agent's mobile number
	FROM kenya.rp_retail_sales AS sales
		LEFT JOIN kenya.sales_agent AS agent ON agent.sales_agent_id = sales.sign_up_sales_agent_id -- Join sales data with agent details
	WHERE sales.sale_type = 'install' -- Filter for 'install' type sales
		AND sales.sales_order_id = sales.unique_account_id -- Match sales order to account
),
-- CTE to get the latest payment date for each account
last_phon AS (
	-- Select the maximum (latest) payment date for each account
	SELECT p.payg_account_id,
		-- Account ID
		MAX(p.transaction_date::date) AS date_ -- Latest transaction date
	FROM src_odoo13_kenya.account_payment p
	GROUP BY p.payg_account_id -- Group by account to get the latest payment date
),
-- CTE to retrieve the last recorded phone number for each account
last_phone AS (
	-- Select the account ID, latest payment date, and phone number
	SELECT p.payg_account_id,
		-- Account ID
		l.date_,
		-- Latest transaction date from the previous CTE
		-- Concatenate distinct valid phone numbers (between 10 and 15 digits)
		LISTAGG(
			DISTINCT(
				CASE
					WHEN LENGTH(p.payer_identifier) > 10
					AND LENGTH(p.payer_identifier) < 15 THEN p.payer_identifier
					ELSE NULL
				END
			),
			','
		) AS payer_identifier -- Aggregated phone number
	FROM last_phon l
		LEFT JOIN src_odoo13_kenya.account_payment p ON l.payg_account_id = p.payg_account_id -- Join with payments table
	WHERE l.date_ = p.transaction_date::date -- Only consider payments on the latest date
	GROUP BY p.payg_account_id,
		l.date_ -- Group by account and transaction date
),
-- CTE to get complete customer data and assign them to PAR buckets based on consecutive late days
complete_data AS (
	SELECT today.date_timestamp::date AS activity_date,
		-- Activity date
		c.unique_account_id,
		-- Unique account ID
		details.customer_name,
		-- Customer's name
		sales_details.sales_person,
		-- Salesperson responsible for the sale
		details.customer_phone_1,
		-- Customer's primary phone number
		details.customer_phone_2,
		-- Customer's secondary phone number
		l.payer_identifier,
		-- Most recent payer phone number
		details.customer_home_address AS nearest_landmark,
		-- Customer's nearest landmark
		details.home_address_2,
		-- Address component 2
		details.home_address_3,
		-- Address component 3
		details.home_address_5,
		-- Address component 5
		details.home_address_4,
		-- Address component 4
		today.daily_rate,
		-- Daily rate for the customer
		filters.shop,
		-- Shop linked to the customer
		today.consecutive_late_days,
		-- Consecutive days of late payment
		-- Classify customers into PAR buckets based on consecutive late days
		CASE
			WHEN today.consecutive_late_days BETWEEN 15 AND 29 THEN '2. PAR 15 - 29'
			WHEN today.consecutive_late_days BETWEEN 30 AND 59 THEN '3. PAR 30 - 59'
			WHEN today.consecutive_late_days BETWEEN 60 AND 119 THEN '4. PAR 60 - 119'
			WHEN today.consecutive_late_days > 119 THEN '5. PAR 120+'
		END AS PAR_bucket,
		-- PAR bucket classification
		-- Assign row number for customers with multiple related accounts
		ROW_NUMBER() OVER (PARTITION BY c.customer_id) AS related_accounts
	FROM kenya.agg_dcs_today AS today
		LEFT JOIN kenya.customer_personal_details AS details ON details.account_id = today.account_id -- Join with customer details
		LEFT JOIN kenya.customer AS c ON c.account_id = details.account_id -- Join customer ID
		LEFT JOIN kenya.rp_portfolio_customer_lookup AS filters ON filters.account_id = today.account_id -- Join with portfolio lookup
		LEFT JOIN sales_details AS sales_details ON sales_details.unique_account_id = c.unique_account_id -- Join with sales details
		LEFT JOIN last_phone AS l ON l.payg_account_id = c.unique_account_id -- Join with the most recent phone number
	WHERE today.consecutive_late_days BETWEEN 15 AND 119 -- Filter for customers with late payments
),
-- CTE to add a filter for ESF defaulters based on daily rate and consecutive late days
initial_data_with_filter_columns AS (
	SELECT *,
		-- Select all columns from complete_data
		-- Mark accounts as ESF defaulters if daily rate is less than 21 and late days > 59
		CASE
			WHEN daily_rate < 21
			AND consecutive_late_days > 59 THEN 1
			ELSE 0
		END AS esf_defaulters -- ESF defaulter flag
	FROM complete_data
),
-- CTE to calculate the last 6 months' utilization rate (UR) for each account
last_six_mo_ur AS (
	SELECT account_id,
		-- Customer account ID
		payg_account_id,
		-- PAYG account ID
		-- Count of days with normal payment status
		SUM(
			CASE
				WHEN payment_status = 'normal' THEN 1
				ELSE 0
			END
		) AS DaysInNormalStatus,
		-- Count of days with normal status excluding pending statuses
		SUM(
			CASE
				WHEN payment_status = 'normal'
				AND enable_status NOT IN ('pending_enabled', 'pending_disabled') THEN 1
				ELSE 0
			END
		) AS DaysInNormalStatusExcPending,
		-- Count of days with normal expiry status
		SUM(
			CASE
				WHEN expiry_timestamp::DATE >= date_timestamp::DATE THEN 1
				ELSE 0
			END
		) AS DaysInNormalExpiry,
		-- Count of days with no consecutive late payments
		SUM(
			CASE
				WHEN consecutive_late_days = 0 THEN 1
				ELSE 0
			END
		) AS DaysInNormalConsecDays,
		-- Count of total active days
		COUNT(DISTINCT daily_customer_snapshot_id) AS DaysActive
	FROM kenya.daily_customer_snapshot dcs
	WHERE dcs.date_timestamp::DATE >= CURRENT_DATE - 180 -- Only consider data from the last 6 months
		AND dcs.date_timestamp::DATE <= CURRENT_DATE
	GROUP BY dcs.account_id,
		payg_account_id -- Group by account and PAYG ID
),
-- Main query combining customer data with UR calculation
main_data_Set AS (
	SELECT initial_data_with_filter_columns.activity_date,
		-- Activity date
		initial_data_with_filter_columns.unique_account_id,
		-- Unique account ID
		initial_data_with_filter_columns.customer_name,
		-- Customer's name
		initial_data_with_filter_columns.sales_person,
		-- Salesperson's name
		initial_data_with_filter_columns.customer_phone_1,
		-- Primary phone number
		initial_data_with_filter_columns.customer_phone_2,
		-- Secondary phone number
		initial_data_with_filter_columns.payer_identifier,
		-- Most recent phone number from payments
		initial_data_with_filter_columns.nearest_landmark,
		-- Nearest landmark
		initial_data_with_filter_columns.home_address_2,
		-- Address component 2
		initial_data_with_filter_columns.home_address_3,
		-- Address component 3
		initial_data_with_filter_columns.home_address_5,
		-- Address component 5
		initial_data_with_filter_columns.home_address_4,
		-- Address component 4
		initial_data_with_filter_columns.daily_rate,
		-- Daily payment rate
		initial_data_with_filter_columns.shop,
		-- Associated shop
		initial_data_with_filter_columns.consecutive_late_days,
		-- Consecutive late days
		initial_data_with_filter_columns.par_bucket,
		-- PAR bucket classification
		last_six_mo_ur.DaysInNormalConsecDays,
		-- Days with no consecutive late payments in 6 months
		last_six_mo_ur.DaysActive,
		-- Total active days in 6 months
		-- Calculate utilization rate (UR) for the last 6 months
		last_six_mo_ur.DaysInNormalConsecDays::DOUBLE PRECISION / last_six_mo_ur.DaysActive AS last_6_month_ur
	FROM initial_data_with_filter_columns
		LEFT JOIN last_six_mo_ur ON last_six_mo_ur.payg_account_id = initial_data_with_filter_columns.unique_account_id
	WHERE esf_defaulters = 0 -- Exclude ESF defaulters
) -- Final query to select records where the last 6-month UR is below 0.7
SELECT *
FROM main_data_Set
WHERE last_6_month_ur < 0.7;