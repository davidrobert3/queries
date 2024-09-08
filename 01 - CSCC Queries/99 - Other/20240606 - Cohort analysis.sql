-----------------------------------------------------
-- 1. Get customer performance data by calculating days on, days active, and expected collections.
-----------------------------------------------------
WITH customer_performance AS (
	-- Retrieve customer performance based on daily customer snapshot data
	SELECT -- Group the data by month based on the date of the snapshot
		date_trunc('month', dcs.date_timestamp::DATE)::DATE AS month_,
		dcs.payg_account_id,
		-- Unique account ID (PAYG account)
		-- Get the maximum daily rate for the customer during the month
		MAX(dcs.daily_rate) AS daily_rate,
		-- Count the number of days the customer had a "normal" payment status
		SUM(
			CASE
				WHEN dcs.payment_status LIKE 'normal' THEN 1
				ELSE 0
			END
		) AS days_on,
		-- Count the number of days the customer was active during the month
		SUM(
			CASE
				WHEN dcs.customer_status LIKE 'active' THEN 1
				ELSE 0
			END
		) AS days_active
	FROM kenya.daily_customer_snapshot dcs -- Table containing daily customer snapshot data
	WHERE -- Filter for data starting from January 1, 2024
		dcs.date_timestamp::DATE >= '2024-01-01'
		AND dcs.date_timestamp::DATE <= current_date::DATE -- Up to the current date
		AND dcs.payg_account_id IN (
			-- Only include customers whose active start date is from 2024 onwards
			SELECT unique_account_id
			FROM kenya.customer c
			WHERE c.customer_active_start_date::DATE >= '2024-01-01'
		)
	GROUP BY 1,
		-- Group by month
		2 -- Group by PAYG account ID
),
-----------------------------------------------------
-- 2. Calculate expected collections and usage rate (UR) for each customer.
-----------------------------------------------------
customer_ur AS (
	SELECT *,
		-- All columns from customer_performance
		-- Calculate expected collections as the product of daily rate and days active
		daily_rate * days_active AS expected_collections,
		-- Calculate Usage Rate (UR) as the ratio of days on to days active
		days_on::float / days_active::float AS UR
	FROM customer_performance -- Use the previously defined customer_performance CTE
) -----------------------------------------------------
-- 3. Retrieve customer performance data with their active start dates.
-----------------------------------------------------
SELECT ur.*,
	-- All columns from customer_ur
	c.customer_active_start_date::DATE -- Include the customer's active start date
FROM customer_ur AS ur -- Join with customer data to get the active start date
	LEFT JOIN kenya.customer c ON ur.payg_account_id = c.unique_account_id;