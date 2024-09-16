with pulse_users as 
(
	select 
		ru.id,
		ru.login
	from src_odoo13_kenya.res_users ru 
),
products as
(
	select 
		pp.id ,
		pt.default_code ,
		pt."name"
	from src_odoo13_kenya.product_product pp 
	left join src_odoo13_kenya.product_template pt on
		pt.id = pp.product_tmpl_id 
),
stock_locations as 
(
	select 
		sl.id ,
		sl.complete_name
	from src_odoo13_kenya.stock_location sl 
)
select 
	sl.complete_name,
	sl3.complete_name ,
	sl2.complete_name ,
	bidl."condition",
	bid.status ,
	bid.status_date::DATE ,
	bid.cancellation_reason ,
	bid.failure_response ,
	ru.login ,
	pp.default_code ,
	pp."name" ,
	bidl.quantity ,
	bidl.quantity_received 
from src_odoo13_kenya.bboxx_internal_delivery bid 
left join src_odoo13_kenya.bboxx_internal_delivery_lines bidl on
	bidl.internal_delivery_id = bid.id 
left join stock_locations sl on
	sl.id = bid.origin_location_id
left join stock_locations sl2 on
	sl2.id = bid.transport_location_id 
left join stock_locations sl3 on
	sl3.id = bid.destination_location_id 
left join pulse_users ru on
	ru.id = bid.create_uid 
left join products pp on
	pp.id = bidl.product_id 
limit 5