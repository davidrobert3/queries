WITH active_customers AS (
    SELECT 
        DISTINCT 
        so.payg_account_id,
--        trim(case
--		when sol."name" in ('[RE0901] 24" TV Remote Control (CMAC)','[KP3165] Upfront Multiple USB Charger Repair OCT22', '[KP3129] Solar panel 50W upgrade', '[KP3167] 24" TV Screen Repair OCT22out of warraty', '[RE0901] 24'' TV Remote Control (CMAC)', '[KP3169] Other 24" TV Repair OCT22 out of warraty') 
--		then substring(sol."name",10)
--		when lower(sol."name") ilike '%remote%control%'
--		then substring(sol."name",11)
--		else sol."name" end) as name 
		sol."name",
--        length(sol."name"),
		upper(substring(so.sales_person,0,7)) as sales_person,
        sa.sales_agent_name,
        so.create_date::DATE as sale_created_date,
        am.write_date::DATE as downpayment_paid_utc_timestamp,
        sol.customerapi_state,
--        so.delivery_type,
        p.tv_subtype AS tv_subtype,
        sl."name" AS shop_name
--        am.id
    FROM
        src_odoo13_kenya.account_move am
    LEFT JOIN 
        src_odoo13_kenya.account_invoice_report air ON air.move_id = am.id
    LEFT JOIN 
        src_odoo13_kenya.account_move_line aml ON aml.move_id = am.id
    LEFT JOIN 
        src_odoo13_kenya.res_users ru ON am.invoice_user_id = ru.id
    LEFT JOIN 
        src_odoo13_kenya.sale_order_line_invoice_rel solir ON air.id = solir.invoice_line_id
    LEFT JOIN 
        src_odoo13_kenya.sale_order_line sol ON sol.id = solir.order_line_id
    LEFT JOIN 
        src_odoo13_kenya.sale_order so ON so.id = sol.order_id
    LEFT JOIN 
        src_odoo13_kenya.stock_location sl ON so.location_id = sl.id
    LEFT JOIN 
        kenya.sales_agent sa ON sa.username = so.sales_person
    left join 
    	kenya.product p on case
		when sol."name" in ('[KP3165] Upfront Multiple USB Charger Repair OCT22', '[KP3129] Solar panel 50W upgrade', '[KP3167] 24" TV Screen Repair OCT22out of warraty', '[KP3169] Other 24" TV Repair OCT22 out of warraty') 
		then substring(sol."name",10)
		when lower(sol."name") ilike '%remote%control%'
		then substring(sol."name",10)
		else sol."name" end = p.product_name
    WHERE
        am.is_down_payment IS TRUE
        AND am.write_date::DATE >= '20240701'
        AND am.invoice_payment_state = 'paid'
        AND so.customerapi_state IN ('active', 'pending_fulfillment')
        -- AND am.invoice_origin = 'BXCK68285790'
        AND am."name" <> aml."name"
        -- LIMIT 10
),
finished_customers AS (
    SELECT 
        DISTINCT 
        am.invoice_origin as payg_account_id,
--        trim(case
--		when sol."name" in ('[RE0901] 24'' TV Remote Control (CMAC)','[KP3165] Upfront Multiple USB Charger Repair OCT22', '[KP3129] Solar panel 50W upgrade', '[KP3167] 24" TV Screen Repair OCT22out of warraty', '[RE0901] 24'' TV Remote Control (CMAC)', '[KP3169] Other 24" TV Repair OCT22 out of warraty', '[RE0901] 24'' TV Remote Control (CMAC)') 
--		then substring(sol."name",10)
--		when lower(sol."name") ilike '%remote%control%'
--		then substring(sol."name",10)
--		else sol."name" end) as name 
		sol."name",
--        length(sol."name"),
        upper(substring(so.sales_person,0,7)) as sales_person,
        sa.sales_agent_name,
        so.create_date::DATE as sale_created_date,
        am.write_date::DATE as downpayment_paid_utc_timestamp,
        sol.customerapi_state,
--        so.delivery_type,
        p.tv_subtype AS tv_subtype,
        sl."name" AS shop_name
--        am.id
    FROM
        src_odoo13_kenya.account_move am
    LEFT JOIN 
        src_odoo13_kenya.account_invoice_report air ON air.move_id = am.id
    LEFT JOIN 
        src_odoo13_kenya.account_move_line aml ON aml.move_id = am.id
    LEFT JOIN 
        src_odoo13_kenya.res_users ru ON am.invoice_user_id = ru.id
    LEFT JOIN 
        src_odoo13_kenya.sale_order_line_invoice_rel solir ON air.id = solir.invoice_line_id
    LEFT JOIN 
        src_odoo13_kenya.sale_order_line sol ON sol.id = solir.order_line_id
    LEFT JOIN 
        src_odoo13_kenya.sale_order so ON so.id = sol.order_id
    LEFT JOIN 
        src_odoo13_kenya.stock_location sl ON so.location_id = sl.id
    LEFT JOIN 
        kenya.sales_agent sa ON sa.username = so.sales_person
    left join 
    	kenya.product p on case
		when sol."name" in ('[KP3165] Upfront Multiple USB Charger Repair OCT22', '[KP3129] Solar panel 50W upgrade', '[KP3167] 24" TV Screen Repair OCT22out of warraty', '[RE0901] 24'' TV Remote Control (CMAC)', '[KP3169] Other 24" TV Repair OCT22 out of warraty', '[RE0901] 24'' TV Remote Control (CMAC)') 
		then substring(sol."name",10)
		when lower(sol."name") ilike '%remote%control%'
		then substring(sol."name",10)
		else sol."name" end = p.product_name
    WHERE
         am.is_down_payment IS TRUE 
         AND am.write_date >= '20240701'
        AND am.invoice_payment_state = 'paid'
        AND so.customerapi_state IN ('finished')
        -- AND am.invoice_origin = 'BXCK68285790'
        AND am."name" <> aml."name"
        -- LIMIT 10
),
combined_query as
(SELECT
    *
FROM
    active_customers
UNION ALL
SELECT
    *
FROM
    finished_customers
)
select *
from combined_query cq
--where cq.payg_account_id = 'BXCK68296452'