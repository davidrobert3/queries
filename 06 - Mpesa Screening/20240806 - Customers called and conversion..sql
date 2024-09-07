select ccdr.*, 
case
	when ccp.unique_customer_id isnull
		then string_agg(ccp2.unique_customer_id::text, ',')
	else string_agg(ccp.unique_customer_id::text, ',')
end as customer
from cscc_3cx_daily_report ccdr 
left join cscc_customer_phone ccp on
	ccdr.destination = ccp.phone_1::text 
	and ccp.down_payment_date >= '20240601'
left join cscc_customer_phone ccp2 on
	ccp2.phone_2::text  = ccdr.destination
	and ccp.down_payment_date >= '20240601'
where ccdr.call_time::DATE >= '20240601'
and ccdr.call_time::DATE <= '20240731'
--and length(caller_id) > 12
and caller_id in ('Elizabeth Odera (029)','Flavian Kimata (051)','Harriet Nyamoita (069)','Teresa Omollo (059)')
group by 1,2,3,4,5,6,7,8,9,10,11,ccp.unique_customer_id