-- Current Portfolio Bonus Query for Retail Monthly Payments (16th to 15th of every month)
-- To get the Deposits 
with downpayments as (
	select customer_id,
		unique_account_id,
		sum(total_downpayment) as total_downpayment
	from kenya.rp_retail_sales
	where downpayment_date::date >= current_date::DATE - 180
		and downpayment_date::date <= current_date::DATE
	group by 1,
		2
),
-- To get the Payments within the most recent 6 months (excluding DP)
payments as (
	select payments.sales_order_id,
		SUM(amount) - coalesce(downpayments.total_downpayment, 0) as repayments,
		downpayments.total_downpayment
	from kenya.payment as payments
		left join downpayments as downpayments on downpayments.unique_account_id = payments.sales_order_id
		left join kenya.customer as customer on customer.unique_account_id = payments.sales_order_id
	where payments.processing_status = 'posted'
		and payments.is_void = false
		and payments.payment_utc_timestamp::DATE >= current_date::DATE - 180
		and payments.payment_utc_timestamp::DATE <= current_date::DATE
	group by payments.sales_order_id,
		downpayments.total_downpayment
),
-- To get current active customers
active as (
	select dcs.date_timestamp::date as activity_date,
		dcs.account_id,
		details.customer_name,
		details.customer_phone_1,
		details.customer_phone_2,
		details.customer_home_address as nearest_landmark,
		details.home_address_4 as locations,
		details.home_address_3 as constituency,
		customer.unique_account_id,
		dcs.consecutive_late_days,
		dcs.expiry_timestamp::date as expiry_date,
		dcs.daily_rate,
		dcs.total_left_to_pay,
		customer.customer_active_end_date,
		customer.customer_active_start_date::text::date as installation_date,
		least(
			(
				(
					current_date::DATE - (customer.customer_active_start_date::DATE + 7)
				)::BIGINT
			),
			180
		) as days_expected
	from kenya.daily_customer_snapshot dcs
		left join kenya.customer as customer on customer.account_id = dcs.account_id
		left join kenya.customer_personal_details as details on details.account_id = customer.account_id
	where customer.customer_final_status is null
		and dcs.date_timestamp::DATE = current_date::DATE
		and upper(details.customer_name) not like '%OPTED%'
),
-- To get the collection rate for the last 6 months from current date 		
collection_rate as (
	select active.activity_date,
		active.account_id,
		active.customer_name,
		active.customer_phone_1,
		active.customer_phone_2,
		active.nearest_landmark,
		active.locations,
		active.constituency,
		active.unique_account_id,
		active.daily_rate,
		active.total_left_to_pay,
		active.customer_active_end_date,
		look.current_hardware_type,
		look.shop,
		look.region,
		active.installation_date,
		active.consecutive_late_days,
		active.days_expected,
		active.expiry_date,
		look.tv_customer,
		coalesce(repayments.repayments, 0) as six_month_repayments,
		repayments.repayments / nullif((active.days_expected * active.daily_rate), 0) as six_month_collection_rate,
		row_number() over (partition by active.unique_account_id) as row_numbers
	from active as active
		left join payments as repayments on repayments.sales_order_id = active.unique_account_id
		left join kenya.rp_portfolio_customer_lookup as look on look.account_id = active.account_id
),
-- Downpayments for the most recent 30 days 
last_30_downpayments as (
	select customer_id,
		unique_account_id,
		sum(total_downpayment) as total_downpayment
	from kenya.rp_retail_sales
	where downpayment_date::date >= current_date::DATE - 30
		and downpayment_date::date <= current_date::DATE
	group by 1,
		2
),
-- To get the collection rate in the last 30 days
last_30_day_CR as (
	select payments.sales_order_id,
		sum(amount) - (
			coalesce(last_30_downpayments.total_downpayment, 0)
		) as payments
	from kenya.payment as payments
		left join last_30_downpayments as last_30_downpayments on last_30_downpayments.unique_account_id = payments.sales_order_id
	where payments.processing_status = 'posted'
		and payments.is_void = false
		and payments.payment_utc_timestamp::DATE >= current_date::DATE - 30
		and payments.payment_utc_timestamp::DATE <= current_date::DATE
	group by payments.sales_order_id,
		last_30_downpayments.total_downpayment
),
-- Combines the 30 day collection rate and the 60 day collection rate 
dataset as (
	select collection_rate.activity_date,
		collection_rate.unique_account_id,
		collection_rate.customer_name,
		collection_rate.customer_phone_1,
		collection_rate.customer_phone_2,
		collection_rate.nearest_landmark,
		collection_rate.locations,
		collection_rate.constituency,
		collection_rate.daily_rate,
		collection_rate.current_hardware_type,
		collection_rate.shop,
		collection_rate.total_left_to_pay,
		coalesce(collection_rate.six_month_collection_rate, 0) as six_month_collection_rate,
		collection_rate.customer_active_end_date,
		collection_rate.installation_date,
		collection_rate.six_month_repayments,
		last_30_day_CR.payments as last_30_day_repayments,
		collection_rate.days_expected,
		coalesce(last_30_day_CR.payments, 0) / nullif((collection_rate.daily_rate * 30), 0) as last_30_day_CR,
		collection_rate.consecutive_late_days,
		collection_rate.expiry_date,
		collection_rate.tv_customer,
		case
			when collection_rate.installation_date + 8 > collection_rate.activity_date then 'New Customer'
			else 'Older Customer'
		end as customer_age_tag
	from collection_rate as collection_rate
		left join last_30_day_CR as last_30_day_CR on last_30_day_CR.sales_order_id = collection_rate.unique_account_id
),
-- Assigning customer segments 
completedata as (
	select *,
		case
			when dataset.consecutive_late_days >= 0
			and dataset.consecutive_late_days < 30
			and (
				dataset.six_month_collection_rate >= 0.66667
				or (
					dataset.six_month_collection_rate < 0.66667
					and dataset.last_30_day_CR >= 0.6667
				)
			)
			and dataset.customer_age_tag = 'Older Customer' then 'Good Payer'
			when (
				dataset.six_month_collection_rate < 0.66667
				and dataset.consecutive_late_days < 30
				and dataset.last_30_day_CR < 0.6667
				and dataset.customer_age_tag = 'Older Customer'
			)
			or (
				dataset.six_month_collection_rate < 0.66667
				and dataset.consecutive_late_days < 30
				and dataset.customer_age_tag = 'Older Customer'
				and dataset.last_30_day_CR is null
			) then 'Slow Payer_Locked Rewards'
			when dataset.consecutive_late_days >= 30
			and dataset.consecutive_late_days < 60
			and dataset.customer_age_tag = 'Older Customer' then 'Late_30-59'
			when dataset.consecutive_late_days >= 60
			and dataset.consecutive_late_days < 120
			and dataset.customer_age_tag = 'Older Customer' then 'Defaulted_60-119'
			when dataset.consecutive_late_days >= 120
			and dataset.customer_age_tag = 'Older Customer' then 'Legacy Customer'
			when dataset.customer_age_tag = 'New Customer' then 'New Customers'
			else 'Unaccounted for bucket'
		end as CustomerSegment
	from dataset as dataset
),
-- Assigns the Rewards and Penalties for PB Calcs
data_with_bonuses as (
	select *,
		case
			when CustomerSegment = 'Good Payer' then 1.0 * daily_rate
			else 0
		end as GoodPayerReward,
		case
			when CustomerSegment = 'Slow Payer_Locked Rewards' then 1.0 * daily_rate
			else 0
		end as SlowPayerLockedRewards,
		case
			when CustomerSegment = 'Late_30-59' then -7 * daily_rate
			else 0
		end as LatePenalty,
		case
			when CustomerSegment = 'Defaulted_60-119' then -14 * daily_rate
			else 0
		end as DefaulterPenalty
	from completedata
),
-- Labeling customers as good payers, slowpayers, late or defaulted 
customer_categories as (
	select *,
		LatePenalty + DefaulterPenalty as total_penalty,
		GoodPayerReward + LatePenalty + DefaulterPenalty as actual_bonus,
		case
			when GoodPayerReward > 0 then 1
			else 0
		end as GoodPayerStatus,
		case
			when SlowPayerLockedRewards > 0 then 1
			else 0
		end as SlowPayerStatus,
		case
			when LatePenalty < 0 then 1
			else 0
		end as LateStatus,
		case
			when DefaulterPenalty < 0 then 1
			else 0
		end as DefaulterStatus
	from data_with_bonuses
),
-- Customer Eligibility Criteria for PB bonus calculations 
eligible_status as (
	select customer_categories.*,
		case
			when GoodPayerStatus = 1 then 1
			when SlowPayerStatus = 1 then 1
			when LateStatus = 1 then 1
			when DefaulterStatus = 1 then 1
			else 0
		end as EligibleStatus
	from customer_categories
),
initial_data as (
	select eligible_status.*,
		case
			when EligibleStatus = 1 then 1.0 * daily_rate
			else 0
		end as MaxBonusAmount,
		case
			when consecutive_late_days > 8
			and consecutive_late_days < 30 then 1
			else 0
		end as PrePenaltyStatus,
		case
			when consecutive_late_days > 8
			and consecutive_late_days < 30 then -7 * daily_rate
			else 0
		end as PrePenaltyPotentialPenalty
	from eligible_status
),
-- Feb 16th amendments to automate the excel filters
-- 1. Identify the ESF Defaulters
-- 2. Identify the Sept Free Ontime Customers  
-- 3. Identify the Dec Free Ontime Customers 
-- Checking for any payments made by the free ontime customers 
-- Adding filter columns to the initial data
initial_data_with_filter_columns as (
	select *,
		case
			when daily_rate < 21
			and consecutive_late_days > 59 then 1
			else 0
		end as esf_defaulters
	from initial_data
),
-- Adding legacy repos 
legacy_repos as (
	select current_date::DATE::DATE as activity_date,
		rpcl.unique_customer_id as unique_account_id,
		null as customer_name,
		null as customer_phone_1,
		null as customer_phone_2,
		null as nearest_landmark,
		null as locations,
		null as consituency,
		fcs.daily_rate,
		null as current_hardware_type,
		rpcl.shop,
		null::int as total_left_to_pay,
		null::int as six_month_collection_rate,
		rpcl.customer_active_end_date::DATE,
		null::date as installation_date,
		null::int as six_month_repayments,
		null::int as last_30_day_repayments,
		null::int as days_expected,
		null::int as last_30_day_cr,
		fcs.consecutive_late_days,
		null::date as expiry_date,
		null as tv_customer,
		null as customer_age_tag,
		null as customersegment,
		(fcs.daily_rate * 14) as goodpayerreward,
		null::int as slowpayerlockedrewards,
		null::int as latepenalty,
		null::int as defaulterpenalty,
		null::int as total_penalty,
		(fcs.daily_rate * 14) as actual_bonus,
		null::int as goodpayerstatus,
		null::int as slowpayerstatus,
		null::int as latestatus,
		null::int as defaulterstatus,
		null::int as eligiblestatus,
		null::int as maxbonusamount,
		null::int as prepenaltystatus,
		null::int as prepenaltypotentialpenalty,
		null::int as esf_defaulters
	from kenya.rp_portfolio_customer_lookup rpcl
		left join kenya.final_customer_snapshot fcs on rpcl.account_id = fcs.account_id
	where rpcl.customer_active_end_date >= '20240916'
		and rpcl.customer_active_end_date <= current_date::DATE - 1
		and rpcl.current_client_status = 'repo'
		and --	    (
		lower(rpcl.repo_technician) not like '%mabonga%' --or lower(rpcl.repo_technician) not like '%vincent koech%')
		and fcs.consecutive_late_days >= 120
	group by 1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		18,
		19,
		20,
		21,
		23,
		24,
		25,
		26,
		27,
		28,
		29,
		30,
		31,
		32
),
full_data as (
	select *
	from initial_data_with_filter_columns
	where esf_defaulters = 0 -- Including free ontime customers who have made a payment
		--	limit 5
	union all
	select *
	from legacy_repos
),
---------------------------------------------------
-- New region assignment
region_assignment as (
	select full_data.*,
		case
			when full_data.shop in ('Nakuru', 'Kabarnet', 'Isiolo', 'Muranga') then 'Central'
			when full_data.shop in ('Kwale', 'Hola', 'Kilifi', 'Malindi') then 'Coast'
			when full_data.shop in ('Kibwezi', 'Voi', 'Oloitoktok', 'Wote') then 'Eastern 1'
			when full_data.shop in (
				'Tharaka Nithi',
				'Matuu',
				'Kitui',
				'Machakos',
				'Kajiado'
			) then 'Eastern 2'
			when full_data.shop in (
				'Kakuma',
				'Kitale',
				'Eldoret',
				'Kipkaren',
				'Kapsabet',
				'Kapenguria'
			) then 'North Rift'
			when full_data.shop in ('Mbita', 'Homa Bay', 'Magunga', 'Kendu Bay') then 'Nyanza 1'
			when full_data.shop in ('Rongo', 'Ndhiwa', 'Migori') then 'Nyanza 2'
			when full_data.shop in ('Katito', 'Kipsitet', 'Oyugis', 'Chepseon') then 'South Rift 1'
			when full_data.shop in ('Narok', 'Bomet', 'Nyangusu') then 'South Rift 2'
			when full_data.shop in ('Butere', 'Bungoma', 'Luanda', 'Kakamega') then 'Western 1'
			when full_data.shop in ('Bumala', 'Bondo', 'Busia', 'Siaya') then 'Western 2'
		end as new_region
	from full_data
)
select *
from region_assignment