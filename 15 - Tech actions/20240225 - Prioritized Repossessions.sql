-----------------------------------------------------------------------------------------------
--This query help in identifying lithium and battery customer
-----------------------------------------------------------------------------------------------
-- LITHIUM AND LEAD_ACID BATTERIES CTEs
	-- get all control units from the DWH and separates them into lithium CTE and Lead_acid CTE
	-- gets customers attached to both --> CTE all_customer_details
	-- calculates customers'age and years since last replacement --> bpower20and50_customers CTE
	-- filters lithium battery customers --> lithium_customers CTE
	-- filters lead_acid customers into those who were installed within the last two years --> leadacid_less_2years CTE
	-- filters older customers(installed more than two years) but got replacement withiin the last 2 years --> leadacid_2year CTE
	-- combines all filtered customer --> prioritized_leadacid_customer CTE
--------------------------------------------------------------------------------
-- 24" AND 32" TV CTEs
	-- gets all products --> product CTE
	-- get all TV pacages --> tv_packages CTE
	-- gets all customers with 24 or 32 tvs --> final_data_tv CTE
--------------------------------------------------------------------------------
 	-- eliminates unnecessary columns and adds customer retailed column --> final_battery_type_customers CTE
	-- combines both TV and battery data --> combined_data CTE
	-- main query that lists all the required columns and marks customers as 24" or 32" TV
------------------------------------------------------------------------------------------------------
--- get all customer data
	-- get the last date that the customer made payment -- last_date CTE
	-- get the last phone number(s) that made paymnet put them in a list -- last_phone CTE
	-- get technician details for each installation done -- tech_details CTE
	-- get agents details for every sales done that is of installation -- agent_details CTE
	-- geta customer details with priority set and installer + agent details added -- customer details
	-- main query to return defaulters only
-----------------------------------------------------------------------------------------------
----
-- CTE to select lithium batteries
with lithium as 
		(
			select 
				distinct cu.battery_type ,
				cu.serial_number,
				cu.product_imei
			from 
				kenya.control_unit cu 
			where
				(cu.battery_type like '%Lithium%' or cu.battery_type like '%LFP%')
				and cu.record_active is true
		),
----
-- CTE to select lead-acid batteries
lead_acid as 
		(
			select 
				distinct cu.battery_type ,
				cu.serial_number,
				cu.product_imei
			from
				kenya.control_unit cu 
			where 
				(cu.battery_type not like '%Lithium%' and cu.battery_type not like '%LFP%')
			  	and cu.record_active is true
		),
----
-- CTE to combine customer details with battery type
all_customer_details as
		(
			select 
				rpcl.unique_customer_id,
				rpcl.account_id,
				rpcl.shop,
				case
					when la.battery_type is not null then 'lead_acid'
					when li.battery_type is not null then 'lithium'
					else 'none' 
				end as battery_type
			from 
				kenya.rp_portfolio_customer_lookup rpcl 
			left join lead_acid la on 
				rpcl.control_unit_serial_number = la.serial_number
			left join lithium li on
				rpcl.control_unit_serial_number = li.serial_number
		),
----
-- CTE to filter and calculate customer age and years sunce last replacement
bpower20and50_customers as 
		(
			select ad.*,
				datediff(year, c.customer_active_start_date::DATE, current_date::DATE) as customer_age,
				datediff(year,ccul.record_active_start_date::DATE, current_date::DATE) as yrs_since_last_replacement
			from 
				all_customer_details as ad
			left join kenya.customer c on
				ad.account_id = c.account_id
			left join kenya.customer_control_unit_link ccul on
				c.account_id = ccul.account_id
			where 
				battery_type not like 'none'
				and c.current_customer_status = 'active'
				and ccul.record_active is true 
		),	
----
-- CTE to select customers with lithium batteries	
lithium_customers as
		(
			select *
			from 
				bpower20and50_customers as b50
			where 
				b50.battery_type = 'lithium'
		),	
----
-- CTE to select lead-acid customers with less than 2 years of age	
leadacid_less_2years as
		(
			select 
				b50.*
			from
				bpower20and50_customers as b50
			where 
				b50.customer_age <= 2
				and b50.battery_type = 'lead_acid'
		),	
----
-- CTE to select lead-acid customers with more than 2 years of age and less than 2 years since last replacement	
leadacid_2year as 
		(
			select 
				b50.*
			from
				bpower20and50_customers as b50
			where 
				b50.customer_age > 2
				and b50.yrs_since_last_replacement <= 2
				and b50.battery_type = 'lead_acid'
		),
----
-- CTE to prioritize lead-acid customers	
prioritized_leadacid_customer as 
		(
			select *
			from 
				leadacid_less_2years
			union all
			select *
			from 
				leadacid_2year
		),
----
-- CTE to combine lead-acid and lithium customers
combined_batterytype_customers as
		(
			select *
			from
				prioritized_leadacid_customer
			union all
			select *
			from
				lithium_customers
		),
----
-- CTE to select product details	
products as 
		(
			select 
				p.product_id,
				p.product_name as pn,
				p.serial_requirement,
				p.category5,
				p.product_type
			from
				kenya.product p
		),		
----
-- CTE to select TV packages	
tv_packages as
		(
			select *
			from 
				kenya.bill_of_material bom2 
			left join products p on
				bom2.component_product_id = p.product_id
			where 
				(lower(p.pn) like '%24%tv%' 
				or lower(p.pn) like '%32%tv%')
				and p.category5 like 'TV'
				and p.product_type like 'appliance'
		),
----
-- CTE to select final TV customer data	
final_data_tv as
		(
			select 
				distinct c.account_id ,
				c.unique_account_id ,
				c.current_customer_status ,
				c.current_payment_status ,
				c.customer_active_start_date::DATE ,
				c.customer_active_end_date::DATE ,
				rrs.shop,
				rrs.current_hardware_type
			from 
				tv_packages tp
			left join kenya.rp_retail_sales rrs on
				tp.pakg_product_id = rrs.product_id 
			left join kenya.customer c on
				rrs.account_id = c.account_id 
			group by 1,2,3,4,5,6,7,8
		),
----
-- CTE to select final customer data based on battery type	
final_battery_type_customers as
		(
			select 
				distinct c.account_id ,
				c.unique_account_id ,
				c.current_customer_status ,
				c.current_payment_status ,
				c.customer_active_start_date::DATE ,
				c.customer_active_end_date::DATE ,
				cb.shop,
				rpcl.current_hardware_type
			from 
				combined_batterytype_customers cb
			left join kenya.rp_retail_sales rrs on
				cb.account_id = rrs.account_id
			left join kenya.customer c on 
				cb.account_id = c.account_id
			left join kenya.rp_portfolio_customer_lookup rpcl on
				cb.account_id = rpcl.account_id
			group by 1,2,3,4,5,6,7,8
		),
----
-- CTE to combine all customer data	
combined_data as 
		(
			select *
			from 
				final_data_tv
			union all
			select *
			from 
					final_battery_type_customers
		),
----
--mark a customer as either 24" TV, 32" TV or Lights only customer
customer_segmentation as 
		(
			select 
	            cd.account_id,
	            cd.unique_account_id,
	            cd.current_customer_status,
	            cd.current_payment_status,
	            cd.customer_active_start_date::DATE,
	            cd.customer_active_end_date::DATE,
	            cd.shop,
	            cd.current_hardware_type,
	            case 
	                when lower(rrs.product_name) like '%24" tv%' then '24" TV'
	                when lower(rrs.product_name) like '%32" tv%' then '32" TV'
	            end as tv_size
	        from 
	            combined_data cd
	        left join 
	            kenya.rp_retail_sales rrs ON cd.account_id = rrs.account_id
		),
----
-- Main query to select final data with TV sizes
all_prioritized_clients as		
		(
			select 
				distinct cs.account_id ,
				cs.unique_account_id ,
				cs.current_customer_status ,
				cs.current_payment_status ,
				cs.customer_active_start_date::DATE ,
				cs.customer_active_end_date::DATE ,
				cs.shop,
				cs.current_hardware_type,
				listagg(distinct cs.tv_size, ', ') AS products,
				'Priority 1' AS priority
			from 
				customer_segmentation cs
			group by 
			    1, 2, 3, 4, 5, 6, 7, 8
		),
----
-- gets last payment date
last_date as
		(
			select 
				ap.payg_account_id,
				max(ap.payment_date) as max_date
			from src_odoo13_kenya.account_payment ap 
			group by 1
		),
----
-- gets last number that made payment and puts in a list
last_phone as
		(
			select 
					distinct ap.payg_account_id,
					listagg(distinct (
					case 
						when len(ap.payer_identifier) > 10 and len(ap.payer_identifier) < 15 and upper(ap.payer_identifier) not like '%BXCK%'
						then ap.payer_identifier
						else null
					end), ', ') as last_payment_phone					
			from src_odoo13_kenya.account_payment ap 
			left join last_date on
				ap.payg_account_id = last_date.payg_account_id
			where ap.payment_date = max_date
			group by 1
		),
---
-- Gets technician details per installation done
first_installation_date as 
		(
			select 
				i.account_id,
				min(i.installation_date) as min_date
			from kenya.installations i
			group by 1
		),		
tech_details as
		(
			select 
				i.installation_id,
				id.min_date as installation_date,
				i.account_id,
				t.username,
				t.technician_name
			from kenya.installations i
			left join kenya.technician t on
				i.technician_id = t.technician_id
			left join first_installation_date id on
				i.account_id = id.account_id
			where i.installation_date = id.min_date
		),
----
-- gets sales agent details per sale made
agent_details as 
		(
		    select
		    	distinct sales.unique_account_id,
		        sales.sales_person,
		        agent.username,
		        agent.sales_agent_bboxx_id,
		        agent.sales_agent_name,
		        agent.sales_agent_mobile
		    from 
		    	kenya.rp_retail_sales as sales
		        left join kenya.sales_agent as agent on
		        	agent.sales_agent_id = sales.sign_up_sales_agent_id
		    where 
		    	sales.sale_type = 'install'
		        and sales.sales_order_id = sales.unique_account_id
		),
----
-- gets all customer details with priority set as 1(for customers to be prioritized) or 2 (other customers)
customer_details as
		(
			select 
				distinct c.unique_account_id,
				cpd.customer_name,
				cpd.customer_phone_1,
				cpd.customer_phone_2,
				lp.last_payment_phone,
				cpd.customer_home_address as nearest_landmark,
				cpd.home_address_2 as county,
				cpd.home_address_3 as constituency,
				cpd.home_address_4 as locations,
				dcs.daily_rate,
				td.technician_name,
				o.shop_name,
				o.shop_region,
				ad.sales_agent_name,
				ad.sales_agent_mobile,
				ad.username as agent_id,
				td.installation_date::date,
				dcs.consecutive_late_days,
				case 
					when apc.priority is null
					then 'Priority 2'
					else apc.priority
				end as Priorioty
			from 
				kenya.daily_customer_snapshot dcs 
			left join all_prioritized_clients apc on
				dcs.account_id = apc.account_id
			left join kenya.customer c on
				dcs.account_id = c.account_id
			left join last_phone lp on
				c.unique_account_id = lp.payg_account_id
			left join kenya.customer_personal_details cpd on
				c.account_id = cpd.account_id
			left join kenya.organisation o on 
				c.organisation_id = o.organisation_id
			left join tech_details td on
				dcs.account_id = td.account_id
			left join agent_details ad on
				c.unique_account_id = ad.unique_account_id		
			where 
				dcs.date_timestamp::date = current_date::DATE - 1
		)
select 
	*
from 
	customer_details
where 
	consecutive_late_days >= 55
--		limit 4