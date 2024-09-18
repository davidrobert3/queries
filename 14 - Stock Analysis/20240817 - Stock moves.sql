select 
	sm.create_date::DATE as move_date ,
	case 
		when ru.login isnull
			then ru2.login 
		else ru.login
	end as user_ ,
	case 
		when sl.type in ('shop', 'region', 'field_staff', 'transport', 'distribution_centre')
			then substring(sl.complete_name,0, position('/' in sl.complete_name))
		else substring(sl2.complete_name, 0, position('/' in sl2.complete_name)) 
	end as shop ,
	sp.delivery_type ,
	sl.complete_name as source_location_name ,
	sl2.complete_name as destination_location_name ,
	sl.sub_type as source_location,
	sl2.sub_type as destination_location,
	spt.sequence_code as move_direction,
	sp.origin as customer_id ,
	pt."name" as product_name,
	sm.product_qty ,
	sm.status , 
	sm.state
from src_odoo13_kenya.stock_move sm 
left join src_odoo13_kenya.stock_location sl on
	sl.id = sm.location_id 
left join src_odoo13_kenya.stock_location sl2 on
	sl2.id = sm.location_dest_id 
left join src_odoo13_kenya.stock_picking sp on
	sp.id = sm.picking_id 
left join src_odoo13_kenya.res_users ru on
	ru.id = sp.user_id 
left join src_odoo13_kenya.product_product pp on
	pp.id = sm.product_id 
left join src_odoo13_kenya.product_template pt on
	pt.id = pp.product_tmpl_id 
left join src_odoo13_kenya.res_users ru2 on
	sm.write_uid = ru2.id 
left join src_odoo13_kenya.stock_picking_type spt on
	sp.picking_type_id = spt.id
where sm.create_date::Date >= '20240729'
limit 200