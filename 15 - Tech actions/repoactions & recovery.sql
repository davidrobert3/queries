select 
        -- rrira.unique_customer_id ,
        rrira.action_date ,
        rrira.shop_name ,
        rrira.technician_name ,
        count(*) OVER(PARTITION BY rrira.action_date, technician_name, shop_name) as number_of_repo
from kenya.rp_retail_installs_repos_actions rrira
LIMIT 5;


select * 
from kenya.customer
where customer.unique_account_id = 'BXCK22352026'