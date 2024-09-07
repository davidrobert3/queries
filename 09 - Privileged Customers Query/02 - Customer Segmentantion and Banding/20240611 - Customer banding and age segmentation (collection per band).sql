SELECT 
--	ccp.payment_date ,
--	pc.ur_bands ,
--	pc.batch ,
--	sum(ccp.sum),
	count(DISTINCT ccp.payg_account_id)
FROM privilege_customer pc 
LEFT JOIN cscc_collection_payments ccp ON
	pc.payg_account_id = ccp.payg_account_id 
WHERE 
ccp.payg_account_id NOTNULL
AND pc.batch = 3
AND ccp.payment_date BETWEEN '20240710' AND '20240716'
--GROUP BY 1,2,3


SELECT count(DISTINCT pc.payg_account_id)
FROM privilege_customer pc 
LEFT JOIN cscc_collection_payments ccp ON
	pc.payg_account_id = ccp.payg_account_id 
WHERE ccp.sum notNULL 
AND pc.batch = 4
AND ccp.payment_date BETWEEN '20240710' AND '20240716'