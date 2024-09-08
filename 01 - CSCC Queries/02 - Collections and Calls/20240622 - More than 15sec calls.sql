-----------------------------------------------------
-- 1. Consolidate customer phone numbers, including primary, secondary, and alternative phones.
-----------------------------------------------------
WITH customer_phones AS (
	SELECT DISTINCT unique_customer_id,
		-- Unique customer ID (BXCK)
		phone_1,
		-- Primary phone number
		phone_2,
		-- Secondary phone number
		-- Concatenate distinct alternative phone numbers, limited to 13 characters
		substring(
			string_agg(DISTINCT alt_phone::TEXT, ', '),
			0,
			13
		) AS alternative
	FROM cscc_customer_phone ccp -- Customer phone table
		LEFT JOIN cscc_customer_alt_phones ccap ON ccp.unique_customer_id = ccap.payg_account_id -- Join to get alternative phone numbers
	WHERE -- Filter customers by unique account ID from the call list for the specified month (September)
		ccp.unique_customer_id IN (
			SELECT unique_account_id
			FROM cscc_call_list ccl
			WHERE month_ = 9 -- Consider calls from September
				-- Uncomment to include other months (e.g., August)
				-- OR month_ = 8
		)
	GROUP BY 1,
		2,
		3 -- Group by customer ID, primary, and secondary phones
),
-----------------------------------------------------
-- 2. Retrieve all calls made to customers by the collections team for September 2024.
--    Match calls with primary, secondary, and alternative phone numbers.
-----------------------------------------------------
call_log_data AS (
	SELECT call_time::DATE,
		-- Date of the call
		caller_id,
		-- The agent who made the call
		destination,
		-- The phone number that was called
		status,
		-- Call status (e.g., completed, missed)
		talking,
		-- Duration of the call in seconds
		ccdr.cost,
		-- Call cost
		-- Match destination phone numbers with customer BXCKs (unique customer IDs)
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		-- Primary phone match
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		-- Secondary phone match
		SUBSTRING(STRING_AGG(ccap.unique_customer_id, ', '), 0, 13) AS unique_customer_id_3 -- Alternative phone match
	FROM cscc_3cx_daily_report ccdr -- Call log data
		-- Join with customer phone data to match primary, secondary, and alternative numbers
		LEFT JOIN customer_phones ccp ON ccdr.destination = ccp.phone_1::TEXT
		LEFT JOIN customer_phones ccp2 ON ccdr.destination = ccp.phone_2::TEXT
		LEFT JOIN customer_phones ccap ON ccdr.destination = ccap.alternative::TEXT
	WHERE -- Filter for calls made by specific collections team agents
		caller_id IN (
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15' -- Only include calls longer than 15 seconds
		AND call_time::DATE >= '2024-09-01' -- Start date (September 1, 2024)
		AND call_time::DATE <= '2024-09-30' -- End date (September 30, 2024)
	GROUP BY 1,
		2,
		3,
		4,
		5,
		6 -- Group by call date, agent, destination, status, duration, and cost
),
-----------------------------------------------------
-- 3. Consolidate the customer BXCK (unique customer ID) based on the available phone number matches.
-----------------------------------------------------
consolidated_customer_bxck AS (
	SELECT call_time,
		-- Date of the call
		caller_id,
		-- Agent who made the call
		destination,
		-- Phone number called
		talking,
		-- Duration of the call
		cost,
		-- Call cost
		-- Determine the customer BXCK based on phone number match priority
		CASE
			WHEN unique_customer_id_1 IS NOT NULL THEN unique_customer_id_1 -- Match with primary phone
			WHEN unique_customer_id_2 IS NOT NULL THEN unique_customer_id_2 -- Match with secondary phone
			ELSE unique_customer_id_3 -- Match with alternative phone
		END AS customer_bxck -- Consolidated customer BXCK
	FROM call_log_data
) -----------------------------------------------------
-- 4. Select final data including call details and the consolidated customer BXCK.
-----------------------------------------------------
SELECT call_time,
	-- Date of the call
	caller_id,
	-- Agent who made the call
	destination,
	-- Phone number called
	talking,
	-- Call duration
	customer_bxck,
	-- Consolidated customer BXCK
	cost -- Call cost
FROM consolidated_customer_bxck c;