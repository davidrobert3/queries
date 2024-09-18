with portfolio_size as (
select
	o.shop_name,
	COUNT(dcs.account_id) as portfolio_size_
from
	kenya.daily_customer_snapshot dcs
left join
        kenya.organisation o on
	dcs.organisation_id = o.organisation_id
where
	dcs.customer_status = 'active'
	and dcs.date_timestamp::DATE = '20240817'
group by
	o.shop_name
),
region_assignment as (
select
	ps.*,
	case
		when ps.portfolio_size_ > 3000 then 'Over 3,000'
		when ps.portfolio_size_::int between 2001 and 3000 then '2,001 to 3,000'
		else '2,000 and below'
	end as Portfolio_Size_Category,
	case
		when ps.shop_name in ('Nakuru', 'Kabarnet', 'Isiolo', 'Muranga') then 'Central'
		when ps.shop_name in ('Kwale', 'Hola', 'Kilifi', 'Malindi') then 'Coast'
		when ps.shop_name in ('Kibwezi', 'Voi', 'Oloitoktok', 'Wote') then 'Eastern 1'
		when ps.shop_name in ('Tharaka Nithi', 'Matuu', 'Kitui', 'Machakos', 'Kajiado') then 'Eastern 2'
		when ps.shop_name in ('Kakuma', 'Kitale', 'Eldoret', 'Kipkaren', 'Kapsabet', 'Kapenguria') then 'North Rift'
		when ps.shop_name in ('Mbita', 'Homa Bay', 'Magunga', 'Kendu Bay') then 'Nyanza 1'
		when ps.shop_name in ('Rongo', 'Ndhiwa', 'Migori') then 'Nyanza 2'
		when ps.shop_name in ('Katito', 'Kipsitet', 'Oyugis', 'Chepseon') then 'South Rift 1'
		when ps.shop_name in ('Narok', 'Bomet', 'Nyangusu') then 'South Rift 2'
		when ps.shop_name in ('Butere', 'Bungoma', 'Luanda', 'Kakamega') then 'Western 1'
		when ps.shop_name in ('Bumala', 'Bondo', 'Busia', 'Siaya') then 'Western 2'
	end as new_region
from
	portfolio_size ps
)
select
	*
from
	region_assignment;
