WITH customer_phones AS 
(
SELECT 
	DISTINCT unique_customer_id ,
	phone_1 ,
	phone_2 ,
	substring(string_agg(DISTINCT alt_phone::TEXT, ', '),0,13) AS alternative
FROM cscc_customer_phone ccp 
LEFT JOIN cscc_customer_alt_phones ccap ON
	ccp.unique_customer_id = ccap.payg_account_id
WHERE ccp.unique_customer_id IN (SELECT unique_account_id
FROM cscc_call_list ccl 
WHERE month_ = 10 )
GROUP BY 1,2,3
),
customer_par as
(
	SELECT 
		cp.*,
		ccl.par_bucket
	FROM customer_phones cp
	left JOIN cscc_call_list ccl ON
		cp.unique_customer_id = ccl.unique_account_id
	WHERE month_ = 10
),
-----------------------------------------------------
-- 1. get all calls made to customers by the collections team.
------------------------------------------------------------
call_log_data AS (
	SELECT
		call_time :: DATE,
		caller_id,
		destination,
		status,
		talking,
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id :: TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id :: TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		SUBSTRING(STRING_AGG(ccp3.unique_customer_id, ', '), 0, 13) AS unique_customer_id_3,
		ccp.par_bucket AS par_bucket_1 ,
		ccp2.par_bucket AS par_bucket_2,
		ccp3.par_bucket AS par_bucket_3
	FROM
		cscc_3cx_daily_report ccdr
		LEFT JOIN customer_par ccp ON ccdr.destination = ccp.phone_1 :: TEXT
		LEFT JOIN customer_par ccp2 ON ccdr.destination = ccp2.phone_2 :: TEXT
		LEFT JOIN customer_par ccp3 ON ccdr.destination = ccp3.alternative :: TEXT
	WHERE
		caller_id IN (
			'Alfrick Ondoo (165)',
			'Ben Odero (116)',
			'Beverlyn Omollo (149)',
			'Brian Kandagor (139)',
			'Brian Kirui (105)',
			'Brian Nyamumbo (115)',
			'Catherine Musyoki (114)',
			'Denis Shikanga (123)',
			'Dennis Omondi (119)',
			'Elizabeth Odera(029)',
			'Elizabeth Winyo(162)',
			'Erick Wafula (154)',
			'Fredrick Otieno (152)',
			'George Odhiambo (140)',
			'Gwen Macharia (129)',
			'Immaculate Okuom (151)',
			'Jackline Koech (109)',
			'Jacob Akach (156)',
			'Jonathan Baraza (120)',
			'Joseph Wambua (157)',
			'Kevin Biaraga (148)',
			'Kevin Ondiek (102)',
			'Martin Samson (147)',
			'Maxwel Odongo (117)',
			'Milka Abich (127)',
			'Mwongela Katiwa (124)',
			'Naserian Musere (126)',
			'Nixon Sang (155)',
			'Queenter Okumu (150)',
			'Sharon Odhiambo (121)',
			'Susan Rotich (125)',
			'Victor Ogolla (153)'
		)
		AND talking >= '00:00:15'
		AND call_time :: DATE >= '2024-10-01'
		AND call_time :: DATE <= '2024-10-31'
	GROUP BY
		1,
		2,
		3,
		4,
		5,
		ccp.par_bucket,
		ccp2.par_bucket,
		ccp3.par_bucket		
),
consolidated_customer_bxck as (
	SELECT
		call_time :: DATE,
		caller_id,
		destination,
		talking,
		CASE
			WHEN unique_customer_id_1 NOTNULL THEN unique_customer_id_1
			WHEN unique_customer_id_1 ISNULL
			AND unique_customer_id_2 NOTNULL THEN unique_customer_id_2
			WHEN unique_customer_id_1 ISNULL AND unique_customer_id_2 ISNULL 
			AND unique_customer_id_3 NOTNULL THEN unique_customer_id_3
		END AS customer_bxck,
		CASE
			WHEN par_bucket_1 NOTNULL THEN par_bucket_1
			WHEN par_bucket_1 ISNULL
			AND par_bucket_2 NOTNULL THEN par_bucket_2
			WHEN par_bucket_1 ISNULL AND par_bucket_2 ISNULL 
			AND par_bucket_3 NOTNULL THEN par_bucket_3
		END AS par_bucket
	FROM
		call_log_data		
),
calls_per_day as (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY caller_id,
			customer_bxck,
			call_time :: DATE
		) AS call_number
	FROM
		consolidated_customer_bxck c
	WHERE
		c.customer_bxck NOTNULL
),
payments AS (
	SELECT
		payg_account_id,
		payment_date :: DATE AS payment_date,
		sum AS Amount_Paid
	FROM
		cscc_collection_payments ccp
),
main_query as (
	SELECT
		DISTINCT caller_id || customer_bxck || payment_date AS index_,
		caller_id,c.call_time,
		customer_bxck,
		par_bucket ,
		p.payment_date,
		p.amount_paid
	FROM
		calls_per_day c
		LEFT JOIN payments p ON c.customer_bxck = p.payg_account_id
	WHERE
		c.call_number = 1
		AND p.payment_date >= c.call_time --AND c.customer_bxck = 'BXCK15540202'
)
SELECT
	DISTINCT index_,
	caller_id,
	customer_bxck,
	par_bucket,
	payment_date,
	amount_paid
FROM
	main_query