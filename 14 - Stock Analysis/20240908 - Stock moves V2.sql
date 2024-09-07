with 
-- First CTE: Stock Move, filtering as needed
stock_move_cte as (
    select 
        sm.id as stock_move_id,
        sm.create_date as stock_move_date,
        sm.product_id,
        sm.product_qty,
        sm.location_id,
        sm.location_dest_id,
        sm.create_uid,
        sm.picking_id,
        sm."name"
    from 
        src_odoo13_kenya.stock_move sm
    where
        sm."name" !~ 'INV:Inventory'
),
-- Second CTE: Product filtered by Stock Move
product_cte as (
    select 
        pp.id as product_id,
        pt.default_code,
        pt."name" as product_name
    from 
        src_odoo13_kenya.product_product pp
    left join 
        src_odoo13_kenya.product_template pt on pp.product_tmpl_id = pt.id
    where 
        pp.id in (select product_id from stock_move_cte)
),
-- Third CTE: Location filtered by Stock Move
location_cte as (
    select 
        sl.id as location_id,
        sl.complete_name as source_stock_location,
        sl.type as move_type
    from 
        src_odoo13_kenya.stock_location sl
    where 
        sl.id in (select location_id from stock_move_cte)
),
-- Fourth CTE: Location Destination filtered by Stock Move
location_dest_cte as (
    select 
        sl2.id as location_dest_id,
        sl2."name",
        sl2.complete_name as destination_stock_location
    from 
        src_odoo13_kenya.stock_location sl2
    where 
        sl2.id in (select location_dest_id from stock_move_cte)
),
-- Fifth CTE: Picking filtered by Stock Move
picking_cte as (
    select 
        sp.id as picking_id,
        sp.delivery_type,
        sp.picking_type_id,
        sp.sale_id,
        sp.user_id
    from 
        src_odoo13_kenya.stock_picking sp
    where 
        sp.id in (select picking_id from stock_move_cte)
),
-- Sixth CTE: Picking Type filtered by Picking
picking_type_cte as (
    select 
        spt.id as picking_type_id,
        spt.sequence_code,
        spt."name" as move_direction_name
    from 
        src_odoo13_kenya.stock_picking_type spt
    where 
        spt.id in (select picking_type_id from picking_cte)
),
-- Seventh CTE: Sale Order filtered by Picking
sale_order_cte as (
    select 
        so.id as sale_id,
        so.payg_account_id
    from 
        src_odoo13_kenya.sale_order so
    where 
        so.id in (select sale_id from picking_cte)
),
-- Eighth CTE: Users filtered by Stock Move and Picking
users_cte as (
    select 
        ru.id as user_id,
        ru.login
    from 
        src_odoo13_kenya.res_users ru
    where 
        ru.id in (select create_uid from stock_move_cte)
        or ru.id in (select user_id from picking_cte)
)
-- Final Select Query
select 
    sp.picking_id,
    sm.stock_move_id,
    sm.stock_move_date,
    pt.default_code,
    pt.product_name,
    case 
        when loc_dest.name like 'Lost' then 0 
        when spt.sequence_code like 'IN%' then sm.product_qty 
        else sm.product_qty * -1
    end as product_qty,
    loc.move_type,
    sp.delivery_type,
    so.payg_account_id,
    substring(
        case 
            when spt.sequence_code like 'IN%' then loc_dest.destination_stock_location
            else loc.source_stock_location
        end, 0, position('/' in 
        case 
            when spt.sequence_code like 'IN%' then loc_dest.destination_stock_location
            else loc.source_stock_location
        end)
    ) as parent_location,
    loc.source_stock_location,
    loc_dest.destination_stock_location,
    spt.sequence_code as move_direction,
    ru2.login as user_responsible,
    spt.move_direction_name,
    ru.login as created_by
from 
    stock_move_cte sm
left join 
    users_cte ru on sm.create_uid = ru.user_id
left join 
    product_cte pt on sm.product_id = pt.product_id
left join 
    location_cte loc on sm.location_id = loc.location_id
left join 
    location_dest_cte loc_dest on sm.location_dest_id = loc_dest.location_dest_id
left join 
    picking_cte sp on sm.picking_id = sp.picking_id
left join 
    picking_type_cte spt on sp.picking_type_id = spt.picking_type_id
left join 
    sale_order_cte so on sp.sale_id = so.sale_id
left join 
    users_cte ru2 on sp.user_id = ru2.user_id
--where 
--    sp.picking_id = 566441
--loc_dest.location_dest_id = 168
--limit 50;