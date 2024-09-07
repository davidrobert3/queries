----------------------------------
-- get the last payment date
with lastpaymentdate as 
	(
		select 
			ap.payg_account_id ,
			max(ap.transaction_date) as last_date
		from src_odoo13_kenya.account_payment ap 
		group by 1
	),
--------------------------------
-- get the last phone number that paid.
	lastphone_ as 
		(
			select 
				ap.payg_account_id ,
				case 
					when len(ap.payer_identifier) < 8 or len(ap.payer_identifier) > 15
						then null
					else ap.payer_identifier
				end as last_payment_phone	
			from lastpaymentdate lp
			left join src_odoo13_kenya.account_payment ap on
				ap.payg_account_id = lp.payg_account_id
			where ap.transaction_date = lp.last_date
		)
----------------------------
-- main query to get write-offs and customer details
select 
	rpcl.unique_customer_id ,
	rpcl.customer_active_start_date as installationdate ,
	cpd.customer_name ,
	cpd.customer_phone_1 ,
	cpd.customer_phone_2 ,
	lp.last_payment_phone ,
	cpd.customer_national_id_type ,
	cpd.customer_national_id_number ,
	rpcl.region ,
	rpcl.shop ,
	case 
		when rpcl.current_system ilike 'offline_token'
			then 'Solar with token'
		when rpcl.current_system in ('nuovopay', 'paytrigger')
			then 'Smartphone'
		else 'Solar product'
	end as producttype ,
	rpcl.current_daily_rate as currentdailyrate ,
	rpcl.current_client_status as accountstatus ,
	rpcl.consecutive_days_expired as consecutivedayslate ,
	rpcl.total_paid_to_date as totalpaidtodate ,
	rpcl.outstanding_balance as outstandingbalance ,
	rpcl.total_paid_to_date ,
    last_day(customer_active_end_date::DATE) as activity_month,
	repo_technician
from
	kenya.rp_portfolio_customer_lookup rpcl
left join kenya.customer_personal_details cpd on
	rpcl.account_id = cpd.account_id
left join lastphone_ lp on
	rpcl.unique_customer_id = lp.payg_account_id
where
	customer_active_end_date is not null
	and repo_technician in ('Vincent Koech', 'Anthony Mabonga')
	and last_day(customer_active_end_date::DATE) >= '2023-12-31'
limit 5