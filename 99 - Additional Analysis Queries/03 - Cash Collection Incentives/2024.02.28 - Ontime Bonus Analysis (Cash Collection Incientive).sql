----------
---get customer details with daily rates and 7 and 30 days payments
with customer_details as
	(
		select 
			dcs.payg_account_id,
			dcs.daily_rate,
			dcs.daily_rate * 7 as seven_days_payment,
			dcs.daily_rate * 30 as thirty_days_payment
		from kenya.daily_customer_snapshot dcs 
		where dcs.date_timestamp::DATE = current_date::DATE	- 1
	),
------
-- gets 7 days payments made
seven_days_payment as
	(
		select 
			p.payg_account_id ,
			p.payment_date::DATE,
			p.amount as paid_for_seven_days
		from src_odoo13_kenya.account_payment p 
		left join customer_details cd on
			p.payg_account_id = cd.payg_account_id
		where p.payment_date::DATE >= '20240201'
		and p.amount = cd.seven_days_payment
	),
--------
-- gets 30 days payments made
thirty_days_payment as 
	(
		select 
			p.payg_account_id ,
			p.payment_date::DATE,
			p.amount as paid_for_thirty_days
		from src_odoo13_kenya.account_payment p 
		left join customer_details cd on
			p.payg_account_id = cd.payg_account_id
		where p.payment_date::DATE >= '20240201'
		and p.amount = cd.thirty_days_payment
	),
new_expiry_day as 
	(
		select 
			dcs.payg_account_id ,
			dcs.date_timestamp::DATE,
			dcs.expiry_timestamp::DATE,
			case 
				when sp.paid_for_seven_days notnull
				then sp.paid_for_seven_days
				else tp.paid_for_thirty_days
			end as amount ,
			case 
				when sp.paid_for_seven_days notnull
				then '7 days'
				else '30 days'
			end as days_paid_for
		from kenya.daily_customer_snapshot dcs 
		left join seven_days_payment sp on
			dcs.payg_account_id = sp.payg_account_id
		left join thirty_days_payment tp on
			dcs.payg_account_id = tp.payg_account_id
		where dcs.date_timestamp::DATE = tp.payment_date::DATE + 1 or dcs.date_timestamp::DATE = sp.payment_date::DATE + 1
	),
prev_expiry_day as 
	(
		select 
			dcs.payg_account_id ,
			dcs.date_timestamp::DATE,
			dcs.expiry_timestamp::DATE
		from kenya.daily_customer_snapshot dcs 
		left join seven_days_payment sp on
			dcs.payg_account_id = sp.payg_account_id
		left join thirty_days_payment tp on
			dcs.payg_account_id = tp.payg_account_id
		where dcs.date_timestamp::DATE = tp.payment_date::DATE or dcs.date_timestamp::DATE = sp.payment_date::DATE
	),
------------
--- catergorizes paymetns as 7 days or 30 days bonuses
catergorized_payments as
	(
		select 
			dcs.payg_account_id ,
			dcs.date_timestamp::DATE,
			case
				when (dcs.date_timestamp::DATE + 1) = new_expiry_day.date_timestamp::DATE and dcs.date_timestamp::DATE = prev_expiry_day.date_timestamp::DATE
				then new_expiry_day.expiry_timestamp::DATE
			end as new_expiry_date,
			case
				when (dcs.date_timestamp::DATE + 1) = new_expiry_day.date_timestamp::DATE and dcs.date_timestamp::DATE = prev_expiry_day.date_timestamp::DATE
				then prev_expiry_day.expiry_timestamp::DATE
			end as prev_expiry_date,
			case 
				when sp.paid_for_seven_days notnull
				then sp.paid_for_seven_days
				else tp.paid_for_thirty_days
			end as amount ,
			case 
				when sp.paid_for_seven_days notnull
				then '7 days'
				else '30 days'
			end as days_paid_for
		from kenya.daily_customer_snapshot dcs 
		left join seven_days_payment sp on
			dcs.payg_account_id = sp.payg_account_id
		left join thirty_days_payment tp on
			dcs.payg_account_id = tp.payg_account_id
		left join prev_expiry_day on 
			dcs.payg_account_id = prev_expiry_day.payg_account_id
		left join new_expiry_day on
			dcs.payg_account_id = new_expiry_day.payg_account_id
		where dcs.date_timestamp::DATE = tp.payment_date::DATE or dcs.date_timestamp::DATE = sp.payment_date::DATE
	),
-----------
-- catergorize bonues
catergorized_bonuses as 
	(
		select 
			date_trunc('day', catergorized_payments.date_timestamp::DATE) as month,
			catergorized_payments.date_timestamp::DATE,
			catergorized_payments.payg_account_id,
			catergorized_payments.amount,
			new_expiry_date,
			prev_expiry_date,
			new_expiry_date - prev_expiry_date as days_awarded,
			sum(case 
				when days_paid_for like '7 days'
				then (new_expiry_date - prev_expiry_date) - 7
				else -1
			end) as seven_days_bonues,
			sum(case 
				when days_paid_for like '30 days'
				then (new_expiry_date - prev_expiry_date) - 30
				else -1
			end) as thirty_days_bonues
		from catergorized_payments
		where prev_expiry_date notnull 
		group by 1,
				catergorized_payments.payg_account_id,
				catergorized_payments.date_timestamp::DATE,
				catergorized_payments.prev_expiry_date,
				catergorized_payments.new_expiry_date,
				catergorized_payments.amount
		order by date_trunc('day', catergorized_payments.date_timestamp::DATE) asc 
	)
-----------
--Main Query
select
	date_trunc('day', catergorized_bonuses.date_timestamp::DATE) as month,
	catergorized_bonuses.date_timestamp - 1 as date_paid,
	catergorized_bonuses.payg_account_id,
	catergorized_bonuses.amount,
	sum(case
		when seven_days_bonues > 0
		then '7 days bonus given'
		when seven_days_bonues = 0
		then '7 days bonus not given'
		else ''
	end) as count_of_seven_days_bonuses,
	sum(case
		when thirty_days_bonues > 0
		then '30 days bonus given'
		when thirty_days_bonues = 1
		then '30 days bonus not given'
		else ''
	end) as count_of_thirty_days_bonuses,
	sum(case
		when thirty_days_bonues = 0 or seven_days_bonues = 0
		then 1
		else 0
	end) as count_of_bonuses
from catergorized_bonuses
group by 1, catergorized_bonuses.date_timestamp, catergorized_bonuses.payg_account_id, catergorized_bonuses.amount
order by date_trunc('day', catergorized_bonuses.date_timestamp::DATE) asc

--
--
--select count(*)
--from kenya.daily_customer_snapshot dcs
--where dcs.date_timestamp::DATE = current_date::DATE