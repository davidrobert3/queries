WITH shop_details AS (
    SELECT
        dcs.payg_account_id,
        dcs.account_id,
        dcs.organisation_id,
        MAX(dcs.date_timestamp::DATE) AS date
    FROM
        kenya.daily_customer_snapshot dcs
    WHERE
        dcs.organisation_id IS NOT NULL
    GROUP BY
        1, 2, 3
),
packages AS (
    SELECT
        p.product_id,
        p.product_name,
        p.serial_requirement
    FROM
        kenya.product p
    WHERE
        p.serial_requirement = 'required'
),
products AS (
    SELECT
        bom2.pakg_product_id,
        bom2.component_product_id,
        bom2.pakg_name,
        pk.*
    FROM
        kenya.bill_of_material bom2
    LEFT JOIN packages pk ON
        bom2.component_product_id = pk.product_id
    WHERE
        pk.serial_requirement IS NOT NULL
),
employees AS (
    SELECT
        e.user_odoo13_id,
        INITCAP(e.employee_name) AS employee_name,
        e.employee_email,
        SUBSTRING(e."location", LENGTH(e."location") - POSITION('/' IN REVERSE(e."location")) + 2) AS tech_location
    FROM
        kenya.employee e
),
voluntary_repo AS (
    SELECT
        s.account_id,
        s.current_contract_status,
        s.customer_product_status,
        s.cancellation_reason AS repo_reason,
        s.cancellation_date::DATE,
        INITCAP(e.employee_name) AS employee_name,
        e.employee_email,
        e.tech_location
    FROM
        kenya.sales s
    LEFT JOIN kenya.customer c ON
        s.account_id = c.account_id
    LEFT JOIN products p ON
        s.product_id = p.pakg_product_id
    LEFT JOIN employees e ON
        s.cancelled_by = e.user_odoo13_id
    WHERE
        p.serial_requirement = 'required'
        AND c.current_customer_status NOT LIKE 'repo'
        AND s.cancellation_reason LIKE 'default_resolution'
),
repo AS (
    SELECT
        r2.account_id,
        r2.repossession_status,
        r2.technician_id,
        r2.repossession_date
    FROM
        kenya.repossession r2
    LEFT JOIN kenya.customer c2 ON
        r2.account_id = c2.account_id
    WHERE
        r2.repossession_status = 'done'
), 
pre_final_output as (
SELECT
    c.account_id,
    c.unique_account_id,
    c.customer_active_end_date::DATE,
    date_trunc('MONTH', c.customer_active_end_date::DATE) as repo_month,
    c.current_customer_status,
    r.repossession_date::DATE,
    r.repossession_status,
    vr.repo_reason,
    t.username,
    t.technician_name,
    vr.employee_name AS voluntary_repo_tech,
    vr.employee_email AS voluntary_repo_tech_email,
    vr.tech_location,
    t.record_source,
    e.tech_location AS shop_name2,
    o.shop_region,
    o.shop_name
FROM
    kenya.customer c
        LEFT JOIN repo r ON
            c.account_id = r.account_id
        LEFT JOIN voluntary_repo AS vr ON
            c.account_id = vr.account_id
        LEFT JOIN kenya.technician t ON
            r.technician_id = t.technician_id
        LEFT JOIN shop_details AS sd ON
            c.account_id = sd.account_id
        LEFT JOIN kenya.organisation o ON
            sd.organisation_id = o.organisation_id
        LEFT JOIN employees e ON
        	e.employee_email = t.username
WHERE
    c.customer_active_end_date IS NOT NULL
    AND c.current_customer_status NOT LIKE 'finished'
    AND c.customer_active_end_date >= '2024-08-16'
),
   labeled_repos as (
  select 
    *,
    case 
        when current_customer_status = 'void'
            and repo_reason = 'default_resolution'
        then 'triggered_repo'        
        when current_customer_status = 'void'
            and repo_reason isnull 
        then 'other'        
        when current_customer_status = 'repo'
            and repo_reason isnull 
        then 'defaulted_repo'
    end as repo_check,        
    case 
        when technician_name isnull 
            then voluntary_repo_tech
        else technician_name
    end as full_technician_column,
        case 
        when shop_name2 isnull 
            then tech_location
        else shop_name
    end as full_shop_name_column 
  from pre_final_output
)
   select 
    *
 from labeled_repos 
 where 
    repo_check <> 'other'
--    AND full_shop_name_column notnull