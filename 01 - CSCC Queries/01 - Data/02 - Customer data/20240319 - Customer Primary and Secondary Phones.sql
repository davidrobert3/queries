-------- -- get customers
WITH customer_details AS (
      SELECT DISTINCT cpd.unique_account_id,
            cpd.customer_phone_1,
            cpd.customer_phone_2
      FROM kenya.customer_personal_details cpd
      GROUP BY 1,
            2,
            3
)
SELECT substring(cpd.customer_phone_1, 2, 13) AS phone_1,
      substring(cpd.customer_phone_2, 2, 13) AS phone_2,
      cpd.unique_account_id
FROM customer_details cpd -- limit 5
--where cpd.unique_account_id = 'BXCK21340538'