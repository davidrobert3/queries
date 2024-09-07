--select *
--from mpesa_screening_results msr 
--limit 5
--

select 
	assessment_date,
	screened_phone_number,
	pdf_name as name_mpesa_statement,
	eligible_discounts ,
	approver ,
	unique_customer_id ,
	customer_name,
	customer_phone_1 ,
	customer_phone_2 ,
	down_payment_date ,
	"customer_active_start-date" as installation_date,
	shop ,
	sales_agent_names ,
	current_system ,
	screening_flag ,
	customer_check ,
	eligibility_criteria 
from mpesa_screening_screened_phone_numbers msspn
left join mpesa_screening_results msr on
	msr.phone_number_2_screened = msspn.modified_phone_number 
left join mpesa_screening_results msr2 on
	msr2.phone_number_2_screened = msspn.modified_phone_number 
--limit 5