-- Retrieve customer details, including their status and product information
SELECT o.shop_name,
	-- Name of the shop associated with the customer
	eoc.erp_customer_id,
	-- ERP customer ID from the esf_only_customers table
	c.current_customer_status,
	-- Current status of the customer from the customer table
	eoc.customer_final_status,
	-- Final status of the customer from the esf_only_customers table
	eoc.number_of_products,
	-- Number of products associated with the customer
	eoc.incomplete_product_count,
	-- Count of products that are incomplete
	eoc.current_daily_rate,
	-- Current daily rate from the esf_only_customers table
	eoc.esf_route,
	-- Route information from the esf_only_customers table
	eoc.opt_out_recorded_date::DATE,
	-- Date when the customer opted out
	eoc.opt_out_route,
	-- Route information related to opting out
	eoc.customer_active_end_date::DATE -- Date when the customer's activity ended
FROM kenya.esf_only_customers eoc
	LEFT JOIN kenya.customer c ON c.unique_account_id = eoc.erp_customer_id -- Join on ERP customer ID
	LEFT JOIN kenya.organisation o ON o.organisation_id = c.organisation_id -- Join on organisation ID
	--LIMIT 5  -- Uncomment to limit the output to the first 5 rows