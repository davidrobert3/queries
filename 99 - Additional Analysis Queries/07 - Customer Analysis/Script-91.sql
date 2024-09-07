----------------------------------------------------------------
-- get customer control units with a start date of this year. this includes all installations
with control_unit as
(
	select 
--		ccul.customer_control_unit_link_id ,
		distinct ccul.account_id ,
		ccul.record_active_start_date::DATE ,
		ccul.record_active_end_date::DATE ,
		ccul.product_imei ,
		row_number() over (partition by ccul.account_id, ccul.product_imei order by ccul.record_active_start_date::DATE desc) as number_of_entries
	from kenya.customer_control_unit_link ccul 
	right join kenya.customer c
		on c.account_id = ccul.account_id and c.current_customer_status ilike 'active'
	where ccul.record_active_start_date::DATE >= '20240101'
	and ccul.account_id = '00027f55e2f7816d919b0cbd801a9aef'
),
------------------------------------------------------------------
-- identify the max entry
max_entries as
(
	select 
			ccul.account_id,
			ccul.product_imei,
			max(number_of_entries) as max_entries
	from control_unit ccul
	group by 1,2
),
-- get the start date of the control unit
start_date as
(
	select 
		cu.account_id ,
		cu.product_imei ,
		cu.record_active_start_date::DATE 
	from control_unit cu
	left join max_entries me 
		on me.account_id = cu.account_id and me.product_imei = cu.product_imei
	where cu.number_of_entries = me.max_entries
),
-- get the end date of the control unit
end_date as
(
	select 
		cu.account_id,
		cu.product_imei,
		cu.record_active_end_date::DATE 
	from control_unit cu
	where cu.number_of_entries = 1
)
-- Main query to bring everything together.
select 
	distinct sd.account_id,
	sd.product_imei,
	cu.serial_number ,
	sd.record_active_start_date,
	ed.record_active_end_date
from start_date sd
left join end_date ed
	on sd.account_id = ed.account_id 
	and ed.product_imei = sd.product_imei
left join kenya.control_unit cu 
	on cu.product_imei = sd.product_imei