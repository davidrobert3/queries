------
--extracts customers with SCM control units with active contracts
with customer_details as 
	(
		select 
			ccul.customer_id,
			ccul.account_id,
			c.unique_account_id ,
			ccul.enable_status
		from 
			kenya.control_unit cu 
		right join kenya.customer_control_unit_link ccul on
			ccul.product_imei = cu.product_imei
		left join kenya.customer c on
			c.account_id = ccul.account_id 
		where 
			cu.record_active is true 
			and cu.is_dcm_enabled is false 
			and cu.current_control_unit_state = 'monitored' 
			and ccul.record_active is true
	),
-----
-- CTE for the last customer status change
latest_connection_date as 
	(
			select 
			    csh.payg_account_id,
			    max(csh.status_changed_utc_timestamp),
			    (current_timestamp - max(csh.status_changed_utc_timestamp)) as last_connection
			from kenya.customer_status_history csh 
--			where csh.payg_account_id = 'BXCK16140303'
			group by csh.payg_account_id
	)
	,
-----
-- get individual customers with disabled, enabled and pending enabled dates
ranked_staus as 
	(
		select 
			csh.payg_account_id ,
			customer_details.unique_account_id,
			customer_details.enable_status as current_enable_status,
			csh.enable_status ,
			csh.status_changed_utc_timestamp,
			case 
				when csh.enable_status = 'disabled' 
					then max(csh.status_changed_utc_timestamp)
				else null
			end as max_disabled,
			case 
				when csh.enable_status = 'pending_enabled' 
					then max(csh.status_changed_utc_timestamp)
				else null
			end as max_pending_enabled,
			case 
				when csh.enable_status = 'enabled' 
					then max(csh.status_changed_utc_timestamp)
				else null
			end as max_enabled, 
			latest_connection_date.last_connection
		from 
			kenya.customer_status_history csh 
		right join customer_details on
			customer_details.unique_account_id = csh.payg_account_id
			and customer_details.unique_account_id notnull 
		left join latest_connection_date on
			latest_connection_date.payg_account_id = customer_details.unique_account_id
--		where csh.payg_account_id = 'BXCK16140303'
		group by 
				1,
				csh.status_changed_utc_timestamp,
				csh.enable_status, 
				customer_details.unique_account_id,
				customer_details.enable_status ,
				latest_connection_date.last_connection
		order by csh.status_changed_utc_timestamp desc 
		)
		,
------
-- get max enabled and max pending_enabled dates
max_status_dates as 
	(
		select 
			payg_account_id,
			current_enable_status,
			last_connection ,
--			max(max_disabled) as last_date_disabled,
			max(max_enabled) as last_date_enabled ,
			max(max_pending_enabled) as last_date_pending_enabled
		from 
			ranked_staus
--			where payg_account_id = 'BXCK16140303'
		group by 
			1, 2, 3
			),
---------
-- get previous disabled date if the customer is currently disabled
fitler_for_max_disabled as 
		(
			select 
				max_status_dates.*,
				max(ranked_staus.max_disabled) as last_date_disabled
			from 
				max_status_dates
			left join ranked_staus on 
				max_status_dates.payg_account_id = ranked_staus.payg_account_id
			where 
				ranked_staus.max_disabled < last_date_pending_enabled
			group by 
				max_status_dates.payg_account_id,
				max_status_dates.current_enable_status,
				max_status_dates.last_connection,
				max_status_dates.last_date_enabled,
				max_status_dates.last_date_pending_enabled
		),	
------------
--- calculates time to switch on in seconds
final_CTE as 
	(
		select 
			*,
			date_diff('second', last_date_disabled, last_date_pending_enabled) as time_taken_to_switch_on_in_seconds
		from 
			fitler_for_max_disabled
	)
--------------------
-- Main query
select 
	payg_account_id,
	current_enable_status,
	to_char(last_date_disabled, 'YYYY-MM-DD HH24:MI:SS') as recent_date_disabled,
	to_char(last_date_enabled,'YYYY-MM-DD HH24:MI:SS') as recent_date_enabled,
	time_taken_to_switch_on_in_seconds,
	last_connection ,
	case 
		when time_taken_to_switch_on_in_seconds < 60 
			then '1. Less than a minute'
		when time_taken_to_switch_on_in_seconds between 60 and 299
			then '2. Between 1 and 5 minutes'
		when time_taken_to_switch_on_in_seconds between 300 and 1799
			then '3. Between 5 to 30 minutes'
		when time_taken_to_switch_on_in_seconds between 1800 and 3599
			then '4. Between 30 minutes to 1 hour'
		when time_taken_to_switch_on_in_seconds between 3600 and 17999
			then '5. Between 1 to 5 hours'
		when time_taken_to_switch_on_in_seconds >= 18000
			then '6. More than 5 hours'
	end as enable_catergories	
from final_CTE



with customer as
	(
		select
			unique_account_id
		from 
			kenya.customer c
	),
	customer_details as
	(
		select
			unique_account_id 
		from 
			kenya.customer_personal_details cpd 
	)
select
	count(c.unique_account_id)
from 
	customer c
left join customer_details cd on
	c.unique_account_id = cd.unique_account_id
--where cd.unique_account_id is null
	
	
	
	select c.customer_id ,
	c.unique_account_id ,
	cpd.customer_name 
	from kenya.customer c
	left join kenya.customer_personal_details cpd on
	c.customer_id = cpd.customer_id 
	where c.unique_account_id = 'BXCK02464545'
	
	
	
	
select 
    date_trunc('day', ap.payment_date) as day,
    round(sum(ap.amount),0) as amount
from 
    src_odoo13_kenya.account_payment ap 
where
    ap.payment_date::date >= '2024-02-01' 
    and ap.type <> 'bonus'
group by
    date_trunc('month', ap.payment_date),
    ap.payment_date
order by date_trunc('day', ap.payment_date) asc;



