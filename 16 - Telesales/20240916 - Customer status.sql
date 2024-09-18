select 
	s.customer_id ,
	s.unique_account_id ,
	s.contract_type ,
	s.package_type ,
	s.current_order_status ,
	s.current_contract_status ,
	s.installation_utc_timestamp::DATE ,
	p.product_name ,
	case 
		when lower(p.product_name) like '%discount%'
			then 'Discounted'
		else null
	end as isdiscounted
from kenya.sales s
left join kenya.product p 
	on p.product_id = s.product_id
--where s.unique_account_id = 'BXCK73271703'