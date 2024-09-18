-- Cohort Analysis
-- Amended Sept 2nd, 2024
-- 1. Addition on m1*

WITH tv_sales_and_upgrades AS (
    select 
        distinct 
        pakg_product_id ,
        bom2.record_active_start_date::DATE AS date_created,
        pakg_name ,
        component_name ,
        case 
            when UPPER(pakg_name) like '%OPTIMI%'
                then 'Sale'
            when UPPER(pakg_name) like '%DISCOUNTED%' or UPPER(pakg_name) like '%UPGRADE%' or UPPER(pakg_name) like '%AERIAL%'
                then 'Upgrade'
            else 'Sale'
        end as Sale_Type,
        'Has TV' as tv_subtype
    from
        kenya.bill_of_material bom2
    where
        upper(bom2.component_name) like '%TV%'
        and upper(bom2.component_name) not like '%AERIAL%'
        and upper(bom2.component_name) not like '%ESF%'
        and upper(bom2.component_name) not like '%ZUKU%'
        --AND bom2.record_active_start_date::DATE >= '2021-12-31'
),
 
tv_upgrade_packages AS (
    SELECT 
        *
    FROM  tv_sales_and_upgrades
    WHERE 
        Sale_Type = 'Upgrade' 
),

upgraded_tv_customers AS (
    SELECT 
        sales.unique_account_id,
        sa.sales_agent_name,
        sa.sales_agent_bboxx_id AS agent_code,
        tv_upgrade_packages.*
    FROM kenya.sales AS sales
        LEFT JOIN tv_upgrade_packages 
            ON tv_upgrade_packages.pakg_product_id = sales.product_id
        LEFT JOIN kenya.sales_agent sa 
            ON sa.sales_agent_id = sales.sales_agent_id 
    WHERE 
        tv_upgrade_packages.pakg_product_id IS NOT NULL 
)

select 
    dcs.payg_account_id,
    rpcl.customer_active_start_date::date as InstallationDate,
    CASE 
        WHEN upgraded_tv_customers.pakg_name IS NULL 
         THEN 'Sale / Other'
        ELSE upgraded_tv_customers.pakg_name
    END AS package_name,
    CASE 
        WHEN upgraded_tv_customers.pakg_name IS NULL
            THEN 'Sale / Other'
        ELSE 'TV Upgrade'
    END AS TV_Upgrade_Flag,
    CASE 
        WHEN upgraded_tv_customers.sales_agent_name IS NULL
            THEN rpcl.sales_agent_names
        ELSE upgraded_tv_customers.sales_agent_name
    END agent_name,
    CASE 
        WHEN upgraded_tv_customers.sales_agent_name IS NULL
            THEN LEFT(rpcl.agent_id_format, 6)
        ELSE LEFT(upgraded_tv_customers.agent_code,6)
    END ke_agent_code,
    rpcl.region, 
    rpcl.shop,
    rpcl.current_hardware_type, 
    rpcl.current_system, 
    rpcl.tv_customer,
    rpcl.downpayment,
    rpcl.daily_rate,
    rpcl.total_contract_value,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 37
                and dcs.consecutive_late_days = 0
                and rpcl.customer_active_start_date::date <= current_date - 7
            then 1
            else 0
        end ) as DaysNormalM1Special,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 37
                and rpcl.customer_active_start_date::date <= current_date - 7
            then 1
            else 0
        end ) as DaysActiveM1special,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 37
                and dcs.consecutive_late_days = 0
                and rpcl.customer_active_start_date::date <= current_date - 37
            then 1
            else 0
        end ) as DaysNormalM1,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 37
                and rpcl.customer_active_start_date::date <= current_date - 37
            then 1
            else 0
        end ) as DaysActiveM1,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 67
                and rpcl.customer_active_start_date::date <= current_date - 67
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM2,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 67
                and rpcl.customer_active_start_date::date <= current_date - 67
            then 1
            else 0
        end ) as DaysActiveM2,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 97
                and rpcl.customer_active_start_date::date <= current_date - 97
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM3,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 97
                and rpcl.customer_active_start_date::date <= current_date - 97
            then 1
            else 0
        end ) as DaysActiveM3,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 127
                and rpcl.customer_active_start_date::date <= current_date - 127
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM4,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 127
                and rpcl.customer_active_start_date::date <= current_date - 127
            then 1
            else 0
        end ) as DaysActiveM4,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 157
                and rpcl.customer_active_start_date::date <= current_date - 157
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM5,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 157
                and rpcl.customer_active_start_date::date <= current_date - 157
            then 1
            else 0
        end ) as DaysActiveM5,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 187
                and rpcl.customer_active_start_date::date <= current_date - 187
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM6,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 187
                and rpcl.customer_active_start_date::date <= current_date - 187
            then 1
            else 0
        end ) as DaysActiveM6,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 217
                and rpcl.customer_active_start_date::date <= current_date - 217
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM7,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 217
                and rpcl.customer_active_start_date::date <= current_date - 217
            then 1
            else 0
        end ) as DaysActiveM7,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 247
                and rpcl.customer_active_start_date::date <= current_date - 247
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM8,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 247
                and rpcl.customer_active_start_date::date <= current_date - 247
            then 1
            else 0
        end ) as DaysActiveM8,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 277
                and rpcl.customer_active_start_date::date <= current_date - 277
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM9,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 277
                and rpcl.customer_active_start_date::date <= current_date - 277
            then 1
            else 0
        end ) as DaysActiveM9,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 307
                and rpcl.customer_active_start_date::date <= current_date - 307
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM10,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 307
                and rpcl.customer_active_start_date::date <= current_date - 307
            then 1
            else 0
        end ) as DaysActiveM10,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 337
                and rpcl.customer_active_start_date::date <= current_date - 337
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM11,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 337
                and rpcl.customer_active_start_date::date <= current_date - 337
            then 1
            else 0
        end ) as DaysActiveM11,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 367
                and rpcl.customer_active_start_date::date <= current_date - 367
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM12,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 367
                and rpcl.customer_active_start_date::date <= current_date - 367
            then 1
            else 0
        end ) as DaysActiveM12,
    
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 397
                and rpcl.customer_active_start_date::date <= current_date - 397
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM13,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 397
                and rpcl.customer_active_start_date::date <= current_date - 397
            then 1
            else 0
        end ) as DaysActiveM13,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 427
                and rpcl.customer_active_start_date::date <= current_date - 427
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM14,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 427
                and rpcl.customer_active_start_date::date <= current_date - 427
            then 1
            else 0
        end ) as DaysActiveM14,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 457
                and rpcl.customer_active_start_date::date <= current_date - 457
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM15,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 457
                and rpcl.customer_active_start_date::date <= current_date - 457
            then 1
            else 0
        end ) as DaysActiveM15,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 487
                and rpcl.customer_active_start_date::date <= current_date - 487
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM16,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 487
                and rpcl.customer_active_start_date::date <= current_date - 487
            then 1
            else 0
        end ) as DaysActiveM16,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 517
                and rpcl.customer_active_start_date::date <= current_date - 517
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM17,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 517
                and rpcl.customer_active_start_date::date <= current_date - 517
            then 1
            else 0
        end ) as DaysActiveM17,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 547
                and rpcl.customer_active_start_date::date <= current_date - 547
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM18,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 547
                and rpcl.customer_active_start_date::date <= current_date - 547
            then 1
            else 0
        end ) as DaysActiveM18,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 577
                and rpcl.customer_active_start_date::date <= current_date - 577
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM19,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 577
                and rpcl.customer_active_start_date::date <= current_date - 577
            then 1
            else 0
        end ) as DaysActiveM19,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 607
                and rpcl.customer_active_start_date::date <= current_date - 607
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM20,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 607
                and rpcl.customer_active_start_date::date <= current_date - 607
            then 1
            else 0
        end ) as DaysActiveM20,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 637
                and rpcl.customer_active_start_date::date <= current_date - 637
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM21,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 637
                and rpcl.customer_active_start_date::date <= current_date - 637
            then 1
            else 0
        end ) as DaysActiveM21,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 667
                and rpcl.customer_active_start_date::date <= current_date - 667
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM22,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 667
                and rpcl.customer_active_start_date::date <= current_date - 667
            then 1
            else 0
        end ) as DaysActiveM22,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 697
                and rpcl.customer_active_start_date::date <= current_date - 697
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM23,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 697
                and rpcl.customer_active_start_date::date <= current_date - 697
            then 1
            else 0
        end ) as DaysActiveM23,
        
     SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 727
                and rpcl.customer_active_start_date::date <= current_date - 727
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM24,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 727
                and rpcl.customer_active_start_date::date <= current_date - 727
            then 1
            else 0
        end ) as DaysActiveM24,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 757
                and rpcl.customer_active_start_date::date <= current_date - 757
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM25,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 757
                and rpcl.customer_active_start_date::date <= current_date - 757
            then 1
            else 0
        end ) as DaysActiveM25,
        
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 787
                and rpcl.customer_active_start_date::date <= current_date - 787
                and dcs.consecutive_late_days = 0
            then 1
            else 0
        end ) as DaysNormalM26,
    SUM(
        case 
            when 
                dcs.date_timestamp::date <= rpcl.customer_active_start_date::date + 787
                and rpcl.customer_active_start_date::date <= current_date - 787
            then 1
            else 0
        end ) as DaysActiveM26
from kenya.daily_customer_snapshot dcs 
    left join kenya.rp_portfolio_customer_lookup rpcl 
        on dcs.account_id = rpcl.account_id 
    LEFT JOIN upgraded_tv_customers 
        ON upgraded_tv_customers.unique_account_id = dcs.payg_account_id 
where 
    rpcl.customer_active_start_date::DATE >= '20230401'
    --and rpcl.current_hardware_type = 'Control Unit with User Manual of Flexx40'
group by 
    dcs.payg_account_id,
    rpcl.customer_active_start_date::date,
    upgraded_tv_customers.pakg_name,
    upgraded_tv_customers.sales_agent_name,
    rpcl.sales_agent_names,
    upgraded_tv_customers.agent_code,
    rpcl.agent_id_format,
    rpcl.region, 
    rpcl.shop,
    rpcl.current_hardware_type, 
    rpcl.current_system, 
    rpcl.tv_customer,
    rpcl.downpayment,
    rpcl.daily_rate,
    rpcl.total_contract_value;



--SELECT * FROM kenya.sales AS sales WHERE sales.unique_account_id = 'BXCK68237630';
--
--SELECT * FROM kenya.sales_agent sa WHERE sa.sales_agent_id = 'a7efd529da75d4df7a79e332c19763d1';

--SELECT 
--* 
--FROM kenya.rp_portfolio_customer_lookup rpcl 
--WHERE 
--    -- rpcl.unique_customer_id  = 'BXCK25561023'
--    rpcl.customer_id = '8ec0debd6d3f4de8a06593e9ab32e42b'
--    
--SELECT  
--    dcs.date_timestamp::DATE,
--    dcs.consecutive_late_days,
--    dcs.daily_rate, 
--    DCS.payment_status 
--FROM kenya.daily_customer_snapshot dcs 
--WHERE 
--    dcs.account_id = 'b96630baaac76fe2e5d09174aca28f5c'
--    --AND dcs.date_timestamp::DATE = '2024-08-27'
--    
--SELECT 
--    *
--FROM kenya.repossession r 
--LIMIT 5
--WHERE 
--    sa.sales_agent_name = 'Judith Akinyi Omondi'
--LIMIT 5

--SELECT 
--    rpcl.agent_id_format,
--    LEFT(rpcl.agent_id_format, 6)
--FROM kenya.rp_portfolio_customer_lookup rpcl
--LIMIT 5

--    SELECT 
--        sales.unique_account_id,
--        sa.sales_agent_name
--    FROM kenya.sales AS sales
--        LEFT JOIN kenya.sales_agent sa 
--            ON sa.sales_agent_id = sales.sales_agent_id 
--    LIMIT 5;
--
--SELECT 
--    *
--FROM kenya.sales_agent sa 
--LIMIT 5;
--
--SELECT 
--*
--FROM kenya.rp_portfolio_customer_lookup rpcl
--LIMIT 5
--