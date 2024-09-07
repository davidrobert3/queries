with count_of_payments as 
(
	select 
		distinct p.account_id ,
		count(distinct third_party_payment_ref_id) as number_of_payments
	from kenya.payment p 
	group by 1
--	limit 5
),
dp_defautlers as
(
	select 
		distinct p.account_id ,
		dcs.payg_account_id ,
		dcs.consecutive_late_days ,
		number_of_payments ,
		count(distinct third_party_payment_ref_id)	as number_of_downpayments
	from kenya.payment p  
	left join count_of_payments cp on
		p.account_id = cp.account_id
	left join kenya.daily_customer_snapshot dcs on
		p.account_id = dcs.account_id
		and dcs.date_timestamp::DATE = current_date 
	where p.is_down_payment is true 
	and dcs.consecutive_late_days >= 60
	and dcs.payg_account_id notnull
	group by 1,2,3,4
	having number_of_payments = count(distinct third_party_payment_ref_id)
--	limit 5
)
select 
	dp.payg_account_id as customer_account_id,
	cpd.customer_name ,
	cpd.customer_phone_1 ,
	cpd.customer_phone_2 ,
	rpcl.shop ,
	rpcl.current_hardware_type ,
	rpcl.current_system ,
	rpcl.customer_active_start_date::DATE as installation_date,
	dp.consecutive_late_days
from dp_defautlers dp
left join kenya.customer_personal_details cpd on
	cpd.account_id = dp.account_id
left join kenya.rp_portfolio_customer_lookup rpcl on
	rpcl.account_id = dp.account_id
--limit 5