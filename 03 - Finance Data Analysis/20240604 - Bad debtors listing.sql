-- CTE to calculate the total amount a customer was expected to pay up until the end of the year
WITH expected_payments AS (
	SELECT DISTINCT dcs.payg_account_id,
		-- Unique customer account ID
		ROUND(SUM(dcs.daily_rate), 0) AS expected -- Total expected amount up to the end of the year
	FROM kenya.daily_customer_snapshot dcs
	WHERE dcs.date_timestamp::DATE <= '20231231' -- Include records up to December 31, 2023
	GROUP BY dcs.payg_account_id
),
-- CTE to calculate the amount customers would have paid during the 7-day grace period after installation
grace_period AS (
	SELECT DISTINCT dcs.payg_account_id,
		-- Unique customer account ID
		ROUND(dcs.daily_rate * 7) AS grace_period_amount -- Daily rate multiplied by 7 days for grace period
	FROM kenya.daily_customer_snapshot dcs
		LEFT JOIN kenya.customer c ON c.account_id = dcs.account_id
	WHERE dcs.date_timestamp::DATE = c.customer_active_start_date::DATE + 1 -- Grace period starts the day after installation
) -- Main query to combine data from the CTEs and calculate total payments
SELECT dcs.payg_account_id,
	-- Unique customer account ID
	p.expected,
	-- Total expected amount for the customer
	g.grace_period_amount,
	-- Amount accounted for during the grace period
	SUM(dcs.total_paid_to_date) AS total_paid -- Total amount paid by the customer to date
FROM kenya.daily_customer_snapshot dcs
	LEFT JOIN expected_payments p ON dcs.payg_account_id = p.payg_account_id -- Join on expected payments
	LEFT JOIN grace_period g ON dcs.payg_account_id = g.payg_account_id -- Join on grace period amounts
WHERE dcs.date_timestamp::DATE = '20231231' -- Filter for the snapshot date (end of year)
GROUP BY dcs.payg_account_id,
	p.expected,
	g.grace_period_amount -- Group by customer account ID, expected payments, and grace period amount