select
	*
from
	cscc_3cx_daily_report ccdr
where
	caller_id like '%(130)' --, 'Vivian Adhiambo (132)', 'Elias Amadaro (134)', 'Joseph Wafula (135)', 'Martha Onyango (136)', 'David Dankale (131)', 'Brian Ouko (133)', 'PHOEBE WAFULA (137)')
	or caller_id like '%(131)'
	or caller_id like '%(132)'
	or caller_id like '%(133)'
	or caller_id like '%(134)'
	or caller_id like '%(135)'
	or caller_id like '%(136)'
	or caller_id like '%(137)'
	or caller_id like '%(141)'