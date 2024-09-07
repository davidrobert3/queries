--------------------------------------------------------------------------------
-- CTE to retrieve alternative phone numbers for PAYG accounts
--------------------------------------------------------------------------------
WITH alt_phones AS (
	SELECT ap.payg_account_id,
		-- PAYG account ID from the account payment table
		-- Check if the payer identifier (phone number) is valid and not a Bboxx identifier
		CASE
			WHEN len(ap.payer_identifier) > 10 -- Phone number should be longer than 10 characters
			AND len(ap.payer_identifier) < 15 -- Phone number should be shorter than 15 characters
			AND upper(ap.payer_identifier) NOT LIKE '%BXCK%' -- Exclude Bboxx internal identifiers
			THEN ap.payer_identifier -- Use the payer identifier as an alternative phone number
			ELSE NULL -- Otherwise, set the phone as NULL
		END AS alt_phone
	FROM src_odoo13_kenya.account_payment ap -- Source table with payment details
	WHERE ap.payment_date::DATE >= '20230101' -- Filter payments from January 1st, 2023 onwards
		AND ap.payment_date::DATE <= current_date::DATE -- Up to the current date
		AND ap.state = 'posted' -- Only include payments that have been posted
		AND ap.payment_status = 'matched' -- Only include matched payments
		AND ap."type" = 'mobile' -- Payments made via mobile
		AND ap.create_uid = 1 -- Filter by the user ID (1 in this case)
	GROUP BY ap.payg_account_id,
		-- Group by PAYG account ID
		alt_phone -- Group by alternative phone number (to avoid duplicates)
) --------------------------------------------------------------------------------
-- Select valid alternative phone numbers for PAYG accounts that are associated 
-- with existing customers in the customer personal details table
--------------------------------------------------------------------------------
SELECT alt_phone,
	-- Alternative phone number
	payg_account_id -- PAYG account ID
FROM alt_phones -- CTE containing alternative phone numbers
WHERE alt_phone IS NOT NULL -- Ensure the phone number is not NULL
	AND payg_account_id IS NOT NULL -- Ensure the PAYG account ID is not NULL
	AND payg_account_id IN (
		-- Filter only PAYG accounts that exist in the customer details
		SELECT unique_account_id -- Unique account ID from the customer details
		FROM kenya.customer_personal_details -- Customer personal details table
	)