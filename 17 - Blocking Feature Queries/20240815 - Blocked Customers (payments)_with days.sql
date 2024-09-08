-----------------------------------------------------
-- Calculate the ratio of days paid for to daily rate
-----------------------------------------------------
SELECT cbc.unique_customer_id,
	-- Unique identifier for the customer from the blocked customers table
	cbc."Test or Control Checker",
	-- Test or control designation from the blocked customers table
	cr.daily_rate,
	-- Daily rate from the collection rate table
	-- Calculate the ratio of days paid for by summing payments and dividing by the daily rate
	SUM(ccp.sum) / SUM(cr.daily_rate) AS days_paid_for
FROM cscc_blocked_customers cbc -- Join with the collection payments table to get payment details
	LEFT JOIN cscc_collection_payments ccp ON cbc.unique_customer_id = ccp.payg_account_id
	AND ccp.payment_date >= '2024-08-14' -- Join with the collection rate table to get the daily rate
	LEFT JOIN collection_rate cr ON cr.unique_account_id = ccp.payg_account_id -- Filter to include only 'Test' records and exclude payments after a specific date
WHERE cbc."Test or Control Checker" = 'Test'
	AND ccp.payment_date::DATE < '2024-08-22' -- Group results by customer ID, test/control designation, and daily rate
GROUP BY cbc.unique_customer_id,
	cbc."Test or Control Checker",
	cr.daily_rate