select 
	si.id as inventory_id,
	si."date" as inventory_update_date,
	sl.complete_name as stock_location_name ,
	sl."name" as stock_location ,
	pt.default_code ,
	pt."name" as product_name,
	case 
		when lower(sl2.complete_name) ~~ '%lost%'
			then sm.product_qty * -1
		else sm.product_qty
	end as stock_adjustment,
	sil.reason ,
	sil.product_qty as current_product_qty,
	sl3.complete_name as source_location ,
	sl2.complete_name as destination_location ,
	si.state ,
	ru.login as created_by
from
	src_odoo13_kenya.stock_inventory si
left join src_odoo13_kenya.stock_inventory_line sil on
	si.id = sil.inventory_id
left join src_odoo13_kenya.product_product pp on
	sil.product_id = pp.id
left join src_odoo13_kenya.product_template pt on
	pt.id = pp.product_tmpl_id
left join src_odoo13_kenya.stock_location sl on
	sl.id = sil.location_id
left join src_odoo13_kenya.res_users ru on
	ru.id = si.write_uid
left join src_odoo13_kenya.stock_move sm on
	sm.inventory_line_id = sil.id
left join src_odoo13_kenya.stock_location sl2 on
	sl2.id = sm.location_dest_id
left join src_odoo13_kenya.stock_location sl3 on
	sl3.id = sm.location_id