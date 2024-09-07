-- changed the table to payments table to kenya.payment
--      The original query had 100865
--      The new query has 113436 which is a 8.8% increase in records.
--      Contributing to a 4% increase in reported collected cash as of 15/02/2024
-- Changed the last_7_day_CR CTE query table from src_odoo13_kenya.account_payment to kenya.payment
--			Rectified the over-reported PB percentage figures.
--			Case:
-- 					BXCK72601546 had a reported 7 days collection rate of 85% in the old query.
--					after the changes, the percentage dropped to 35% consitent.
-- Added a condition to remove opted out customers
-- Test an assumption that the app only returns one entry per customer regardless of whether they have more than one account

WITH downpayments AS 
(
    SELECT 
        customer_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM 
        kenya.rp_retail_sales 
    WHERE 
        downpayment_date::date >= CURRENT_DATE - INTERVAL '6 MONTH'
    GROUP BY 
        1, 2
),
payments AS 
(
    SELECT 
        payments.sales_order_id AS payg_account_id,
        SUM(amount) - COALESCE(downpayments.total_downpayment, 0) AS repayments, 
        downpayments.total_downpayment 
    FROM 
        kenya.payment AS payments
        LEFT JOIN downpayments AS downpayments 
            ON downpayments.unique_account_id = payments.sales_order_id
        LEFT JOIN kenya.customer AS customer 
            ON customer.unique_account_id = payments.sales_order_id 
    WHERE
        payments.is_void IS FALSE
        AND payments.third_party_payment_ref_id NOT LIKE '%BONUS%'
        AND payments.payment_utc_timestamp::date >= CURRENT_DATE - INTERVAL '6 MONTH'
    GROUP BY 
        payments.sales_order_id,
        downpayments.total_downpayment  
    ORDER BY 
        payments.sales_order_id
),
---------------------------------------------
-- Add agent reassignment/remapping CTE. Add new 
    sales_agents as 
    ( 
        select 
            sa.sales_agent_id ,
            sa.sales_agent_name ,
            upper(substring(sa.username, 0, 7)) as agent_code ,
            sa.sales_agent_mobile
        from kenya.sales_agent sa
     ),
     rp_sales as 
     (
         select 
            sales.unique_account_id ,
            case
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0767','KE1189')
                	then 'KE2986'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0134', 'KE2785')
                    then 'KE1992'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2784', 'KE2353', 'KE0666')
                    then 'KE0168'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0580')
                    then 'KE7249'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1130', 'KE0617', 'KE1187')
                    then 'KE7311'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0057', 'KE0047', 'KE0501')
                    then 'KE4204'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2508')
                    then 'KE7154'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0035')
                    then 'KE7884'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0858', 'KE3719', 'KE1315', 'KE1331')
                    then 'KE7158'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0861')
                    then 'KE7505'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE5400')
                    then 'KE6434'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0344')
                    then 'KE7417'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0297')
                    then 'KE7414'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE4240')
                    then 'KE2552'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE4840')
                    then 'KE7332'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1134', 'KE0830')
                    then 'KE1304'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE7356', 'KE1329', 'KE1240', 'KE0714')
                    then 'KE5314'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE7126')
                    then 'KE7324'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2624')
                    then 'KE7739'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0046')
                    then 'KE7620'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6071')
                    then 'KE7697'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0931')
                    then 'KE4959'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0609')
                    then 'KE7398'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE3382')
                     then 'KE7598'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0611')
                    then 'KE4828'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2806')
                    then 'KE3381'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0932')
                    then 'KE2807'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2806')
                    then 'KE3381'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1750')
                    then 'KE1749'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1216')
                    then 'KE1826'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1828', 'KE2733', 'KE2745')
                    then 'KE1893'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1107')
                    then 'KE1372'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2849', 'KE1753')
                    then 'KE1305'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2187')
                    then 'KE5681'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2284')
                    then 'KE7881'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1230')
                    then 'KE7871'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE3018')
                    then 'KE4021'
              -- Transfers done 25th April, 2024
                when upper(substring(sales.sales_person, 0, 7)) in ('KE3974', 'KE0595', 'KE0648', 'KE1953', 'KE2949', 'KE3513')
                    then 'KE2231'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0139', 'KE0415', 'KE0505', 'KE1167', 'KE2064', 'KE2230', 'KE2954', 'KE0277', 'KE0327', 'KE0438', 'KE0976', 'KE1168', 'KE1959', 'KE2063', 'KE2947', 'KE3011', 'KE3516', 'KE4180', 'KE4312', 'KE0192', 'KE0195', 'KE0198', 'KE0217', 'KE0331', 'KE0340', 'KE0463', 'KE0971', 'KE0978', 'KE1954', 'KE2654', 'KE3012', 'KE3510', 'KE4140')
                    then 'KE2286'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0162', 'KE2647', 'KE0342', 'KE0203', 'KE0366', 'KE0913', 'KE0915', 'KE1845', 'KE1958', 'KE2953', 'KE3508', 'KE3509', 'KE4141')
                    then 'KE0928'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE5647', 'KE7715', 'KE3904', 'KE4145', 'KE7722')
                    then 'KE0582'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE7089', 'KE5774', 'KE6239', 'KE7590')
                    then 'KE7889'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE7756', 'KE2400', 'KE4601', 'KE5775')
                    then 'KE7088'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1866', 'KE4672', 'KE4717', 'KE7413', 'KE0206', 'KE0011', 'KE1297')
                    then 'KE1609'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE4673', 'KE4588', 'KE4207', 'KE3912', 'KE7589', 'KE3819', 'KE0821')
                    then 'KE0077'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0040', 'KE1255')
                    then 'KE0218'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0004', 'KE0675', 'KE0006', 'KE1136')
                    then 'KE4150'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE4919', 'KE0544', 'KE0024', 'KE0662', 'KE0585')
                    then 'KE7925'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0050', 'KE0085', 'KE0089', 'KE1373')
                    then 'KE2101'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0483', 'KE4499', 'KE2280', 'KE7847', 'KE0774', 'KE3663', 'KE0190', 'KE1469', 'KE4029', 'KE4221')
                    then 'KE4936'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0201', 'KE0402', 'KE0088', 'KE1468', 'KE3664', 'KE3824', 'KE4907', 'KE5119', 'KE7813', 'KE7814', 'KE0826', 'KE2279')
                    then 'KE7693'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0003')
                    then 'KE5206'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0587', 'KE0018')
                    then 'KE6229'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6630', 'KE4801', 'KE3229', 'KE3765', 'KE2846', 'KE1539')
                    then 'KE2466'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE3314', 'KE2190', 'KE2564', 'KE2558', 'KE3093', 'KE5056', 'KE1596')
                    then 'KE1544'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE4493', 'KE5057', 'KE5691', 'KE2376')
                    then 'KE1554'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2211')
                    then 'KE2706'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6896', 'KE6902', 'KE5386')
                    then 'KE3461'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6492')
                    then 'KE6343'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6016', 'KE6501')
                    then 'KE6491'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE3173', 'KE5969', 'KE6900', 'KE6348', 'KE3176', 'KE6350', 'KE3174', 'KE6496', 'KE6895', 'KE3149', 'KE3179', 'KE4814', 'KE6032', 'KE6100', 'KE6498', 'KE7728', 'KE7777', 'KE7845')
                    then 'KE7844'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE4822')
                    then 'KE4820'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6898', 'KE7812', 'KE6342')
                    then 'KE7525'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE4819', 'KE6133', 'KE6345', 'KE7453', 'KE3175', 'KE7681')
                    then 'KE6897'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6134')
                    then 'KE6135'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1267', 'KE1240', 'KE4341')
                    then 'KE5319'
                -- transfer on 29th April, 2024
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1292')
                    then 'KE7377'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE3131')
                    then 'KE6840'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1098')
                    then 'KE7924'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1183')
                    then 'KE2979'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0052')
                    then 'KE4498'
                -- trnsfers on 6th May, 2024
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1379','KE2385','KE3071','KE5247')
                    then 'KE4787'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2489','KE1676')
                    then 'KE2386'
				when upper(substring(sales.sales_person, 0, 7)) in ('KE3029','KE6316','KE2731','KE2731')
                    then 'KE1837'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1622','KE2730')
                    then 'KE4059'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1044')
                    then 'KE4556'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2727', 'KE2490','KE3028')
                    then 'KE6319'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE1646','KE1286','KE2178')
                    then 'KE6317'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE3073','KE1835','KE2728')
                    then 'KE7817'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE6916','KE6325','KE6320','KE3871','KE3069','KE2732','KE1841','KE1644','KE4550','KE3868','KE2384','KE1675','KE1643','KE6327','KE2387')
                    then 'KE7792'
                when upper(substring(sales.sales_person, 0, 7)) in ('KE2177','KE6913','KE6318','KE2333','KE3033','KE4785','KE5249','KE6103','KE6912','KE4604')
                    then 'KE7855'
                else upper(substring(sales.sales_person, 0, 7))
            end as agent_code       
         from kenya.rp_retail_sales as sales
         where sales.sale_type = 'install'
        and sales.sales_order_id = sales.unique_account_id   
   --and sales.unique_account_id= 'BXCK00000131'
     ),
sales_details AS 
(
   select
            sales.unique_account_id,
            sales.agent_code as sales_person ,
            agent.agent_code as username,
            agent.sales_agent_name,
            agent.sales_agent_mobile
        from rp_sales as sales
        left join sales_agents as agent on
            sales.agent_code = agent.agent_code
--      where agent.agent_code = 'KE1292'
--     limit 6	
),
active AS 
(
    SELECT 
        today.date_timestamp::date AS activity_date,
        today.customer_id,
        initcap(details.customer_name) as customer_name,
        details.customer_phone_1,
        details.customer_phone_2,
        details.home_address_4 AS locations,
        details.home_address_3 AS constituency,
        customer.location_customer_met_latitude,
        customer.location_customer_met_longitude,
        customer.location_customer_met_accuracy,
        customer.unique_account_id,
        today.consecutive_late_days,
        today.daily_rate,
        sales_details.sales_agent_name,
        sales_details.sales_person,
        sales_details.sales_agent_mobile,
        customer.customer_active_end_date,
        customer.customer_active_start_date::text::date AS installation_date,
        LEAST(((CURRENT_DATE - (customer.customer_active_start_date::DATE + 7))::BIGINT), 180) AS days_expected
    FROM 
        kenya.agg_dcs_today AS today 
        LEFT JOIN kenya.customer AS customer   
            ON customer.account_id = today.account_id
        LEFT JOIN sales_details AS sales_details 
            ON sales_details.unique_account_id = customer.unique_account_id
        LEFT JOIN kenya.customer_personal_details AS details 
            ON details.account_id = customer.account_id
    WHERE 
        customer.customer_final_status IS null
        and UPPER(details.customer_name) not like '%OPT%OUT%'
--        and today.date_timestamp::DATE = current_date::DATE
),
collection_rate AS 
(
    SELECT
        active.activity_date,
        active.customer_id,
        case
        	when count(*) over (partition by active.customer_name)>1
        	then active.customer_name || ' ('||row_number () over (partition by active.customer_name)||')'
        	else active.customer_name
        end as client_name,
  			active.unique_account_id ,
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
        LEFT JOIN payments AS repayments  
            ON repayments.payg_account_id = active.unique_account_id
        LEFT JOIN kenya.rp_portfolio_customer_lookup AS look  
            ON look.customer_id = active.customer_id 
),
last_30_downpayments AS 
(
    SELECT 
        customer_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM 
        kenya.rp_retail_sales 
    WHERE 
        downpayment_date::date BETWEEN CURRENT_DATE - 7  AND CURRENT_DATE - 1
    GROUP BY 
        1, 2
),
last_7_day_CR AS 
(
    SELECT 
        payments.sales_order_id AS payg_account_id,
        SUM(amount) - (COALESCE(last_30_downpayments.total_downpayment, 0)) AS payments
    FROM 
        kenya.payment AS payments 
        LEFT JOIN last_30_downpayments AS last_30_downpayments 
            ON last_30_downpayments.unique_account_id = payments.sales_order_id
    WHERE 	
        payments.is_void IS FALSE
        AND payments.third_party_payment_ref_id NOT LIKE '%BONUS%'
        AND payments.payment_utc_timestamp::DATE BETWEEN CURRENT_DATE - 7  AND CURRENT_DATE - 1
    GROUP BY 
        payments.sales_order_id,
        last_30_downpayments.total_downpayment 
),
dataset AS 
(
    SELECT
        collection_rate.activity_date AS last_refresh_date,
        current_date - 7 ||' to '||  current_date - 1 as period_,
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
        collection_rate.sales_agent_mobile::TEXT AS sales_agent_mobile,
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
        LEFT JOIN last_7_day_CR AS last_7_day_CR  
            ON last_7_day_CR.payg_account_id = collection_rate.unique_account_id 
    WHERE 
        collection_rate.row_numbers = 1
)
SELECT
    *,
    7 * daily_rate AS total_expected_cash,
    CASE 
        WHEN dataset.consecutive_late_days >= 0 AND dataset.consecutive_late_days < 30 THEN 1
        ELSE 0
    END AS PAR_0_29,
    CASE 
        WHEN dataset.consecutive_late_days >= 30 AND dataset.consecutive_late_days < 59 THEN 1
        ELSE 0
    END AS PAR_30_59,
    CASE 
        WHEN dataset.consecutive_late_days >= 60 AND dataset.consecutive_late_days < 120 THEN 1
        ELSE 0
    END AS PAR_60_119,
    CASE 
        WHEN dataset.consecutive_late_days > 120 THEN 1
        ELSE 0
    END AS PAR_120,
    CASE 
        WHEN dataset.consecutive_late_days >= 0 AND dataset.consecutive_late_days < 30 
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
        WHEN dataset.consecutive_late_days BETWEEN 0 AND 119 AND dataset.customer_age_tag = 'Older Customer' THEN 1
        ELSE 0 
    END AS eligible
FROM 
    dataset AS dataset
-- WHERE 
--    dataset.unique_account_id = 'BXCK72601546'