select 
	c.unique_account_id ,
	c.customer_active_end_date::date ,
	o.shop_name ,
	t.username 
from kenya.repossession r 
left join kenya.customer c on
r.account_id = c.account_id 
left join kenya.organisation o on 
c.organisation_id = o.organisation_id 
left join kenya.technician t on
r.technician_id = t.technician_id 
where t.username in ('t.mabonga@bboxx.co.uk', 'a.mabonga@bboxx.co.uk', 'v.koech@bboxx.co.uk')
and c.customer_active_end_date::date >= '20240701'
and c.customer_active_end_date <= '20240802'