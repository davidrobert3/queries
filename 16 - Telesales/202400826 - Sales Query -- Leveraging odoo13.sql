WITH move_details AS (
    SELECT 
        am.id,
        am.name,
        am.write_date::DATE AS dp_date
    FROM src_odoo13_kenya.account_move am
    WHERE 
        am.write_date::DATE >= '2024-01-01'
        AND am.is_down_payment IS TRUE
        AND invoice_payment_state LIKE 'paid'
),
products_cte AS (
    SELECT 
        pp.id AS product_id,
        pt.name AS product_name,
        CASE 
            WHEN pp.id IN (
                SELECT DISTINCT pc.parent_id
                FROM src_odoo13_kenya.product_components pc
                LEFT JOIN src_odoo13_kenya.product_product pp ON pp.id = pc.product_id
                LEFT JOIN src_odoo13_kenya.product_template pt ON pp.product_tmpl_id = pt.id
                WHERE 
                    UPPER(pt.name) LIKE '%TV%'
                    AND UPPER(pt.name) NOT LIKE '%ZUKU%'
                    AND UPPER(pt.name) NOT LIKE '%ESF%'
                    AND UPPER(pt.name) NOT LIKE '%AERIAL%'
                    AND UPPER(pt.name) NOT LIKE '%REMOTE%'
            )
            THEN 'Has TV'
            ELSE 'No TV'
        END AS tv_sale
    FROM
        src_odoo13_kenya.product_product pp
    LEFT JOIN src_odoo13_kenya.product_template pt ON pp.product_tmpl_id = pt.id
),
users AS (
    SELECT
        ru.id,
        ru.login AS useremail
    FROM
        src_odoo13_kenya.res_users ru
),
sales_details AS (
    SELECT 
        solir.invoice_line_id AS invoice_id,
        so.payg_account_id AS unique_account_id,
        sol.contract_reference,
        sol.create_date::DATE,
        so.date_order::DATE,
        UPPER(SUBSTRING(so.sales_person, 0, 7)) AS sales_agent,
        u.useremail,
        so.sale_type,
        so.state AS isSale,
        sl.complete_name AS shop,
        so.customerapi_state AS status ,
        sol.create_tool as signed_up_on
    FROM
        src_odoo13_kenya.sale_order_line_invoice_rel solir
    LEFT JOIN src_odoo13_kenya.sale_order_line sol ON solir.order_line_id = sol.id
    LEFT JOIN src_odoo13_kenya.sale_order so ON sol.order_id = so.id
    LEFT JOIN users u ON u.id = so.create_uid
    LEFT JOIN src_odoo13_kenya.stock_location sl ON sl.id = so.location_id
)
SELECT
    sd.unique_account_id,
    trim(p.product_name) as product_name,
    sd.sales_agent,
    sd.useremail AS created_by,
    sd.create_date,
    md.dp_date,
    sd.status,
    p.tv_sale,
    sd.shop ,
    sd.signed_up_on
FROM
    src_odoo13_kenya.account_invoice_report air
LEFT JOIN products_cte p ON p.product_id = air.product_id
LEFT JOIN sales_details sd ON sd.invoice_id = air.id
RIGHT JOIN move_details md ON md.name = air.name
WHERE 
    sd.isSale NOT LIKE 'cancel';
