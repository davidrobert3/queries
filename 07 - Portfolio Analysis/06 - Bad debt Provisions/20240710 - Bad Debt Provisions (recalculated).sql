

-- get customer snapshot data as of a point in time and total due at
WITH customer_snap AS 
(
	SELECT 
		dcs.date_timestamp::DATE,
		dcs.account_id ,
		dcs.payg_account_id ,
		round(dcs.total_paid_to_date,0) AS total_paid_to_date ,
		dcs.consecutive_late_days ,
		dcs.total_due_to_date 
	FROM kenya.daily_customer_snapshot dcs 
	WHERE dcs.date_timestamp::DATE = current_date -- Enter the SNAPSHOT date
	--AND dcs.payg_account_id = 'BXCK64543366' --'BXCK25646365'
),
total_paid AS 
(
	SELECT 
		p.account_id ,
		round(sum(amount),0) AS total_amount_paid
	FROM kenya.payment p 
	LEFT JOIN customer_snap snap ON
		p.account_id = snap.account_id
	WHERE
	p.is_void IS FALSE 
	AND p.is_bonus IS FALSE 
	AND p.is_refunded IS FALSE 
	AND p.payment_utc_timestamp::DATE < snap.date_timestamp
	GROUP BY 1
),
sales_details as
(
	SELECT 
			c.date_timestamp::DATE,
			s.account_id ,
			unique_account_id ,
			contract_reference ,
			billing_method_name ,
			contract_length ,
			customer_product_status ,
			credit_price ,
			s.total_paid_to_date ,
			total_value ,
			downpayment ,
			instalment ,
			downpayment_credit_amount ,
			installation_utc_timestamp::DATE,
			CASE 
				WHEN completion_date NOTNULL 
					THEN completion_date::DATE
				WHEN cancellation_date NOTNULL 
					THEN cancellation_date::DATE
				WHEN repossession_utc_timestamp NOTNULL	
					THEN repossession_utc_timestamp::DATE
				ELSE NULL 
			END AS finish_date,
			CASE 
				WHEN completion_date NOTNULL 
					THEN datediff('days', installation_utc_timestamp::DATE, completion_date::DATE)
				WHEN cancellation_date NOTNULL 
					THEN datediff('days', installation_utc_timestamp::DATE, cancellation_date::DATE)
				WHEN repossession_utc_timestamp NOTNULL	
					THEN datediff('days', installation_utc_timestamp::DATE, repossession_utc_timestamp ::DATE)
				ELSE NULL 
			END AS days_taken,
			datediff('days', installation_utc_timestamp::DATE, date_timestamp::DATE) - downpayment_credit_amount AS days_since_installation ,
			CASE 
				WHEN (datediff('days', installation_utc_timestamp::DATE, date_timestamp::DATE)::float + downpayment_credit_amount) * credit_price::float >= total_value
					THEN total_value 
				ELSE (datediff('days', installation_utc_timestamp::DATE, date_timestamp::DATE)::float - downpayment_credit_amount) * credit_price::float
			END AS expected
		FROM kenya.sales s 
		RIGHT JOIN customer_snap c ON
			s.unique_account_id = c.payg_account_id
),
active_contracts AS 
(
SELECT 
	details.unique_account_id,
	details.contract_reference,
	details.days_taken,
	details.total_value,
	total_paid_to_date,
	details.expected + downpayment AS total_due_
FROM sales_details details
WHERE finish_date > date_timestamp OR finish_date ISNULL
),
completed_and_voided_contracts as
(
	SELECT 
		details.unique_account_id,
		details.contract_reference,
		details.days_taken,
		details.total_value,
		total_paid_to_date,
		CASE
			WHEN details.customer_product_status = 'completed'
				THEN 0--details.total_value
			ELSE ((days_taken - downpayment_credit_amount) * credit_price)+downpayment
		END AS total_due_
	FROM sales_details details
	WHERE finish_date < date_timestamp
),
union_active_and_finished_contracts as
(
	SELECT 
		*
	FROM 
		active_contracts
	UNION ALL
	SELECT 
		*
	FROM 
		completed_and_voided_contracts
),
calculated_total_due AS 
(
	SELECT
		DISTINCT unique_account_id,
		sum(total_paid_to_date) AS calculated_total_paid ,
		sum(total_value) AS contract_value,
		sum(total_due_) AS calculated_total_due
	FROM union_active_and_finished_contracts
	GROUP BY 1
)--,
--consolidated_cte as
--(
SELECT 
--	snap.date_timestamp::DATE,
	due.unique_account_id,
	snap.consecutive_late_days,
	due.contract_value,
	snap.total_paid_to_date,
	paid.total_amount_paid,
	due.calculated_total_paid,
	snap.total_due_to_date,
	due.calculated_total_due
FROM calculated_total_due due
LEFT JOIN customer_snap snap ON
	snap.payg_account_id = due.unique_account_id
LEFT JOIN total_paid paid ON
	paid.account_id = snap.account_id
--)
--select 
--	dcs.date_timestamp::DATE as "Activity Month",
--	count(distinct dcs.unique_account_id) as "Portfolio Size" ,
--	case 
--		when dcs.consecutive_late_days <= 0
--			then '0. PAR_0 (Not PAR)'
--		when dcs.consecutive_late_days >= 1
--			and dcs.consecutive_late_days <= 30
--			then '1. PAR 1 to 30 days'
--		when dcs.consecutive_late_days >= 31
--			and dcs.consecutive_late_days <= 60
--			then '2. PAR 31 to 60 days'
--		when dcs.consecutive_late_days >= 61
--			and dcs.consecutive_late_days <= 90
--			then '3. PAR 61 to 90 days'
--		when dcs.consecutive_late_days >= 91
--			and dcs.consecutive_late_days <= 120
--			then '4. PAR 91 to 120 days'
--		else '5. PAR >120 days'
--	end as "PAR Category",
--	round(sum(calculated_total_due),0) as "Total Period Invoices (KES)",
--	round(sum(total_due_to_date),0) as "Total Period Invoices (KES)",
--	round(sum(dcs.total_amount_paid*-1),0) as "Total Paid To-Date (KES)",
--	round(sum(dcs.calculated_total_due - dcs.total_amount_paid),0) as "Total Period Balance (KES)" ,
--	round(sum(dcs.total_due_to_date - dcs.total_amount_paid),0) as "Total Period Balance (KES)" 
--from consolidated_cte dcs 
--group by 
--"Activity Month",
--"PAR Category"
--order by "PAR Category" asc 