with startimes_clients as (
	select
		distinct rrs.account_id,
		rrs.unique_account_id,
		rrs.downpayment_date,
		rrs.install_date,
		cpd.customer_name,
		cpd.customer_phone_1,
		cpd.customer_phone_2,
		cpd.customer_national_id_number,
		cpd.home_address_1,
		rrs.product_name,
		rrs.sale_type,
		rrs.downpayment,
		rrs.credit_price as DailyRate
	from
		kenya.rp_retail_sales rrs
		left join kenya.customer_personal_details cpd on rrs.account_id = cpd.account_id
	where
		(
			lower(rrs.product_name) like '%startime%' --or lower(rrs.product_name) like '%zuku%'
		)
),
total_paid_mar as (
	select
		p.payg_account_id as AccountID,
		SUM(p.amount) as TotalPaid
	from
		src_odoo13_kenya.account_payment as p
	where
		p.state = 'posted'
		and p.payment_status = 'matched'
		and p."type" = 'mobile'
		and p.transaction_date :: DATE >= '20240301' --<--- enter the specific date here
		and p.transaction_date :: DATE <= '20240331'
	group by
		p.payg_account_id
),
days_on_mar as (
	select
		account_id,
		SUM(
			case
				when consecutive_late_days = 0 then 1
				else 0
			end
		) as DaysInNormalConsecDays,
		COUNT(distinct daily_customer_snapshot_id) as DaysActive
	from
		kenya.daily_customer_snapshot dcs
	where
		dcs.date_timestamp :: DATE >= '20240301' --<--- enter the specific date here
		and dcs.date_timestamp :: DATE <= '20240331'
	group by
		dcs.account_id
),
total_paid_april as (
	select
		p.payg_account_id as AccountID,
		SUM(p.amount) as TotalPaid
	from
		src_odoo13_kenya.account_payment as p
	where
		p.state = 'posted'
		and p.payment_status = 'matched'
		and p."type" = 'mobile'
		and p.transaction_date :: DATE >= '20240401' --<--- enter the specific date here
		and p.transaction_date :: DATE <= '20240430'
	group by
		p.payg_account_id
),
days_on_april as (
	select
		account_id,
		SUM(
			case
				when consecutive_late_days = 0 then 1
				else 0
			end
		) as DaysInNormalConsecDays,
		COUNT(distinct daily_customer_snapshot_id) as DaysActive
	from
		kenya.daily_customer_snapshot dcs
	where
		dcs.date_timestamp :: DATE >= '20240401' --<--- enter the specific date here
		and dcs.date_timestamp :: DATE <= '20240430'
	group by
		dcs.account_id
),
total_paid_may as (
	select
		p.payg_account_id as AccountID,
		SUM(p.amount) as TotalPaid
	from
		src_odoo13_kenya.account_payment as p
	where
		p.state = 'posted'
		and p.payment_status = 'matched'
		and p."type" = 'mobile'
		and p.transaction_date :: DATE >= '20240501' --<--- enter the specific date here
		and p.transaction_date :: DATE <= '20240531'
	group by
		p.payg_account_id
),
days_on_may as (
	select
		account_id,
		SUM(
			case
				when consecutive_late_days = 0 then 1
				else 0
			end
		) as DaysInNormalConsecDays,
		COUNT(distinct daily_customer_snapshot_id) as DaysActive
	from
		kenya.daily_customer_snapshot dcs
	where
		dcs.date_timestamp :: DATE >= '20240501' --<--- enter the specific date here
		and dcs.date_timestamp :: DATE <= '20240531'
	group by
		dcs.account_id
),
total_paid_june as (
	select
		p.payg_account_id as AccountID,
		SUM(p.amount) as TotalPaid
	from
		src_odoo13_kenya.account_payment as p
	where
		p.state = 'posted'
		and p.payment_status = 'matched'
		and p."type" = 'mobile'
		and p.transaction_date :: DATE >= '20240601' --<--- enter the specific date here
		and p.transaction_date :: DATE <= '20240630'
	group by
		p.payg_account_id
),
days_on_june as (
	select
		account_id,
		SUM(
			case
				when consecutive_late_days = 0 then 1
				else 0
			end
		) as DaysInNormalConsecDays,
		COUNT(distinct daily_customer_snapshot_id) as DaysActive
	from
		kenya.daily_customer_snapshot dcs
	where
		dcs.date_timestamp :: DATE >= '20240601' --<--- enter the specific date here
		and dcs.date_timestamp :: DATE <= '20240630'
	group by
		dcs.account_id
),
days_on_lifetime as (
	select
		distinct dcs.account_id,
		SUM(
			case
				when consecutive_late_days = 0 then 1
				else 0
			end
		) as DaysInNormalConsecDays,
		COUNT(distinct daily_customer_snapshot_id) as DaysActive,
		(
			dcs.daily_rate * datediff(
				days,
				c.customer_active_start_date :: DATE,
				current_date :: DATE
			)
		) as TotalAmountExpected
	from
		kenya.daily_customer_snapshot dcs
		left join kenya.customer c on dcs.account_id = c.account_id
	where
		dcs.date_timestamp :: DATE >= c.customer_active_start_date :: DATE --<--- enter the specific date here
		and dcs.date_timestamp :: DATE <= current_date
	group by
		dcs.account_id,
		dcs.daily_rate,
		c.customer_active_start_date
),
total_paid_lifetime as (
	select
		p.payg_account_id as AccountID,
		SUM(p.amount) as TotalPaid
	from
		src_odoo13_kenya.account_payment as p
		left join kenya.customer c on p.payg_account_id = c.unique_account_id
	where
		p.state = 'posted'
		and p.transaction_date :: DATE >= c.customer_active_start_date :: DATE --<--- enter the specific date here
		and p.transaction_date :: DATE <= current_date :: DATE
	group by
		p.payg_account_id
)
select
	startimes_clients.*,
	total_paid_mar.TotalPaid as TotalPaidInMarch,
	days_on_mar.DaysActive as DaysActiveMarch,
	days_on_mar.DaysInNormalConsecDays as DaysOnMarch,
	total_paid_april.TotalPaid as TotalPaidInApril,
	days_on_april.DaysActive as DaysActiveApril,
	days_on_april.DaysInNormalConsecDays as DaysOnApril,
	total_paid_may.TotalPaid as TotalPaidInMay,
	days_on_may.DaysActive as DaysActiveMay,
	days_on_may.DaysInNormalConsecDays as DaysOnMay,
	total_paid_june.TotalPaid as TotalPaidInJune,
	days_on_june.DaysActive as DaysActiveJune,
	days_on_june.DaysInNormalConsecDays as DaysOnJune,
	total_paid_lifetime.TotalPaid as TotalPaidInLifetime,
	days_on_lifetime.DaysActive as DaysActiveLifetime,
	days_on_lifetime.DaysInNormalConsecDays as DaysOnLifetime
from
	startimes_clients
	left join total_paid_mar on startimes_clients.unique_account_id = total_paid_mar.AccountID
	left join days_on_mar on startimes_clients.account_id = days_on_mar.account_id
	left join total_paid_april on startimes_clients.unique_account_id = total_paid_april.AccountID
	left join days_on_april on startimes_clients.account_id = days_on_april.account_id
	left join total_paid_may on startimes_clients.unique_account_id = total_paid_may.AccountID
	left join days_on_may on startimes_clients.account_id = days_on_may.account_id
	left join total_paid_june on startimes_clients.unique_account_id = total_paid_june.AccountID
	left join days_on_june on startimes_clients.account_id = days_on_june.account_id
	left join days_on_lifetime on startimes_clients.account_id = days_on_lifetime.account_id
	left join total_paid_lifetime on startimes_clients.unique_account_id = total_paid_lifetime.AccountID --	limit 5;