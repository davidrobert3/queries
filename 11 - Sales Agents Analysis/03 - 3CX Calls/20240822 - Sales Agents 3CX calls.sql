select
	*
from
	cscc_3cx_daily_report ccdr
where
--	caller_id like '%(118)' 
--	or 
	caller_id like '%(130)'
	or caller_id like '%(131)'
	or caller_id like '%(132)'
	or caller_id like '%(133)'
	or caller_id like '%(134)'
	or caller_id like '%(135)'
	or caller_id like '%(136)'
	or caller_id like '%(137)'
	or caller_id like '%(141)'
	or caller_id like '%(142)'
	or caller_id like '%(143)'
	or caller_id like '%(144)'
	or caller_id like '%(145)'
	or caller_id like '%(158)'
	or caller_id like '%(159)'
	or caller_id like '%(161)'
order by call_time desc 