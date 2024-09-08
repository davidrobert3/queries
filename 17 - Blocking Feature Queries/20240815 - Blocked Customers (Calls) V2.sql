WITH customer_phones AS (
	-- Get distinct customer phone details and alternative phones
	SELECT DISTINCT unique_customer_id,
		-- Unique customer identifier
		phone_1,
		-- Primary phone number
		phone_2,
		-- Secondary phone number
		SUBSTRING(
			STRING_AGG(DISTINCT alt_phone::TEXT, ', '),
			0,
			13
		) AS alternative -- Aggregated alternative phone numbers
	FROM cscc_customer_phone ccp
		LEFT JOIN cscc_customer_alt_phones ccap ON ccp.unique_customer_id = ccap.payg_account_id
	WHERE ccp.unique_customer_id IN (
			SELECT unique_account_id
			FROM cscc_call_list ccl
			WHERE month_ IN (8, 9) -- Filter for calls made in August and September
		)
	GROUP BY 1,
		2,
		3
),
customer_par AS (
	-- Join customer phones with call list to include par_bucket information
	SELECT cp.*,
		-- All fields from customer_phones
		ccl.par_bucket -- Par bucket value from the call list
	FROM customer_phones cp
		LEFT JOIN cscc_call_list ccl ON cp.unique_customer_id = ccl.unique_account_id
	WHERE month_ IN (8, 9) -- Filter for August and September
),
-----------------------------------------------------
-- 1. Get all calls made to customers by the collections team.
------------------------------------------------------------
call_log_data AS (
	SELECT call_time::DATE,
		-- Date of the call
		caller_id,
		-- ID of the caller
		destination,
		-- Destination phone number
		status,
		-- Status of the call
		talking,
		-- Duration of the call
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		-- Aggregated unique customer ID for phone_1
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		-- Aggregated unique customer ID for phone_2
		SUBSTRING(
			STRING_AGG(ccp3.unique_customer_id, ', '),
			0,
			13
		) AS unique_customer_id_3,
		-- Aggregated unique customer ID for alternative phones
		ccp.par_bucket AS par_bucket_1,
		-- Par bucket for phone_1
		ccp2.par_bucket AS par_bucket_2,
		-- Par bucket for phone_2
		ccp3.par_bucket AS par_bucket_3 -- Par bucket for alternative phones
	FROM cscc_3cx_daily_report ccdr
		LEFT JOIN customer_par ccp ON ccdr.destination = ccp.phone_1::TEXT
		LEFT JOIN customer_par ccp2 ON ccdr.destination = ccp2.phone_2::TEXT
		LEFT JOIN customer_par ccp3 ON ccdr.destination = ccp3.alternative::TEXT
	WHERE caller_id IN (
			'Agneta Otina (122)',
			'Alex Ombok (118)',
			'Brian Kirui (105)',
			'Brian Nyamumbo (115)',
			'Catherine Musyoki (114)',
			'Denis Shikanga (123)',
			'Dennis Omondi (119)',
			'Ishmael Kaleku (117)',
			'Jackline Koech (109)',
			'Jonathan Baraza (120)',
			'Joy Kamau (128)',
			'Kevin Ondiek (102)',
			'Milka Abich (127)',
			'Mwongela Katiwa (124)',
			'Naserian Musere (126)',
			'Nchoe Ntimama (116)',
			'Sharon Odhiambo (121)',
			'Susan Rotich (125)',
			'Vivian Chepkorir (113)',
			'Gwen Macharia (129)',
			'Brian Kandagor (139)',
			'Jeremiah Wambui (138)',
			'George Odhiambo (140)',
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15' -- Minimum call duration
		AND call_time::DATE >= '2024-08-14' -- Filter start date
		AND call_time::DATE <= '2024-09-04' -- Filter end date
	GROUP BY 1,
		2,
		3,
		4,
		5,
		ccp.par_bucket,
		ccp2.par_bucket,
		ccp3.par_bucket
),
consolidated_customer_bxck AS (
	-- Consolidate customer IDs and par buckets from all available phone types
	SELECT call_time::DATE,
		-- Date of the call
		caller_id,
		-- ID of the caller
		destination,
		-- Destination phone number
		status,
		-- Status of the call
		talking,
		-- Duration of the call
		CASE
			WHEN unique_customer_id_1 IS NOT NULL THEN unique_customer_id_1
			WHEN unique_customer_id_1 IS NULL
			AND unique_customer_id_2 IS NOT NULL THEN unique_customer_id_2
			ELSE unique_customer_id_3
		END AS customer_bxck,
		-- Consolidated unique customer ID
		CASE
			WHEN par_bucket_1 IS NOT NULL THEN par_bucket_1
			WHEN par_bucket_1 IS NULL
			AND par_bucket_2 IS NOT NULL THEN par_bucket_2
			ELSE par_bucket_3
		END AS par_bucket -- Consolidated par bucket
	FROM call_log_data
) -- Final selection of distinct records for each call
SELECT DISTINCT caller_id,
	-- ID of the caller
	call_time::DATE,
	-- Date of the call
	customer_bxck,
	-- Consolidated unique customer ID
	talking -- Duration of the call
FROM consolidated_customer_bxck c