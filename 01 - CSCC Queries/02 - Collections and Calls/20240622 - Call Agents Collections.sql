Add ckear and conscience comments


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
WHERE month_ = 9 --or 
--month_ = 8
)
GROUP BY 1,2,3
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
		SUBSTRING(STRING_AGG(ccap.unique_customer_id, ', '), 0, 13) AS unique_customer_id_3
	FROM
		cscc_3cx_daily_report ccdr
		LEFT JOIN customer_phones ccp ON ccdr.destination = ccp.phone_1 :: TEXT
		LEFT JOIN customer_phones ccp2 ON ccdr.destination = ccp2.phone_2 :: TEXT
		LEFT JOIN customer_phones ccap ON ccdr.destination = ccap.alternative :: TEXT
	WHERE
		caller_id IN (
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15'
		AND call_time::DATE >= '2024-09-01'
		AND call_time::DATE <= '2024-09-30'
	GROUP BY
		1,
		2,
		3,
		4,
		5
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
			WHEN unique_customer_id_1 ISNULL
			AND unique_customer_id_3 NOTNULL THEN unique_customer_id_3
		END AS customer_bxck
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
		caller_id,
		customer_bxck,
		p.payment_date,
		p.amount_paid
	FROM
		calls_per_day c
		LEFT JOIN payments p ON c.customer_bxck = p.payg_account_id
	WHERE
		c.call_number = 1
		AND p.payment_date >= (c.call_time::DATE) --AND c.customer_bxck = 'BXCK15540202'
) 
SELECT
	DISTINCT index_,
	caller_id,
	customer_bxck,
	payment_date,
	amount_paid
FROM
	main_query