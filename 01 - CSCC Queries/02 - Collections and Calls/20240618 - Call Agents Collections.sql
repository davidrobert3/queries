-----------------------------------------------------
-- 1. Get all calls made to customers by the collections team.
-- This CTE extracts call logs for the specified agents, and attempts to match phone numbers with customer IDs.
------------------------------------------------------------
WITH call_log_data AS (
	SELECT call_time::DATE,
		-- The date when the call was made
		caller_id,
		-- The ID of the agent who made the call
		destination,
		-- The phone number that was called
		status,
		-- Status of the call (e.g., answered, missed)
		talking,
		-- Duration of the call in seconds
		-- Try to match the called phone number with customer IDs from different sources
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		-- Primary phone number match
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		-- Secondary phone number match
		SUBSTRING(STRING_AGG(ccap.payg_account_id, ', '), 0, 13) AS unique_customer_id_3 -- Alternate phone number match
	FROM cscc_3cx_daily_report ccdr -- Join phone numbers to match with customer details
		LEFT JOIN cscc_customer_phone ccp ON ccdr.destination = ccp.phone_1::TEXT -- Primary phone
		LEFT JOIN cscc_customer_phone ccp2 ON ccdr.destination = ccp2.phone_2::TEXT -- Secondary phone
		LEFT JOIN cscc_customer_alt_phones ccap ON ccdr.destination = ccap.alt_phone::TEXT -- Alternate phone
	WHERE -- Filter by agents who made the calls
		caller_id IN (
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15' -- Only include calls with a duration of at least 15 seconds
		AND call_time::DATE >= '2024-06-01' -- Calls made after June 1, 2024
		AND call_time::DATE <= '2024-06-30' -- Calls made before June 30, 2024
	GROUP BY 1,
		2,
		3,
		4,
		5
),
-----------------------------------------------------
-- 2. Consolidate customer IDs into one column for each call.
-- This merges the customer IDs (BXCKs) from different sources into one, prioritizing primary, then secondary, then alternate phones.
------------------------------------------------------------
consolidated_customer_bxck AS (
	SELECT call_time::DATE,
		-- The date when the call was made
		caller_id,
		-- The agent ID who made the call
		destination,
		-- The phone number that was called
		talking,
		-- Duration of the call
		-- Consolidate customer IDs, using primary, then secondary, then alternate phone match
		CASE
			WHEN unique_customer_id_1 IS NOT NULL THEN unique_customer_id_1
			WHEN unique_customer_id_1 IS NULL
			AND unique_customer_id_2 IS NOT NULL THEN unique_customer_id_2
			WHEN unique_customer_id_1 IS NULL
			AND unique_customer_id_3 IS NOT NULL THEN unique_customer_id_3
		END AS customer_bxck -- The final unique customer ID
	FROM call_log_data
),
-----------------------------------------------------
-- 3. Assign a call number to each customer per day.
-- This CTE assigns a number to each call made to the same customer on the same day, to track repeat calls.
------------------------------------------------------------
calls_per_day AS (
	SELECT *,
		-- All columns from the previous CTE
		ROW_NUMBER() OVER (
			PARTITION BY caller_id,
			customer_bxck,
			call_time::DATE
		) AS call_number -- Rank the calls made by an agent to the same customer on the same day
	FROM consolidated_customer_bxck c
	WHERE c.customer_bxck IS NOT NULL -- Only include calls with a valid customer ID
),
-----------------------------------------------------
-- 4. Retrieve customer payments made during the period.
-- This CTE selects payments made by customers from the collection payments table.
------------------------------------------------------------
payments AS (
	SELECT payg_account_id,
		-- The customer PAYG account ID
		payment_date::DATE AS payment_date,
		-- The date of the payment
		sum AS Amount_Paid -- The total amount paid
	FROM cscc_collection_payments ccp
),
-----------------------------------------------------
-- 5. Main query to combine call data with payment information.
-- This step joins the call log and payment data, ensuring that we only include the first call made to each customer and payments made after the call.
------------------------------------------------------------
main_query AS (
	SELECT DISTINCT caller_id || customer_bxck || payment_date AS index_,
		-- Create a unique index for each row based on the agent, customer, and payment date
		caller_id,
		-- The agent who made the call
		customer_bxck,
		-- The customer ID (BXCK)
		p.payment_date,
		-- The date of the payment
		p.Amount_Paid -- The amount of the payment
	FROM calls_per_day c
		LEFT JOIN payments p ON c.customer_bxck = p.payg_account_id -- Join payments with call data on the customer BXCK
	WHERE c.call_number = 1 -- Only include the first call made to each customer per day
		AND p.payment_date >= c.call_time -- Only include payments made after the call
) -----------------------------------------------------
-- 6. Final selection of unique records.
-- This query selects unique records of customers who made payments, ensuring no duplicate payments are counted.
------------------------------------------------------------
SELECT DISTINCT index_,
	-- The unique index created earlier
	caller_id,
	-- The agent who made the call
	customer_bxck,
	-- The customer ID
	payment_date,
	-- The payment date
	Amount_Paid -- The amount paid by the customer
FROM main_query;