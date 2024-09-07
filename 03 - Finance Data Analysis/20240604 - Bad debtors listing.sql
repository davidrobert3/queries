with expected_payments as
(
	select 
		distinct dcs.payg_account_id ,
		round(sum(dcs.daily_rate),0) as expected
	from kenya.daily_customer_snapshot dcs 
	where dcs.date_timestamp::DATE <= '20231231'
	group by 1
),
grace_period as 
(
	select 
		distinct dcs.payg_account_id ,
		round(dcs.daily_rate * 7) as grace_period_amount
	from kenya.daily_customer_snapshot dcs 
	left join kenya.customer c on
		c.account_id = dcs.account_id 
	where dcs.date_timestamp::DATE = c.customer_active_start_date::DATE +1
)
select 
	dcs.payg_account_id ,
	p.expected,
	g.grace_period_amount ,
	sum(dcs.total_paid_to_date) as total_paid
from kenya.daily_customer_snapshot dcs
	left join expected_payments p on
		dcs.payg_account_id = p.payg_account_id
	left join grace_period g on
		dcs.payg_account_id = g.payg_account_id
where dcs.date_timestamp::DATE = '20231231'
group by 1,2,3


