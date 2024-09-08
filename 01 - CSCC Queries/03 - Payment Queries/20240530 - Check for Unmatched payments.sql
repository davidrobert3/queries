-----------------------------------------------------
-- 1. Retrieve payment details for transactions that meet specific conditions.
-----------------------------------------------------
SELECT ap.payment_date::DATE,
	-- The date of the payment
	ap.transaction_reference,
	-- Unique payment transaction reference
	ap.amount,
	-- Payment amount
	ap.payer_identifier -- Identifier of the payer
FROM src_odoo13_kenya.account_payment ap -- Payment data table
WHERE -- Filter payments that occurred on or after April 1, 2024
	ap.payment_date::DATE >= '2024-04-01' -- Only select payments where the payer identifier length is greater than 16 characters
	AND LENGTH(ap.payer_identifier) > 16 -- Include payments with a status that contains 'unmatched'
	AND ap.payment_status LIKE '%unmatched%' -- Exclude payments that are marked as cancelled
	AND ap.state NOT LIKE 'cancelled';