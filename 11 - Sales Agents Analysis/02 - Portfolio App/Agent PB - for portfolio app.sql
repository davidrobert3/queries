-- changed the table to payments table to kenya.payment
--      The original query had 100865
--      The new query has 113436 which is a 8.8% increase in records.
--      Contributing to a 4% increase in reported collected cash as of 15/02/2024
-- Changed the last_7_day_CR CTE query table from src_odoo13_kenya.account_payment to kenya.payment
--      Rectified the over-reported PB percentage figures.
--      Case:
--          BXCK72601546 had a reported 7 days collection rate of 85% in the old query.
--          after the changes, the percentage dropped to 35% consitent.
-- Added a condition to remove opted out customers
-- Test an assumption that the app only returns one entry per customer regardless of whether they have more than one account
WITH downpayments AS (
    SELECT
        customer_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM
        kenya.rp_retail_sales
    WHERE
        downpayment_date :: date >= CURRENT_DATE - INTERVAL '6 MONTH'
    GROUP BY
        1,
        2
),
payments AS (
    SELECT
        payments.sales_order_id AS payg_account_id,
        SUM(amount) - COALESCE(downpayments.total_downpayment, 0) AS repayments,
        downpayments.total_downpayment
    FROM
        kenya.payment AS payments
        LEFT JOIN downpayments AS downpayments ON downpayments.unique_account_id = payments.sales_order_id
        LEFT JOIN kenya.customer AS customer ON customer.unique_account_id = payments.sales_order_id
    WHERE
        payments.is_void IS FALSE
        AND payments.third_party_payment_ref_id NOT LIKE '%BONUS%'
        AND payments.payment_utc_timestamp :: date >= CURRENT_DATE - INTERVAL '6 MONTH'
    GROUP BY
        payments.sales_order_id,
        downpayments.total_downpayment
    ORDER BY
        payments.sales_order_id
),
sales_details AS (
    SELECT
        DISTINCT sales.unique_account_id,
        sales.sales_person,
        agent.username,
        agent.sales_agent_name,
        agent.sales_agent_mobile
    FROM
        kenya.rp_retail_sales AS sales
        LEFT JOIN kenya.sales_agent AS agent ON agent.sales_agent_id = sales.sign_up_sales_agent_id
    WHERE
        sales.sale_type = 'install'
        AND sales.sales_order_id = sales.unique_account_id
),
active AS (
    SELECT
        today.date_timestamp :: date AS activity_date,
        today.customer_id,
        initcap(details.customer_name) as customer_name,
        details.customer_phone_1,
        details.customer_phone_2,
        details.home_address_4 AS locations,
        details.home_address_3 AS constituency,
        cpd.location_customer_met_latitude,
        cpd.location_customer_met_longitude,
        customer.location_customer_met_accuracy,
        customer.unique_account_id,
        today.consecutive_late_days,
        today.daily_rate,
        sales_details.sales_agent_name,
        sales_details.sales_person,
        sales_details.sales_agent_mobile,
        customer.customer_active_end_date,
        customer.customer_active_start_date :: text :: date AS installation_date,
        LEAST(
            (
                (
                    CURRENT_DATE - (customer.customer_active_start_date :: DATE + 7)
                ) :: BIGINT
            ),
            180
        ) AS days_expected
    FROM
        kenya.agg_dcs_today AS today
        LEFT JOIN kenya.customer AS customer ON customer.account_id = today.account_id
        left join kenya.customer_personal_details as cpd on cpd.account_id = today.account_id
        LEFT JOIN sales_details AS sales_details ON sales_details.unique_account_id = customer.unique_account_id
        LEFT JOIN kenya.customer_personal_details AS details ON details.account_id = customer.account_id
    WHERE
        customer.customer_final_status IS null
        and UPPER(details.customer_name) not like '%OPT%OUT%' --        and today.date_timestamp::DATE = current_date::DATE
),
collection_rate AS (
    SELECT
        active.activity_date,
        active.customer_id,
        case
            when count(*) over (partition by active.customer_name) > 1 then active.customer_name || ' (' || row_number () over (partition by active.customer_name) || ')'
            else active.customer_name
        end as client_name,
        active.unique_account_id,
        active.customer_phone_1,
        active.customer_phone_2,
        active.locations,
        active.location_customer_met_latitude,
        active.location_customer_met_longitude,
        active.location_customer_met_accuracy,
        active.daily_rate,
        active.customer_active_end_date,
        active.sales_person,
        active.sales_agent_mobile,
        active.sales_agent_name,
        look.shop,
        look.region,
        active.installation_date,
        active.consecutive_late_days,
        active.days_expected,
        COALESCE(repayments.repayments, 0) AS six_month_repayments,
        repayments.repayments / NULLIF((active.days_expected * active.daily_rate), 0) AS six_month_collection_rate,
        ROW_NUMBER() OVER (PARTITION BY active.unique_account_id) AS row_numbers
    FROM
        active AS active
        LEFT JOIN payments AS repayments ON repayments.payg_account_id = active.unique_account_id
        LEFT JOIN kenya.rp_portfolio_customer_lookup AS look ON look.customer_id = active.customer_id
),
last_30_downpayments AS (
    SELECT
        customer_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM
        kenya.rp_retail_sales
    WHERE
        downpayment_date :: date BETWEEN CURRENT_DATE - 7
        AND CURRENT_DATE - 1
    GROUP BY
        1,
        2
),
last_7_day_CR AS (
    SELECT
        payments.sales_order_id AS payg_account_id,
        SUM(amount) - (
            COALESCE(last_30_downpayments.total_downpayment, 0)
        ) AS payments
    FROM
        kenya.payment AS payments
        LEFT JOIN last_30_downpayments AS last_30_downpayments ON last_30_downpayments.unique_account_id = payments.sales_order_id
    WHERE
        payments.is_void IS FALSE
        AND payments.third_party_payment_ref_id NOT LIKE '%BONUS%'
        AND payments.payment_utc_timestamp :: DATE BETWEEN CURRENT_DATE - 7
        AND CURRENT_DATE - 1
    GROUP BY
        payments.sales_order_id,
        last_30_downpayments.total_downpayment
),
dataset AS (
    SELECT
        collection_rate.activity_date AS last_refresh_date,
        collection_rate.region,
        collection_rate.shop,
        collection_rate.unique_account_id,
        collection_rate.client_name as customer_name,
        collection_rate.customer_phone_1,
        collection_rate.customer_phone_2,
        collection_rate.locations AS ward,
        collection_rate.location_customer_met_latitude,
        collection_rate.location_customer_met_longitude,
        CASE
            WHEN collection_rate.daily_rate IN (15, 14.46) THEN 1
            ELSE 0
        END AS ESF_only_status,
        collection_rate.sales_agent_name,
        UPPER(SUBSTRING(collection_rate.sales_person, 0, 7)) AS Agent_id,
        0 AS agent_status,
        COALESCE(last_7_day_CR.payments, 0) / NULLIF((collection_rate.daily_rate * 7), 0) AS last_7_day_CR,
        0 AS technician_name,
        collection_rate.daily_rate,
        collection_rate.consecutive_late_days,
        collection_rate.sales_agent_mobile :: TEXT AS sales_agent_mobile,
        COALESCE(collection_rate.six_month_collection_rate, 0) AS six_month_collection_rate,
        collection_rate.installation_date,
        last_7_day_CR.payments AS cash_collected,
        collection_rate.days_expected,
        CASE
            WHEN collection_rate.installation_date + 8 > collection_rate.activity_date THEN 'New Customer'
            ELSE 'Older Customer'
        END AS customer_age_tag
    FROM
        collection_rate AS collection_rate
        LEFT JOIN last_7_day_CR AS last_7_day_CR ON last_7_day_CR.payg_account_id = collection_rate.unique_account_id
    WHERE
        collection_rate.row_numbers = 1
)
SELECT
    *,
    7 * daily_rate AS total_expected_cash,
    CASE
        WHEN dataset.consecutive_late_days >= 0
        AND dataset.consecutive_late_days < 30 THEN 1
        ELSE 0
    END AS PAR_0_29,
    CASE
        WHEN dataset.consecutive_late_days >= 30
        AND dataset.consecutive_late_days < 59 THEN 1
        ELSE 0
    END AS PAR_30_59,
    CASE
        WHEN dataset.consecutive_late_days >= 60
        AND dataset.consecutive_late_days < 120 THEN 1
        ELSE 0
    END AS PAR_60_119,
    CASE
        WHEN dataset.consecutive_late_days > 120 THEN 1
        ELSE 0
    END AS PAR_120,
    CASE
        WHEN dataset.consecutive_late_days >= 0
        AND dataset.consecutive_late_days < 30
        AND (
            dataset.six_month_collection_rate >= 0.66667
            OR (
                dataset.six_month_collection_rate < 0.66667
                AND dataset.last_7_day_CR >= 0.6667
            )
        )
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Good Payer'
        WHEN (
            dataset.six_month_collection_rate < 0.66667
            AND dataset.consecutive_late_days < 30
            AND dataset.last_7_day_CR < 0.6667
            AND dataset.customer_age_tag = 'Older Customer'
        )
        OR (
            dataset.six_month_collection_rate < 0.66667
            AND dataset.consecutive_late_days < 30
            AND dataset.customer_age_tag = 'Older Customer'
            AND dataset.last_7_day_CR IS NULL
        ) THEN 'Slow Payer_Locked Rewards'
        WHEN dataset.consecutive_late_days >= 30
        AND dataset.consecutive_late_days < 60
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Late_30-59'
        WHEN dataset.consecutive_late_days >= 60
        AND dataset.consecutive_late_days < 120
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Defaulted_60-119'
        WHEN dataset.consecutive_late_days >= 120
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Legacy Customer'
        WHEN dataset.customer_age_tag = 'New Customer' THEN 'New Customers'
        ELSE 'Unaccounted for bucket'
    END AS CustomerSegment,
    CASE
        WHEN dataset.consecutive_late_days BETWEEN 0
        AND 119
        AND dataset.customer_age_tag = 'Older Customer' THEN 1
        ELSE 0
    END AS eligible
FROM
    dataset AS dataset 
    where installation_date::DATE is not null 
    --    dataset.unique_account_id = 'BXCK72601546'
    --------------------------------------------------------------------
    --  END
    --------------------------------------------------------------------