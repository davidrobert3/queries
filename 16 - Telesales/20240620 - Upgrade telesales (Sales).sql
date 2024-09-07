SELECT 
    signup_utc_timestamp :: DATE,
    unique_account_id,
    billing_method_name,
    current_order_status,
    customer_product_status,
    CASE 
    	WHEN customer_product_action_type = 'install'
    		THEN 'sale'
    	WHEN customer_product_action_type = 'upgrade'
    		THEN 'upgrade'
    	ELSE 'unknown'
    END AS action_type,
    downpayment,
    downpayment_paid_utc_timestamp :: DATE,
    total_down_payment_paid_to_date,
    instalment,
    substring(UPPER(s.sales_person), 0, 7) AS agent_id,
    sa.sales_agent_name
FROM
    kenya.sales s
    LEFT JOIN kenya.sales_agent sa ON sa.sales_agent_id = s.sales_agent_id
WHERE
    substring(UPPER(s.sales_person), 0, 7) in ('KE7500', 'KE7501', 'KE7561', 'KE7982', 'KE7983')
    AND signup_utc_timestamp :: DATE >= '20240601'