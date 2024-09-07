select 
--count(*)
	so.payg_account_id  ,
	c.unique_account_id ,
	sol."name" ,
	sm.product_name ,
	sm.product_qty ,
	sl.hier3_name ,
	c.customer_active_start_date::date,
	sm.date_done::DATE 
from kenya.stock_moves sm 
left join kenya.stock_location sl on
	sm.stock_source_location_id = sl.stock_location_id 
left join src_odoo13_kenya.stock_picking sp  on
	sm.stock_picking_id = sp.id 
left join src_odoo13_kenya.sale_order so on
	sp.sale_id = so.id
right join kenya.customer c on
	so."name" = c.unique_account_id 
left join src_odoo13_kenya.sale_order_line sol on
	so.id = sol.order_id 
where sm.delivery_type in ('pickup','home_delivery')
and c.customer_active_start_date ::DATE >= '20230303'
and sm.state = 'done'
