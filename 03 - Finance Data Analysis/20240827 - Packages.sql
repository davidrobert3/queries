-- Select distinct records to avoid duplicates
SELECT DISTINCT bom2.pakg_name,
	-- Name of the package from the bill of materials
	s.contract_type,
	-- Type of sales contract
	s.downpayment,
	-- Amount of downpayment for the sale
	s.total_value,
	-- Total value of the sale
	s.credit_price -- Price of the product on credit
	-- Uncomment the lines below if needed for additional information
	-- bom2.record_active_start_date::DATE,  -- Start date when the record became active
	-- bom2.record_active_end_date::DATE  -- End date when the record was no longer active
FROM kenya.bill_of_material bom2
	LEFT JOIN kenya.sales s ON s.product_id = bom2.pakg_product_id -- Join sales records with the bill of materials based on product ID
	-- Uncomment the line below to limit the result to the first 500 records
	-- LIMIT 500