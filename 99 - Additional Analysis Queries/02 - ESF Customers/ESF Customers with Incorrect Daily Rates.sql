----------------------------------
-- get active contract per customer
with esf_active_contracts as
		(
			select 
					s.account_id ,
					sum(s.credit_price) as current_daily_rate , 
					count(billing_method_name) as contracts
			from 
				kenya.sales s 
			where 
				s.current_contract_status = 'active'
			group by 1
		)
--------------------------
-- Main query to get descrepancy in the daily rate on the dcs table and what is should be shown on pulse
-- for customer with a daily rate between ksh. 14 and ksh. 15.9. Assumption that these are supposed to
-- ESF only customers
select 
	dcs.payg_account_id ,
	dcs.daily_rate ,
	active.current_daily_rate,
	active.contracts as number_of_active_contracts
from 
	kenya.daily_customer_snapshot dcs 
left join kenya.rp_portfolio_customer_lookup rpcl on
	dcs.payg_account_id = rpcl.unique_customer_id 
left join kenya.customer c on
	dcs.account_id = c.account_id 
left join esf_active_contracts active on
	dcs.account_id = active.account_id
where
	dcs.date_timestamp::DATE = current_date::DATE
	and dcs.daily_rate between 13 and 15.9
--	and active.contracts > 1
--	and active.current_daily_rate <> dcs.daily_rate
