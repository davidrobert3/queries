select cpd.unique_account_id,
	cpd.customer_name,
	c.current_customer_status,
	substring(cpd.customer_phone_1, 2, 13) as customer_phone_1,
	substring(cpd.customer_phone_2, 2, 13) as customer_phone_2,
	c.customer_active_start_date::DATE,
	look.down_payment_date::date,
	c.cre
from kenya.customer_personal_details cpd
	left join kenya.customer c on c.account_id = cpd.account_id
	left join kenya.rp_portfolio_customer_lookup look on look.account_id = c.account_id
where cpd.unique_account_id notnull