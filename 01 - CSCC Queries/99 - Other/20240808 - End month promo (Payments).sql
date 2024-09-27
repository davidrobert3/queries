-----------------------------------------------------
-- Retrieve detailed payment and sales order data
-----------------------------------------------------
SELECT c.unique_account_id AS sales_order_id,
	-- Unique identifier for the sales order from the customer table
	p.contract_reference,
	-- Contract reference for the payment
	p.amount,
	-- Amount of the payment
	p.subsidy_amount,
	-- Subsidy amount associated with the payment
	p.payment_utc_timestamp::DATE,
	-- Date when the payment was made
	p.reconciliation_utc_timestamp::DATE,
	-- Date when the payment was reconciled
	p.third_party_payment_ref_id,
	-- Third-party reference ID for the payment
	p.processing_status,
	-- Status of the payment processing
	p.reconciliation_status,
	-- Status of the payment reconciliation
	p.matching_type,
	-- Type of matching for the payment
	s.credit_price -- Credit price from the sales table
FROM kenya.payment p -- Join with the sales table to get sales details
	LEFT JOIN kenya.sales s ON s.account_id = p.account_id -- Join with the customer table to get customer details
	LEFT JOIN kenya.customer c ON c.account_id = p.account_id -- Filter the data for payments within the specified date range
WHERE p.payment_utc_timestamp::DATE >= '2024-07-19'
	AND p.payment_utc_timestamp::DATE <= '2024-07-22' -- Exclude void, bonus, refunded, and down payment records
	AND p.is_void IS FALSE
	AND p.is_bonus IS FALSE
	AND p.is_refunded IS FALSE
	AND p.processing_status !~ 'draft'
	AND p.reconciliation_status !~ 'unmatched'