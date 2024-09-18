with stock_moves_cte as 
(
SELECT 
		sm.product_name ,
		sm.product_qty ,
		sm.state ,
		sm.date_done::DATE ,
		sp."name" ,
		sp.delivery_type ,
		so."name" AS name_,
		sl."location" ,
		ru.login AS done_by
	FROM kenya.stock_moves sm 
	LEFT JOIN src_odoo13_kenya.stock_picking sp ON
		sp.id = sm.stock_picking_id 
	LEFT JOIN src_odoo13_kenya.sale_order so  ON
		so.id = sp.sale_id 
	LEFT JOIN src_odoo13_kenya.stock_location sl ON
		sl.id = sp.location_dest_id 
	LEFT JOIN src_odoo13_kenya.res_users ru ON
		ru.id = sp.user_id
	where sm.delivery_type = 'replacement_in'
	AND sm.date_done::DATE >= '20240701'
	and so.name = 'BXCK20523444'
	ORDER BY sm.date_done::DATE desc
),
replacement_date as 
(
	select 
		c.account_id,
		name_,
		date_done
	from stock_moves_cte smc
	left join kenya.customer c on
		c.unique_account_id = smc.name_
)
--,
--payments as 
--(
select 
	distinct rd.date_done,
	rd.name_,
	sum(p.amount)
from replacement_date rd
left join kenya.payment p on 
	p.account_id = rd.account_id
--left join replacement_date rd on
--	c.unique_account_id = rd.name_
where 
	p.is_void = false 
	and p.is_refunded = false
	and p.processing_status = 'posted'
	and p.reconciliation_status = 'matched'
	and rd.name_ = 'BXCK20523444'
group by 1,2