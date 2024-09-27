SELECT 
    date_trunc('month', dcs.date_timestamp::DATE)::DATE - 1 AS month,
    SUM(
        CASE 
            WHEN dcs.consecutive_late_days = 0 THEN 1
            ELSE 0
        END
    ) AS customers_with_credit,
    SUM(
        CASE
            WHEN dcs.consecutive_late_days >= 1 AND dcs.consecutive_late_days <= 59 THEN 1
            ELSE 0
        END
    ) AS late_customers,
    SUM(
        CASE 
            WHEN dcs.consecutive_late_days > 59 THEN 1
            ELSE 0
        END
    ) AS customers_in_default
FROM
    kenya.daily_customer_snapshot dcs
WHERE
    dcs.date_timestamp::DATE = date_trunc('month', dcs.date_timestamp::DATE)::DATE
    AND dcs.date_timestamp::DATE >= '2024-01-01'
GROUP BY
    1
ORDER BY 1 DESC 