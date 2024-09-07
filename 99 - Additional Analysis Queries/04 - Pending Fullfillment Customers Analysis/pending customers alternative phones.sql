----------
--get the fisrt downpayment date
with first_payment_date as 
	(
		select 
			ap.payg_account_id ,
			min(ap.payment_date::date) as min_payment_date
		from src_odoo13_kenya.account_payment ap 
		where len(ap.payer_identifier) between 10 and 14
		and upper(ap.payer_identifier) not like '%BXCK%'
		group by 1
	),
--------------
-- gets the phone numbers used to pay
dp_phone_numbers as
	(
		select 
		distinct ap.payg_account_id ,
				ap.payer_identifier as dp_phone_number ,
				ap.account_identifier
		from first_payment_date
		left join src_odoo13_kenya.account_payment ap on
		ap.payg_account_id = first_payment_date.payg_account_id
		where ap.payment_date::DATE = first_payment_date.min_payment_date
		group by 1, ap.payer_identifier, ap.account_identifier
	)
--------
-- Main query
	select 
		distinct c.unique_account_id ,
		c.current_customer_status ,
		cpd.customer_name,
		cpd.customer_phone_1 ,
		cpd.customer_phone_2 ,
		dp_phone_numbers.dp_phone_number ,
--		dp_phone_numbers.account_identifier,
		s.shop ,
		sa.sales_agent_name ,
		case 
			when len(sa.sales_agent_bboxx_id) > 7
			then upper(substring(sa.sales_agent_bboxx_id, 0, 7))
			else upper(sa.sales_agent_bboxx_id)
		end as sales_code
from kenya.customer c 
left join dp_phone_numbers on 
c.unique_account_id = dp_phone_numbers.payg_account_id
left join kenya.rp_retail_sales s on 
c.account_id = s.account_id 
left join kenya.customer_personal_details cpd on 
c.account_id = cpd.account_id
left join kenya.employee e on
c.sign_up_employee_id = e.employee_id
left join kenya.sales_agent sa on
c.sign_up_sales_agent_id = sa.sales_agent_id 
where c.current_customer_status = 'pending_fulfillment'