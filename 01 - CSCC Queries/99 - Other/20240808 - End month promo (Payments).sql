select 
	c.unique_account_id as sales_order_id,
	p.contract_reference ,
	p.amount ,
	p.subsidy_amount ,
	p.payment_utc_timestamp::DATE,
	p.reconciliation_utc_timestamp::DATE,
	p.third_party_payment_ref_id ,
	p.processing_status ,
	p.reconciliation_status ,
	p.matching_type ,
	s.credit_price 
from kenya.payment p 
left join kenya.sales s on
	s.account_id = p.account_id
left join kenya.customer c on
	c.account_id = p.account_id 
where p.payment_utc_timestamp::DATE >= '20240719'
and p.payment_utc_timestamp::DATE <= '20240722'
and p.is_void is false
and p.is_bonus is false
and p.is_refunded is false
and p.is_down_payment is false
and p.processing_status !~ 'draft'
and p.reconciliation_status !~ 'unmatched'