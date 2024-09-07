with customers as (
	select c.unique_account_id,
		c.account_id,
		cpd.customer_name,
		o.shop_name,
		c.customer_active_start_date
	from kenya.customer c
		left join kenya.customer_personal_details cpd on c.account_id = cpd.account_id
		left join kenya.organisation o on c.organisation_id = o.organisation_id -- limit 1;
),
startime as (
	select rrs.account_id as rrsAccountID,
		rrs.product_name,
		rrs.unique_account_id,
		SUM(DISTINCT(rrs.total_downpayment)) AS totalDownpayment,
		rrs.downpayment_date AS downpayment_date,
		dcs.account_id,
		round(
			(
				(sum(dcs.daily_rate)) /(
					datediff(
						day,
						c2.customer_active_start_date::DATE,
						current_date
					)
				)
			),
			0
		) as avgDR,
		datediff(
			day,
			c2.customer_active_start_date::DATE,
			current_date
		) as days
	from kenya.daily_customer_snapshot dcs
		left join kenya.rp_retail_sales rrs on dcs.account_id = rrs.account_id
		left join kenya.customer c2 on dcs.account_id = c2.account_id
	WHERE -- rrs.account_id = '765957ffce4490bb750d5e4a891796b6'
		-- and 
		(
			lower(rrs.product_name) like '%zuku%'
			or lower(rrs.product_name) like '%startime%'
		)
		and dcs.date_timestamp::DATE >= c2.customer_active_start_date
	GROUP BY 1,
		2,
		3,
		5,
		6,
		c2.customer_active_start_date
		-- limit 1;
),
downpayment as (
	select rrs2.account_id,
		rrs2.unique_account_id,
		sum(rrs2.total_downpayment) as totalDownpaymentPaid
	from kenya.rp_retail_sales rrs2
	group by 1,
		2 -- limit 1
)
select 
	-- to_char(p.payment_utc_timestamp, 'Mon-YYYY'),
	customers.unique_account_id,
	customers.customer_name,
	customers.shop_name,
	startime.totalDownpayment,
	startime.product_name,
	downpayment.totalDownpaymentPaid,
	(
		(
			sum(p.amount) - downpayment.totalDownpaymentPaid
		) /(startime.avgDR * startime.days)
	) as cp,
	-- p.account_id,
	sum(p.amount) as totalPaid
from startime
	left join customers on startime.account_id = customers.account_id
	left join kenya.payment p on startime.account_id = p.account_id
	left join downpayment on customers.account_id = downpayment.account_id
where p.payment_utc_timestamp::DATE >= customers.customer_active_start_date
	and lower(p.processing_status) = 'posted'
group by 1,
	customers.unique_account_id,
	customers.account_id,
	customers.customer_name,
	startime.account_id,
	startime.unique_account_id,
	startime.downpayment_date,
	startime.rrsAccountID,
	startime.product_name,
	startime.totalDownpayment,
	startime.avgDR,
	startime.days,
	p.account_id,
	customers.shop_name,
	customers.customer_active_start_date,
	downpayment.totalDownpaymentPaid,
	downpayment.account_id,
	downpayment.unique_account_id,
	downpayment.totalDownpaymentPaid