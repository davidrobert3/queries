-- CTE to calculate the total payments made by customers within a specified date range.
WITH payments AS (
	SELECT p.customer_id,
		-- Customer identifier
		SUM(p.amount) AS total_payments -- Total amount paid by the customer
	FROM kenya.payment p
	WHERE p.is_void IS FALSE -- Exclude void payments
		AND p.third_party_payment_ref_id NOT LIKE 'BONUS%' -- Exclude bonus payments
		AND p.payment_utc_timestamp::DATE >= '20230401' -- Payments from April 1, 2023
		AND p.payment_utc_timestamp::DATE <= '20230901' -- Payments up to September 1, 2023
		AND p.is_bonus IS FALSE -- Exclude bonus payments
		AND p.is_refunded IS FALSE -- Exclude refunded payments
		AND p.processing_status ILIKE 'posted' -- Only include posted payments
		AND p.reconciliation_status ILIKE 'matched' -- Only include matched payments
	GROUP BY p.customer_id
),
-- CTE to calculate the total amount a customer was expected to pay up until the snapshot date.
expected_payments AS (
	SELECT DISTINCT dcs.payg_account_id,
		-- Unique customer account ID
		ROUND(SUM(dcs.daily_rate), 0) AS expected -- Total expected payment up to the snapshot date
	FROM kenya.daily_customer_snapshot dcs
	WHERE dcs.date_timestamp::DATE <= '20230331' -- Up to March 31, 2023
	GROUP BY dcs.payg_account_id
),
-- CTE to calculate the amount customers would have paid during the 7-day grace period after installation.
grace_period AS (
	SELECT DISTINCT dcs.payg_account_id,
		-- Unique customer account ID
		ROUND(dcs.daily_rate * 7) AS grace_period_amount -- Daily rate multiplied by 7 days
	FROM kenya.daily_customer_snapshot dcs
		LEFT JOIN kenya.customer c ON c.account_id = dcs.account_id
	WHERE dcs.date_timestamp::DATE = c.customer_active_start_date::DATE + 1 -- Snapshot date is the day after the customer's installation
) -- Main query to combine all the data and assign PAR (Payment Arrears) categories.
SELECT dcs.date_timestamp::DATE AS "Activity Month",
	-- Date of the snapshot
	COUNT(DISTINCT dcs.customer_id) AS "Portfolio Size",
	-- Number of unique customers
	CASE
		WHEN dcs.consecutive_late_days <= 0 THEN '0. PAR_0 (Not PAR)' -- No late payments
		WHEN dcs.consecutive_late_days BETWEEN 1 AND 30 THEN '1. PAR 1 to 30 days' -- Late by 1 to 30 days
		WHEN dcs.consecutive_late_days BETWEEN 31 AND 60 THEN '2. PAR 31 to 60 days' -- Late by 31 to 60 days
		WHEN dcs.consecutive_late_days BETWEEN 61 AND 90 THEN '3. PAR 61 to 90 days' -- Late by 61 to 90 days
		WHEN dcs.consecutive_late_days BETWEEN 91 AND 120 THEN '4. PAR 91 to 120 days' -- Late by 91 to 120 days
		ELSE '5. PAR >120 days' -- Late by more than 120 days
	END AS "PAR Category",
	ROUND(SUM(ep.expected - g.grace_period_amount), 0) AS "Total Period Invoices (KES) - Calculated",
	-- Calculated total invoices, adjusted for grace period
	ROUND(SUM(dcs.total_due_to_date), 0) AS "Total Period Invoices (KES)",
	-- Total amount due to date
	ROUND(SUM(dcs.total_paid_to_date * -1), 0) AS "Total Paid To-Date (KES)",
	-- Total amount paid to date (negated for comparison)
	ROUND(
		SUM(
			(ep.expected - g.grace_period_amount) - dcs.total_paid_to_date
		),
		0
	) AS "Total Period Balance (KES) - Calculated",
	-- Calculated balance, adjusting for expected payments and grace period
	ROUND(
		SUM(dcs.total_due_to_date - dcs.total_paid_to_date),
		0
	) AS "Total Period Balance (KES)",
	-- Actual balance, calculated as total due minus total paid
	ROUND(SUM(p.total_payments), 0) AS repayments -- Total repayments made by customers
FROM kenya.daily_customer_snapshot dcs
	LEFT JOIN payments p ON dcs.customer_id = p.customer_id
	LEFT JOIN expected_payments ep ON dcs.payg_account_id = ep.payg_account_id
	LEFT JOIN grace_period g ON dcs.payg_account_id = g.payg_account_id
WHERE dcs.date_timestamp::DATE = '20230331' -- Filter for the snapshot date
GROUP BY dcs.date_timestamp::DATE,
	-- Activity month
	CASE
		WHEN dcs.consecutive_late_days <= 0 THEN '0. PAR_0 (Not PAR)'
		WHEN dcs.consecutive_late_days BETWEEN 1 AND 30 THEN '1. PAR 1 to 30 days'
		WHEN dcs.consecutive_late_days BETWEEN 31 AND 60 THEN '2. PAR 31 to 60 days'
		WHEN dcs.consecutive_late_days BETWEEN 61 AND 90 THEN '3. PAR 61 to 90 days'
		WHEN dcs.consecutive_late_days BETWEEN 91 AND 120 THEN '4. PAR 91 to 120 days'
		ELSE '5. PAR >120 days'
	END
ORDER BY "PAR Category" ASC;
-- Order by PAR category