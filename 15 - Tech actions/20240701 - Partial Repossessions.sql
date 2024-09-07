with shop_details as (
select
	dcs.payg_account_id,
	dcs.account_id,
	dcs.organisation_id,
	MAX(dcs.date_timestamp::DATE) as date
from
	kenya.daily_customer_snapshot dcs
where
	dcs.organisation_id is not null
group by
	1,
	2,
	3
),
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
products as (
select
	bom2.pakg_product_id,
	bom2.component_product_id,
	bom2.pakg_name,
	pk.*
from
	kenya.bill_of_material bom2
left join packages pk on
	bom2.component_product_id = pk.product_id
where
	pk.serial_requirement is not null
),
employees as (
select
	e.user_odoo13_id,
	INITCAP(e.employee_name) as employee_name,
	e.employee_email,
	SUBSTRING(e."location",
	LENGTH(e."location") - position('/' in REVERSE(e."location")) + 2) as tech_location
from
	kenya.employee e
),
voluntary_repo as (
select
	s.account_id,
	s.current_contract_status,
	s.customer_product_status,
	s.cancellation_reason as repo_reason,
	s.cancellation_date::DATE,
	INITCAP(e.employee_name) as employee_name,
	e.employee_email,
	e.tech_location
from
	kenya.sales s
left join kenya.customer c on
	s.account_id = c.account_id
left join products p on
	s.product_id = p.pakg_product_id
left join employees e on
	s.cancelled_by = e.user_odoo13_id
where
	p.serial_requirement = 'required'
	and c.current_customer_status not like 'repo'
	and s.cancellation_reason like 'default_resolution'
),
repo as (
select
	r2.account_id,
	r2.repossession_status,
	r2.technician_id,
	r2.repossession_date
from
	kenya.repossession r2
left join kenya.customer c2 on
	r2.account_id = c2.account_id
where
	r2.repossession_status = 'done'
),
pre_final_output as (
select
	c.account_id,
	c.unique_account_id,
	c.customer_active_end_date::DATE,
	date_trunc('MONTH',
	c.customer_active_end_date::DATE) as repo_month,
	c.current_customer_status,
	r.repossession_date::DATE,
	r.repossession_status,
	vr.repo_reason,
	t.username,
	t.technician_name,
	vr.employee_name as voluntary_repo_tech,
	vr.employee_email as voluntary_repo_tech_email,
	vr.tech_location,
	t.record_source,
	o.shop_name,
	o.shop_region
from
	kenya.customer c
left join repo r on
	c.account_id = r.account_id
left join voluntary_repo as vr on
	c.account_id = vr.account_id
left join kenya.technician t on
	r.technician_id = t.technician_id
left join shop_details as sd on
	c.account_id = sd.account_id
left join kenya.organisation o on
	sd.organisation_id = o.organisation_id
where
	c.customer_active_end_date is not null
	and c.current_customer_status not like 'finished'
	and c.customer_active_end_date >= '2024-01-01'
),
-----------------------------------
-- product recovery
product_recovery as
(
select 
		so.payg_account_id ,
		sm.product_name,
		sm.product_qty ,
		sm.state ,
		sm.date_done ,
		( sl.hier1_name || '/ ' || sl.hier2_name || '/ ' || sl.hier3_name || '/ ' || sl.hier4_name) as stock_location,
		case
			when sl.hier4_name = 'Returned'
				then 'Recovered'
		else 'Lost'
	end as isRecovered
from
	kenya.stock_moves sm
left join src_odoo13_kenya.stock_picking sp on
	sm.stock_picking_id = sp.id
left join src_odoo13_kenya.sale_order so on 
	sp.sale_id = so.id
left join kenya.stock_location sl on 
	sm.stock_dest_location_id = sl.stock_location_id
where
	sm.delivery_type in ('repossession_returned', 'repossession_lost', 'contract_cancellation_returned', 'contract_cancellation_lost')
),
 labeled_repos as (
select
	pre_final_output.*,
	product_recovery.product_name,
	product_recovery.product_qty ,
	product_recovery.isrecovered ,
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
			when shop_name isnull 
            then tech_location
			else shop_name
		end as full_shop_name_column
	from
		pre_final_output
	left join product_recovery on
		product_recovery.payg_account_id = pre_final_output.unique_account_id
)
 select
	*
from
	labeled_repos
where
	repo_check <> 'other'
--	limit 5