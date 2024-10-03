-- Daily PAR Distribution
SELECT distinct 
--	dcs.date_timestamp::DATE || ' - ' || dcs.payg_account_id as index_,
    date_trunc('month',dcs.date_timestamp::DATE)::DATE as month,
--    rpcl.shop, 
--    dcs.payg_account_id ,
    CASE 
        WHEN dcs.consecutive_late_days = 0
            THEN '1. PAR 0'
        WHEN dcs.consecutive_late_days <= 30
            THEN '2. PAR 1 - 30'
        WHEN dcs.consecutive_late_days <= 60
            THEN '3. PAR 31 - 60'
        WHEN dcs.consecutive_late_days <= 90
            THEN '4. PAR 61 - 90'
        WHEN dcs.consecutive_late_days <= 120
            THEN '5. PAR 91 - 120'
        WHEN dcs.consecutive_late_days > 120
            THEN '6. PAR 120+'
        ELSE '7. Other'
    END AS Par_Buckets,
    COUNT(dcs.account_id) AS customers
FROM kenya.daily_customer_snapshot dcs 
    LEFT JOIN kenya.rp_portfolio_customer_lookup rpcl 
        ON rpcl.unique_customer_id = dcs.payg_account_id 
WHERE 
    dcs.date_timestamp::DATE >= '20240101' and dcs.payment_status <> 'inactive' and dcs.date_timestamp::DATE = date_trunc('month',dcs.date_timestamp::DATE)::DATE
GROUP BY 
    1,2