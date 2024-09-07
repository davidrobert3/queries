-----------------------------------------
-- get contract performance. The first CTE was shared by Sean
with contract_perfomance as (
select
		c.unique_account_id,
		c.account_id,
		o.shop_name ,
		p.product_name,
		s.total_paid_to_date,
		s.total_value,
		s.total_due_to_date,
		s.credit_price,
		s.installation_utc_timestamp::date,
		datediff(day,
	s.installation_utc_timestamp::date,
	current_date) as days_active,
		s.downpayment,
		s.downpayment_credit_amount,
			case
			when (s.credit_price * ((datediff(days,
		s.installation_utc_timestamp::date,
		current_date))-s.downpayment_credit_amount)) + s.downpayment > s.total_value
				then s.total_value
		else (s.credit_price * ((datediff(days,
		s.installation_utc_timestamp::date,
		current_date))-s.downpayment_credit_amount)) + s.downpayment
	end as recalc_total_due
from
	kenya.sales s
join kenya.customer c on
	s.account_id = c.account_id
join kenya.product p on
	s.product_id = p.product_id
left join kenya.organisation o on 
		c.organisation_id = o.organisation_id
)
--------------------------------
--Main Query
select 
		contract_perfomance.unique_account_id,
		s.billing_method_name ,
		contract_perfomance.shop_name,
		sum(contract_perfomance.total_paid_to_date)/ sum(contract_perfomance.total_due_to_date) as performance_band
from
	contract_perfomance
left join kenya.rp_portfolio_customer_lookup rpcl on
	contract_perfomance.unique_account_id = rpcl.unique_customer_id
left join kenya.sales s on 
	contract_perfomance.account_id = s.account_id
where
	rpcl.current_system in ('paytrigger', 'nuovopay')
group by
	1,
	2,
	3