-----------------------------------------------------
-- 1. Get all calls made to customers by the collections team.
-----------------------------------------------------
-- Retrieve the relevant call details along with customer IDs for calls made by the collections team
SELECT call_time::DATE,
	-- The date when the call was made
	caller_id,
	-- The ID of the caller from the collections team
	destination,
	-- The phone number the call was made to
	status,
	-- The status of the call (e.g., completed, failed)
	talking,
	-- Duration of the call, to filter calls that lasted 15 seconds or more
	-- Fetch the unique customer ID associated with phone_1, limited to 13 characters
	SUBSTRING(
		STRING_AGG(ccp.unique_customer_id::TEXT, ', '),
		0,
		13
	) AS unique_customer_id_1,
	-- Fetch the unique customer ID associated with phone_2, limited to 13 characters
	SUBSTRING(
		STRING_AGG(ccp2.unique_customer_id::TEXT, ', '),
		0,
		13
	) AS unique_customer_id_2,
	-- Fetch the unique customer ID associated with alternative phones, limited to 13 characters
	SUBSTRING(STRING_AGG(ccap.payg_account_id, ', '), 0, 13) AS unique_customer_id_3
FROM cscc_3cx_daily_report ccdr -- Table containing call logs
	-- Join customer phone data to map the destination number to a customer via phone_1
	LEFT JOIN cscc_customer_phone ccp ON ccdr.destination = ccp.phone_1::TEXT -- Join customer phone data to map the destination number to a customer via phone_2
	LEFT JOIN cscc_customer_phone ccp2 ON ccdr.destination = ccp2.phone_2::TEXT -- Join alternative customer phone data for additional mapping to customer IDs
	LEFT JOIN cscc_customer_alt_phones ccap ON ccdr.destination = ccap.alt_phone::TEXT
WHERE -- Filter for calls made by specific members of the collections team
	caller_id IN (
		'Fidelis Wanja (026)',
		'Tresy Onchong''a (049)',
		'Faith Okoth (013)',
		'Emily Mwirigi (052)',
		'Mercy Gogo (056)',
		'Quenter Akoth (040)'
	) -- Ensure only calls that lasted 15 seconds or more are included
	AND talking >= '00:00:15' -- Commented out date range filter for flexibility in selecting date ranges
	-- AND call_time::DATE >= '2024-06-01'
	-- AND call_time::DATE <= '2024-06-30'
GROUP BY 1,
	-- Group by call date
	2,
	-- Group by caller ID
	3,
	-- Group by destination number
	4,
	-- Group by call status
	5;
-- Group by call duration