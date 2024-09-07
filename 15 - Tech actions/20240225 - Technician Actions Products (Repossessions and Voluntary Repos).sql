---------------------------------------------------------------------
---- get shop details for all customers in the portfolio
with shop_details as (
	select
		dcs.payg_account_id,
		dcs.account_id,
		dcs.organisation_id,
		MAX(dcs.date_timestamp :: DATE) AS date
	from
		kenya.daily_customer_snapshot dcs
	where
		dcs.organisation_id IS NOT NULL
	group by
		1,
		2,
		3
),
------------
-- gets products with control units
packages as (
	select
		p.product_id,
		p.product_name,
		p.serial_requirement
	from
		kenya.product p
	where
		p.serial_requirement = 'required'
),
--------------------------------
--- gets package names that will have control units
products as (
	select
		bom2.pakg_product_id,
		bom2.component_product_id,
		bom2.pakg_name,
		pk.*
	from
		kenya.bill_of_material bom2
		left join packages pk ON bom2.component_product_id = pk.product_id
	where
		pk.serial_requirement IS NOT NULL
),
-------------------------
----gets employee data
employees as (
	select
		e.user_odoo13_id,
		INITCAP(e.employee_name) AS employee_name,
		e.employee_email,
		SUBSTRING(
			e."location",
			LENGTH(e."location") - POSITION('/' IN REVERSE(e."location")) + 2
		) AS tech_location
	from
		kenya.employee e
),
--------------------
-- gets all voluntary repos
voluntary_repo as (
	select
		s.account_id,
		s.current_contract_status,
		s.customer_product_status,
		s.cancellation_reason AS repo_reason,
		s.cancellation_date :: DATE,
		INITCAP(e.employee_name) AS employee_name,
		e.employee_email,
		e.tech_location,
		s.sale_id,
		listagg(distinct p.pakg_name, ', ') as packages ---- for individual packages uncomment the section below
		-- p.pakg_name
	from
		kenya.sales s
		left join kenya.customer c ON s.account_id = c.account_id
		left join products p ON s.product_id = p.pakg_product_id
		left join employees e ON s.cancelled_by = e.user_odoo13_id
	where
		p.serial_requirement = 'required'
		and c.current_customer_status not like 'repo'
		and s.cancellation_reason like 'default_resolution'
	group by
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9
),
---------------------------------
-- get all repossessions done
repo as (
	select
		r2.account_id,
		r2.repossession_status,
		r2.technician_id,
		r2.repossession_date
	from
		kenya.repossession r2
		left join kenya.customer c2 ON r2.account_id = c2.account_id
	where
		r2.repossession_status = 'done'
),
-------------------------
-- combined data from all the CTEs
pre_final_output as (
	select
		c.account_id,
		c.unique_account_id,
		c.customer_active_end_date :: DATE,
		date_trunc('MONTH', c.customer_active_end_date :: DATE) as repo_month,
		c.current_customer_status,
		r.repossession_date :: DATE,
		r.repossession_status,
		vr.repo_reason,
		t.username,
		t.technician_name,
		vr.employee_name AS voluntary_repo_tech,
		vr.employee_email AS voluntary_repo_tech_email,
		vr.tech_location,
		t.record_source,
		o.shop_name,
		o.shop_region,
		case
			when listagg(rrs.product_name, ', ') is null then vr.packages
			else listagg(rrs.product_name, ', ')
		end as packages ---- to get unaggregated list of packages, uncomment the next line of code
		--	    	case
		--	    		when rrs.product_name is null
		--	    		then vr.pakg_name as 
		--	    		else rrs.product_name
		--	    	end as individual_packages
	from
		kenya.customer c
		left join repo r on c.account_id = r.account_id
		left join voluntary_repo as vr on c.account_id = vr.account_id
		left join kenya.technician t on r.technician_id = t.technician_id
		left join shop_details as sd on c.account_id = sd.account_id
		left join kenya.organisation o on sd.organisation_id = o.organisation_id
		left join kenya.rp_retail_sales rrs on c.account_id = rrs.account_id
	where
		c.customer_active_end_date is not null
		and c.current_customer_status not like 'finished'
		and c.customer_active_end_date >= '2024-01-01'
	group by
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		vr.packages
),
-----------------------------
-- label repos as triggered, defaulted or defaulted repos
labeled_repos as (
	select
		*,
		case
			when current_customer_status = 'void'
			and repo_reason = 'default_resolution' then 'triggered_repo'
			when current_customer_status = 'void'
			and repo_reason isnull then 'other'
			when current_customer_status = 'repo'
			and repo_reason isnull then 'defaulted_repo'
		end as repo_check,
		case
			when technician_name isnull then voluntary_repo_tech
			else technician_name
		end as full_technician_column,
		case
			when shop_name isnull then tech_location
			else shop_name
		end as full_shop_name_column
	from
		pre_final_output
) -------------------
-- main query 
select
	*
from
	labeled_repos
where
	repo_check <> 'other'