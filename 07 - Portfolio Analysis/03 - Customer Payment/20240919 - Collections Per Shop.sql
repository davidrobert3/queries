-- get payments done by customers
WITH payment_details AS (
    SELECT 
        o.shop_name,
        c.account_id,
        c.unique_account_id,
        date_trunc('month', c.customer_active_start_date::DATE)::DATE as start_month ,
        date_trunc('month', p.payment_utc_timestamp::DATE)::DATE AS month_,
        date_diff(
            'day',
            date_trunc('month', p.payment_utc_timestamp::DATE) ,
            date_add('month',1,date_trunc('month', p.payment_utc_timestamp::DATE))
        ) AS number_of_days,
        SUM(p.amount) AS amount_paid
    FROM kenya.customer c
    LEFT JOIN kenya.organisation o ON 
        o.organisation_id = c.organisation_id 
    LEFT JOIN kenya.payment p ON 
        p.account_id = c.account_id 
        AND p.is_void = false 
        AND p.is_refunded = false
        AND p.payment_utc_timestamp::DATE >= '2024-01-01'
        and p.third_party_payment_ref_id not ilike 'BONUS%'
    GROUP BY 1, 2, 3, 4, 5, 6
),
--calculate day active and days normal
customer_days_active_and_normal as (
select 
	date_trunc('month', dcs.date_timestamp::DATE)::DATE month_ ,
	dcs.account_id ,
	sum(case 
		when dcs.payment_status = 'normal'
			then 1
		else 0
	end) as days_normal ,
	sum(case 
		when dcs.customer_status = 'active'
			then 1
		else 0
	end) as days_active
from kenya.daily_customer_snapshot dcs 
where dcs.date_timestamp::DATE >= '20240101'
group by 1,2
--limit 10
) 
	SELECT 
	    pd.month_,
	    pd.shop_name,
	    pd.unique_account_id,
	    s.account_id,
	    can.days_active,
	    can.days_normal,
	    pd.amount_paid ,
	    number_of_days ,
	    start_month ,
	    can.days_active * SUM(s.credit_price) as expected_amount,
	    SUM(s.credit_price) AS daily_rate
	FROM kenya.sales s
	LEFT JOIN payment_details pd ON
	    pd.account_id = s.account_id 
	left join customer_days_active_and_normal can on
		s.account_id = can.account_id
		and pd.month_ = can.month_
	WHERE s.action_date <= pd.month_
		and (s.completion_date::DATE > pd.month_ or s.cancellation_date::DATE > pd.month_ or s.completion_date isnull or s.cancellation_date isnull)
	GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
--	LIMIT 20