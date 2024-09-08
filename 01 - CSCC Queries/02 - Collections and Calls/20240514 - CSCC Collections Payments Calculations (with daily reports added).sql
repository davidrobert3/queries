-----------------------------------------------------
-- 1. Retrieve all calls made to customers by the collections team.
-- This CTE extracts call logs and attempts to match phone numbers with customers based on different phone numbers (primary, secondary, alternate).
------------------------------------------------------------
WITH call_log_data AS (
	SELECT call_time::DATE,
		-- Date of the call
		caller_id,
		-- Agent who made the call
		destination,
		-- Customer's phone number
		status,
		-- Status of the call (e.g., answered, missed)
		talking,
		-- Duration of the call
		-- Attempt to match phone numbers with unique customer IDs from different sources
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		-- Primary phone
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id::TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		-- Secondary phone
		SUBSTRING(STRING_AGG(ccap.payg_account_id, ', '), 0, 13) AS unique_customer_id_3 -- Alternate phone
	FROM cscc_3cx_daily_report ccdr
		LEFT JOIN cscc_customer_phone ccp ON ccdr.destination = ccp.phone_1::TEXT -- Join on primary phone number
		LEFT JOIN cscc_customer_phone ccp2 ON ccdr.destination = ccp2.phone_2::TEXT -- Join on secondary phone number
		LEFT JOIN cscc_customer_alt_phones ccap ON ccdr.destination = ccap.alt_phone::TEXT -- Join on alternate phone number
	WHERE caller_id IN (
			-- Filter to calls made by specific agents
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15' -- Only include calls that lasted at least 15 seconds
		-- AND call_time::DATE >= '2024-06-01'  -- Optionally filter by call date range
		-- AND call_time::DATE <= '2024-06-30'
	GROUP BY 1,
		2,
		3,
		4,
		5
),
-----------------------------------------------------------
-- 2. Merge the unique customer IDs from the previous step into one column.
-- This will prioritize primary, secondary, and alternate phone numbers in that order.
------------------------------------------------------------------
customer_to_call_assignment AS (
	SELECT call_time,
		caller_id,
		destination,
		status,
		talking,
		-- Assign unique customer ID based on the availability of phone numbers (primary, secondary, or alternate)
		CASE
			WHEN unique_customer_id_1 IS NOT NULL THEN unique_customer_id_1
			WHEN unique_customer_id_1 IS NULL
			AND unique_customer_id_2 IS NOT NULL THEN unique_customer_id_2
			WHEN unique_customer_id_1 IS NULL
			AND unique_customer_id_2 IS NULL
			AND unique_customer_id_3 IS NOT NULL THEN unique_customer_id_3
			ELSE NULL
		END AS BXCK -- Final unique customer ID (BXCK)
	FROM call_log_data
),
--------------------------------------------------------------------
-- 3. Main query to get detailed call logs for customers, including call frequency.
-- This includes the number of times each customer was called.
--------------------------------------------------------------------------------
call_details AS (
	SELECT call_time::DATE AS call_date,
		-- Date of the call
		caller_id AS Agent_Name,
		-- Name of the agent who made the call
		destination AS Customer_Phone_Number,
		-- Customer's phone number
		talking,
		-- Call duration
		BXCK AS unique_customer_id,
		-- Unique customer ID
		ROW_NUMBER() OVER (
			PARTITION BY BXCK
			ORDER BY call_time::DATE DESC
		) AS number_of_times_called -- Rank calls by recency
	FROM customer_to_call_assignment
	WHERE BXCK IS NOT NULL -- Only include calls with a valid customer ID
),
------------------------------------------------------------------------------------------
-- 4. Retrieve the last agent to call each customer.
-- This helps identify the most recent interaction with each customer.
---------------------------------------------------------------------------------------
last_agent_to_call_customer AS (
	SELECT *
	FROM call_details
	WHERE number_of_times_called = 1 -- Get the most recent call (rank = 1)
),
---------------------------------------------------------------------------------------------
-- 5. Get all customer payments made during the report period.
-- This includes payments for customers who were called during the period.
--------------------------------------------------------------------------------------------
payments AS (
	SELECT payg_account_id,
		-- PAYG account ID
		payment_date::DATE AS payment_date,
		-- Date of the payment
		SUM AS Amount_Paid -- Total payment amount
	FROM cscc_collection_payments ccp
		RIGHT JOIN customer_to_call_assignment ON customer_to_call_assignment.BXCK = ccp.payg_account_id -- Join with call data
		-- WHERE payment_date::DATE BETWEEN '2024-06-01' AND '2024-06-30'  -- Optional filter by payment date range
),
---------------------------------------------------------------------------------------------
-- 6. Combine all data: call details, payments, and the last agent to call each customer.
-- This final step aggregates call logs and payment data for further analysis.
------------------------------------------------------------------------------------------
final_cte AS (
	SELECT -- Create a unique index for each record based on customer ID, agent name, and phone number
		call_details.unique_customer_id || ' - ' || call_details.Agent_Name || ' - ' || call_details.Customer_Phone_Number || ' - ' || call_details.number_of_times_called AS index_,
		call_details.unique_customer_id,
		-- Unique customer ID
		call_details.Agent_Name,
		-- Agent name
		call_details.Customer_Phone_Number,
		-- Customer's phone number
		call_details.Call_Date,
		-- Date of the call
		payments.payment_date,
		-- Payment date
		payments.Amount_Paid,
		-- Payment amount
		ROW_NUMBER() OVER (
			PARTITION BY payments.payg_account_id,
			payments.payment_date
		) AS payment_number -- Avoid duplicate payments
	FROM call_details
		LEFT JOIN payments ON payments.payg_account_id = call_details.unique_customer_id
		AND payments.payment_date >= call_details.call_date -- Only include payments made after the call
		LEFT JOIN last_agent_to_call_customer ON last_agent_to_call_customer.unique_customer_id = call_details.unique_customer_id
) ---------------------------------------------------------------------------------------------
-- 7. Final selection of records where each customer has made at least one payment.
------------------------------------------------------------------------------------------
SELECT *
FROM final_cte
WHERE payment_number = 1 -- Only include the first payment for each customer