--------------------------------------------
-- call logs
with call_details as (
	select 
		"Actual BXCK" as unique_customer_id,
		"Caller ID" as Agent_Name,
		"Corrected Phone Number"::TEXT as Customer_Phone_Number,
		"Call Time" as Call_Date,
		ROW_NUMBER() over (partition by "Actual BXCK" order by "Call Time" desc) as number_of_times_called
	from cscc_collections cc 
	where 
		"Actual BXCK" <> 'None'
	group by 1,2,3,4
	order by 
		"Call Time" desc
),
----------------------------------------
-- calls made per call agent
calls_made as 
(
	select 
		distinct "Caller ID" as agent_name_,
		count(*) as calls_made
	from cscc_collections
	group by 1
),
--------------------------------
-- get the most recent call and the call agent who made the call it
assign_call_agent as (
select 
	unique_customer_id,
	Agent_Name
from call_details
where number_of_times_called = 1
),
--------------------------------------------
-- get all payments within the period
payments as (
	select 
		payg_account_id,
		payment_date::DATE as payment_date,
		sum as Amount_Paid
	from cscc_collection_payments ccp 
),
-----------------------------------
-- combine the call log data and the payment data with the all filters added
combined_data as 
(
	select
		call_details.unique_customer_id ,
		call_details.Agent_Name ,
		call_details.Call_Date ,
		payments.payment_date ,
		payments.Amount_Paid ,
		ROW_NUMBER() over (partition by payments.payg_account_id) as double_entry,
		max(call_details.number_of_times_called) as number_of_calls_made
	from call_details
	left join payments on
		payments.payg_account_id = call_details.unique_customer_id 
		and payments.payment_date >= call_details.call_date
	left join assign_call_agent on
		assign_call_agent.unique_customer_id = call_details.unique_customer_id
	where 
		call_details.agent_name = assign_call_agent.agent_name
	group by 
		1,
		2,
		3,
		4,
		5,
		payments.payg_account_id
),
------------------------------
-- get amount collected by each call agent
total_collections as
(
	select 
		distinct agent_name,
		round(sum(amount_paid)::int,0) as amount_collected
	from 
		combined_data
	group by 1
)
---------------------------------------------------
-- calculate payout for each call agent
select 
	case
		when agent_name in ('Fidelis Wanja (026)', 'Tresy Onchong''a (049)')
			then '1. 16 - 30 days'
		when agent_name in ('Faith Okoth (013)','Emily Mwirigi (052)')
			then '2. 31 - 60 days'
		when agent_name in ('Mercy Gogo (056)','Quenter Akoth (040)')
			then '3. 60 - 119 days'
	end as category,
	total_collections.agent_name,	
	calls_made.calls_made,
	total_collections.amount_collected,
	case
		when agent_name in ('Fidelis Wanja (026)', 'Tresy Onchong''a (049)')
			then (amount_collected::int - 200000) * 0.03
		when agent_name in ('Faith Okoth (013)','Emily Mwirigi (052)')
			then (amount_collected::int - 100000) * 0.05
		when agent_name in ('Mercy Gogo (056)','Quenter Akoth (040)')
			then (amount_collected::int - 50000) * 0.1
	end as payout	
from total_collections
left join calls_made on
	total_collections.agent_name = calls_made.agent_name_