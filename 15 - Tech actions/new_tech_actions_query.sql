select
    rrira.unique_customer_id,
    rrira.technician_name,
    rrira.username,
    rrira.action_date as action_date_timestamp,
    rrira.action_date :: date as action_date,
    rrira.shop_name,
    rrira.action_type,
    rrira.current_hardware_type,
    r.technician_id --sm.delivery_type 
from
    kenya.rp_retail_installs_repos_actions rrira
    LEFT JOIN kenya.customer c ON rrira.unique_customer_id = c.unique_account_id
    LEFT JOIN kenya.repossession r ON r.account_id = c.account_id
where
    rrira.action_date >= '2024-01-01' --	AND r.technician_id ISNULL 
    AND rrira.action_type IN ('Repossessions', 'Fulfillments') --	limit 5
    --and