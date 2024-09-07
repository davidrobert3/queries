-- customers called by daniel
-- customers called by phoebe
	-- if they paid after the call


with customer_details as
(
	select 
		caller_id ,
		call_time::DATE ,
		destination as phone_called ,
		status as isAnswered,
		talking as call_duration ,
		case
			when cp.unique_customer_id is null
				then cp2.unique_customer_id 
			else cp.unique_customer_id
		end as customerid
	from cscc_3cx_daily_report ccdr
	left join cscc_customer_phone cp on
		cp.phone_1 = destination::float
		and length(destination) <= 12
	left join cscc_customer_phone cp2 on
		cp2.phone_2  = destination::float
		and length(destination) <= 12
	where 
	length(destination) = 12 and 
	ccdr.caller_id ilike '%(137)%'
	or ccdr.caller_id ilike '%(141)%'
)
select customer_details.*,
sum(ccp.sum)
from customer_details
left join cscc_collection_payments ccp on
	ccp.payg_account_id = customer_details.customerid
	and ccp.payment_date::DATE >= customer_details.call_time::DATE
group by 1,2,3,4,5,6

--BXCK30051659