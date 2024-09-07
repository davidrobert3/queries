------------------------------------------------------------------------
-- The query is responsible for getting a list of customers with a last 3 month collection rate between 70% to 90%.
-- The goal is to send text messages to them pointing out their good paiying status while also encouraging them to continuing being good payers inorder to receive better services
-- Here is the logic used;
		--> 1. contract_details CTE
					--> Responsible for getting customer information like installation date and personal info
					--> Calcualtes customer age
					--> Gets basic contract details like daily rate, contract value and downpayment
		--> 2. total_paid_three_months CTE
					--> Responsible for getting the amount paid by a customer for past three months.
					--> Filters out bonuses and voided payment.
					--> summizes the amount and categorizes it to each customer
		--> 3. semi_final_cte CTE 
					--> Calculates last three months less dp in cases where the customer was installed with the 3 month period.
					--> Calculated expected amount with both customers installed within the last 3 months and older customers taken into consideration
					--> Filters out customers with no unique customer account.
		--> 4. final_cte CTE 
					--> Calculates collection rates for each customer
					--> Calculates cash missed 
		--> 5. Main Query
					--> filters for customers with a collection rate between 70% and 90%
		

--------------
-- gets customer detail including their ages with consecutive days late and daily rates. 
WITH contract_details AS 
	(	
		SELECT 
			DISTINCT dcs.customer_id,
			dcs.account_id, 
			rpcl.unique_customer_id, 
			rpcl.customer_active_start_date::DATE AS InstallationDate,
			c.down_payment_paid_date, 
			cpd.customer_name, 
			cpd.customer_phone_1, 
			cpd.customer_phone_2, 
			rpcl.region, 
			rpcl.shop, 
			rpcl.sales_agent_names,
			rpcl.current_hardware_type, 
			rpcl.current_system, 
			rpcl.control_unit_serial_number,
			rpcl.downpayment,  
			rpcl.daily_rate AS rpcl_daily_rate,
			rpcl.total_contract_value, 
			rpcl.tv_customer, 
			dcs.customer_status,
			dcs.payment_status,
			dcs.enable_status, 
			c.current_customer_status, 
			dcs.expiry_timestamp::DATE AS ExpiryDate,
			dcs.consecutive_late_days,
			dcs.date_timestamp::DATE - rpcl.customer_active_start_date::DATE AS customer_age
		from
			kenya.daily_customer_snapshot dcs 
		LEFT JOIN kenya.customer c 
			ON dcs.account_id = c.account_id
			AND c.current_customer_status = 'active'
		LEFT JOIN kenya.rp_portfolio_customer_lookup rpcl 
			ON dcs.account_id = rpcl.account_id 
			AND rpcl.current_client_status = 'active'
		LEFT JOIN kenya.customer_personal_details cpd 
			ON dcs.account_id = cpd.account_id  
		WHERE 
			dcs.date_timestamp::DATE = CURRENT_DATE::DATE - 1  --<--- enter the specific date here
	),

	
-----------------------
-- get the total amount paid by each customer for the last three months
	total_paid_three_months AS 
	(
		SELECT 
			p.payg_account_id AS AccountID, 
			SUM(p.amount) AS TotalPaid
		FROM src_odoo13_kenya.account_payment AS p
		WHERE 
			p.state = 'posted'
			AND p."type" = 'mobile'
			AND p.transaction_date::DATE >= CURRENT_DATE::DATE - 91 --<--- enter the specific date here
			AND p.transaction_date::DATE <= CURRENT_DATE::DATE
		GROUP BY 
			p.payg_account_id
	),
	
---------------------
-- calculates the total amount paid by a customer for the last three months less dp and expected amount
	semi_final_cte AS 
	(
		SELECT 
			contract_details.*,
			total_paid_three_months.TotalPaid as TotalPaidLast3Months,	
			(CASE 
				WHEN contract_details.customer_age < 91
					THEN total_paid_three_months.TotalPaid - contract_details.downpayment
				ELSE total_paid_three_months.TotalPaid
			END) as TotalPaidLast3Months_net_dp,
			(CASE 
				WHEN contract_details.customer_age > 91
					THEN 90 * contract_details.rpcl_daily_rate
				ELSE (contract_details.customer_age - 7) * contract_details.rpcl_daily_rate
			END) AS expected_payments_last_three_months
		FROM contract_details 
		LEFT JOIN total_paid_three_months
			ON contract_details.unique_customer_id = total_paid_three_months.AccountID
		WHERE contract_details.unique_customer_id NOTNULL 
 	),
 ---------------------------------
 -- calculates cash collection rate for the last three months
 	final_cte AS 
	(
		 SELECT 
		 	unique_customer_id,
		 	installationdate,
		 	customer_name,
		 	customer_phone_1,
		 	current_hardware_type,
		 	customer_age,
		 	rpcl_daily_rate,
		 	downpayment,
		 	expected_payments_last_three_months,
		 	TotalPaidLast3Months,
		 	TotalPaidLast3Months_net_dp,
		 	round(COALESCE(TotalPaidLast3Months_net_dp,0)/NULLIF((expected_payments_last_three_months),0),2) as cash_collection_rate_last_three_months,
		 	expected_payments_last_three_months - TotalPaidLast3Months_net_dp as cash_missed_supposed_to_pay
		 FROM semi_final_cte
		 WHERE customer_age > 7
	 )  
----------------------------
-- Main query to filter based on cash collection
 SELECT 
 	unique_customer_id,
	installationdate,
	customer_name,
 	customer_phone_1,
 	current_hardware_type,
 	cash_collection_rate_last_three_months,
 	cash_missed_supposed_to_pay,
 	TotalPaidLast3Months_net_dp,
 	expected_payments_last_three_months
 FROM final_cte
 WHERE 
 	cash_collection_rate_last_three_months > 0.69999999
 	AND cash_collection_rate_last_three_months < 0.9