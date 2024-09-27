select 
	date_trunc('month', rpcl.customer_active_end_date::DATE)::DATE - 1 as repo_month ,
	sum(case 
		when rpcl.current_client_status = 'repo'
			then 1
		else 0
	end) as repossessions,
	sum(case 
		when rpcl.current_client_status = 'lost'
			then 1
		else 0
	end) as write_offs,
	sum(case 
		when rpcl.current_client_status = 'finished'
			then 1
		else 0
	end) as completions
from kenya.rp_portfolio_customer_lookup rpcl 
where rpcl.customer_active_end_date::DATE >= '20240501'
group by 1
order by 1 desc 