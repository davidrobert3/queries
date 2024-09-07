SELECT
    p.account_id,
    ROUND(SUM(p.amount), 0) - COALESCE(downpayment.totalDownpayment, 0) AS totalPaid,
    datediff(day, current_date, downpayment.downpayment_date) as days
FROM kenya.payment p
LEFT JOIN (
    SELECT
        rrs.account_id,
        rrs.unique_account_id,
        SUM(rrs.total_downpayment) AS totalDownpayment,
        rrs.downpayment_date AS downpayment_date
    FROM kenya.rp_retail_sales rrs
    WHERE rrs.account_id = '765957ffce4490bb750d5e4a891796b6'
     and (lower(rrs.product_name) like '%zuku%'
     or lower(rrs.product_name) like '%startime%')
    GROUP BY 1, 2, 4
) AS downpayment ON p.account_id = downpayment.account_id
LEFT JOIN (
    SELECT
        dcs.account_id,
        dcs.daily_rate
    FROM kenya.daily_customer_snapshot dcs
    WHERE dcs.date_timestamp::DATE = '2024-01-15'
) AS dr ON p.account_id = dr.account_id
WHERE p.account_id = '765957ffce4490bb750d5e4a891796b6'
    AND p.processing_status LIKE 'posted'
    AND p.reconciliation_utc_timestamp::DATE >= current_date - interval '6 months'
GROUP BY 1, downpayment.totalDownpayment, dr.daily_rate, downpayment.downpayment_date;
 
select rrs.account_id,
    rrs.unique_account_id,
    SUM(DISTINCT(rrs.total_downpayment)) AS totalDownpayment,
    rrs.downpayment_date AS downpayment_date,
    dcs.account_id,
    round(((sum(dcs.daily_rate))/(datediff(day, rrs.downpayment_date, current_date))),0) as avgDR
from kenya.daily_customer_snapshot dcs
    left join kenya.rp_retail_sales rrs on dcs.account_id = rrs.account_id
WHERE rrs.account_id = '765957ffce4490bb750d5e4a891796b6'
    and (
        lower(rrs.product_name) like '%zuku%'
        or lower(rrs.product_name) like '%startime%'
    )
    and dcs.date_timestamp::DATE >= rrs.downpayment_date
GROUP BY 1,
    2,
    4,
    5
