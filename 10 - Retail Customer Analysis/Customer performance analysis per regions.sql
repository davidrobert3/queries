with part1 as (
select
	c.unique_account_id,
	p.product_name,
	p.category5,
	s.total_paid_to_date,
	s.total_value,
	s.total_due_to_date,
	s.credit_price,
	s.installation_utc_timestamp::date,
	datediff(day,
	s.installation_utc_timestamp::date,
	current_date) as days_active,
	s.downpayment,
	s.downpayment_credit_amount,
	case
		when 
                (s.credit_price * ((datediff(days,
		s.installation_utc_timestamp::date,
		current_date))- s.downpayment_credit_amount)) + s.downpayment > s.total_value
                then s.total_value
		else (s.credit_price * ((datediff(days,
		s.installation_utc_timestamp::date,
		current_date))- s.downpayment_credit_amount)) + s.downpayment
	end as recalc_total_due
	--just in case there was any uncertainty around DWH version of total_due_to_date
from
	kenya.sales s
join kenya.customer c on
	s.account_id = c.account_id
join kenya.product p on
	s.product_id = p.product_id
where
	c.customer_active_end_date is null
	-- and c.unique_account_id ='BXCK24400157'
),
customer_performance as 
(
	select 
		distinct c.unique_account_id ,
		cpd.customer_name ,
		cpd.customer_phone_1 ,
		cpd.customer_phone_2 ,
		cpd.home_address_2 ,
		cpd.home_address_3 ,
		cpd.home_address_4 ,
		cpd.home_address_5 ,
		cpd.customer_home_address ,
		o.shop_name as shop ,
		rpcl.tv_customer,
		sum(p.total_paid_to_date)/sum(p.total_due_to_date) as performance_band
	from kenya.customer c
		left join kenya.customer_personal_details cpd on
			cpd.unique_account_id = c.unique_account_id 
		left join kenya.organisation o on 
			o.organisation_id = c.organisation_id 
		left join part1 p on 
			p.unique_account_id = c.unique_account_id 
		left join kenya.rp_portfolio_customer_lookup rpcl on 
			rpcl.account_id = c.account_id
	where c.current_customer_status ilike 'active'
	group by 1,2,3,4,5,6,7,8,9,10,11
),
region_assignment as 
    (
        select 
            customer_performance.*,
            case
                when customer_performance.shop in ('Nakuru', 'Kabarnet', 'Isiolo', 'Muranga')
                    then 'Central'
                when customer_performance.shop in ('Kwale', 'Hola', 'Kilifi', 'Malindi')
                    then 'Coast'
                when customer_performance.shop in ('Kibwezi',    'Voi',  'Oloitoktok',   'Wote')
                    then 'Eastern 1'
                when customer_performance.shop in ('Tharaka Nithi',  'Matuu',    'Kitui',    'Machakos', 'Kajiado')
                    then 'Eastern 2'
                when customer_performance.shop in ('Kakuma', 'Kitale',   'Eldoret',  'Kipkaren', 'Kapsabet', 'Kapenguria')
                    then 'North Rift'
                when customer_performance.shop in ('Mbita',  'Homa Bay', 'Magunga',  'Kendu Bay')
                    then 'Nyanza 1'
                when customer_performance.shop in ('Rongo',  'Ndhiwa',   'Migori')
                    then 'Nyanza 2'
                when customer_performance.shop in ('Katito', 'Kipsitet', 'Oyugis',   'Chepseon')
                    then 'South Rift 1'
                when customer_performance.shop in ('Narok',  'Bomet',    'Nyangusu')
                    then 'South Rift 2'
                when customer_performance.shop in ('Butere', 'Bungoma',  'Luanda',   'Kakamega')
                    then 'Western 1'
                when customer_performance.shop in ('Bumala', 'Bondo',    'Busia',    'Siaya')
                    then 'Western 2'
            end as new_region
        from customer_performance
    )
    select *
    from region_assignment r
    where r.new_region ilike 'north rift'