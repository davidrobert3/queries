------------------------------------------
-- get customers' days active and days normal for the past 6 months
with customer_active_and_normal as
(
	select 
		distinct dcs.payg_account_id ,
		sum(case 
			when dcs.payment_status ilike 'normal'
			then 1
			else 0
		end) as days_normal,
		sum(case
			when dcs.customer_status ilike 'active'
			then 1
			else 0
		end) as days_active	
	from kenya.daily_customer_snapshot dcs 
	where dcs.date_timestamp::DATE >= current_date - 179
	group by 1
)
----------------------------------------------
-- calculate the UR of each customer while accounting for those with less than 180 days active and less the grace period
select 
	customer_details.*,
	customer_details.days_normal::float/
	(case 
		when customer_details.days_active < 180
			then datediff(day,c.customer_active_start_date::DATE, current_date) - 7
		else customer_details.days_active
		end
	)::float as ur -- <-- convert the results to a float to get double precision
from customer_active_and_normal as customer_details
left join kenya.customer c on
	c.unique_account_id = customer_details.payg_account_id
where
	customer_details.days_active > 7 -- <-- remove recent installations
	and c.customer_active_end_date isnull -- <-- remove repossessed, finished and voided accounts