with tv_packages as
(
select
		distinct 
	        pakg_product_id as product_id,
		bom2.record_active_start_date::DATE as date_created,
		pakg_name ,
		component_name ,
		case
			when UPPER(pakg_name) like '%OPTIMI%'
	                then 'TV Sale'
		when UPPER(pakg_name) like '%DISCOUNTED%'
		or UPPER(pakg_name) like '%UPGRADE%'
		or UPPER(pakg_name) like '%AERIAL%'
	                then 'TV Upgrade'
		else 'TV Sale'
	end as Sale_Type,
		'Has TV' as tv_subtype
from
		kenya.bill_of_material bom2
where
		upper(bom2.component_name) like '%TV%'
	and upper(bom2.component_name) not like '%AERIAL%'
	and upper(bom2.component_name) not like '%ESF%'
	and upper(bom2.component_name) not like '%ZUKU%'
	and upper(bom2.component_name) not like '%REMOTE%'
),
tv_sales_and_upgrades_details as
(
select 
		s.account_id ,
		tp.sale_type ,
		tp.tv_subtype ,
		s.installation_utc_timestamp::DATE ,
		s.completion_date ::DATE ,
		s.cancellation_date ::DATE
from
	kenya.sales s
inner join tv_packages tp on
		tp.product_id = s.product_id
where s.installation_utc_timestamp::DATE notnull 
)
select
	distinct dcs.payg_account_id ,
	case
		when ts.tv_subtype is not null and ts.installation_utc_timestamp::DATE < dcs.date_timestamp::DATE
            then ts.tv_subtype
		else 'No TV'
	end as tv_flag ,
	case
		when ts.sale_type is not null and ts.installation_utc_timestamp::DATE < dcs.date_timestamp::DATE
            then ts.sale_type
		else 'Not a TV Upgrade'
	end as tv_sale_type
from
	kenya.daily_customer_snapshot dcs
left join tv_sales_and_upgrades_details ts on
	dcs.account_id = ts.account_id
where
	dcs.date_timestamp::DATE = '20240801'