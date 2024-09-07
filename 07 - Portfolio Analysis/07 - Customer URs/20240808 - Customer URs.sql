select 
	distinct payg_account_id ,
	date_trunc('month', date_timestamp::DATE)::DATE as month_,
	o.shop_name,
	sum(case 
		when payment_status like 'normal'
			then 1
		else 0
	end) as days_nomal ,
	sum(case 
		when customer_status like 'active'
			then 1
		else 0
	end) as days_active
from kenya.daily_customer_snapshot dcs 
left join kenya.organisation o on 
	dcs.organisation_id = o.organisation_id 
where dcs.date_timestamp::DATE >= '20240101'
group by 1,2,3