---This is a query that calculates the cp of customers during replacment.
-- Logic
	-- 1. get details of replacements done including the day the replacement was done.
	-- 2. calculate the cp of the customer during replacement.
	-- 3. with the final CTE both stock moves and CPs are brought together
--######################################################################################################
-- get details of replacements done.
WITH stock_moves_cte as
(SELECT 
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
ORDER BY sm.date_done::DATE DESC 
),
-- sales details for customers to help in calculating the cp
part1 as (
SELECT
	date_done::DATE || ' - ' || c.unique_account_id AS index_,
    c.unique_account_id,
    c.account_id,
    smc.date_done::DATE,
    p.product_name,
    p.category5,
    s.total_paid_to_date,
    s.total_value,
    s.total_due_to_date,
    s.credit_price,
    i.installation_date::date,
    s.downpayment ,
    s.downpayment_credit_amount ,
    case
        when 
                (s.credit_price * ((datediff(days,
        i.installation_date::date,
        current_date))- s.downpayment_credit_amount)) + s.downpayment > s.total_value
                then s.total_value
        else (s.credit_price * ((datediff(days,
        i.installation_date::date,
        current_date))- s.downpayment_credit_amount)) + s.downpayment
    end as recalc_total_due_current
from
    kenya.sales s
join kenya.customer c on
    s.account_id = c.account_id
join kenya.product p on
    s.product_id = p.product_id
JOIN stock_moves_cte smc ON
	smc.name_ = c.unique_account_id
join kenya.installations i on
	i.installation_id = s.installation_id
--    limit 10 
),
-- contract performance for customers
contract_performance as 
(
select 
    distinct p1.index_ ,
    p1.unique_account_id,
    p1.date_done::DATE,
    max(p.payment_utc_timestamp::DATE) AS date_paid,
    sum(p.amount) AS total,
--    sum(p.amount)/sum(p1.recalc_total_due) as performance_band_before_replacement,
    sum(p1.total_paid_to_date)/sum(p1.recalc_total_due_current) as performance_band_after_replacement
from part1 p1
LEFT JOIN kenya.payment p ON
	p1.account_id = p.account_id AND p.payment_utc_timestamp::DATE <= p1.date_done::DATE
group by 1,2,3
)
-- final query to bring everything together.
SELECT 
	cp.index_,
	smc.name_,
	smc.product_name,
	smc.date_done::DATE,
	date_paid,
	total,
	smc.done_by,
	smc."location",
	 SUBSTRING(smc."location", LENGTH(smc."location") - POSITION('/' IN REVERSE(smc."location")) + 2) AS shop,
--	cp.performance_band_before_replacement,
	cp.performance_band_after_replacement,
	sum(p.amount) AS amount_paid
FROM stock_moves_cte smc
LEFT JOIN contract_performance cp ON
	smc.name_ = cp.unique_account_id AND smc.date_done::DATE =cp.date_done::DATE
LEFT JOIN kenya.customer c on
	c.unique_account_id = smc.name_
LEFT JOIN kenya.payment p ON
	p.account_id = c.account_id AND p.payment_utc_timestamp::DATE = smc.date_done::DATE
GROUP BY 1,2,3,4,5,6,7,8,shop,10
--LIMIT 5