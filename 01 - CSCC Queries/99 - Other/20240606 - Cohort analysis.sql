with customer_performance as
(
select 
	date_trunc('month', date_timestamp::DATE)::DATE as month_,
	dcs.payg_account_id ,
	max(dcs.daily_rate) as daily_rate,
	sum(case 
		when dcs.payment_status like 'normal'
			then 1
		else 0
	end) as days_on	,
	sum(case 
		when dcs.customer_status like 'active'
			then 1
		else 0
	end) as days_active	
from kenya.daily_customer_snapshot dcs 
where dcs.date_timestamp::DATE >= '20240101'
and dcs.date_timestamp::DATE <= current_date::DATE
and dcs.payg_account_id IN (SELECT unique_account_id 
FROM kenya.customer c 
WHERE c.customer_active_start_date::DATE >= '20240101')
group by 1,2
),
customer_ur as
(
select *,
daily_rate * days_active as expected_collections,
days_on::float/days_active::float as UR
from customer_performance
)
select 
	ur.*,
	c.customer_active_start_date::DATE
from customer_ur AS ur
LEFT JOIN kenya.customer c 
ON payg_account_id = c.unique_account_id 