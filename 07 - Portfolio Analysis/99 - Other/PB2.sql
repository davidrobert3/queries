--select * from kenya.agg_dcs_today limit 5 

with downpayments as  
	(
	select 
		customer_id,
		unique_account_id,
		sum(total_downpayment) as total_downpayment
	from kenya.rp_retail_sales 
	where 
		downpayment_date::date >= '20231216' - 180
		and downpayment_date::date <= '20231216' 
        group by 1,2
	),
	
	payments as 
	(
	select
		payments.sales_order_id,
	    SUM(amount) - coalesce(downpayments.total_downpayment,0) AS repayments, 
		downpayments.total_downpayment 
	from kenya.payment AS payments
		left join downpayments as downpayments 
			on downpayments.unique_account_id = payments.sales_order_id  
		left join kenya.customer as customer 
			on customer.unique_account_id = payments.sales_order_id 
	WHERE
		payments.processing_status = 'posted' 
		and payments.is_void  = FALSE
		AND payments.payment_utc_timestamp::DATE >= '20231216' - 180
		AND payments.payment_utc_timestamp::DATE <= '20231216'
		--and payments.sales_order_id = 'BXCK00036111'
		--and customer.unique_account_id = 'BXCK67854266'
	GROUP BY
		payments.sales_order_id,
		downpayments.total_downpayment  
	),
   
	
active as 
	(
	select 
		dcs.date_timestamp::date as activity_date,
		dcs.account_id,
		details.customer_name,
		details.customer_phone_1,
        details.customer_phone_2,
        details.customer_home_address as nearest_landmark,
		details.home_address_4 AS locations,
        details.home_address_3 AS constituency,
		customer.unique_account_id,
		dcs.consecutive_late_days,
		dcs.expiry_timestamp::date as expiry_date,
		dcs.daily_rate,		
		customer.customer_active_end_date,
		customer.customer_active_start_date::text::date as installation_date,
		LEAST((('20231216'   - (customer.customer_active_start_date::DATE + 7))::BIGINT), 180) AS days_expected
	from kenya.daily_customer_snapshot dcs 
	left join kenya.customer as customer   
		on customer.account_id = dcs.account_id
		 left join kenya.customer_personal_details as details on 
	     details.account_id = customer.account_id
	where customer.customer_final_status is null
		and dcs.date_timestamp::DATE = '20231216'
		and upper(details.customer_name) not like '%OPTED%'
		--and dcs.account_id = '1905f2f00eec4817286719b91fa33d6e'

	),
	
collection_rate as 
	(
	select
		active.activity_date,
		active.account_id,
		active.customer_name,
		active.customer_phone_1,
		active.customer_phone_2,
		active.nearest_landmark,
		active.locations,
		active.constituency,
		active.unique_account_id,
		active.daily_rate,
		active.customer_active_end_date,
		look.current_hardware_type,
		look.shop,
		look.region,
		active.installation_date,
		active.consecutive_late_days,
		active.days_expected,
		active.expiry_date,
		look.tv_customer,
		coalesce(repayments.repayments,0) as six_month_repayments,
		repayments.repayments/ nullif((active.days_expected* active.daily_rate),0) as six_month_collection_rate,
		row_number() over 
		(
		partition by active.unique_account_id
		) as row_numbers
	from active as active
		left join payments as repayments  
			on repayments.sales_order_id = active.unique_account_id
		left join kenya.rp_portfolio_customer_lookup as look  
			on look.account_id = active.account_id 
	),

last_30_downpayments as 
	(
	select 
		customer_id,
		unique_account_id,
		sum(total_downpayment) as total_downpayment
	from kenya.rp_retail_sales 
	where 
		downpayment_date::date >= '20231216' - 30
		and downpayment_date::date <= '20231216' 
        group by 1,2
	),

last_30_day_CR AS 
(
	SELECT 
		payments.sales_order_id,
		sum(amount) - (coalesce(last_30_downpayments.total_downpayment,0)) AS payments
	FROM kenya.payment AS payments 
		left join last_30_downpayments as last_30_downpayments 
			on last_30_downpayments.unique_account_id = payments.sales_order_id 
	WHERE 
		payments.processing_status = 'posted'
		and payments.is_void = false 
		AND payments.payment_utc_timestamp::DATE >= '20231216' - 30 
		AND payments.payment_utc_timestamp::DATE <= '20231216'
	GROUP BY 
		payments.sales_order_id,
		last_30_downpayments.total_downpayment 
	),
	
dataset as 
	(
	select
		collection_rate.account_id,
		collection_rate.unique_account_id,
		collection_rate.nearest_landmark,
		collection_rate.locations,
		collection_rate.constituency,
		collection_rate.daily_rate,
		collection_rate.current_hardware_type,
		collection_rate.shop,
		collection_rate.region, 
		coalesce(collection_rate.six_month_collection_rate,0) as six_month_collection_rate, 
		collection_rate.customer_active_end_date,
		collection_rate.installation_date,
		collection_rate.six_month_repayments,
		last_30_day_CR.payments as last_30_day_repayments,
		collection_rate.days_expected,
		coalesce(last_30_day_CR.payments,0) / nullif((collection_rate.daily_rate * 30),0) as last_30_day_CR,
		collection_rate.consecutive_late_days,
		collection_rate.expiry_date,
		collection_rate.tv_customer,
		    CASE 
		      WHEN collection_rate.installation_date + 8  > collection_rate.activity_date
		        THEN 'New Customer'
		      ELSE 'Older Customer'
		      end as customer_age_tag
	from collection_rate as collection_rate 
		left join last_30_day_CR as last_30_day_CR  
			on last_30_day_CR.sales_order_id = collection_rate.unique_account_id 
	),

completedata as 
	(
	select
		*,
		 CASE 
		      WHEN 
		            dataset.consecutive_late_days >= 0    
		            AND dataset.consecutive_late_days < 30
		            AND 
		            (
		            dataset.six_month_collection_rate >= 0.66667
		            or 
                        (
                        dataset.six_month_collection_rate < 0.66667 
                        AND dataset.last_30_day_CR >= 0.6667
                        )
		            )
		            AND dataset.customer_age_tag = 'Older Customer'
		      THEN 'Good Payer'  
		      WHEN 
		            (dataset.six_month_collection_rate < 0.66667
		            and dataset.consecutive_late_days < 30
		            and dataset.last_30_day_CR < 0.6667
					and dataset.customer_age_tag = 'Older Customer'
		            )
		            or 
		            (
		            dataset.six_month_collection_rate < 0.66667
		            and dataset.consecutive_late_days < 30
					and dataset.customer_age_tag = 'Older Customer'
		            and dataset.last_30_day_CR is null
		            )
		      then 'Slow Payer_Locked Rewards'
		      when 
		            dataset.consecutive_late_days >= 30
		            AND dataset.consecutive_late_days < 60
		            AND dataset.customer_age_tag = 'Older Customer' 
		      THEN 'Late_30-59'
		      WHEN 
		            dataset.consecutive_late_days >= 60
		            AND dataset.consecutive_late_days < 120
		            AND dataset.customer_age_tag = 'Older Customer'
		      THEN 'Defaulted_60-119'  
		      WHEN 
		            dataset.consecutive_late_days >= 120
		            AND dataset.customer_age_tag = 'Older Customer'
		      THEN 'Legacy Customer'
		      WHEN 
		            dataset.customer_age_tag = 'New Customer' 
		      THEN  'New Customers'      
		      ELSE 'Unaccounted for bucket'
		    END AS CustomerSegment
	from dataset as dataset
	),

data_with_bonuses AS (
  SELECT 
    *,
    CASE 
        WHEN 
            CustomerSegment = 'Good Payer'
        THEN 1.0 * daily_rate
        ELSE 0 
    END AS GoodPayerReward,
    CASE 
        WHEN 
            CustomerSegment = 'Slow Payer_Locked Rewards'
        THEN 1.0 * daily_rate
        ELSE 0 
    END AS SlowPayerLockedRewards,
    CASE 
        WHEN 
            CustomerSegment = 'Late_30-59'
       THEN -7 * daily_rate
       ELSE 0 
    END AS LatePenalty,
    CASE 
      WHEN 
        CustomerSegment = 'Defaulted_60-119' 
      THEN -14 * daily_rate
      ELSE 0
    END AS DefaulterPenalty
  FROM completedata
 	 ),

  customer_categories as (
    SELECT 
      *,
      LatePenalty + DefaulterPenalty AS total_penalty,
      GoodPayerReward + LatePenalty + DefaulterPenalty AS actual_bonus,
      CASE 
        WHEN 
            GoodPayerReward > 0 
        THEN 1
        ELSE 0 
      END AS GoodPayerStatus,
      CASE 
        WHEN 
            SlowPayerLockedRewards > 0 
          THEN 1
        ELSE 0 
      END AS SlowPayerStatus,
      CASE 
        WHEN 
            LatePenalty < 0 
         THEN 1
        ELSE 0 
      END AS LateStatus,
      CASE 
        WHEN 
            DefaulterPenalty < 0 
        then 1
        else 0
      END AS DefaulterStatus
    FROM data_with_bonuses
    ), 

eligible_status as (
    select 
        customer_categories.*,
        case 
            when 
                GoodPayerStatus = 1 
            then 1 
            when 
                SlowPayerStatus = 1
            then 1
            when 
                LateStatus = 1
            then 1
            when 
                DefaulterStatus = 1
            then 1
            else 0 
        end as EligibleStatus
    from customer_categories 
    )
	
select 
    eligible_status.*,
    case 
        when 
            EligibleStatus = 1
        then 1.0*daily_rate 
        else 0
    end as MaxBonusAmount,
    case 
        when 
            consecutive_late_days >8
            and consecutive_late_days <30
        then 1
        else 0
    end as PrePenaltyStatus,
    case 
        when 
            consecutive_late_days >8
            and consecutive_late_days <30
        then -7*daily_rate
        else 0
    end as PrePenaltyPotentialPenalty 
from eligible_status
--where eligible_status.unique_account_id = 'BXCK00036111'
--limit 5 