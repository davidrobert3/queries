--get initial customer sales details with age per contract
with cal_customer_age as
(
	select 
		distinct s.unique_account_id ,
		s.contract_reference ,
		s.billing_method_name ,
		s.installation_utc_timestamp::DATE ,
		s.current_contract_status,
		total_value as contract_value,
		total_paid_to_date as total_paid,
		round(((total_paid_to_date)::float/(credit_price)::float),0) as age
	from kenya.sales s 
	where credit_price notnull and credit_price <> 0 and s.current_contract_status not in ('void','submitted','repo','pending_fulfillment', 'finished')
--		and unique_account_id = 'BXCK76147635'
),
-- get esf accounts only for later labeling
esf_checking as	
(
	select
		distinct unique_account_id,
		'ESF Customer' as ESF_Check
	from
		cal_customer_age
	where
		billing_method_name in ('HPA - bPower20 ESF', 'HPA - bPower20 ESF v1', 'HPA - bPower50 (Aeris)', 'HPA - Energy Service Fee V0', 'HPA - ESF TV Sign up', 'HPA - ESF V1', 'HPA - ESF V2', 'HPA - Mdosi ESF', 'HPA - Mdosi TV ESF', 'HPA - Mdosi TV32 ESF', 'HPA - Mwanzo ESF')
),
--get the current customer age by referring to the oldest non-active account and label customers as either esf or non-esf
final_age as
(
	select 
		distinct a.unique_account_id,
		max(age) over (partition by a.unique_account_id) as customer_age,
		case 
			when esf_check !~~ 'ESF Customer'
				then 'Non-ESF'
			else 'ESF_Customer'
		end as esf_check
	from cal_customer_age a
	left join esf_checking e on
		e.unique_account_id = a.unique_account_id
),
-- get consolidated customer details
customer_details as 
(
	select 
		dcs.payg_account_id ,
		dcs.account_id ,
		c.customer_active_start_date::DATE,
		dcs.daily_rate ,
		dcs.total_paid_to_date ,
		dcs.total_left_to_pay ,
		customer_age,
		esf_check
	from kenya.daily_customer_snapshot dcs 
	left join kenya.customer c on 
		c.account_id = dcs.account_id 
	left join final_age f on
		dcs.payg_account_id = f.unique_account_id
	where dcs.date_timestamp::DATE = current_date::DATE
--	and dcs.payg_account_id = 'BXCK30025149'
),
-- calculate the past six month UR using days normal and days active
days_on_active as
(
	select 
		distinct payg_account_id ,
		sum(case 
			when dcs.payment_status ~~ 'normal'
				then 1
			else 0
		end) as days_normal,	
		sum(case 
			when dcs.customer_status ~~ 'active'
				then 1
			else 0
		end) days_active	
	from kenya.daily_customer_snapshot dcs 
	where dcs.date_timestamp::date > current_date - 180
	and dcs.date_timestamp::DATE <= current_date
--	and dcs.payg_account_id = 'BXCK30025149'
	group by 1
),
-- calculate customer UR to be used for ur segmentation
customer_ur as
(
	select d.payg_account_id,
	d.days_normal::float/d.days_active::float as ur
	from days_on_active d
)
-- main query to segment customers into ur bands and age segments.
select 
	d.payg_account_id,
	c.customer_active_start_date,
	c.daily_rate,
	c.total_paid_to_date ,
	c.total_left_to_pay,
	c.customer_age,
	d.days_normal,
	d.days_active ,
	u.ur ,
	esf_check,
	case 
		when ur < 0.6
			then '4. Bronze'
		when ur >= 0.6  and ur < 0.7
			then '3. Silver'
		when ur >=0.7 and ur < 0.9
			then '2. Gold'
		when ur >= 0.9
			then '1. Platinum'
		else '5. Edge case'
	end as ur_bands,
	case
		when customer_age < 90
			then '1. New'
		when customer_age >= 90 and customer_age < 365
			then '2. 3 months to 1 Year'
		when customer_age >= 365 and customer_age < 730
			then '3. 1 Year to 2 Years'
		when customer_age >= 730 and customer_age < 1095
			then '4. 2 Years to 3 Years'
		when customer_age > 1095 and daily_rate between 13 and 21
			then '5. ESF'
		else '6. Contract Ending'
	end as age_segment	
from customer_details c
left join days_on_active d on
	c.payg_account_id = d.payg_account_id
left join customer_ur u on
	u.payg_account_id = c.payg_account_id
--where customer_age > 1095 and daily_rate > 21