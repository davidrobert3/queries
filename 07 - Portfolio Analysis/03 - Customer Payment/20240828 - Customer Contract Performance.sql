with part1 as (
select  c.unique_account_id ,
		p.product_name,
		s.total_paid_to_date,
		s.total_value,
		s.total_due_to_date,
		s.credit_price,
		s.installation_utc_timestamp::date,
		datediff(day,s.installation_utc_timestamp::date,current_date) as days_active,
		s.downpayment,
		s.downpayment_credit_amount,
			case
			when (s.credit_price * ((datediff(days,s.installation_utc_timestamp::date,current_date))-s.downpayment_credit_amount)) + s.downpayment > s.total_value
				then s.total_value
			else (s.credit_price * ((datediff(days,s.installation_utc_timestamp::date,current_date))-s.downpayment_credit_amount)) + s.downpayment
				end as recalc_total_due --just in case there was any uncertainty around DWH version of total_due_to_date
from kenya.sales s 
	join kenya.customer c on s.account_id = c.account_id 
	join kenya.product p on s.product_id = p.product_id 
)
select 
distinct unique_account_id,
sum(total_paid_to_date)/sum(total_due_to_date) as performance_band
from part1
group by 1