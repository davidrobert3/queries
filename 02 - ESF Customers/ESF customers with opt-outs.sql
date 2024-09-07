SELECT 
	o.shop_name ,
	erp_customer_id ,
	c.current_customer_status ,
	eoc.customer_final_status ,
	number_of_products ,
	incomplete_product_count ,
	current_daily_rate ,
	esf_route ,
	opt_out_recorded_date ::DATE,
	opt_out_route ,
	eoc.customer_active_end_date::DATE
FROM kenya.esf_only_customers eoc
LEFT JOIN kenya.customer c 
	ON c.unique_account_id = eoc.erp_customer_id 
LEFT JOIN kenya.organisation o ON 
	o.organisation_id = c.organisation_id 
--LIMIT 5