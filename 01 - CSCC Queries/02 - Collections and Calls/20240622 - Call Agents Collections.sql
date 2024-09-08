-----------------------------------------------------
-- 1. Retrieve distinct customer phone numbers including alternative phone numbers.
--    This step consolidates primary, secondary, and alternative phone numbers for each customer.
-----------------------------------------------------
WITH customer_phones AS (
	SELECT DISTINCT unique_customer_id,
		-- Unique customer identifier (BXCK)
		phone_1,
		-- Primary phone number
		phone_2,
		-- Secondary phone number
		-- Concatenate distinct alternative phone numbers (limited to 13 characters)
		SUBSTRING(
			STRING_AGG(DISTINCT alt_phone::TEXT, ', '),
			0,
			13
		) AS alternative
	FROM cscc_customer_phone ccp -- Table containing customer phone details
		LEFT JOIN cscc_customer_alt_phones ccap ON ccp.unique_customer_id = ccap.payg_account_id -- Join to get alternative phone numbers
	WHERE -- Filter by customers in the call list for a specific month (September in this case)
		ccp.unique_customer_id IN (
			SELECT unique_account_id
			FROM cscc_call_list ccl
			WHERE month_ = 9 -- Filter by September
				-- Uncomment to include additional months (e.g., August)
				-- OR month_ = 8
		)
	GROUP BY 1,
		2,
		3 -- Group by unique customer ID, primary phone, and secondary phone
),
-----------------------------------------------------
-- 2. Retrieve all calls made to customers by the collections team within September 2024.
--    Match calls with primary, secondary, and alternative phone numbers.
-----------------------------------------------------
call_log_data AS (
	SELECT call_time::DATE,
		-- Date of the call
		caller_id,
		-- Agent making the call
		destination,
		-- Phone number called
		status,
		-- Status of the call (e.g., completed, missed)
		talking,
		-- Duration of the call in seconds
		-- Match call destinations with customer phone numbers (BXCKs) from the previous CTE
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		SUBSTRING(STRING_AGG(ccap.unique_customer_id, ', '), 0, 13) AS unique_customer_id_3
	FROM cscc_3cx_daily_report ccdr -- Main call log table
		-- Join with customer phone data for primary, secondary, and alternative numbers
		LEFT JOIN customer_phones ccp ON ccdr.destination = ccp.phone_1::TEXT
		LEFT JOIN customer_phones ccp2 ON ccdr.destination = ccp.phone_2::TEXT
		LEFT JOIN customer_phones ccap ON ccdr.destination = ccap.alternative::TEXT
	WHERE -- Filter for specific collection agents
		caller_id IN (
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15' -- Only include calls longer than 15 seconds
		AND call_time::DATE >= '2024-09-01' -- Start date filter (September 1, 2024)
		AND call_time::DATE <= '2024-09-30' -- End date filter (September 30, 2024)
	GROUP BY 1,
		2,
		3,
		4,
		5 -- Group by date, agent, phone number, status, and duration
),
-----------------------------------------------------
-- 3. Consolidate the customer BXCK (unique customer ID) based on the available phone number matches.
-----------------------------------------------------
consolidated_customer_bxck AS (
	SELECT call_time,
		-- Date of the call
		caller_id,
		-- Agent making the call
		destination,
		-- Phone number called
		talking,
		-- Duration of the call
		-- Prioritize customer BXCKs based on phone number matches
		CASE
			WHEN unique_customer_id_1 IS NOT NULL THEN unique_customer_id_1
			WHEN unique_customer_id_2 IS NOT NULL THEN unique_customer_id_2
			WHEN unique_customer_id_3 IS NOT NULL THEN unique_customer_id_3
		END AS customer_bxck -- Consolidated customer BXCK
	FROM call_log_data
),
-----------------------------------------------------
-- 4. Get the number of calls made to each customer per day and assign a call number.
-----------------------------------------------------
calls_per_day AS (
	SELECT *,
		-- All columns from the consolidated data
		ROW_NUMBER() OVER (
			PARTITION BY caller_id,
			customer_bxck,
			call_time::DATE
		) AS call_number -- Assign a number to each call made to the same customer per day
	FROM consolidated_customer_bxck c
	WHERE c.customer_bxck IS NOT NULL -- Only include calls with a valid customer BXCK
),
-----------------------------------------------------
-- 5. Retrieve all payments made by customers.
-----------------------------------------------------
payments AS (
	SELECT payg_account_id,
		-- Customer BXCK (unique customer identifier)
		payment_date::DATE AS payment_date,
		-- Date of the payment
		sum AS Amount_Paid -- Amount paid by the customer
	FROM cscc_collection_payments ccp
),
-----------------------------------------------------
-- 6. Combine call log and payment data, matching payments with the customer BXCK and call date.
-----------------------------------------------------
main_query AS (
	SELECT DISTINCT caller_id || customer_bxck || payment_date AS index_,
		-- Unique identifier for each record
		caller_id,
		-- Agent who made the call
		customer_bxck,
		-- Customer BXCK
		p.payment_date,
		-- Date of payment
		p.amount_paid -- Amount paid by the customer
	FROM calls_per_day c
		LEFT JOIN payments p ON c.customer_bxck = p.payg_account_id -- Join payment data with call log based on customer BXCK
	WHERE c.call_number = 1 -- Only consider the first call made to the customer on each day
		AND p.payment_date >= c.call_time::DATE -- Filter payments that occurred after the call date
) -----------------------------------------------------
-- 7. Select the final data with unique index and payment details for each customer.
-----------------------------------------------------
SELECT DISTINCT index_,
	-- Unique identifier for each record
	caller_id,
	-- Agent who made the call
	customer_bxck,
	-- Customer BXCK
	payment_date,
	-- Date of payment
	amount_paid -- Amount paid by the customer
FROM main_query;