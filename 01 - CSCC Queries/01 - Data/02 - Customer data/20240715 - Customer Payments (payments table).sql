--------------------------------------------
---- get payments made within the month
SELECT c.unique_account_id AS payg_account_id,
	p.payment_utc_timestamp::DATE AS payment_date,
	sum(p.amount)
FROM kenya.payment p
	LEFT JOIN kenya.customer c ON c.account_id = p.account_id
WHERE p.payment_utc_timestamp::DATE >= '20240401'
	AND p.is_void IS FALSE
	AND p.is_bonus IS FALSE
	AND p.is_refunded IS FALSE
	AND p.is_down_payment IS FALSE
GROUP BY 1,
	2
ORDER BY payment_date DESC