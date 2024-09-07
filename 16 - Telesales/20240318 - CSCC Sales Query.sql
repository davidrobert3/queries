---------------------------------------------
-- getting the number of sales with a specified period of time
-------------------------------------------------------
SELECT 
		c.unique_account_id ,
		s.shop ,
		s.sale_type ,
		s.downpayment_date::DATE,
		s.install_date::DATE,
		s.current_contract_status ,
		s.sale_subtype ,
		s.product_name ,
		upper(substring(s.sales_person, 0, 7)) AS sales_agent_code
FROM
	kenya.rp_retail_sales s
left join kenya.customer c on
	c.account_id = s.account_id 
WHERE
	s.downpayment_date::DATE >= '20240701' --<--- start date
--	and s.downpayment_date::DATE <= '20240701' -- <-- end date