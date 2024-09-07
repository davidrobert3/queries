with part1 as 
	(
		select
			c.unique_account_id,
			p.product_name,
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
				when (s.credit_price * ((datediff(days, s.installation_utc_timestamp::date, current_date))-s.downpayment_credit_amount)) + s.downpayment > s.total_value
					then s.total_value
				else (s.credit_price * ((datediff(days, s.installation_utc_timestamp::date, current_date))-s.downpayment_credit_amount)) + s.downpayment
			end as recalc_total_due --just in case there was any uncertainty around DWH version of total_due_to_date
		from
			kenya.sales s
		join kenya.customer c on
			s.account_id = c.account_id
		join kenya.product p on
			s.product_id = p.product_id
		where 
			s.current_contract_status not ilike 'pending fulfillment'
			and (s.billing_method_name not ilike '%flexx%' or s.billing_method_name not ilike '%taa imara%')
	),
	customer_contract_performance as 
	(
		select
			unique_account_id ,
			sum(total_paid_to_date)/ sum(total_due_to_date) as performance_band
		from
			part1
		group by unique_account_id
	),
	customer_details as
	(
		select 
			cp.*,
			pd.customer_name ,
			pd.customer_phone_1 ,
			pd.customer_phone_2 
		from customer_contract_performance cp
		left join kenya.customer_personal_details pd on
			cp.unique_account_id = pd.unique_account_id 
--		limit 5
	),
	customer_daily_rates as
	(
		select 
			distinct s.unique_account_id ,
			look.tv_customer ,
			sum(s.credit_price) as daily_rate
		from kenya.sales s 
		left join kenya.rp_portfolio_customer_lookup look on
			s.account_id = look.account_id 
		where 
			s.current_contract_status ilike 'active'
			and (s.billing_method_name not ilike '%flexx%' or s.billing_method_name not ilike '%taa imara%')
		group by 1, 2
--		limit 5
	)
	select 
		d.unique_account_id,
		d.customer_name ,
		d.customer_phone_1,
		d.customer_phone_2 ,
		cdr.tv_customer ,
		cdr.daily_rate ,
		d.performance_band
	from customer_details d
	left join customer_daily_rates cdr on
		d.unique_account_id = cdr.unique_account_id
	where 
		cdr.daily_rate <= 21
		and cdr.tv_customer not like 'Has TV'
--	limit 5