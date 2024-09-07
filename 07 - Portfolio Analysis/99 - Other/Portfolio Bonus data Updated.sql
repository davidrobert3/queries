-- Selecting data from kenya.agg_dcs_today with a limit of 5
WITH downpayments AS (
    SELECT customer_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM kenya.rp_retail_sales
    WHERE downpayment_date::date >= '20240101' - INTERVAL '6 MONTH'
    GROUP BY 1,
        2
),
payments AS (
    SELECT payments.customer_id,
        SUM(amount) - COALESCE(downpayments.total_downpayment, 0) AS repayments,
        downpayments.total_downpayment
    FROM kenya.payment AS payments
        LEFT JOIN downpayments AS downpayments ON downpayments.customer_id = payments.customer_id
        LEFT JOIN kenya.customer AS customer ON customer.customer_id = payments.customer_id
    WHERE payments.processing_status = 'posted'
        AND payments.reconciliation_utc_timestamp::DATE >= '20240101' - INTERVAL '6 MONTH'
    GROUP BY payments.customer_id,
        downpayments.total_downpayment
),
sales_details AS (
    SELECT DISTINCT 
        sales.unique_account_id,
        sales.sales_person,
        agent.username,
        agent.sales_agent_name,
        agent.sales_agent_mobile
    FROM kenya.rp_retail_sales AS sales
        LEFT JOIN kenya.sales_agent AS agent ON UPPER(agent.sales_agent_bboxx_id) = UPPER(SUBSTRING(sales.sales_person, 0, 7))
    WHERE sales.sale_type = 'install'
        AND sales.sales_order_id = sales.unique_account_id
),
active AS (
    SELECT 
        today.date_timestamp::date AS activity_date,
        today.account_id,
        -- details.customer_name,
        -- details.customer_phone_1,
        -- details.customer_phone_2,
        -- details.customer_home_address AS nearest_landmark,
        -- details.home_address_4 AS locations,
        -- details.home_address_3 AS constituency,
        customer.unique_account_id,
        customer.customer_id,
        today.consecutive_late_days,
        today.expiry_timestamp::date AS expiry_date,
        today.daily_rate,
        -- sales_details.sales_agent_name,
        -- sales_details.sales_person,
        -- sales_details.sales_agent_mobile,
        customer.customer_active_end_date,
        customer.customer_active_start_date::TEXT::date AS installation_date,
        LEAST(
            (
                (
                    '20240101' - (customer.customer_active_start_date::DATE + 7)
                )::BIGINT
            ),
            180
        ) AS days_expected
    FROM kenya.agg_dcs_today AS today
        LEFT JOIN kenya.customer AS customer ON customer.account_id = today.account_id
        LEFT JOIN sales_details AS sales_details ON sales_details.unique_account_id = customer.unique_account_id
        LEFT JOIN kenya.customer_personal_details AS details ON details.account_id = customer.account_id
    WHERE customer.customer_final_status IS NULL
        AND UPPER(details.customer_name) NOT LIKE '%OPTED%'
),
collection_rate AS (
    SELECT active.activity_date,
        active.account_id,
        -- active.customer_name,
        -- active.customer_phone_1,
        -- active.customer_phone_2,
        -- active.nearest_landmark,
        -- active.locations,
        -- active.constituency,
        active.unique_account_id,
        active.daily_rate,
        active.customer_active_end_date,
        -- active.sales_person,
        -- active.sales_agent_mobile,
        -- active.sales_agent_name,
        look.current_hardware_type,
        look.shop,
        look.region,
        active.installation_date,
        active.consecutive_late_days,
        active.days_expected,
        active.expiry_date,
        look.tv_customer,
        COALESCE(repayments.repayments, 0) AS six_month_repayments,
        repayments.repayments / NULLIF((active.days_expected * active.daily_rate), 0) AS six_month_collection_rate,
        ROW_NUMBER() OVER (PARTITION BY active.unique_account_id) AS row_numbers
    FROM active AS active
        LEFT JOIN payments AS repayments ON repayments.customer_id = active.customer_id
        LEFT JOIN kenya.rp_portfolio_customer_lookup AS look ON look.account_id = active.account_id
),
last_30_downpayments AS (
    SELECT customer_id,
        account_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM kenya.rp_retail_sales
    WHERE downpayment_date::date >= '20240101' - INTERVAL '1 MONTH'
    GROUP BY 1,
        2,
        3
),
last_30_day_CR AS (
    SELECT payments.account_id,
        SUM(amount) - COALESCE(last_30_downpayments.total_downpayment, 0) AS payments
    FROM kenya.payment AS payments
        LEFT JOIN last_30_downpayments AS last_30_downpayments ON last_30_downpayments.account_id = payments.account_id
    WHERE payments.processing_status = 'posted'
        AND payments.reconciliation_utc_timestamp::TEXT::DATE BETWEEN '20240101' - 30 AND '20240101'
    GROUP BY payments.account_id,
        last_30_downpayments.total_downpayment
),
dataset AS (
    SELECT 
        -- collection_rate.account_id,
        collection_rate.unique_account_id,
        -- collection_rate.customer_name,
        -- collection_rate.customer_phone_1,
        -- collection_rate.customer_phone_2,
        -- collection_rate.nearest_landmark,
        -- collection_rate.locations,
        -- collection_rate.constituency,
        collection_rate.daily_rate,
        -- collection_rate.current_hardware_type,
        collection_rate.shop,
        collection_rate.region,
        -- collection_rate.sales_agent_name,
        -- collection_rate.sales_person,
        -- collection_rate.sales_agent_mobile::TEXT AS sales_agent_mobile,
        -- UPPER(SUBSTRING(collection_rate.sales_person, 0, 7)) AS Agent_id,
        COALESCE(collection_rate.six_month_collection_rate, 0) AS six_month_collection_rate,
        collection_rate.customer_active_end_date,
        collection_rate.installation_date,
        collection_rate.six_month_repayments,
        last_30_day_CR.payments AS last_30_day_repayments,
        collection_rate.days_expected,
        COALESCE(last_30_day_CR.payments, 0) / NULLIF((collection_rate.daily_rate * 30), 0) AS last_30_day_CR,
        collection_rate.consecutive_late_days,
        collection_rate.expiry_date,
        collection_rate.tv_customer,
        CASE
            WHEN collection_rate.installation_date + 8 > collection_rate.activity_date THEN 'New Customer'
            ELSE 'Older Customer'
        END AS customer_age_tag
    FROM collection_rate AS collection_rate
        LEFT JOIN last_30_day_CR AS last_30_day_CR ON last_30_day_CR.account_id = collection_rate.account_id
),
completedata AS (
    SELECT *,
        CASE
            WHEN dataset.consecutive_late_days >= 0
            AND dataset.consecutive_late_days < 30
            AND (
                dataset.six_month_collection_rate >= 0.66667
                OR (
                    dataset.six_month_collection_rate < 0.66667
                    AND dataset.last_30_day_CR >= 0.6667
                )
            )
            AND dataset.customer_age_tag = 'Older Customer' THEN 'Good Payer'
            WHEN (
                dataset.six_month_collection_rate < 0.66667
                AND dataset.consecutive_late_days < 30
                AND dataset.last_30_day_CR < 0.6667
                AND dataset.customer_age_tag = 'Older Customer'
            )
            OR (
                dataset.six_month_collection_rate < 0.66667
                AND dataset.consecutive_late_days < 30
                AND dataset.customer_age_tag = 'Older Customer'
                AND dataset.last_30_day_CR IS NULL
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
        END AS CustomerSegment
    FROM dataset AS dataset
),
data_with_bonuses AS (
    SELECT *,
        CASE
            WHEN CustomerSegment = 'Good Payer' THEN 1.0 * daily_rate
            ELSE 0
        END AS GoodPayerReward,
        CASE
            WHEN CustomerSegment = 'Slow Payer_Locked Rewards' THEN 1.0 * daily_rate
            ELSE 0
        END AS SlowPayerLockedRewards,
        CASE
            WHEN CustomerSegment = 'Late_30-59' THEN -7 * daily_rate
            ELSE 0
        END AS LatePenalty,
        CASE
            WHEN CustomerSegment = 'Defaulted_60-119' THEN -14 * daily_rate
            ELSE 0
        END AS DefaulterPenalty
    FROM completedata
),
customer_categories AS (
    SELECT *,
        LatePenalty + DefaulterPenalty AS total_penalty,
        GoodPayerReward + LatePenalty + DefaulterPenalty AS actual_bonus,
        CASE
            WHEN GoodPayerReward > 0 THEN 1
            ELSE 0
        END AS GoodPayerStatus,
        CASE
            WHEN SlowPayerLockedRewards > 0 THEN 1
            ELSE 0
        END AS SlowPayerStatus,
        CASE
            WHEN LatePenalty < 0 THEN 1
            ELSE 0
        END AS LateStatus,
        CASE
            WHEN DefaulterPenalty < 0 THEN 1
            ELSE 0
        END AS DefaulterStatus
    FROM data_with_bonuses
),
eligible_status AS (
    SELECT customer_categories.*,
        CASE
            WHEN GoodPayerStatus = 1 THEN 1
            WHEN SlowPayerStatus = 1 THEN 1
            WHEN LateStatus = 1 THEN 1
            WHEN DefaulterStatus = 1 THEN 1
            ELSE 0
        END AS EligibleStatus
    FROM customer_categories
)
SELECT eligible_status.*,
    CASE
        WHEN EligibleStatus = 1 THEN 1.0 * daily_rate
        ELSE 0
    END AS MaxBonusAmount,
    CASE
        WHEN consecutive_late_days > 8
        AND consecutive_late_days < 30 THEN 1
        ELSE 0
    END AS PrePenaltyStatus,
    CASE
        WHEN consecutive_late_days > 8
        AND consecutive_late_days < 30 THEN -7 * daily_rate
        ELSE 0
    END AS PrePenaltyPotentialPenalty
FROM eligible_status 
-- limit 5;