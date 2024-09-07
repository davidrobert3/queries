--Get 6 month collection rate
--Remove downpayments fron new sales
--Check weird scenerios;
--Customer start_date earlier than downpayment date
--Daily rate is 0 or null
--Inactive customers showing as active
--Expected cash is 0
--CTE to get downpayments
with downpayments as 
     (
		select
			customer_id,
			unique_account_id,
			sum(total_downpayment) as total_downpayment
		from
			kenya.rp_retail_sales
		where
			downpayment_date::date >= CURRENT_DATE - interval '6 MONTH'
		group by
			1,
			2  
     ),
--CTE to get customer repayments
	payments as 
     (
		select
			payments.payg_account_id,
			SUM(amount) - coalesce(downpayments.total_downpayment,
			0) as repayments,
			downpayments.total_downpayment
		from
			src_odoo13_kenya.account_payment as payments
		left join downpayments as downpayments 
		                 on
			downpayments.unique_account_id = payments.payg_account_id
		left join kenya.customer as customer
		                 on
			customer.unique_account_id = payments.payg_account_id
		where
			payments.state = 'posted'
			and payments.transaction_date >= CURRENT_DATE - interval '6 MONTH'
			--and customer.unique_account_id = 'BXCK67854266'
		group by
			payments.payg_account_id,
			downpayments.total_downpayment 
     ),
---------------------------------------------
-- Add agent reassignment/remapping CTE. Add new 
    sales_agents as 
    ( 
    	select 
     		sa.sales_agent_id ,
     		sa.sales_agent_name ,
     		upper(substring(sa.username, 0, 7)) as agent_code ,
			sa.sales_agent_mobile
     	from kenya.sales_agent sa
     ),
     rp_sales as 
     (
	     select 
	     	sales.unique_account_id ,
	     	case
	     		when upper(substring(sales.sales_person, 0, 7)) in ('KE0767', 'KE0830', 'KE1189')
	     			then 'KE2986'
	     		else upper(substring(sales.sales_person, 0, 7))
	     	end as agent_code    	
	     from kenya.rp_retail_sales as sales
	     where sales.sale_type = 'install'
   		and sales.sales_order_id = sales.unique_account_id   
   --and sales.unique_account_id= 'BXCK00000131'
     ),
     sales_details as
     	(
     	select
     		sales.unique_account_id,
		    sales.agent_code as sales_person ,
		    agent.agent_code as username,
		    agent.sales_agent_name,
		    agent.sales_agent_mobile
     	from rp_sales as sales
     	left join sales_agents as agent on
     		sales.agent_code = agent.agent_code
--     	where agent.agent_code = 'KE1292'
--     limit 6
     		)
     		,     
	active as 
     (
		select 
--			count(*)
			today.date_timestamp::date as activity_date,
			today.customer_id,
			details.customer_name,
			details.customer_phone_1,
			details.customer_phone_2,
			details.home_address_4 as locations,
			details.home_address_3 as constituency,
			customer.location_customer_met_latitude,
			customer.location_customer_met_longitude,
			customer.location_customer_met_accuracy,
			customer.unique_account_id,
			today.consecutive_late_days,
			today.daily_rate,
			sales_details.sales_agent_name,
			upper(substring(sales_details.sales_person, 0, 7)) as sales_person ,
			sales_details.sales_agent_mobile,
			customer.customer_active_end_date,
			customer.customer_active_start_date::text::date as installation_date,
			least(((CURRENT_DATE - (customer.customer_active_start_date::DATE + 7))::BIGINT),
			180) as days_expected
		from
			kenya.agg_dcs_today as today
		left join kenya.customer as customer   
		           on
			customer.account_id = today.account_id
		left join sales_details as sales_details on
			sales_details.unique_account_id = customer.unique_account_id
		left join kenya.customer_personal_details as details on
			details.account_id = customer.account_id
		where
			customer.customer_final_status is null
--			and sales_details.username = 'KE1292'			
			)
			,
------------------------------------------------------------------
--Calculate collection rates
	collection_rate as 
     (
		select 
--				count(*)
			active.activity_date,
			active.customer_id,
			active.customer_name,
			active.customer_phone_1,
			active.customer_phone_2,
			active.locations,
			active.constituency,
			active.unique_account_id,
			active.location_customer_met_latitude,
			active.location_customer_met_longitude,
			active.location_customer_met_accuracy,
			active.daily_rate,
			active.customer_active_end_date,
			active.sales_person,
			active.sales_agent_mobile,
			active.sales_agent_name,
			look.shop,
			look.region,
			active.installation_date,
			active.consecutive_late_days,
			active.days_expected,
			coalesce(repayments.repayments,
			0) as six_month_repayments,
			repayments.repayments / nullif((active.days_expected * active.daily_rate),
			0) as six_month_collection_rate,
			row_number() over 
		           (
		           partition by active.unique_account_id
		           ) as row_numbers
		from
			active as active
		left join payments as repayments 
		                 on
			repayments.payg_account_id = active.unique_account_id
		left join kenya.rp_portfolio_customer_lookup as look 
		                 on
			look.customer_id = active.customer_id
--		where active.sales_person = 'KE1292'	
			--limit 5
     ),
	last_30_downpayments as 
     (
		select
			customer_id,
			unique_account_id,
			sum(total_downpayment) as total_downpayment
		from
			kenya.rp_retail_sales
		where
			downpayment_date::date between current_date -7 and CURRENT_DATE - 1
		group by
			1,
			2
     ),
	last_7_day_CR as
	(
		select
			payments.payg_account_id,
			sum(amount) - (coalesce(last_30_downpayments.total_downpayment,
			0)) as payments
		from
			src_odoo13_kenya.account_payment as payments
		left join last_30_downpayments as last_30_downpayments on
			last_30_downpayments.unique_account_id = payments.payg_account_id
		where
			payments.state = 'posted'
			and payments.transaction_reference not like '%BONUS%'
			and payments.transaction_date::TEXT::DATE between current_date -7 and CURRENT_DATE -1
		group by
			payments.payg_account_id,
			last_30_downpayments.total_downpayment
     ),
	dataset as 
     (
		select
			collection_rate.activity_date as last_refresh_date,
			current_date - 7 || ' to ' || current_date - 1 as period_,
			collection_rate.region,
			collection_rate.shop,
			collection_rate.unique_account_id,
			collection_rate.customer_name,
			collection_rate.customer_phone_1,
			collection_rate.customer_phone_2,
			collection_rate.locations as ward,
			collection_rate.location_customer_met_latitude,
			collection_rate.location_customer_met_longitude,
			case
				when 
		            collection_rate.daily_rate in( 15, 14.46)
		            then 1
				else 0
			end as ESF_only_status,
			collection_rate.sales_agent_name,
			collection_rate.sales_person as agent_id,
			0 as agent_status,
			coalesce(last_7_day_CR.payments,
			0) / nullif((collection_rate.daily_rate * 7),
			0) as last_7_day_CR,
			0 as technician_name,
			collection_rate.daily_rate,
			collection_rate.consecutive_late_days,
			collection_rate.sales_agent_mobile::TEXT as sales_agent_mobile,
			coalesce(collection_rate.six_month_collection_rate,
			0) as six_month_collection_rate,
			collection_rate.installation_date,
			--collection_rate.six_month_repayments,
			last_7_day_CR.payments as cash_collected,
			collection_rate.days_expected,
			case
				when collection_rate.installation_date + 8 > collection_rate.activity_date
		                   then 'New Customer'
				else 'Older Customer'
			end as customer_age_tag
		from
			collection_rate as collection_rate
		left join last_7_day_CR as last_7_day_CR 
		                 on
			last_7_day_CR.payg_account_id = collection_rate.unique_account_id
		where
			collection_rate.row_numbers = 1
     )
		select
			*,
			7 * daily_rate as total_expected_cash,
			case
				when 
		      dataset.consecutive_late_days >= 0
					and dataset.consecutive_late_days < 30
		      then 1
					else 0
				end as PAR_0_29,
				case
					when 
		      dataset.consecutive_late_days >= 30
					and dataset.consecutive_late_days < 59
		      then 1
					else 0
				end as PAR_30_59,
				case
					when 
		      dataset.consecutive_late_days >= 60
					and dataset.consecutive_late_days < 120
		      then 1
					else 0
				end as PAR_60_119,
				case
					when 
		      dataset.consecutive_late_days > 120   
		      then 1
					else 0
				end as PAR_120,
				case
					when 
		                       dataset.consecutive_late_days >= 0
					and dataset.consecutive_late_days < 30
					and 
		                       (
		                       dataset.six_month_collection_rate >= 0.66667
						or 
		                       (
		                      dataset.six_month_collection_rate < 0.66667
							and dataset.last_7_day_CR >= 0.6667
		                       )
		                       )
					and dataset.customer_age_tag = 'Older Customer'
		                then 'Good Payer'
					when 
		                       (dataset.six_month_collection_rate < 0.66667
						and dataset.consecutive_late_days < 30
						and dataset.last_7_day_CR < 0.6667
						and dataset.customer_age_tag = 'Older Customer'
		                       )
					or 
		                       (
		                       dataset.six_month_collection_rate < 0.66667
						and dataset.consecutive_late_days < 30
						and dataset.customer_age_tag = 'Older Customer'
						and dataset.last_7_day_CR is null
		                       )
		                then 'Slow Payer_Locked Rewards'
					when 
		                       dataset.consecutive_late_days >= 30
					and dataset.consecutive_late_days < 60
					and dataset.customer_age_tag = 'Older Customer' 
		                then 'Late_30-59'
					when 
		                       dataset.consecutive_late_days >= 60
					and dataset.consecutive_late_days < 120
					and dataset.customer_age_tag = 'Older Customer'
		                then 'Defaulted_60-119'
					when 
		                       dataset.consecutive_late_days >= 120
					and dataset.customer_age_tag = 'Older Customer'
		                then 'Legacy Customer'
					when 
		                       dataset.customer_age_tag = 'New Customer' 
		                then 'New Customers'
					else 'Unaccounted for bucket'
				end as CustomerSegment,
				case
					when dataset.consecutive_late_days between 0 and 119
					and dataset.customer_age_tag = 'Older Customer' 
		           then 1
					else 0
				end as eligible
			from
				dataset
			where dataset.customer_name not like '%OPTED OUT%'
			
			
			
		