-- Retrieve payments made within a specified date range
SELECT ap.payg_account_id,
      -- Unique identifier for the account making the payment
      ap.payment_date::DATE,
      -- Payment date
      SUM(ap.amount) -- Total amount of payments made on the specified date
FROM src_odoo13_kenya.account_payment ap
WHERE ap.state = 'posted' -- Filter for payments that are posted
      AND ap.payment_status = 'matched' -- Filter for payments that are matched
      AND ap."type" = 'mobile' -- Filter for mobile payments
      AND ap.payment_date::DATE >= '2024-10-04' -- Start date for payments
      -- AND ap.payment_date::DATE <= '2024-08-30'  -- Uncomment to specify an end date
GROUP BY 1,
      2 -- Group by account ID and payment date
ORDER BY payment_date DESC;
-- Order results by payment date in descending order