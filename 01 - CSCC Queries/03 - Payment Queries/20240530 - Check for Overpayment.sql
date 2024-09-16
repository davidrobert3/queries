-----------------------------------------------------
-- 1. Get the latest payment date for a specific customer (BXCK).
-----------------------------------------------------
WITH last_payment_date AS (
	SELECT ap.payg_account_id,
		-- The unique customer account ID (BXCK)
		MAX(ap.transaction_date) AS max_date -- The most recent payment date for the customer
	FROM src_odoo13_kenya.account_payment ap -- Payment data table
	WHERE --ap.payg_account_id LIKE 'BXCK67928113' -- Search for payments by customer BXCK
		-- Uncomment the following line to search by a specific payment transaction reference
		-- AND ap.transaction_reference LIKE 'SHC5RO456B'
		ap.transaction_date >= '20240101'  
	GROUP BY 1 -- Group by the customer account ID (BXCK)
) -----------------------------------------------------
-- 2. Retrieve payment details for the customer based on the latest payment date.
-----------------------------------------------------
SELECT ap.payg_account_id,
	-- Customer account ID (BXCK)
	ap.transaction_date::DATE,
	-- Transaction date
	-- Determine whether the payment is an overpayment or posted
	CASE
		WHEN ap.state LIKE 'draft' THEN 'Overpayment' -- If the payment is in draft, consider it an overpayment
		ELSE 'Posted' -- Otherwise, mark it as posted
	END AS isOverPayment,
	ap.amount,
	-- Payment amount
	ap.transaction_reference -- Payment transaction reference
FROM last_payment_date -- The latest payment date for the customer
	LEFT JOIN src_odoo13_kenya.account_payment ap ON ap.payg_account_id = last_payment_date.payg_account_id -- Match payments by customer account ID
	AND last_payment_date.max_date = ap.transaction_date -- Match the payment by the latest transaction date
ORDER BY ap.state DESC;
-- Sort by payment state, with draft payments (overpayments) listed first