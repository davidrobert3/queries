-- get customer details including the amount due
WITH sales_details AS 
(
SELECT
		s.unique_account_id ,
		s.contract_reference,
		s.product_id,
		s.billing_method_name,
		s.current_contract_status ,
		s.completion_date::DATE ,
		s.credit_price ,
		s.total_paid_to_date ,
		s.total_left_to_pay ,
		s.total_value ,
		s.total_due_to_date,
		case
			when (s.credit_price * ((datediff(days,s.installation_utc_timestamp::date,current_date))-s.downpayment_credit_amount)) + s.downpayment > s.total_value
				then s.total_value
		else (s.credit_price * ((datediff(days,s.installation_utc_timestamp::date,current_date))-s.downpayment_credit_amount)) + s.downpayment
		end as total_due,
		s.contract_length ,
		round((s.total_left_to_pay::float / s.credit_price::float),
	0) AS days_remaining_per_contract,
		round((s.total_paid_to_date::float / s.credit_price::float),
	0) AS days_paid
FROM
		kenya.sales s
WHERE
		s.credit_price !~~ 0
	AND s.current_contract_status NOT IN ('pending_fulfillment', 'submitted', 'repo')
),
-- count customer active contracts and current daily rate
count_active_contract AS
(
SELECT
		DISTINCT unique_account_id,
		count(*),
		sum(credit_price) AS daily_rate
FROM
		sales_details
WHERE
		current_contract_status ~~ 'active'
GROUP BY
		1
),
-- identify esf customers
esf_customers AS 
(
SELECT
		DISTINCT s.unique_account_id,
		'ESF-Customer' AS esf_check
FROM
		sales_details s
WHERE
		s.billing_method_name IN ('HPA - bPower20 ESF', 'HPA - bPower20 ESF v1', 'HPA - bPower50 (Aeris)', 'HPA - Energy Service Fee V0', 'HPA - ESF TV Sign up', 'HPA - ESF V1', 'HPA - ESF V2', 'HPA - Mdosi ESF', 'HPA - Mdosi TV ESF', 'HPA - Mdosi TV32 ESF', 'HPA - Mwanzo ESF') 
),
-- consolidate esf and non-esf customers and get their contract period
consolidate_with_non_esf AS 
(
SELECT
		DISTINCT details.unique_account_id,
		max(contract_length) OVER (PARTITION BY details.unique_account_id) AS contract_length,
		CASE
			WHEN esf_check ISNULL THEN 'Non-esf'
		ELSE 'ESF-Customer'
	END isESF
FROM
		sales_details details
LEFT JOIN esf_customers esf ON
		details.unique_account_id = esf.unique_account_id 
WHERE details.billing_method_name !~~ '%Maintenance%'
AND details.billing_method_name NOT ILIKE '%zuku%'
AND details.billing_method_name NOT ILIKE '%startime%'
AND details.billing_method_name NOT ILIKE '%Solar%'
AND details.billing_method_name NOT ILIKE '%panel%'
),
-- get customer tv type packages
customer_products AS
(
SELECT 
			DISTINCT s.unique_account_id ,
			bom2.component_name
FROM
	sales_details s
LEFT JOIN kenya.product p ON
			s.product_id = p.product_id
LEFT JOIN kenya.bill_of_material bom2 ON
			p.product_id = bom2.pakg_product_id
WHERE
	--s.unique_account_id = 'BXCK00025346'
	--and 
	s.billing_method_name ILIKE '%tv%'
	AND bom2.component_name NOT ILIKE '%aerial%'
	AND bom2.component_name ILIKE '%tv%'
	AND bom2.component_name NOT ILIKE '%zuku%'
	AND bom2.component_name NOT ILIKE '%startime%' 
),
-- calculate customer's days to go and contract peroid in years
 days_remaining_cte AS 
(
SELECT
		DISTINCT details.unique_account_id,
		ca.daily_rate,
		p.component_name,
		isESF,
		esf.contract_length/365.25 AS contract_length,
		CASE
			WHEN ROW_NUMBER() OVER (PARTITION BY details.unique_account_id ORDER BY days_remaining_per_contract DESC) = 2 AND isESF ~~ 'ESF-Customer' AND ca.count > 1
				THEN days_remaining_per_contract
		WHEN ROW_NUMBER() OVER (PARTITION BY details.unique_account_id ORDER BY days_remaining_per_contract DESC) = 1 AND isESF !~~ 'ESF-Customer' AND ca.count > 0
				THEN days_remaining_per_contract
		WHEN ca.count = 1 AND isESF ~~ 'ESF-Customer'
				THEN max(completion_date) OVER (PARTITION BY details.unique_account_id) - current_date
		WHEN ca.count = 0 OR ca.count ISNULL 
				THEN max(completion_date) OVER (PARTITION BY details.unique_account_id) - current_date
		END AS days_to_and_after_esf_or_completion,
		sum(total_paid_to_date) OVER (PARTITION BY details.unique_account_id) AS total_paid,
		sum(total_due_to_date) OVER (PARTITION BY details.unique_account_id) AS total_due_to_date,
		sum(total_due) OVER (PARTITION BY details.unique_account_id) AS total_due
	FROM
			sales_details details
	LEFT JOIN consolidate_with_non_esf esf ON
			esf.unique_account_id = details.unique_account_id
	LEFT JOIN count_active_contract ca ON
			ca.unique_account_id = details.unique_account_id
	LEFT JOIN customer_products p ON
			p.unique_account_id = details.unique_account_id
),
-- get customer lifetim ur
customer_lifetime_UR AS 
(
SELECT 
		DISTINCT dcs.payg_account_id,
		sum(CASE 
			WHEN dcs.payment_status ~~ 'normal'
				THEN 1
			ELSE 0
		END) AS days_normal,
		sum(CASE
			WHEN dcs.customer_status ~~ 'active'
				THEN 1
			ELSE 0
		END) AS days_active
FROM
	kenya.daily_customer_snapshot dcs
GROUP BY
	1
),
-- all data and create customer catergories based on age and cp
full_customer_details AS
(
SELECT
		DISTINCT dr.unique_account_id,
		cpd.customer_name ,
		c.current_customer_status ,
		cpd.customer_phone_1 ,
		cpd.customer_phone_2 ,
		look.current_hardware_type ,
		look.current_system ,
		look.tv_customer ,
		dr.component_name,
		cpd.home_address_2 ,
		cpd.home_address_3 ,
		cpd.home_address_4 ,
		cpd.home_address_5 ,
		cpd.customer_home_address ,
		look.shop ,
		dr.isESF,
		dr.daily_rate,
		dr.days_to_and_after_esf_or_completion,
		ur.days_normal::float / ur.days_active::float AS lifetime_ur,
		dr.total_paid,
		dr.total_due,
		dr.total_paid::float / 
		(CASE 
			WHEN ca.count notnull
				THEN dr.total_due::float
			ELSE dr.total_due::float
		END) AS performance,
	CASE
		WHEN isESF ~~ 'ESF-Customer'
			AND days_to_and_after_esf_or_completion <= 0 AND dr.daily_rate NOTNULL 
			THEN 'ESF Only(Huduma Only)'
			WHEN isESF !~~ 'ESF-Customer'
			AND days_to_and_after_esf_or_completion <= 0
			THEN 'Chapchap/21M/18M and Phones Completed'
		END AS already_finished_customers_catergory,
	CASE 
		WHEN dr.contract_length < 0.5 AND isESF !~~ 'ESF-Customer'
			THEN '1. Less than 0.5 Years'
		WHEN isESF !~~ 'ESF-Customer' AND dr.contract_length >= 0.5 AND dr.contract_length <= 1
			THEN '2. Between 0.5 and 1 Year'
		WHEN isESF !~~ 'ESF-Customer' AND dr.contract_length > 1 AND dr.contract_length <= 2
			THEN '3. Between 1 and 2 Years'
		WHEN isESF !~~ 'ESF-Customer' AND dr.contract_length > 2 AND dr.contract_length <= 3.5
			THEN '4. Between 2 and 3 Years'
		ELSE '5. More than 3 Years'
	END AS "Chapchap/21M/18M and Phones Completed pay plan",
	CASE
		WHEN days_to_and_after_esf_or_completion BETWEEN -30 AND 0
			THEN '1. Finished within last 4 weeks'
		WHEN days_to_and_after_esf_or_completion BETWEEN -60 AND -30
			THEN '2. Finished within last 8 weeks'
		WHEN days_to_and_after_esf_or_completion BETWEEN -90 AND -60
			THEN '3. Finished within last 3 months'
		WHEN days_to_and_after_esf_or_completion < -90
			THEN '4. Finished within more than 3 months ago'
		WHEN days_to_and_after_esf_or_completion BETWEEN 0 AND 30
			THEN '5. Finishing current month'
		WHEN days_to_and_after_esf_or_completion BETWEEN 30 AND 60
			THEN '6. Finishing in the next 4 - 8 weeks'
		WHEN days_to_and_after_esf_or_completion BETWEEN 60 AND 90
			THEN '7. Finishing within next 3 months'
		ELSE '8. More than 3 month to complete'
	END AS customer_age_catergory ,
	CASE 
		WHEN (dr.total_paid::float / dr.total_due::float) >= 0.9
			THEN '1. Above 90%'
		WHEN (dr.total_paid::float / dr.total_due::float) >= 0.8 AND (dr.total_paid::float / dr.total_due::float) < 0.9
			THEN '2. Between 80% and 90%'
		WHEN (dr.total_paid::float / dr.total_due::float) >= 0.7 AND (dr.total_paid::float / dr.total_due::float) < 0.8
			THEN '3. Between 70% and 80%'
		WHEN (dr.total_paid::float / dr.total_due::float) >= 0.5 AND (dr.total_paid::float / dr.total_due::float) < 0.7
			THEN '4. Between 50% and 70%'
		WHEN (dr.total_paid::float / dr.total_due::float) < 0.5
			THEN '5. Less than 50%'
	END AS performance_band
	FROM
		days_remaining_cte dr
	LEFT JOIN kenya.customer_personal_details cpd ON
			cpd.unique_account_id = dr.unique_account_id
	LEFT JOIN kenya.customer c ON 	
			c.account_id = cpd.account_id
	LEFT JOIN customer_lifetime_UR ur ON
			ur.payg_account_id = dr.unique_account_id
	LEFT JOIN kenya.rp_portfolio_customer_lookup look ON
			look.account_id = cpd.account_id
	LEFT JOIN count_active_contract ca ON
			ca.unique_account_id = dr.unique_account_id
	WHERE 
		dr.days_to_and_after_esf_or_completion NOTNULL
--		AND c.current_payment_status !~~ 'inactive'
--			and 
--			dr.unique_account_id = 'BXCK00136101'
)
SELECT 
	fc.*
FROM
	full_customer_details fc