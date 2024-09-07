 with sales_agents as 
    ( 
        select 
            sa.sales_agent_id ,
            sa.sales_agent_name ,
            upper(substring(sa.username, 0, 7)) as agent_code ,
            sa.sales_agent_mobile
        from kenya.sales_agent sa
     )
         select 
            sales.unique_account_id ,
            case
                when upper(substring(sales.sales_person, 0, 7)) in ('KE0767', 'KE0830', 'KE1189')
                    then 'KE2986'
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
                 when upper(substring(sales.sales_person, 0, 7)) in ('KE2784', 'KE2353', 'KE0666')
                    then 'KE0168'
                 when upper(substring(sales.sales_person, 0, 7)) in ('KE0580')
                    then 'KE7249'
                 when upper(substring(sales.sales_person, 0, 7)) in ('KE0134', 'KE2785')
                    then 'KE1992'
                 when upper(substring(sales.sales_person, 0, 7)) in ('KE1130', 'KE0617', 'KE1187')
                    then 'KE7311'
                else upper(substring(sales.sales_person, 0, 7))
            end as agent_code       
         from kenya.rp_retail_sales as sales
         where sales.sale_type = 'install'
        and sales.sales_order_id = sales.unique_account_id  