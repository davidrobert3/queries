with prev as 
      	(
select 
	      		distinct dcs.date_timestamp::DATE as snap_date,
	     		dcs.payg_account_id as account ,
	     		dcs.consecutive_late_days
from
	     		kenya.daily_customer_snapshot dcs
where
	      		dcs.date_timestamp::DATE >= current_date::DATE - 1
		),
	today as 
		(
select 
				distinct dcs.date_timestamp::DATE as snap_date,
		     	dcs.payg_account_id as account,
		     	dcs.consecutive_late_days
from 
	     		kenya.daily_customer_snapshot dcs
where 
	     		dcs.date_timestamp::DATE >= current_date::DATE
      )
  select
	  prev.snap_date,
	  prev.account,
	  prev.consecutive_late_days,
	  today.snap_date,
	  today.account,
	  today.consecutive_late_days,
	  case
		when prev.consecutive_late_days > today.consecutive_late_days
	  		then 'Paid'
		else ' '
	end payment_check
from
	prev
full join today on
	today.account = prev.account
where 
	  (today.account notnull
		and prev.consecutive_late_days between 30 and 120
		and prev.consecutive_late_days > today.consecutive_late_days