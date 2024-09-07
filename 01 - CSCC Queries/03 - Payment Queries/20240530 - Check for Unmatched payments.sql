select 
	ap.payment_date::DATE,
	ap.transaction_reference ,
	ap.amount ,
	ap.payer_identifier
from src_odoo13_kenya.account_payment ap 
where 
ap.payment_date::DATE >= '20240401'
and len(ap.payer_identifier) > 16
and ap.payment_status ~~ 'unmatched'
and ap.state !~~ 'cancelled'