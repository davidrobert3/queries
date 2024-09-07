WITH current_active_ctomers AS
(
	SELECT 
		dcs.account_id ,
		dcs.consecutive_late_days ,
		dcs.expiry_timestamp::DATE
	FROM kenya.daily_customer_snapshot dcs 
	WHERE dcs.date_timestamp::DATE = current_date 
)
SELECT 
	dcs.customer_id , --1
	ca.account_id, --2
	cpd.customer_name , --3
	rpcl.unique_customer_id , --4
	rpcl.customer_active_start_date::DATE AS installation_date, --5
	rpcl.down_payment_date::DATE, --6
	cpd.customer_phone_1 , --7
	cpd.customer_phone_2 , --8
	rpcl.sales_agent_names , --9
	rpcl.shop , --10
	rpcl.current_hardware_type , --11
	rpcl.current_system , --12
	rpcl.serial_number , --13
	rpcl.downpayment , --14
	rpcl.current_daily_rate , --15
	rpcl.total_contract_value , --16
	rpcl.tv_customer , --17
	rpcl.current_client_status , --18
	rpcl.current_payment_status , --19
	rpcl.current_enable_status , --20
	ca.consecutive_late_days, --21
	ca.expiry_timestamp::DATE, --22
	rpcl.total_paid_to_date , --23
	rpcl.outstanding_balance , --24
	rpcl.esf_customer , --25
	sum(CASE 
		WHEN dcs.customer_status = 'active'
			THEN 1
		ELSE 0
	END) AS days_active_lifetime,
	sum(CASE
		WHEN dcs.payment_status = 'normal'
			THEN 1
		ELSE 0
	END) AS days_normal_lifetime,
	sum(CASE 
		WHEN dcs.customer_status = 'active' AND dcs.date_timestamp::DATE >= current_date - 179
			THEN 1
		ELSE 0
	END) AS days_active_six_months,
	sum(CASE
		WHEN dcs.payment_status = 'normal' AND dcs.date_timestamp::DATE >= current_date - 179
			THEN 1
		ELSE 0
	END) AS days_normal_six_months,
	sum(CASE
		WHEN dcs.payment_status = 'normal' AND dcs.date_timestamp::DATE >= current_date - 179
			THEN 1
		ELSE 0
	END)::float/
	sum(CASE 
		WHEN dcs.customer_status = 'active' AND dcs.date_timestamp::DATE >= current_date - 179
			THEN 1
		ELSE 0
	END)::float AS six_months_UR
FROM current_active_ctomers ca
LEFT JOIN kenya.daily_customer_snapshot dcs ON
	dcs.account_id = ca.account_id
LEFT JOIN kenya.customer_personal_details cpd ON
	ca.account_id = cpd.account_id
LEFT JOIN kenya.rp_portfolio_customer_lookup rpcl ON
	rpcl.account_id = ca.account_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
--LIMIT 5