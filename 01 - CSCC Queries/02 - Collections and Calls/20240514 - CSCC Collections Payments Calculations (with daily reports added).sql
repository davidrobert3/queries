-----------------------------------------------------
-- 1. get all calls made to customers by the collections team.
------------------------------------------------------------
WITH call_log_data AS (
	SELECT
		call_time :: DATE,
		caller_id,
		destination,
		status,
		talking,
		SUBSTRING(
			STRING_AGG(ccp.unique_customer_id :: TEXT, ', '),
			0,
			13
		) AS unique_customer_id_1,
		SUBSTRING(
			STRING_AGG(ccp2.unique_customer_id :: TEXT, ', '),
			0,
			13
		) AS unique_customer_id_2,
		SUBSTRING(STRING_AGG(ccap.payg_account_id, ', '), 0, 13) AS unique_customer_id_3
	FROM
		cscc_3cx_daily_report ccdr
		LEFT JOIN cscc_customer_phone ccp ON ccdr.destination = ccp.phone_1 :: TEXT
		LEFT JOIN cscc_customer_phone ccp2 ON ccdr.destination = ccp2.phone_2 :: TEXT
		LEFT JOIN cscc_customer_alt_phones ccap ON ccdr.destination = ccap.alt_phone :: TEXT
	WHERE
		caller_id IN (
			'Fidelis Wanja (026)',
			'Tresy Onchong''a (049)',
			'Faith Okoth (013)',
			'Emily Mwirigi (052)',
			'Mercy Gogo (056)',
			'Quenter Akoth (040)'
		)
		AND talking >= '00:00:15' --		AND call_time::DATE >= '2024-06-01'
		--		AND call_time::DATE <= '2024-06-30'
	GROUP BY
		1,
		2,
		3,
		4,
		5
),
-----------------------------------------------------------
-- 2. merge the unique customer ids into one column
------------------------------------------------------------------
customer_to_call_assignment AS (
	SELECT
		call_time,
		caller_id,
		destination,
		status,
		talking,
		CASE
			WHEN unique_customer_id_1 NOTNULL then unique_customer_id_1
			WHEN unique_customer_id_1 ISNULL
			AND unique_customer_id_2 NOTNULL THEN unique_customer_id_2
			WHEN unique_customer_id_1 ISNULL
			AND unique_customer_id_2 isnull
			AND unique_customer_id_3 NOTNULL THEN unique_customer_id_3
			ELSE NULL
		END AS BXCK
	FROM
		call_log_data --	where destination like '254768116540'	
),
--------------------------------------------------------------------
----- 3. main query to get the final data on call logs and customers called
--------------------------------------------------------------------------------
call_details as (
	SELECT
		call_time :: DATE AS call_date,
		caller_id AS Agent_Name,
		destination AS Customer_Phone_Number,
		talking,
		BXCK AS unique_customer_id,
		ROW_NUMBER() OVER (
			PARTITION BY BXCK
			ORDER BY
				call_time :: DATE DESC
		) AS number_of_times_called
	FROM
		customer_to_call_assignment
	WHERE
		bxck NOTNULL --	group by 1
		--
),
------------------------------------------------------------------------------------------
-- 4. Retrieve the last agent to call the customer -----------------------------------------
---------------------------------------------------------------------------------------
last_agent_to_call_customer AS (
	SELECT
		*
	FROM
		call_details
	WHERE
		number_of_times_called = 1
),
---------------------------------------------------------------------------------------------
-- 3. Get all the customer payments made in the month of report ----------------------------
------------------------------------------------------------------------------------------------
payments AS (
	SELECT
		payg_account_id,
		payment_date :: DATE AS payment_date,
		sum AS Amount_Paid
	FROM
		cscc_collection_payments ccp
		right join customer_to_call_assignment on customer_to_call_assignment.BXCK = ccp.payg_account_id --    where payment_date::DATE between '20240601' and '20240630'
),
---------------------------------------------------------------------------------------------
-- 4. Bringing everything together ---------------------------------------------------------
------------------------------------------------------------------------------------------
final_cte as (
	select
		--count(*)
		call_details.unique_customer_id || ' - ' || call_details.Agent_Name || ' - ' || call_details.Customer_Phone_Number || ' - ' || call_details.number_of_times_called AS index_,
		call_details.unique_customer_id,
		call_details.Agent_Name,
		call_details.Customer_Phone_Number,
		call_details.Call_Date,
		payments.payment_date,
		payments.Amount_Paid,
		ROW_NUMBER() OVER (
			PARTITION BY payments.payg_account_id,
			payments.payment_date
		) AS payment_number
	FROM
		call_details
		LEFT JOIN payments ON payments.payg_account_id = call_details.unique_customer_id
		AND payments.payment_date >= call_details.call_date
		LEFT JOIN last_agent_to_call_customer ON last_agent_to_call_customer.unique_customer_id = call_details.unique_customer_id --where call_details.unique_customer_id = 'BXCK77077546'
)
select
	*
from
	final_cte
where
	payment_number = 1