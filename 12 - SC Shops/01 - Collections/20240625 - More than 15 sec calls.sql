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
WHERE month_ = 9
)
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
	WHERE month_ = 9
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
			'Brian Kirui (105)',
			'Agneta Otina (122)',
			'Jonathan Baraza (120)',
			'Dennis Omondi (119)',
			'Susan Rotich (125)',
			'Mwongela Katiwa (124)',
			'Brian Nyamumbo (115)',
			'George Odhiambo (140)',
			'Brian Kandagor (139)',
			'Naserian Musere (126)',
			'Sharon Odhiambo (121)',
			'Milka Abich (127)',
			'Jackline Koech (109)',
			'Denis Shikanga (123)',
			'Gwen Macharia (129)',
			'Jeremiah Wambui (138)',
			'Ishmael Kaleku (117)',
			'Catherine Musyoki (114)',
			'Alex Ombok (118)',
			'Ben Odero (116)',
			'Beverlyn Omollo (149)',
			'Erick Wafula (154)',
			'Fredrick Otieno (152)',
			'Immaculate Okuom (151)',
			'Kevin Biaraga (148)',
			'Kevin Ondiek (102)',
			'Martin Samson (147)',
			'Queenter Okumu (150)',
			'Victor Ogolla (153)'
		)
		AND talking >= '00:00:15'
		AND call_time :: DATE >= '2024-09-01'
		AND call_time :: DATE <= '2024-09-30'
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
		status,
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
)
	SELECT 
		call_time,
		caller_id ,
		destination,
		par_bucket,
		status,
		talking,
		customer_bxck
	FROM
		consolidated_customer_bxck c