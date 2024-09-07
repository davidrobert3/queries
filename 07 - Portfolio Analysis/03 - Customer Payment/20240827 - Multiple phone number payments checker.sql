with count_of_payments as 
(
	select 
		distinct ap.payer_identifier ,
		count(distinct ap.payg_account_id) as number_of_accounts
	from src_odoo13_kenya.account_payment ap 
	where ap.payment_date::DATE >= '20240715'
	and ap.payment_status like 'matched'
	and ap.state like 'posted'
	and ap.payer_identifier is not null
	group by 1
),
payments as
(
	select 
		p.third_party_payment_ref_id as ref_number
	from kenya.payment p 
	where p.payment_utc_timestamp::DATE >= '20240715'
	and p.is_down_payment is true 
)
select 
	count_.*,
	pay.transaction_reference ,
	pay.payg_account_id ,
	pay.payment_date::DATE ,
	 p.ref_number ,
	sum(pay.amount) 
from count_of_payments count_
left join src_odoo13_kenya.account_payment pay on
	pay.payer_identifier = count_.payer_identifier
	and pay.payment_date::DATE >= '20240715'
	and pay.payment_status like 'matched'
	and pay.state like 'posted'
left join payments p on
	pay.transaction_reference = p.ref_number 
where count_.number_of_accounts > 1
group by 1,2,3,4,5,6