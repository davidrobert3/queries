-- CTE to get sales details along with associated sales agents
WITH sales_details AS (
	SELECT DISTINCT sales.unique_account_id,
		-- Unique account ID for each sale
		sales.sales_person,
		-- Salesperson responsible for the sale
		agent.username,
		-- Sales agent's username
		agent.sales_agent_bboxx_id,
		-- Bboxx ID for the sales agent
		agent.sales_agent_name,
		-- Full name of the sales agent
		agent.sales_agent_mobile -- Mobile number of the sales agent
	FROM kenya.rp_retail_sales AS sales
		LEFT JOIN kenya.sales_agent AS agent ON agent.sales_agent_id = sales.sign_up_sales_agent_id -- Join to get sales agent details
	WHERE sales.sale_type = 'install' -- Filter for 'install' type sales
		AND sales.sales_order_id = sales.unique_account_id -- Ensure sales order matches the account
),
-- CTE to get the latest payment date for each account
last_phon AS (
	SELECT p.payg_account_id,
		-- PAYG account ID
		MAX(p.transaction_date::date) AS date_ -- Latest payment date
	FROM src_odoo13_kenya.account_payment p
	GROUP BY p.payg_account_id -- Group by account to get the latest payment date
),
-- CTE to get the latest phone number associated with the latest payment
last_phone AS (
	SELECT p.payg_account_id,
		-- PAYG account ID
		l.date_,
		-- Latest payment date from the previous CTE
		-- Concatenate distinct phone numbers, separating them with a comma
		LISTAGG(DISTINCT(p.payer_identifier), ',') AS payer_identifier
	FROM last_phon l
		LEFT JOIN src_odoo13_kenya.account_payment p ON l.payg_account_id = p.payg_account_id -- Join to get phone numbers for the accounts
	WHERE l.date_ = p.transaction_date::date -- Only include payments made on the latest date
	GROUP BY p.payg_account_id,
		l.date_ -- Group by account and date
) -- Main query to retrieve customer activity and details, including phone numbers and PAR bucket classification
SELECT today.date_timestamp::date AS activity_date,
	-- Activity date
	c.unique_account_id,
	-- Unique account ID
	details.customer_name,
	-- Customer's name
	sales_details.sales_person,
	-- Salesperson's name from sales details
	details.customer_phone_1,
	-- Customer's primary phone number
	details.customer_phone_2,
	-- Customer's secondary phone number
	last_phone.payer_identifier,
	-- Latest phone number from the last_phone CTE
	details.customer_home_address AS nearest_landmark,
	-- Nearest landmark to the customer's home
	details.home_address_2,
	-- Address component 2
	details.home_address_3,
	-- Address component 3
	details.home_address_5,
	-- Address component 5
	details.home_address_4,
	-- Address component 4
	today.daily_rate,
	-- Customer's daily rate
	filters.shop,
	-- Associated shop for the customer
	today.consecutive_late_days,
	-- Consecutive late payment days
	-- Classify customers into PAR buckets based on consecutive late days
	CASE
		WHEN today.consecutive_late_days BETWEEN 15 AND 29 THEN '2. PAR 1 - 30'
		WHEN today.consecutive_late_days BETWEEN 30 AND 59 THEN '3. PAR 30 - 60'
		WHEN today.consecutive_late_days BETWEEN 60 AND 120 THEN '4. PAR 60 - 120'
		WHEN today.consecutive_late_days > 90 THEN '5. PAR 120+'
	END AS PAR_bucket,
	-- PAR bucket classification
	-- Assign row numbers for related accounts
	ROW_NUMBER() OVER (PARTITION BY c.customer_id) AS related_accounts
FROM kenya.agg_dcs_today AS today
	LEFT JOIN kenya.customer_personal_details AS details ON details.account_id = today.account_id -- Join with customer personal details
	LEFT JOIN kenya.customer AS c ON c.account_id = details.account_id -- Join with customer account data
	LEFT JOIN kenya.rp_portfolio_customer_lookup AS filters ON filters.account_id = today.account_id -- Join with portfolio customer lookup
	LEFT JOIN sales_details ON sales_details.unique_account_id = c.unique_account_id -- Join with sales details
	LEFT JOIN last_phone ON c.unique_account_id = last_phone.payg_account_id -- Join with latest phone details
WHERE today.consecutive_late_days BETWEEN 15 AND 120 -- Filter for customers with late payments between 15 and 120 days