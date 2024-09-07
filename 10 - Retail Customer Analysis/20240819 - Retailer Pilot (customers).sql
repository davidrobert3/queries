select 
	distinct cpd.unique_account_id ,
	rpcl.current_client_status ,
	rpcl.current_payment_status ,
	rpcl.customer_active_start_date::DATE as installation_date,
	cpd.customer_phone_1 ,
	cpd.customer_phone_2 ,
	cpd.home_address_1 as Region,
	cpd.home_address_2 as County,
	cpd.home_address_3 as "Sub-county" ,
	cpd.home_address_4 as Ward,
	cpd.customer_home_address as nearest_landmark ,
	rpcl.sales_agent_names as agent_name,
	rpcl.agent_id_format as agent_code,
	rpcl.contract_performance * 100 as cp ,
	rpcl.current_system ,
	case
		when rpcl.esf_customer = 0
			then 'Non-ESF Customer'
		else 'ESF Customer'
	end as isESF ,
	rpcl.esf_only_date ,
	rpcl.esf_route ,
	rpcl.shop 
from kenya.rp_portfolio_customer_lookup rpcl
left join kenya.customer_personal_details cpd on
	cpd.account_id = rpcl.account_id 
where cpd.home_address_4 ilike 'Mitaboni' --'Keringet'
and rpcl.current_payment_status not like 'inactive'
--limit 5