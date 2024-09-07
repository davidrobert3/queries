with list_of_table as (
select 'kenya.daily_customer_snapshot' as "DB Table", max(dcs.date_timestamp::DATE) as "Last Refresh Date"
from kenya.daily_customer_snapshot dcs group by	1
union all
select 'kenya.customer' as "DB Table", max(c.customer_active_start_date::DATE) as "Last Refresh Date"
from kenya.customer c
group by 1
union all
select 'kenya.sales' as "DB Table",	max(s.signup_utc_timestamp::DATE) as "Last Refresh Date"
from kenya.sales s
group by 1
union all
select 'kenya.rp_portfolio_customer_lookup' as "DB Table", max(look.down_payment_date::DATE) as "Last Refresh Date"
from kenya.rp_portfolio_customer_lookup look
group by 1
union all
select 'kenya.rp_retail_sales' as "DB Table", max(rrs.downpayment_date::DATE) as "Last Refresh Date"
from kenya.rp_retail_sales rrs
group by 1
union all
select 'kenya.payments' as "DB Table", max(p.payment_utc_timestamp::DATE) as "Last Refresh Date"
from kenya.payment p 
group by 1
)
select
	*,
	case when "DB Table" like 'kenya.daily_customer_snapshot' and "Last Refresh Date" <> current_date then false
		when "DB Table" not like 'kenya.daily_customer_snapshot' and "Last Refresh Date" <> current_date - 1 then false
		else true end as "isRefreshed"
from list_of_table lt
order by 1 desc