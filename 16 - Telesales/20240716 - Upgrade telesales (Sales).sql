SELECT 
distinct case 
	when s.unique_account_id isnull
		then sales_order_id
	else s.unique_account_id 
end as unique_account_id ,
	billing_method_name ,
	substring(UPPER(s.sales_person), 0, 7) AS sales_person ,
	sa.sales_agent_name,
	s.sale_created_date::DATE,
	s.downpayment_paid_utc_timestamp::DATE,
	s.current_order_status, 
	s.customer_product_action_type ,
	s.tv_subtype ,
	o.shop_name 
FROM kenya.sales s
LEFT JOIN kenya.sales_agent sa ON
	s.sales_agent_id  = sa.sales_agent_id 
LEFT JOIN kenya.customer c ON
	c.account_id = s.account_id 
LEFT JOIN kenya.organisation o ON 
	o.organisation_id = c.organisation_id 
WHERE 
--substring(UPPER(s.sales_person), 0, 7) in ('KE7500', 'KE7501', 'KE7561', 'KE7982', 'KE7983')
--AND 
(s.sale_created_date::DATE >= '20240701'
OR s.downpayment_paid_utc_timestamp::DATE >= '20240701')
and s.current_order_status in ('finished', 'active', 'pending_fulfillment')
ORDER BY s.downpayment_paid_utc_timestamp::DATE DESC
--LIMIT 5