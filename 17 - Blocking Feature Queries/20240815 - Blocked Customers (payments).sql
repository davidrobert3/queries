--------------------------------------------
---- get payments made within the month
select
      ap.payg_account_id,
      ap.payment_date::date,
      sum(ap.amount)
from
      src_odoo13_kenya.account_payment ap
where
      ap.state = 'posted'
      and ap.payment_status = 'matched'
      and ap."type" = 'mobile'
      and ap.payment_date :: DATE >= '20240814' --<-- start date
--      and ap.payment_date::DATE <= '20240430' --<-- end date
group by
      1,
      2
ORDER BY payment_date DESC