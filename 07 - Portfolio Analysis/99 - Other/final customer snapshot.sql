select 
    rpcl.account_id, 
    rpcl.unique_customer_id,
    rpcl.region, 
    rpcl.shop,
    rpcl.customer_active_end_date::DATE as RepoDate,
    rpcl.repo_technician,
    fcs.payment_status,
    fcs.consecutive_late_days ,
    fcs.daily_rate
from kenya.rp_portfolio_customer_lookup rpcl 
    left join kenya.final_customer_snapshot fcs 
        on rpcl.account_id = fcs.account_id
where 
    rpcl.customer_active_end_date >= '20231216'
    -- and rpcl.customer_active_end_date <= '20240120'
    and rpcl.current_client_status = 'repo'
    and rpcl.repo_technician not like '%Mabonga%'
    and fcs.consecutive_late_days::int >= 120
--limit 5;