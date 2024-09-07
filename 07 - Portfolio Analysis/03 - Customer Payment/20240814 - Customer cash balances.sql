select c.unique_account_id,
		rpcl.daily_rate,
		c.current_payment_status,
		current_min_switch_on_late as days_min_to_pay_late,
		current_min_switch_on_default as days_min_to_pay_default,
		case when  c.current_payment_status='late'
				then rpcl.daily_rate*current_min_switch_on_late
			when c.current_payment_status='default'
				then rpcl.daily_rate*current_min_switch_on_default 
			else null end  as cash_min_to_pay,
		c.current_cash_balance,
		case when  c.current_payment_status='late'
				then (rpcl.daily_rate*current_min_switch_on_late)- c.current_cash_balance
			when c.current_payment_status='default'
				then (rpcl.daily_rate*current_min_switch_on_default) - c.current_cash_balance 
			else null end as delta_to_pay
from kenya.customer c 
	join kenya.rp_portfolio_customer_lookup rpcl on c.account_id = rpcl.account_id 
where c.current_payment_status in ('late','default')
--limit 50