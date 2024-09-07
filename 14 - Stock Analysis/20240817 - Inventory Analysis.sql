select 
	sil.inventory_date::date ,
	sil.inventory_id ,
	ru.login ,
	sl.location,
	sl.sub_type ,
	pp.name ,
	sil.product_qty --,
--	sil.product_id ,
--	sil.product_qty ,
--	sil.*,
--	pp.*,
--	sl.*,
--	ru.*
from src_odoo13_kenya.stock_inventory_line sil 
left join src_odoo13_kenya.product_product pp2 on
	pp2.id = sil.product_id 
left join src_odoo13_kenya.product_template pp on
	pp2.product_tmpl_id = pp.id 
left join src_odoo13_kenya.stock_location sl on
	sl.id = sil.location_id 
left join src_odoo13_kenya.res_users ru on
	ru.id = sil.write_uid 
--left join src_odoo13_kenya.
where sil.inventory_date::DATE >= '20240729'
--and sil.inventory_id = 49410