-----------------------------------------------------
-- 1. get all calls made to customers by the collections team.
------------------------------------------------------------
-- WITH call_log_data AS
-- (
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
	5 -- )