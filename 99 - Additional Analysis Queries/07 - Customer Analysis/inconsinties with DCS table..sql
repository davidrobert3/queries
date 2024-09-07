with customers as
(SELECT 
    --* 
dcs.date_timestamp::DATE,
    payg_account_id,
    payment_status,
    customer_status,
    enable_status,
    consecutive_late_days  
FROM kenya.daily_customer_snapshot dcs 
WHERE 
    dcs.date_timestamp::DATE >= '2024-05-01'
    AND dcs.payment_status = 'default'
    AND consecutive_late_days < 60
)
select 
	distinct date_timestamp,
	count(*)
from customers
group by 1
order by date_timestamp desc 