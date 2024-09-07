select
	payments.sales_order_id as payg_account_id,
	SUM(amount)
from
	kenya.payment as payments
where
	payments.is_void is false
	and payments.third_party_payment_ref_id not like '%BONUS%'
	and payments.payment_utc_timestamp :: DATE between (case
		when to_char(current_date,
		'Day') like 'Monday'
		then current_date - 7
		when to_char(current_date,
		'Day') like 'Tuesday'
		then current_date - 1
		when to_char(current_date,
		'Day') like 'Wednesday'
		then current_date - 2
		when to_char(current_date,
		'Day') like 'Thursday'
		then current_date - 3
		when to_char(current_date,
		'Day') like 'Friday'
		then current_date - 4
		when to_char(current_date,
		'Day') like 'Saturday'
		then current_date - 5
		when to_char(current_date,
		'Day') like 'Sunday'
		then current_date - 6
	end)
        and CURRENT_DATE
group by
	payments.sales_order_id
