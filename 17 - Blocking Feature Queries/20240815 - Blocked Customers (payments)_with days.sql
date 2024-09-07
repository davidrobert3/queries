select 
	cbc.unique_customer_id ,
	cbc."Test or Control Checker" ,
	cr.daily_rate ,
--	cbc.date_called ,
	sum(ccp.sum)/ sum(cr.daily_rate) as days_paid_for
from
	cscc_blocked_customers cbc
left join cscc_collection_payments ccp on
	cbc.unique_customer_id = ccp.payg_account_id
	and ccp.payment_date >= '20240814'
left join collection_rate cr on
	cr.unique_account_id = ccp.payg_account_id
where
	cbc."Test or Control Checker" = 'Test'
	and ccp.payment_date::DATE < '20240822'
group by
	1,
	2,
	3