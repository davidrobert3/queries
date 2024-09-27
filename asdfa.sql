select sm.date_done::DATE,
	substring(sol.contract_reference, 0, 13) as unique_account_id,
	sol.contract_reference,
	c.current_customer_status,
	c.customer_active_start_date::DATE as purchase_date,
	c.customer_active_end_date::DATE as repossession_date,
	sol.customerapi_state as customer_final_status,
	sp.delivery_type,
	sm.product_name,
	sm.product_qty,
	spt."name",
	sp.*
from kenya.stock_moves sm
	left join src_odoo13_kenya.stock_picking sp on sp.id = sm.stock_picking_id
	left join src_odoo13_kenya.sale_order_line sol on sol.id = sm.sale_order_line_odoo13_id
	left join src_odoo13_kenya.stock_picking_type spt on spt.id = sp.picking_type_id
	left join kenya.customer c on c.unique_account_id = trim(substring(sol.contract_reference, 0, 13))
where sm.delivery_type in (
		'contract_cancellation_lost',
		'contract_cancellation_returned',
		'repossession_returned',
		'repossession_lost'
	)
	and sm.date_done::DATE >= '20240101' --limit 50