select 
	dcs.payg_account_id ,
	dcs.daily_rate ,
	dcs.total_due_to_date ,
	dcs.total_paid_to_date ,
	dcs.total_left_to_pay ,
	dcs.total_due_to_date - dcs.total_paid_to_date as amount_not_paid
from kenya.daily_customer_snapshot dcs 
where dcs.date_timestamp::DATE = date_trunc('month', current_date::DATE)::DATE