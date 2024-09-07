-- get all payment done by the customer during 6 months after the snapshot date
with payments as
(	
	select 
		p.customer_id ,
		sum(p.amount) as total_payments
	from kenya.payment p 
	where 
		p.is_void is false 
		and p.third_party_payment_ref_id not like 'BONUS%'
		and p.payment_utc_timestamp::date >= '20230401'
		and p.payment_utc_timestamp::date <= '20230901'
		and p.is_bonus is false 
		and p.is_refunded is false 
		and p.processing_status ilike 'posted'
		and p.reconciliation_status ilike 'matched'
	group by 1
),
-- get the amount the customers is expected to have paid up until the snapshot date
expected_payments as
(
	select 
		distinct dcs.payg_account_id ,
		round(sum(dcs.daily_rate),0) as expected
	from kenya.daily_customer_snapshot dcs 
	where dcs.date_timestamp::DATE <= '20230331'
	group by 1
),
-- get the amount the customers would have paid during the 7 days grace period
grace_period as 
(
	select 
		distinct dcs.payg_account_id ,
		round(dcs.daily_rate * 7) as grace_period_amount -- takes the daily rate during first installation multiplied by 7
	from kenya.daily_customer_snapshot dcs 
	left join kenya.customer c on
		c.account_id = dcs.account_id 
	where dcs.date_timestamp::DATE = c.customer_active_start_date::DATE + 1 -- gets the snapshot date when the customer was installed (add 1 coz snapshots are a later)
)
-- Main query that brings everything together and assigns PARs
select 
	dcs.date_timestamp::DATE as "Activity Month",
	count(distinct dcs.customer_id) as "Portfolio Size" ,
	case 
		when dcs.consecutive_late_days <= 0
			then '0. PAR_0 (Not PAR)'
		when dcs.consecutive_late_days >= 1
			and dcs.consecutive_late_days <= 30
			then '1. PAR 1 to 30 days'
		when dcs.consecutive_late_days >= 31
			and dcs.consecutive_late_days <= 60
			then '2. PAR 31 to 60 days'
		when dcs.consecutive_late_days >= 61
			and dcs.consecutive_late_days <= 90
			then '3. PAR 61 to 90 days'
		when dcs.consecutive_late_days >= 91
			and dcs.consecutive_late_days <= 120
			then '4. PAR 91 to 120 days'
		else '5. PAR >120 days'
	end as "PAR Category",
	round(sum(ep.expected - g.grace_period_amount),0) as "Total Period Invoices (KES) - Caculated",
	round(sum(dcs.total_due_to_date),0) as "Total Period Invoices (KES)",
	round(sum(dcs.total_paid_to_date*-1),0) as "Total Paid To-Date (KES)",
	round(sum((ep.expected - g.grace_period_amount) - dcs.total_paid_to_date),0) as "Total Period Balance (KES) - Calculated" ,
	round(sum(dcs.total_due_to_date - dcs.total_paid_to_date),0) as "Total Period Balance (KES)" ,
	round(sum(p.total_payments),0) as repayments
from kenya.daily_customer_snapshot dcs 
left join payments p on
	dcs.customer_id = p.customer_id
left join expected_payments ep on
	dcs.payg_account_id = ep.payg_account_id
left join grace_period g on
	dcs.payg_account_id = g.payg_account_id
where dcs.date_timestamp::DATE = '20230331'
group by 
"Activity Month",
"PAR Category"
order by "PAR Category" asc 