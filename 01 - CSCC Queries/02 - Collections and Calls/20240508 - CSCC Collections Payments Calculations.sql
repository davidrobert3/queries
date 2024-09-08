--------------------------------------------
-- Get details of calls made, including unique customer IDs, agent names, 
-- phone numbers, call dates, and a ranking of the number of times called
--------------------------------------------
WITH call_details AS (
	SELECT "Actual BXCK" AS unique_customer_id,
		-- Unique customer ID (BXCK)
		"Caller ID" AS Agent_Name,
		-- Name of the call agent
		"Corrected Phone Number"::TEXT AS Customer_Phone_Number,
		-- Customer's phone number
		"Call Time" AS Call_Date,
		-- Date and time of the call
		ROW_NUMBER() OVER (
			PARTITION BY "Actual BXCK"
			ORDER BY "Call Time" DESC
		) AS number_of_times_called -- Rank calls by recency
	FROM cscc_collections cc -- Source table for call logs
	WHERE "Actual BXCK" <> 'None' -- Filter out entries with no customer ID
	GROUP BY 1,
		2,
		3,
		4 -- Group by customer ID, agent name, phone number, and call date
	ORDER BY "Call Time" DESC -- Order by most recent call
),
--------------------------------------------
-- Count the number of calls made by each agent
--------------------------------------------
calls_made AS (
	SELECT DISTINCT "Caller ID" AS agent_name_,
		-- Name of the call agent
		COUNT(*) AS calls_made -- Count the number of calls made by the agent
	FROM cscc_collections -- Source table for call logs
	GROUP BY 1 -- Group by agent name
),
--------------------------------------------
-- Identify the most recent call for each customer and the agent who made it
--------------------------------------------
assign_call_agent AS (
	SELECT unique_customer_id,
		-- Unique customer ID
		Agent_Name -- Name of the agent who made the most recent call
	FROM call_details
	WHERE number_of_times_called = 1 -- Only get the most recent call (rank = 1)
),
--------------------------------------------
-- Retrieve all payments within a specified period
--------------------------------------------
payments AS (
	SELECT payg_account_id,
		-- PAYG account ID
		payment_date::DATE AS payment_date,
		-- Date of payment
		SUM AS Amount_Paid -- Total amount paid
	FROM cscc_collection_payments ccp -- Source table for payment details
),
--------------------------------------------
-- Combine call logs and payment data, ensuring all filters and conditions are applied
--------------------------------------------
combined_data AS (
	SELECT call_details.unique_customer_id,
		-- Unique customer ID
		call_details.Agent_Name,
		-- Name of the call agent
		call_details.Call_Date,
		-- Date of the call
		payments.payment_date,
		-- Payment date
		payments.Amount_Paid,
		-- Amount paid
		ROW_NUMBER() OVER (PARTITION BY payments.payg_account_id) AS double_entry,
		-- Avoid duplicate payment entries
		MAX(call_details.number_of_times_called) AS number_of_calls_made -- Maximum number of calls made to a customer
	FROM call_details
		LEFT JOIN payments ON payments.payg_account_id = call_details.unique_customer_id
		AND payments.payment_date >= call_details.call_date -- Only get payments made after the call
		LEFT JOIN assign_call_agent ON assign_call_agent.unique_customer_id = call_details.unique_customer_id -- Ensure matching agent
	WHERE call_details.Agent_Name = assign_call_agent.Agent_Name -- Filter to include only agents who made the most recent call
	GROUP BY 1,
		2,
		3,
		4,
		5,
		payments.payg_account_id
),
--------------------------------------------
-- Calculate the total amount collected by each call agent
--------------------------------------------
total_collections AS (
	SELECT DISTINCT agent_name,
		-- Name of the call agent
		ROUND(SUM(Amount_Paid)::INT, 0) AS amount_collected -- Total amount collected by the agent
	FROM combined_data -- Use the combined data of calls and payments
	GROUP BY 1 -- Group by agent name
) ---------------------------------------------------
-- Calculate the payout for each call agent based on the amount collected and a tiered structure
---------------------------------------------------
SELECT CASE
		-- Categorize agents based on specific names and days of follow-up
		WHEN agent_name IN ('Fidelis Wanja (026)', 'Tresy Onchong''a (049)') THEN '1. 16 - 30 days'
		WHEN agent_name IN ('Faith Okoth (013)', 'Emily Mwirigi (052)') THEN '2. 31 - 60 days'
		WHEN agent_name IN ('Mercy Gogo (056)', 'Quenter Akoth (040)') THEN '3. 60 - 119 days'
	END AS category,
	-- Create category based on agent and days of follow-up
	total_collections.agent_name,
	-- Call agent name
	calls_made.calls_made,
	-- Total number of calls made by the agent
	total_collections.amount_collected,
	-- Total amount collected by the agent
	-- Calculate the payout based on the amount collected and tiered payout percentages
	CASE
		WHEN agent_name IN ('Fidelis Wanja (026)', 'Tresy Onchong''a (049)') THEN (amount_collected::INT - 200000) * 0.03
		WHEN agent_name IN ('Faith Okoth (013)', 'Emily Mwirigi (052)') THEN (amount_collected::INT - 100000) * 0.05
		WHEN agent_name IN ('Mercy Gogo (056)', 'Quenter Akoth (040)') THEN (amount_collected::INT - 50000) * 0.1
	END AS payout -- Calculate the payout for each agent
FROM total_collections
	LEFT JOIN calls_made ON total_collections.agent_name = calls_made.agent_name_ -- Join with call logs to get total calls made