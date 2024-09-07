with customer_details as 
(
	select 
		dcs.date_timestamp::DATE,
		dcs.payg_account_id ,
		cpd.customer_name ,
		cpd.customer_phone_1 ,
		cpd.customer_phone_2 ,
		dcs.payment_status ,
		dcs.daily_rate ,
		dcs.total_paid_to_date ,
		dcs.total_left_to_pay ,
		datediff(month, c.customer_active_start_date::DATE, current_date) as customer_age ,
		listagg(p.product_name, ', ') as customer_products ,
		o.shop_name ,
		look.tv_customer ,
		look.current_system ,
		case 
			when look.tv_customer ilike 'has tv' and (bom2.component_name  ilike '24%TV%' or bom2.component_name ilike '%24%TV%'or bom2.component_name ilike '%TV%24%')
					then '24" TV'
			when look.tv_customer ilike 'has tv' and  (bom2.component_name  ilike '32%TV%' or bom2.component_name ilike '%32%TV%'or bom2.component_name ilike '%TV%32%')
				then '32" TV'
			when look.tv_customer ilike 'has tv'
				then 'Other TVs'
			when look.current_system ilike '%offline_token%' and look.tv_customer ilike 'no tv'
				then 'Flexx40'
			when look.current_system ilike '%bpower20%' and look.tv_customer ilike 'no tv'
				then 'bPower20'
			when look.current_system ilike '%bpower50%' and look.tv_customer ilike 'no tv'
				then 'bPower50'
			when look.current_system in ('nuovopay', 'paytrigger') and look.tv_customer ilike 'no tv'
				then 'Connect'
		end as Category ,		
		ROUND(RAND() * 1000000, 0) as index_ 
	from kenya.daily_customer_snapshot dcs 
	left join kenya.customer c on
		c.account_id = dcs.account_id 
	left join kenya.sales s on
		s.account_id = c.account_id 
	left join kenya.organisation o on 
		o.organisation_id = dcs.organisation_id 
	left join kenya.customer_personal_details cpd on 
		cpd.account_id = dcs.account_id 
	left join kenya.rp_portfolio_customer_lookup as look on
		dcs.account_id = look.account_id
	left join kenya.product p on
		s.product_id = p.product_id 
		and p.product_type not like 'appliance'
	left join kenya.bill_of_material bom2 on
		p.product_id = bom2.pakg_product_id
		and bom2.component_name ilike '%tv%'
		and bom2.component_name not like '%Aerial%'
	where
		dcs.date_timestamp::DATE = current_date
		and c.current_customer_status ilike 'active'
	group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15
--	limit 5
),
customer_tv_check as
(
	select *
	from customer_details
	where customer_details.category notnull 
	and category not like 'Other TVs'
	--limit 500
)
select *
from customer_tv_check

































select *
from kenya.sales s 
left join kenya.product p on
	s.product_id = p.product_id 
where s.unique_account_id = 'BXCK36560204'

select
distinct bom2.pakg_name ,
bom2.pakg_product_id  ,
case
	when bom2.component_name  ilike '32%TV%' or bom2.component_name ilike '%32%TV%'or bom2.component_name ilike '%TV%32%'
		then '32" TV'
	when bom2.component_name  ilike '24%TV%' or bom2.component_name ilike '%24%TV%'or bom2.component_name ilike '%TV%24%'
		then '24" TV'
	else 'Other TVs'
end as tv_subtype 
from kenya.product p
left join kenya.bill_of_material bom2 on
	p.product_id = bom2.pakg_product_id 
where p.product_type not like 'appliance'
and p.tv_subtype like 'TV'
and bom2.component_name ilike '%tv%'
and bom2.component_name not like '%Aerial%'
--and p.product_name ilike 'TV 24'' with Aerial'
limit 10000

select *
from kenya.bill_of_material bom2 
where bom2.pakg_product_id like 'dcf8e056844cde2df669ce9efd2dde2d'