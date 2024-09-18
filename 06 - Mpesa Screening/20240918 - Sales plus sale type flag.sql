-- M-PESA Screening Flags with Sale or Repo

WITH sales_upgrades_table AS (
    SELECT 
        customer_id,
        unique_customer_id, 
        account_id,
        customer_active_start_date,
        CASE
            WHEN (ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_active_start_date::DATE ASC)) = 1
                THEN 'Original Sale'
            ELSE 'Upgrade'
        END AS Sale_Flag
    FROM kenya.rp_portfolio_customer_lookup AS look_up
)
    
SELECT
    lookup.unique_customer_id,
    sales_upgrades_table.sale_flag,
    customer_details.customer_name,
    customer_details.customer_phone_1,
    customer_details.customer_phone_2,
    lookup.account_id,
    lookup.down_payment_date::DATE,
    lookup.customer_active_start_date::DATE,
    lookup.shop,
    lookup.sales_agent_names,
    lookup.tv_customer_flag,
    lookup.current_hardware_type,
    lookup.current_system,
    -- lookup.agent_id_format,
    CASE
        WHEN lookup.down_payment_date::DATE >= '2024-03-15'
            THEN 'After Mandatory Screening'
        ELSE 'Before Mandatory Screening'
    END AS Screening_Flag
FROM kenya.rp_portfolio_customer_lookup AS lookup
    LEFT JOIN kenya.customer_personal_details AS customer_details
        ON lookup.account_id = customer_details.account_id
    LEFT JOIN sales_upgrades_table 
        ON sales_upgrades_table.unique_customer_id = lookup.unique_customer_id 
WHERE
    lookup.down_payment_date::DATE >= '2024-03-15'
    -- AND lookup.unique_customer_id = 'BXCK68198134'