-----------------------------------------------------
-- 1. Retrieve call log data made by specific agents within the specified date range
--    and attempt to match the phone numbers with customer IDs.
-----------------------------------------------------
WITH call_log_data AS (
	SELECT call_time::DATE,
		-- Date of the call
		caller_id,
		-- ID of the agent making the call
		destination,
		-- Phone number being called
		status,
		-- Status of the call (e.g., answered, missed)
		talking,
		-- Duration of the call in seconds
		-- Attempt to match phone numbers to unique customer IDs (BXCKs)
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		-- Match with phone_1 from the customer table
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		-- Match with phone_2 from the customer table
		SUBSTRING(STRING_AGG(ccap.payg_account_id, ', '), 0, 13) AS unique_customer_id_3 -- Match with alt_phone from alternate phone table
	FROM cscc_3cx_daily_report ccdr -- Main call log table
		-- Join to find matching phone numbers in different customer phone tables
		LEFT JOIN cscc_customer_phone ccp ON ccdr.destination = ccp.phone_1::TEXT -- Join with primary phone number
		LEFT JOIN cscc_customer_phone ccp2 ON ccdr.destination = ccp2.phone_2::TEXT -- Join with secondary phone number
		LEFT JOIN cscc_customer_alt_phones ccap ON ccdr.destination = ccap.alt_phone::TEXT -- Join with alternate phone number
	WHERE -- Filter for specific agents in the call log
		caller_id IN (
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15' -- Only include calls longer than 15 seconds
		AND call_time::DATE >= '2024-06-01' -- Only include calls made on or after June 1, 2024
		AND call_time::DATE <= '2024-06-30' -- Only include calls made on or before June 30, 2024
	GROUP BY 1,
		2,
		3,
		4,
		5 -- Group by the date, agent, phone number, status, and call duration
),
-----------------------------------------------------
-- 2. Consolidate the customer BXCK (unique customer ID) by prioritizing different phone matches.
--    This step combines customer IDs from various phone number matches into a single identifier.
-----------------------------------------------------
consolidated_customer_bxck AS (
	SELECT call_time,
		-- Date of the call
		caller_id,
		-- Agent making the call
		destination,
		-- Phone number that was called
		talking,
		-- Duration of the call
		-- Select the customer BXCK based on the priority: phone_1 > phone_2 > alt_phone
		CASE
			WHEN unique_customer_id_1 IS NOT NULL THEN unique_customer_id_1
			WHEN unique_customer_id_1 IS NULL
			AND unique_customer_id_2 IS NOT NULL THEN unique_customer_id_2
			WHEN unique_customer_id_1 IS NULL
			AND unique_customer_id_3 IS NOT NULL THEN unique_customer_id_3
		END AS customer_bxck -- Consolidated unique customer ID (BXCK)
	FROM call_log_data -- Use data from the previous CTE
) -----------------------------------------------------
-- 3. Select final data
--    Return the call details along with the consolidated customer BXCK for each call.
-----------------------------------------------------
SELECT call_time,
	-- Date of the call
	caller_id,
	-- Agent who made the call
	destination,
	-- Phone number that was called
	talking,
	-- Duration of the call
	customer_bxck -- Consolidated unique customer ID (BXCK)
FROM consolidated_customer_bxck c;