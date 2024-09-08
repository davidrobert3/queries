-----------------------------------------------------
-- 1. Get current active customers and their details
-----------------------------------------------------
WITH current_active_customers AS (
	-- Retrieve data for customers with a snapshot taken on the current date
	SELECT dcs.account_id,
		-- Customer account ID
		dcs.consecutive_late_days,
		-- Number of consecutive late payment days
		dcs.expiry_timestamp::DATE -- Expiry date of the account
	FROM kenya.daily_customer_snapshot dcs
	WHERE dcs.date_timestamp::DATE = current_date -- Filter for the current date
)
SELECT cpd.customer_id,
	-- Customer ID
	ca.account_id,
	-- Account ID from the active customers data
	cpd.customer_name,
	-- Customer's name
	rpcl.unique_customer_id,
	-- Unique customer ID from the portfolio lookup
	rpcl.customer_active_start_date::DATE AS installation_date,
	-- Date when the customer became active
	rpcl.down_payment_date::DATE,
	-- Date of the down payment
	cpd.customer_phone_1,
	-- Primary contact phone number
	cpd.customer_phone_2,
	-- Secondary contact phone number
	rpcl.sales_agent_names,
	-- Names of the sales agents
	rpcl.shop,
	-- Shop associated with the customer
	rpcl.current_hardware_type,
	-- Type of hardware currently used
	rpcl.current_system,
	-- Current system of the customer
	rpcl.serial_number,
	-- Serial number of the hardware
	rpcl.downpayment,
	-- Amount of down payment
	rpcl.current_daily_rate,
	-- Current daily rate for the customer
	rpcl.total_contract_value,
	-- Total value of the contract
	rpcl.tv_customer,
	-- Indicates if the customer is a TV customer
	rpcl.current_client_status,
	-- Current status of the client
	rpcl.current_payment_status,
	-- Current payment status
	rpcl.current_enable_status,
	-- Current enable status
	ca.consecutive_late_days,
	-- Number of consecutive late payment days
	ca.expiry_timestamp::DATE,
	-- Expiry date of the account
	rpcl.total_paid_to_date,
	-- Total amount paid to date
	rpcl.outstanding_balance,
	-- Outstanding balance
	rpcl.esf_customer,
	-- Indicates if the customer is an ESF customer
	-- Calculate the number of days the customer has been active in their lifetime
	SUM(
		CASE
			WHEN dcs.customer_status = 'active' THEN 1
			ELSE 0
		END
	) AS days_active_lifetime,
	-- Calculate the number of days the customer has had a "normal" payment status in their lifetime
	SUM(
		CASE
			WHEN dcs.payment_status = 'normal' THEN 1
			ELSE 0
		END
	) AS days_normal_lifetime,
	-- Calculate the number of days the customer has been active in the last six months
	SUM(
		CASE
			WHEN dcs.customer_status = 'active'
			AND dcs.date_timestamp::DATE >= current_date - 179 THEN 1
			ELSE 0
		END
	) AS days_active_six_months,
	-- Calculate the number of days the customer has had a "normal" payment status in the last six months
	SUM(
		CASE
			WHEN dcs.payment_status = 'normal'
			AND dcs.date_timestamp::DATE >= current_date - 179 THEN 1
			ELSE 0
		END
	) AS days_normal_six_months,
	-- Calculate the Usage Rate (UR) for the last six months as the ratio of normal payment days to active days
	SUM(
		CASE
			WHEN dcs.payment_status = 'normal'
			AND dcs.date_timestamp::DATE >= current_date - 179 THEN 1
			ELSE 0
		END
	)::float / SUM(
		CASE
			WHEN dcs.customer_status = 'active'
			AND dcs.date_timestamp::DATE >= current_date - 179 THEN 1
			ELSE 0
		END
	)::float AS six_months_UR
FROM current_active_customers ca -- Use the current active customers data
	LEFT JOIN kenya.daily_customer_snapshot dcs ON dcs.account_id = ca.account_id -- Join on account ID
	LEFT JOIN kenya.customer_personal_details cpd ON ca.account_id = cpd.account_id -- Join with personal details
	LEFT JOIN kenya.rp_portfolio_customer_lookup rpcl ON rpcl.account_id = ca.account_id -- Join with portfolio lookup
GROUP BY 1,
	-- customer_id
	2,
	-- account_id
	3,
	-- customer_name
	4,
	-- unique_customer_id
	5,
	-- installation_date
	6,
	-- down_payment_date
	7,
	-- customer_phone_1
	8,
	-- customer_phone_2
	9,
	-- sales_agent_names
	10,
	-- shop
	11,
	-- current_hardware_type
	12,
	-- current_system
	13,
	-- serial_number
	14,
	-- downpayment
	15,
	-- current_daily_rate
	16,
	-- total_contract_value
	17,
	-- tv_customer
	18,
	-- current_client_status
	19,
	-- current_payment_status
	20,
	-- current_enable_status
	21,
	-- consecutive_late_days
	22,
	-- expiry_timestamp
	23,
	-- total_paid_to_date
	24,
	-- outstanding_balance
	25 -- esf_customer
	--LIMIT 5 -- Uncomment to limit the number of results