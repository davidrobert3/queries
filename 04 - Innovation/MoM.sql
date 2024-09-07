with startime as (
select
	rrs.account_id as rrsAccountID,
	--	c.unique_account_id ,
	rrs.product_name,
	rrs.unique_account_id,
	rrs.downpayment_date as pkgDownpaymentDate,
	case
		when
	rrs.downpayment_date::DATE between c.customer_active_start_date::DATE and current_date 
	then
	rrs.total_downpayment
		else null
	end as totalDownpayment,
	case
		when 
	rrs.downpayment_date::DATE between c.customer_active_start_date::DATE and current_date
	then
	rrs.downpayment_date::DATE
		else null
	end as downpaymentDate
	,
	round(
            (
                (sum(dcs.daily_rate)) /(
                    datediff(
                        day,
	c.customer_active_start_date::DATE,
	current_date
                    )
                )
            ),
	0
        ) as avgDR,
	datediff(day,
	c.customer_active_start_date::DATE,
	current_date) as days	
from
	kenya.daily_customer_snapshot dcs
left join kenya.rp_retail_sales rrs on
	dcs.account_id = rrs.account_id
left join kenya.customer c on
	dcs.account_id = c.account_id
where
	(
            lower(rrs.product_name) like '%zuku%'
		or lower(rrs.product_name) like '%startime%'
        )
	and dcs.date_timestamp::DATE >= c.customer_active_start_date::DATE
--	and rrs.unique_account_id = 'BXCK68160167'
group by
	1,
	2,
	3,
	4,
	5,
	rrs.downpayment_date,c.customer_active_start_date::DATE
),
customers as (
select
	c.unique_account_id,
	c.account_id,
	cpd.customer_name,
	o.shop_name,
	c.customer_active_start_date
from
	kenya.customer c
left join kenya.customer_personal_details cpd on
	c.account_id = cpd.account_id
left join kenya.organisation o on
	c.organisation_id = o.organisation_id
	-- limit 1;
),
downpayment as (
select
	rrs2.account_id,
	rrs2.unique_account_id,
	rrs2.downpayment_paid_utc_timestamp::DATE,
	c2.current_customer_status,
	sum(rrs2.total_downpayment) as totalDownpaymentPaid,
	sum(rrs2.total_downpayment) over (partition by rrs2.account_id) as totalDownpaymentPaid2
from
	kenya.rp_retail_sales rrs2
	left join kenya.customer c2 on
	rrs2.account_id = c2.customer_active_start_date::DATE
--where
	--	rrs2.account_id = 'd1b0fc4cc136f238bdea702cb10e0154'
	--	and 
--	rrs2.downpayment_paid_utc_timestamp::DATE >= c2.customer_active_start_date::DATE
group by
	1,c2.current_customer_status,rrs2.total_downpayment,
	2,
	3
)
select
--	to_char(p.payment_utc_timestamp,
--	'Mon-YYYY'),
	downpayment.current_customer_status,
	customer.current_customer_status ,
	startime.pkgDownpaymentDate,
	downpayment.downpayment_paid_utc_timestamp::DATE,
	customers.unique_account_id,
	customers.customer_name,
	downpayment.totalDownpaymentPaid2 ,
	downpayment.current_customer_status ,
	customers.shop_name,
	startime.totalDownpayment,
	startime.product_name,
	downpayment.totalDownpaymentPaid,
	(
        (
            sum(p.amount)
        ) /(startime.avgDR * startime.days)
    ) as cp,
	--	p.account_id,
	sum(p.amount) as totalPaid,
	(startime.avgDR * startime.days) as expectedAmount
from
	startime
left join customers on
	startime.rrsAccountID = customers.account_id
left join kenya.payment p on
	startime.rrsAccountID = p.account_id
left join downpayment on
	customers.account_id = downpayment.account_id
left join kenya.customer on
		rrsAccountID = customer.account_id 
where
	p.payment_utc_timestamp::DATE >= customers.customer_active_start_date::DATE
	and lower(p.processing_status) = 'posted'
group by
	1,
	2,
	customers.unique_account_id,
	customer.current_customer_status ,
	--	customers.account_id,
	customers.customer_name,
	startime.pkgDownpaymentDate,
	downpayment.downpayment_paid_utc_timestamp::DATE,
	startime.unique_account_id,
	startime.downpaymentDate,
	startime.rrsAccountID,
	startime.product_name,
	startime.totalDownpayment,
	downpayment.current_customer_status,
	downpayment.totalDownpaymentPaid2 ,
	downpayment.current_customer_status ,
	startime.avgDR,
	startime.days,
	p.account_id,
	customers.shop_name,
	customers.customer_active_start_date,
	downpayment.totalDownpaymentPaid,
	downpayment.account_id,
	downpayment.unique_account_id,
	downpayment.totalDownpaymentPaid
	-- limit 2;