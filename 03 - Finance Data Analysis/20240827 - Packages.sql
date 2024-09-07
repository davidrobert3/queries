select distinct 
	bom2.pakg_name ,
	s.contract_type ,
	s.downpayment ,
	s.total_value ,
	s.credit_price --,
--	bom2.record_active_start_date::DATE ,
--	bom2.record_active_end_date::DATE 
from kenya.bill_of_material bom2 
left join kenya.sales s on
	s.product_id = bom2.pakg_product_id 
--limit 500