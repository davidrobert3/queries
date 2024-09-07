with last_payment_date as
(
	select
		ap.payg_account_id,
		max(ap.transaction_date) as max_date
	from 
		src_odoo13_kenya.account_payment ap 
	where 
		ap.payg_account_id like 'BXCK05333636' --<--- search by customer BXCK
--		ap.transaction_reference like 'SE77JD3H73' --<-- search by payment transaction reference
	group by 1
)
SELECT 
	ap.payg_account_id ,
	ap.transaction_date::DATE ,
	case 
		when ap.state like 'draft'
			then 'Overpayment'
		else 'Posted'
	end as isOverPayment,
	ap.amount ,
	ap.transaction_reference 
FROM last_payment_date
left join src_odoo13_kenya.account_payment ap on
	ap.payg_account_id = last_payment_date.payg_account_id 
	and last_payment_date.max_date = ap.transaction_date 
order by ap.state desc 