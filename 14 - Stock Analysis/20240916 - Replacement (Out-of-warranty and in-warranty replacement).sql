with stock_moves_cte as
(
select 
		sm.product_name ,
		sm.product_qty ,
		sm.state ,
		sm.date_done::DATE ,
		sp."name" ,
		sp.delivery_type ,
		so."name" as name_,
		sl."location" ,
		ru.login as done_by
from
	kenya.stock_moves sm
left join src_odoo13_kenya.stock_picking sp on
		sp.id = sm.stock_picking_id
left join src_odoo13_kenya.sale_order so on
		so.id = sp.sale_id
left join src_odoo13_kenya.stock_location sl on
		sl.id = sp.location_dest_id
left join src_odoo13_kenya.res_users ru on
		ru.id = sp.user_id
where
	sm.delivery_type = 'replacement_in'
--	and sm.date_done::DATE >= '20240701'
order by
	sm.date_done::DATE desc
),
replacement_details as
(
select
	distinct 
		date_done::DATE as date_of_replacement ,
		s.unique_account_id,
		s.billing_method_name ,
		bom2.pakg_product_id ,
		bom2.pakg_name ,
		bom2.component_name ,
		s.contract_length ,
		date_diff('day',
	s.installation_utc_timestamp::DATE,
	date_done::DATE ) as days_to_replacement,
	smc."location" as location,
	smc.done_by
from
	stock_moves_cte smc
left join kenya.sales s on
	smc.name_ = s.unique_account_id
left join kenya.bill_of_material bom2 on
		bom2.pakg_product_id = s.product_id
where
	bom2.component_name = smc.product_name
),
repair_product as
(
	select distinct 
		s.unique_account_id ,
		s.billing_method_name 
	from kenya.sales s
	where lower(s.billing_method_name) like '%repair%'
	and s.current_contract_status in ('active', 'finished')
)
select 
		rd.unique_account_id || ' - ' || rd.date_of_replacement || ' - ' || rd.component_name,
		rd.*,
		case 
			when rd.days_to_replacement > rd.contract_length
				then 'Out_of_warranty_replacement'
		else 'In_warranty_replacement'
	end as warranty_flag ,
	rp.billing_method_name
from
	replacement_details rd
	left join repair_product rp on
		rp.unique_account_id = rd.unique_account_id
--limit 50