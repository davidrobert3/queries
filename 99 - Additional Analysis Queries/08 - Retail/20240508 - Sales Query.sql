select unique_account_id, region as customer_region, --rrs.contract_type, 
case shop
When 'Muranga' Then 'Central'
When 'Nakuru' Then 'Central'
When 'Katito' Then 'South Rift 1'
When 'Oyugis' Then 'South Rift 1'
When 'Nyangusu' Then 'South rift 2'
When 'Narok' Then 'South rift 2'
When 'Homa Bay' Then 'Nyanza 1'
When 'Mbita' Then 'Nyanza 1'
When 'Magunga' Then 'Nyanza 1'
When 'Rongo' Then 'Nyanza 2'
When 'Ndhiwa' Then 'Nyanza 2'
When 'Migori' Then 'Nyanza 2'
When 'Voi' Then 'Eastern 1'
When 'Kibwezi' Then 'Eastern 1'
When 'Wote' Then 'Eastern 1'
When 'Machakos' Then 'Eastern 2'
When 'Kitui' Then 'Eastern 2'
When 'Matuu' Then 'Eastern 2'
When 'Kipkaren' Then 'North Rift'
When 'Kapsabet' Then 'North Rift'
When 'Kakuma' Then 'North Rift'
When 'Luanda' Then 'Western 1'
When 'Butere' Then 'Western 1'
When 'Bondo' Then 'Western 2'
When 'Siaya' Then 'Western 2'
When 'Kilifi' Then 'Coast'
When 'Kwale' Then 'Coast'
When 'Malindi' Then 'Coast'
When 'Isiolo' Then 'Central'
When 'Kabarnet' Then 'Central'
When 'Hola' Then 'Coast'
When 'Oloitoktok' Then 'Eastern 1'
When 'Kajiado' Then 'Eastern 2'
When 'Tharaka Nithi' Then 'Eastern 2'
When 'Eldoret' Then 'North Rift'
When 'Kapenguria' Then 'North Rift'
When 'Kitale' Then 'North Rift'
When 'Kendu Bay' Then 'Nyanza 1'
When 'Chepseon' Then 'South Rift 1'
When 'Kipsitet' Then 'South Rift 1'
When 'Bomet' Then 'South rift 2'
When 'Kakamega' Then 'Western 1'
When 'Bumala' Then 'Western 2'
When 'Busia' Then 'Western 2'
When 'Bungoma' Then 'Western 1'
When 'Kapsowar' Then 'Closed'
When 'Kinango' Then 'Closed'
When 'Kisumu' Then 'Closed'
When 'Lodwar' Then 'Closed'
When 'Maralal' Then 'Closed'
When 'Masara' Then 'Closed'
When 'Nyahururu' Then 'Closed'
When 'Nyamira' Then 'Closed'
When 'Serem' Then 'Closed'
When 'Taveta' Then 'Closed'
end as new_region_mapping,
shop as customer_shop,downpayment_date,
date_part('week',downpayment_date) as week_of_year,date_part('month',downpayment_date) as _month,
date_part('day',downpayment_date) as _day,
to_char(downpayment_date, 'day') as day_name,product_name,
case trim(product_name)
When 'Mwanzo 3BT 18M V1.03.2023' Then 'Sale'
When 'Upgrade of Radio v3.03.2023' Then 'Upgrade'
When 'Upgrade of Torch v3.03.2023' Then 'Upgrade'
When '21M Mdosi 4BRT JUN22' Then 'Sale'
When '21M Mdosi 5BR JUN22' Then 'Sale'
When '21M Mdosi 5BT JUN22' Then 'Sale'
When '21M Mdosi TV24 4BR JUN22' Then 'Sale'
When '21M Mdosi TV24 4BR v3.03.2023' Then 'Sale'
When '21M Mdosi TV24 4BT JUN22' Then 'Sale'
When '21M Mdosi TV24 4BT v3.03.2023' Then 'Sale'
When '21M Mdosi TV24 5B JUN22' Then 'Sale'
When '21M Mdosi TV32 3BR NOV21' Then 'Sale'
When '21M Mdosi TV32 3BT NOV21' Then 'Sale'
When '21M Mdosi TV32 4BR JUN22' Then 'Sale'
When '21M Mdosi TV32 4BR v3.03.2023' Then 'Sale'
When '21M Mdosi TV32 4BT JUN22' Then 'Sale'
When '21M Mdosi TV32 4BT v3.03.2023' Then 'Sale'
When '21M Mdosi TV32 5B JUN22' Then 'Sale'
When '21M Optimised 24" TV with Aerial' Then 'Sale'
When '21M SureChill Fridge OCT22' Then 'Sale'
When '24" TV Screen Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When '24" TV Screen Repair OCT22out of warraty' Then 'Repair/Maintenance'
When '24" TV V2 with Aerial + Lithium Battery' Then 'Upgrade'
When '24" TV V2 with Aerial NOV21' Then 'Upgrade'
When '24" TV V2 with Aerial v3.03.2023' Then 'Upgrade'
When '24″ TV V2 with Aerial' Then 'Upgrade'
When '32" TV Screen Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When '32" TV with Aerial + Lithium Battery' Then 'Upgrade'
When '36M Optimised 24" TV with Aerial' Then 'Sale'
When '36M Optimised 24" TV with Aerial v3.03.2023' Then 'Sale'
When 'Bboxx Faida (bP50 Lights)' Then 'faida'
When 'BBOXX Faida TV' Then 'faida'
When 'Bboxx Subwoofer with PVC leather' Then 'Upgrade'
When 'bPower50 TV Maintenance' Then 'Repair/Maintenance'
When 'Cash Optimised 24" TV with Aerial v3.03.2023' Then 'Sale'
When 'Chap Chap Mdosi 4BRT MAY21' Then 'Sale'
When 'Chap Chap Mdosi 4BRT OCT21' Then 'Sale'
When 'Chap Chap Mdosi 5BT MAY21' Then 'Sale'
When 'Chap Chap Mdosi TV 4BR_JUL21' Then 'Sale'
When 'Chap Chap Mdosi TV32 3BR OCT21' Then 'Sale'
When 'Chap Chap Mdosi TV32 3BT OCT21' Then 'Sale'
When 'Chap Chap TV 4BR' Then 'Sale'
When 'DC Radio (V4)' Then 'Upgrade'
When 'DC Radio (V4.1)' Then 'Upgrade'
When 'DC Shaver' Then 'Upgrade'
When 'Discounted bP20 to Lithium battery + 24" TV v1.03.2023' Then 'Upgrade'
When 'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023' Then 'Upgrade'
When 'Discounted Fan upgrade v3.03.2023' Then 'Upgrade'
When 'Discounted shaver OCT21' Then 'Upgrade'
When 'Discounted subwoofer OCT21' Then 'Upgrade'
When 'Discounted Sub-woofer upgrade v3.03.2023' Then 'Upgrade'
When 'Discounted TV 24" with Aerial + Lithium Battery' Then 'Upgrade'
When 'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023' Then 'Upgrade'
When 'Discounted TV 24" with Aerial OCT21' Then 'Upgrade'
When 'Discounted TV 32" with Aerial + Lithium Battery' Then 'Upgrade'
When 'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023' Then 'Upgrade'
When 'Discounted TV 32" with Aerial OCT21' Then 'Upgrade'
When 'Energy Service Fee V0' Then 'faida'
When 'Faida Chap Chap' Then 'faida'
When 'Fan Upgrade' Then 'Upgrade'
When 'Flexx10 Cash V3.03.2023' Then 'Sale'
When 'Flexx40 13M 3B v2.11.2022' Then 'Sale'
When 'Flexx40 13M 3BR v2.11.2022' Then 'Sale'
When 'Flexx40 21M 3B v2.11.2022' Then 'Sale'
When 'Flexx40 21M 3B V3.03.2023' Then 'Sale'
When 'Flexx40 21M 3BR v2.11.2022' Then 'Sale'
When 'Flexx40 21M 3BR v3.03.2023' Then 'Sale'
When 'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)' Then 'Sale'
When 'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)' Then 'Sale'
When 'Flexx40 3B cash v1.11.2022' Then 'Sale'
When 'Flexx40 3B Cash V2.03.2023' Then 'Sale'
When 'Flexx40 3B v3.03.2023' Then 'Sale'
When 'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)' Then 'Sale'
When 'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)' Then 'Sale'
When 'Flexx40 3BR cash v1.11.2022' Then 'Sale'
When 'Flexx40 3BR v3.03.2023' Then 'Sale'
When 'LED Bulb Set' Then 'Upgrade'
When 'Light bulb upgrade v3.03.2023' Then 'Upgrade'
When 'LPG discounted 36 Months' Then 'Upgrade'
When 'LPG Upgrade 18 OCT21' Then 'Upgrade'
When 'Mdosi 4BRT v3.03.2023' Then 'Sale'
When 'Mdosi 5BR v3.03.2023' Then 'Sale'
When 'Mdosi 5BT v3.03.2023' Then 'Sale'
When 'Mdosi Cash 4BRT JUN22' Then 'Sale'
When 'Mdosi Cash 4BRT v3.03.2023' Then 'Sale'
When 'Mdosi Cash 5BR JUN22' Then 'Sale'
When 'Mdosi Cash TV24 4BR JUN22' Then 'Sale'
When 'Mdosi Lights Radio' Then 'Sale'
When 'Mdosi Lights RT' Then 'Sale'
When 'Mdosi TV 24" 4BR v3.03.2023' Then 'Sale'
When 'Mdosi TV 24" 4BT v3.03.2023' Then 'Sale'
When 'Mdosi TV 24" 5B v3.03.2023' Then 'Sale'
When 'Mdosi TV 32" 4BR V3.03.2023' Then 'Sale'
When 'Mdosi TV 32" 4BT V3.03.2023' Then 'Sale'
When 'Mdosi TV 32" 5B v3.03.2023' Then 'Sale'
When 'Mdosi TV Radio' Then 'Sale'
When 'Mdosi TV Torch' Then 'Sale'
When 'Mwanzo 3BR 18M JUN22' Then 'Sale'
When 'Mwanzo 3BR 18M v1.03.2023' Then 'Sale'
When 'Mwanzo 3BT 18M JUN22' Then 'Sale'
When 'Mwanzo 4B 18M JUN22' Then 'Sale'
When 'Mwanzo Cash 3BT JUN22' Then 'Sale'
When 'Optimised 24" TV with Aerial v3.03.2023' Then 'Sale'
When 'Other 24" TV Repair OCT22 out of warraty' Then 'Repair/Maintenance'
When 'OtherCU-BatteryRepair OCT22out of waraty' Then 'Repair/Maintenance'
When 'Promo 24” TV V2 with Aerial_JUL21' Then 'Upgrade'
When 'Promo Flexx10 Cash JUN22' Then 'Sale'
When 'Promo Flexx40 Lights APR22' Then 'Sale'
When 'Promo Flexx40 Radio JUN22' Then 'Sale'
When 'Repair CU OCT21' Then 'Repair/Maintenance'
When 'Repair Radio V4 OCT21' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (in warranty' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (out of warranty)' Then 'Repair/Maintenance'
When 'Solar panel 50W upgrade' Then 'Upgrade'
When 'SPHN_Discounted Samsung A13 v1.03.2023' Then 'Sale'
When 'SPHN_SAgent_Samsung A03 Core' Then 'Sale'
When 'SPHN_Samsung A03 Core' Then 'Sale'
When 'SPHN_Samsung A03 Core bundled Offer v1.12.22' Then 'Sale'
When 'SPHN_Samsung A03 Core v1.03.2023_test' Then 'Sale'
When 'SPHN_Samsung A03 Core v3.10.2022' Then 'Sale'
When 'SPHN_Samsung A13 bundled Offer v1.12.22' Then 'Sale'
When 'SPHN_Samsung A13 v3.10.2022' Then 'Sale'
When 'SPHN_Samsung A14 v1.07.2023' Then 'Sale'
When 'StarTimes Nova with Subscription' Then 'Upgrade'
When 'StarTimes Nova with Subscription v2.03.2023' Then 'Upgrade'
When 'SureChill Fridge v3.03.2023' Then 'Sale'
When 'Taa Imara 5BR – High DP Pilot (Kakuma & Isiolo)' Then 'Sale'
When 'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)' Then 'Sale'
When 'Taa Imara 5BR v1.03.2023' Then 'Sale'
When 'Taa Imara 5BT – High DP Pilot (Kakuma & Isiolo)' Then 'Sale'
When 'Taa Imara 5BT – Low DP Pilot (Kibwezi & Wote)' Then 'Sale'
When 'Taa Imara 5BT v1.03.2023' Then 'Sale'
When 'Torch' Then 'Upgrade'
When 'Torch V3' Then 'Upgrade'
When 'TV 15'''' with Aerial' Then 'Faida'
When 'TV 24'''' with Aerial' Then 'Upgrade'
When 'TV 24" with Aerial + Lithium Battery V2.03.2023' Then 'Upgrade'
When 'TV 32" with Aerial + Lithium Battery v2.03.2023' Then 'Upgrade'
When 'Unilever Retailer' Then 'Upgrade'
When 'Upfront Multiple USB Charger Repair OCT22' Then 'Repair/Maintenance'
When 'Upgrade Fan v3.03.2023' Then 'Upgrade'
When 'Upgrade Light bulb set' Then 'Upgrade'
When 'Upgrade of Radio' Then 'Upgrade'
When 'Upgrade Power Bank 10000mAh' Then 'Upgrade'
When 'Upgrade Shaver v2.03.2023' Then 'Upgrade'
When 'Upgrade Shaver v3.03.2023' Then 'Upgrade'
When 'Upgrade Subwoofer' Then 'Upgrade'
When 'Upgrade Subwoofer V1.03.2023' Then 'Upgrade'
When 'Upgrade Subwoofer  V1.03.2023' Then 'Upgrade'
When 'Upgrade Torch' Then 'Upgrade'
When 'Welcome Pack V1' Then 'faida'
When 'Welcome Pack V2 Bulb' Then 'faida'
When 'Welcome Pack V2 Radio V3' Then 'faida'
When 'Welcome Pack V2 Radio V4' Then 'faida'
When 'Welcome Pack V2 Torch' Then 'faida'
When 'ZUKU Satellite TV Kit with Subscription' Then 'Upgrade'
When 'ZUKU Satellite TV Kit with Subscription v2.03.2023' Then 'Upgrade'
When 'Upgrade Subwoofer V1.03.2023' Then 'Upgrade'
When 'Flexx40 3BR v3.09.2023' Then 'Sale'
When 'Flexx40 3B v3.09.2023' Then 'Sale'
When 'Mdosi TV 32" 4BT v3.09.2023' Then 'Sale'
When '39” PAYGO TV v1.08.2023' Then 'Sale'
When 'Taa Imara 5BT v1.09.2023' Then 'Sale'
When 'Taa Imara 5BR v1.09.2023' Then 'Sale'
When 'Mdosi TV 24" 4BR v3.09.2023' Then 'Sale'
When 'SPHN_Samsung A14 v2.09.2023' Then 'Sale'
When 'Chap Chap Mdosi 4BRT' Then 'Sale'
When 'Taa Imara 4BRT v1.09.2023' Then 'Sale'
when 'Infinix Smart 7 HD 2+64GB' then 'Sale'
when 'Tecno Pop 7 Pro 4+64GB' then 'Sale'
when 'Mdosi TV 32" 4BR v3.09.2023' then 'Sale'
when 'Mdosi TV 24" 4BT v3.09.2023' then 'Sale'
When 'Mdosi TV 24" 5B v3.09.2023' then 'Sale'
When 'Mdosi TV 32" 5B v3.09.2023' then 'Sale'
When 'bPower 160 TV 32" 4BR v1.10.2023' then 'Sale'
When 'Mdosi TV 24" 4BR + Fan v3.09.2023' then 'Sale'
When 'Flexx 12 v1.11.2023' then 'Sale'
When 'Mwananchi TV 24" 4BT v1.10.2023' then 'Sale'
When 'Sonko TV 39" 5B + Fan v1.10.2023' then 'Sale'
when 'Tosha TV 32" 4BT v1.10.2023' then 'Sale'
when 'Tosha TV 32" 4BR v1.10.2023' then 'Sale'
when 'Tosha Upgrade TV 32" v1.11.2023' then 'Sale'
when 'Tosha Upgrade TV 32" 4BR v1.11.2023' then 'Sale'
When 'Tosha Upgrade TV 32" v1.11.2023' Then 'Upgrade'
When 'Tosha Upgrade TV 32" 4BR  v1.11.2023' Then 'Upgrade'
when 'Mwananchi TV 24" 4BR v1.10.2023' then 'Sale'
when 'Mwananchi Upgrade TV 24" v1.11.2023' then 'Upgrade'
when 'Power Bank 10000mAh' then 'Upgrade'
when 'Samsung A14' then 'Sale'
when 'Samsung A03 Core' then 'Sale'
when '12W Solar Panel of Flexx40' then 'Upgrade'
when 'bP60 to bPower120 + 24" TV upgrade v1.11.23' then 'Upgrade'
when 'Sonko TV 39" 5B + Woofer v1.10.2023'then 'Sale'
when 'CU Lithium 9.9Ah Upgrade V1.03.2023' then 'Upgrade'
When 'Flexx40 3B v4.03.2024' Then 'Sale'
When 'Flexx40 3BR v4.03.2024' Then 'Sale'
When 'Taa Imara 4BRT v2.03.2024' Then 'Sale'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'Upgrade'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'Sale'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'Sale'
When 'Taa Imara 5BR v2.03.2024' Then 'Sale'
When 'CU Lithium 9.9Ah Upgrade V2.03.2024' Then 'Upgrade'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'Upgrade'
When 'Flexx 12 v2.03.2024' Then 'Sale'
When 'Flexx40 3B v4.03.2024' Then 'Sale'
When 'Flexx40 3BR v4.03.2024' Then 'Sale'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'Sale'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'Sale'
When 'Taa Imara 4BRT v2.03.2024' Then 'Sale'
When 'Taa Imara 5BR v2.03.2024' Then 'Sale'
When 'Taa Imara 5BT v2.03.2024' Then 'Sale'
When 'TV 24" with Aerial + Lithium Battery V3.03.2024' Then 'Upgrade'
end as Sale_type,
case trim(product_name)
When 'Mwanzo 3BT 18M V1.03.2023' Then 'Mwanzo'
When 'Upgrade of Radio v3.03.2023' Then 'Radio'
When 'Upgrade of Torch v3.03.2023' Then 'Torch'
When '21M Mdosi 4BRT JUN22' Then 'Mdosi Lights'
When '21M Mdosi 5BR JUN22' Then 'Mdosi Lights'
When '21M Mdosi 5BT JUN22' Then 'Mdosi Lights'
When '21M Mdosi TV24 4BR JUN22' Then 'Mdosi TV 24"'
When '21M Mdosi TV24 4BR v3.03.2023' Then 'Mdosi Tv 24"'
When '21M Mdosi TV24 4BT JUN22' Then 'Mdosi TV 24"'
When '21M Mdosi TV24 4BT v3.03.2023' Then 'Mdosi Tv 24"'
When '21M Mdosi TV24 5B JUN22' Then 'Mdosi TV 24"'
When '21M Mdosi TV32 3BR NOV21' Then 'Mdosi TV 32"'
When '21M Mdosi TV32 3BT NOV21' Then 'Mdosi TV 32"'
When '21M Mdosi TV32 4BR JUN22' Then 'Mdosi TV 32"'
When '21M Mdosi TV32 4BR v3.03.2023' Then 'Mdosi Tv 32"'
When '21M Mdosi TV32 4BT JUN22' Then 'Mdosi TV 32"'
When '21M Mdosi TV32 4BT v3.03.2023' Then 'Mdosi Tv 32"'
When '21M Mdosi TV32 5B JUN22' Then 'Mdosi TV 32"'
When '21M Optimised 24" TV with Aerial' Then 'Mdosi Tv 24"'
When '21M SureChill Fridge OCT22' Then 'SureChill'
When '24" TV Screen Repair OCT22 (in warranty)' Then 'Repair'
When '24" TV Screen Repair OCT22out of warraty' Then 'TV upgrade 24"'
When '24" TV V2 with Aerial + Lithium Battery' Then 'TV upgrade 24"'
When '24" TV V2 with Aerial NOV21' Then 'TV upgrade 24"'
When '24" TV V2 with Aerial v3.03.2023' Then 'TV upgrade 24"'
When '24″ TV V2 with Aerial' Then 'TV upgrade 24"'
When '32" TV Screen Repair OCT22 (in warranty)' Then 'Repair'
When '32" TV with Aerial + Lithium Battery' Then 'TV upgrade 32"'
When '36M Optimised 24" TV with Aerial' Then 'Mdosi Tv 24"'
When '36M Optimised 24" TV with Aerial v3.03.2023' Then 'Mdosi Tv 24"'
When 'Bboxx Faida (bP50 Lights)' Then 'faida'
When 'BBOXX Faida TV' Then 'faida'
When 'Bboxx Subwoofer with PVC leather' Then 'Subwoofer'
When 'bPower50 TV Maintenance' Then 'Repair'
When 'Cash Optimised 24" TV with Aerial v3.03.2023' Then 'Mdosi Tv 24"'
When 'Chap Chap Mdosi 4BRT MAY21' Then 'Mdosi Lights'
When 'Chap Chap Mdosi 4BRT OCT21' Then 'Mdosi Lights'
When 'Chap Chap Mdosi 5BT MAY21' Then 'Mdosi Lights'
When 'Chap Chap Mdosi TV 4BR_JUL21' Then 'Mdosi TV 24"'
When 'Chap Chap Mdosi TV32 3BR OCT21' Then 'Mdosi TV 32"'
When 'Chap Chap Mdosi TV32 3BT OCT21' Then 'Mdosi TV 32"'
When 'Chap Chap TV 4BR' Then 'Mdosi TV 24"'
When 'DC Radio (V4)' Then 'Radio'
When 'DC Radio (V4.1)' Then 'Radio'
When 'DC Shaver' Then 'Shaver'
When 'Discounted bP20 to Lithium battery + 24" TV v1.03.2023' Then 'CU+TV_Upgrade'
When 'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023' Then 'CU_Upgrade'
When 'Discounted Fan upgrade v3.03.2023' Then 'Fan'
When 'Discounted shaver OCT21' Then 'Shaver'
When 'Discounted subwoofer OCT21' Then 'Subwoofer'
When 'Discounted Sub-woofer upgrade v3.03.2023' Then 'Subwoofer'
When 'Discounted TV 24" with Aerial + Lithium Battery' Then 'TV upgrade 24"'
When 'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023' Then 'TV upgrade 24"'
When 'Discounted TV 24" with Aerial OCT21' Then 'TV upgrade 24"'
When 'Discounted TV 32" with Aerial + Lithium Battery' Then 'TV upgrade 32"'
When 'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023' Then 'TV upgrade 32"'
When 'Discounted TV 32" with Aerial OCT21' Then 'TV upgrade 32"'
When 'Energy Service Fee V0' Then 'faida'
When 'Faida Chap Chap' Then 'faida'
When 'Fan Upgrade' Then 'Fan'
When 'Flexx10 Cash V3.03.2023' Then 'Flexx 10'
When 'Flexx40 13M 3B v2.11.2022' Then 'Flexx 40'
When 'Flexx40 13M 3BR v2.11.2022' Then 'Flexx 40'
When 'Flexx40 21M 3B v2.11.2022' Then 'Flexx 40'
When 'Flexx40 21M 3B V3.03.2023' Then 'Flexx 40'
When 'Flexx40 21M 3BR v2.11.2022' Then 'Flexx 40'
When 'Flexx40 21M 3BR v3.03.2023' Then 'Flexx 40'
When 'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3B cash v1.11.2022' Then 'Flexx 40'
When 'Flexx40 3B Cash V2.03.2023' Then 'Flexx 40'
When 'Flexx40 3B v3.03.2023' Then 'Flexx 40'
When 'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3BR cash v1.11.2022' Then 'Flexx 40'
When 'Flexx40 3BR v3.03.2023' Then 'Flexx 40'
When 'LED Bulb Set' Then 'Bulb'
When 'Light bulb upgrade v3.03.2023' Then 'Bulb'
When 'LPG discounted 36 Months' Then 'LPG'
When 'LPG Upgrade 18 OCT21' Then 'LPG'
When 'Mdosi 4BRT v3.03.2023' Then 'Mdosi Lights'
When 'Mdosi 5BR v3.03.2023' Then 'Mdosi Lights'
When 'Mdosi 5BT v3.03.2023' Then 'Mdosi Lights'
When 'Mdosi Cash 4BRT JUN22' Then 'Mdosi Lights'
When 'Mdosi Cash 4BRT v3.03.2023' Then 'Mdosi Lights'
When 'Mdosi Cash 5BR JUN22' Then 'Mdosi Lights'
When 'Mdosi Cash TV24 4BR JUN22' Then 'Mdosi TV 24"'
When 'Mdosi Lights Radio' Then 'Mdosi Lights'
When 'Mdosi Lights RT' Then 'Mdosi Lights'
When 'Mdosi TV 24" 4BR v3.03.2023' Then 'Mdosi Tv 24"'
When 'Mdosi TV 24" 4BT v3.03.2023' Then 'Mdosi Tv 24"'
When 'Mdosi TV 24" 5B v3.03.2023' Then 'Mdosi Tv 24"'
When 'Mdosi TV 32" 4BR V3.03.2023' Then 'Mdosi Tv 32"'
When 'Mdosi TV 32" 4BT V3.03.2023' Then 'Mdosi Tv 32"'
When 'Mdosi TV 32" 5B v3.03.2023' Then 'Mdosi Tv 32"'
When 'Mdosi TV Radio' Then 'Mdosi TV 24"'
When 'Mdosi TV Torch' Then 'Mdosi TV 24"'
When 'Mwanzo 3BR 18M JUN22' Then 'Mwanzo'
When 'Mwanzo 3BR 18M v1.03.2023' Then 'Mwanzo'
When 'Mwanzo 3BT 18M JUN22' Then 'Mwanzo'
When 'Mwanzo 4B 18M JUN22' Then 'Mwanzo'
When 'Mwanzo Cash 3BT JUN22' Then 'Mwanzo'
When 'Optimised 24" TV with Aerial v3.03.2023' Then 'Mdosi Tv 24"'
When 'Other 24" TV Repair OCT22 out of warraty' Then 'Repair'
When 'OtherCU-BatteryRepair OCT22out of waraty' Then 'Repair'
When 'Promo 24” TV V2 with Aerial_JUL21' Then 'TV upgrade 24"'
When 'Promo Flexx10 Cash JUN22' Then 'Flexx 10'
When 'Promo Flexx40 Lights APR22' Then 'Flexx 40'
When 'Promo Flexx40 Radio JUN22' Then 'Flexx 40'
When 'Repair CU OCT21' Then 'Repair'
When 'Repair Radio V4 OCT21' Then 'Repair'
When 'Shaver Repair OCT22 (in warranty' Then 'Repair'
When 'Shaver Repair OCT22 (in warranty)' Then 'Repair'
When 'Shaver Repair OCT22 (out of warranty)' Then 'Repair'
When 'Solar panel 50W upgrade' Then 'CU_Upgrade'
When 'SPHN_Discounted Samsung A13 v1.03.2023' Then 'Smartphone'
When 'SPHN_SAgent_Samsung A03 Core' Then 'Smartphone'
When 'SPHN_Samsung A03 Core' Then 'Smartphone'
When 'SPHN_Samsung A03 Core bundled Offer v1.12.22' Then 'Smartphone'
When 'SPHN_Samsung A03 Core v1.03.2023_test' Then 'Smartphone'
When 'SPHN_Samsung A03 Core v3.10.2022' Then 'Smartphone'
When 'SPHN_Samsung A13 bundled Offer v1.12.22' Then 'Smartphone'
When 'SPHN_Samsung A13 v3.10.2022' Then 'Smartphone'
When 'SPHN_Samsung A14 v1.07.2023' Then 'Smartphone'
When 'StarTimes Nova with Subscription' Then 'StarTimes'
When 'StarTimes Nova with Subscription v2.03.2023' Then 'StarTimes'
When 'SureChill Fridge v3.03.2023' Then 'Surechill'
When 'Taa Imara 5BR – High DP Pilot (Kakuma & Isiolo)' Then 'Taa Imara'
When 'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)' Then 'Taa Imara'
When 'Taa Imara 5BR v1.03.2023' Then 'Taa Imara'
When 'Taa Imara 5BT – High DP Pilot (Kakuma & Isiolo)' Then 'Taa Imara'
When 'Taa Imara 5BT – Low DP Pilot (Kibwezi & Wote)' Then 'Taa Imara'
When 'Taa Imara 5BT v1.03.2023' Then 'Taa Imara'
When 'Torch' Then 'Torch'
When 'Torch V3' Then 'Torch'
When 'TV 15'''' with Aerial' Then 'Faida'
When 'TV 24'''' with Aerial' Then 'TV upgrade 24"'
When 'TV 24" with Aerial + Lithium Battery V2.03.2023' Then 'TV upgrade 24"'
When 'TV 32" with Aerial + Lithium Battery v2.03.2023' Then 'TV upgrade 32"'
When 'Unilever Retailer' Then 'Unilever'
When 'Upfront Multiple USB Charger Repair OCT22' Then 'Repair'
When 'Upgrade Fan v3.03.2023' Then 'Fan'
When 'Upgrade Light bulb set' Then 'Bulb'
When 'Upgrade of Radio' Then 'Radio'
When 'Upgrade Power Bank 10000mAh' Then 'Power Bank'
When 'Upgrade Shaver v2.03.2023' Then 'Shaver'
When 'Upgrade Shaver v3.03.2023' Then 'Shaver'
When 'Upgrade Subwoofer' Then 'Subwoofer'
When 'Upgrade Subwoofer V1.03.2023' Then 'Subwoofer'
When 'Upgrade Subwoofer  V1.03.2023' Then 'Subwoofer'
When 'Upgrade Torch' Then 'Torch'
When 'Welcome Pack V1' Then 'faida'
When 'Welcome Pack V2 Bulb' Then 'faida'
When 'Welcome Pack V2 Radio V3' Then 'faida'
When 'Welcome Pack V2 Radio V4' Then 'faida'
When 'Welcome Pack V2 Torch' Then 'faida'
When 'ZUKU Satellite TV Kit with Subscription' Then 'Zuku'
When 'ZUKU Satellite TV Kit with Subscription v2.03.2023' Then 'Zuku'
When 'Flexx40 3BR v3.09.2023' Then 'Flexx 40'
When 'Flexx40 3B v3.09.2023' Then 'Flexx 40'
When 'Mdosi TV 32" 4BT v3.09.2023' Then 'Mdosi Tv 32"'
When '39” PAYGO TV v1.08.2023' Then 'Paygo_TV'
When 'Taa Imara 5BT v1.09.2023' Then 'Taa Imara'
When 'Taa Imara 5BR v1.09.2023' Then 'Taa Imara'
When 'Mdosi TV 24" 4BR v3.09.2023' Then 'Mdosi Tv 24"'
When 'SPHN_Samsung A14 v2.09.2023' Then 'Smartphone'
when 'Infinix Smart 7 HD 2+64GB' then 'Smartphone'
when 'Tecno Pop 7 Pro 4+64GB' then 'Smartphone'
When 'Chap Chap Mdosi 4BRT' Then 'Mdosi Lights'
When 'Taa Imara 4BRT v1.09.2023' Then 'Taa Imara'
when 'Mdosi TV 32" 4BR v3.09.2023' then 'Mdosi Tv 32"'
when 'Mdosi TV 24" 4BT v3.09.2023' then 'Mdosi Tv 24"'
When 'Mdosi TV 24" 5B v3.09.2023' then 'Mdosi Tv 24"'
When 'Mdosi TV 32" 5B v3.09.2023' then 'Mdosi Tv 32"'
When 'bPower 160 TV 32" 4BR v1.10.2023' then 'Mdosi Tv 32"'
When 'Mdosi TV 24" 4BR + Fan v3.09.2023' then 'Mdosi Tv 24"'
When 'Flexx 12 v1.11.2023' then 'Flexx 12'
When 'Mwananchi TV 24" 4BT v1.10.2023' then 'Paygo TV'
When 'Sonko TV 39" 5B + Fan v1.10.2023' then 'Paygo TV'
when 'Tosha TV 32" 4BT v1.10.2023' then 'Paygo TV'
when 'Tosha TV 32" 4BR v1.10.2023' then 'Paygo TV'
when 'Tosha Upgrade TV 32" v1.11.2023' then 'TV upgrade 32"'
when 'Tosha Upgrade TV 32" 4BR v1.11.2023' then 'TV upgrade 32"'
When 'Tosha Upgrade TV 32" v1.11.2023' Then 'TV upgrade 32"'
When 'Tosha Upgrade TV 32" 4BR  v1.11.2023' Then 'TV upgrade 32"'
when 'Mwananchi TV 24" 4BR v1.10.2023' then 'Paygo TV'
when 'Mwananchi Upgrade TV 24" v1.11.2023' then 'Paygo TV'
when 'Power Bank 10000mAh' then 'Power Bank'
when 'Samsung A14' then 'Smartphone'
when 'Samsung A03 Core' then 'Smartphone'
when '12W Solar Panel of Flexx40' then 'Torch'
when 'bP60 to bPower120 + 24" TV upgrade v1.11.23' then 'TV upgrade 24"'
when 'Sonko TV 39" 5B + Woofer v1.10.2023'then 'Paygo TV'
when 'CU Lithium 9.9Ah Upgrade V1.03.2023' then 'CU_Upgrade'
When 'Flexx40 3B v4.03.2024' Then 'Flexx 40'
When 'Flexx40 3BR v4.03.2024' Then 'Flexx 40'
When 'Taa Imara 4BRT v2.03.2024' Then 'Taa Imara'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'TV upgrade 24"'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'Mdosi Tv 24"'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'Mdosi Tv 24"'
When 'Taa Imara 5BR v2.03.2024' Then 'Taa Imara'
When 'CU Lithium 9.9Ah Upgrade V2.03.2024' Then 'CU_Upgrade'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'TV upgrade 24"'
When 'Flexx 12 v2.03.2024' Then 'Flexx 12'
When 'Flexx40 3B v4.03.2024' Then 'Flexx 40'
When 'Flexx40 3BR v4.03.2024' Then 'Flexx 40'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'Mdosi Tv 24"'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'Mdosi Tv 24"'
When 'Taa Imara 4BRT v2.03.2024' Then 'Taa Imara'
When 'Taa Imara 5BR v2.03.2024' Then 'Taa Imara'
When 'Taa Imara 5BT v2.03.2024' Then 'Taa Imara'
When 'TV 24" with Aerial + Lithium Battery V3.03.2024' Then 'TV upgrade 24"'
end as Package,
case trim(product_name)
When 'Mwanzo 3BT 18M V1.03.2023' Then 'Bpower Lights'
When 'Upgrade of Radio v3.03.2023' Then 'other Appliances Upgrade'
When 'Upgrade of Torch v3.03.2023' Then 'other Appliances Upgrade'
When '21M Mdosi 4BRT JUN22' Then 'Bpower Lights'
When '21M Mdosi 5BR JUN22' Then 'Bpower Lights'
When '21M Mdosi 5BT JUN22' Then 'Bpower Lights'
When '21M Mdosi TV24 4BR JUN22' Then 'TV sales'
When '21M Mdosi TV24 4BR v3.03.2023' Then 'TV sales'
When '21M Mdosi TV24 4BT JUN22' Then 'TV sales'
When '21M Mdosi TV24 4BT v3.03.2023' Then 'TV sales'
When '21M Mdosi TV24 5B JUN22' Then 'TV sales'
When '21M Mdosi TV32 3BR NOV21' Then 'TV sales'
When '21M Mdosi TV32 3BT NOV21' Then 'TV sales'
When '21M Mdosi TV32 4BR JUN22' Then 'TV sales'
When '21M Mdosi TV32 4BR v3.03.2023' Then 'TV sales'
When '21M Mdosi TV32 4BT JUN22' Then 'TV sales'
When '21M Mdosi TV32 4BT v3.03.2023' Then 'TV sales'
When '21M Mdosi TV32 5B JUN22' Then 'TV sales'
When '21M Optimised 24" TV with Aerial' Then 'Tv sales'
When '21M SureChill Fridge OCT22' Then 'Surechill'
When '24" TV Screen Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When '24" TV Screen Repair OCT22out of warraty' Then 'TV upgrade'
When '24" TV V2 with Aerial + Lithium Battery' Then 'TV upgrade'
When '24" TV V2 with Aerial NOV21' Then 'TV upgrade'
When '24" TV V2 with Aerial v3.03.2023' Then 'TV upgrade'
When '24″ TV V2 with Aerial' Then 'TV upgrade'
When '32" TV Screen Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When '32" TV with Aerial + Lithium Battery' Then 'TV upgrade'
When '36M Optimised 24" TV with Aerial' Then 'Tv sales'
When '36M Optimised 24" TV with Aerial v3.03.2023' Then 'TV sales'
When 'Bboxx Faida (bP50 Lights)' Then 'faida'
When 'BBOXX Faida TV' Then 'faida'
When 'Bboxx Subwoofer with PVC leather' Then 'other Appliances Upgrade'
When 'bPower50 TV Maintenance' Then 'Repair/Maintenance'
When 'Cash Optimised 24" TV with Aerial v3.03.2023' Then 'TV sales'
When 'Chap Chap Mdosi 4BRT MAY21' Then 'Bpower Lights'
When 'Chap Chap Mdosi 4BRT OCT21' Then 'Bpower Lights'
When 'Chap Chap Mdosi 5BT MAY21' Then 'Bpower Lights'
When 'Chap Chap Mdosi TV 4BR_JUL21' Then 'TV sales'
When 'Chap Chap Mdosi TV32 3BR OCT21' Then 'TV sales'
When 'Chap Chap Mdosi TV32 3BT OCT21' Then 'TV sales'
When 'Chap Chap TV 4BR' Then 'TV sales'
When 'DC Radio (V4)' Then 'other Appliances Upgrade'
When 'DC Radio (V4.1)' Then 'other Appliances Upgrade'
When 'DC Shaver' Then 'other Appliances Upgrade'
When 'Discounted bP20 to Lithium battery + 24" TV v1.03.2023' Then 'TV upgrade'
When 'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023' Then 'other Appliances Upgrade'
When 'Discounted Fan upgrade v3.03.2023' Then 'other Appliances Upgrade'
When 'Discounted shaver OCT21' Then 'other Appliances Upgrade'
When 'Discounted subwoofer OCT21' Then 'other Appliances Upgrade'
When 'Discounted Sub-woofer upgrade v3.03.2023' Then 'other Appliances Upgrade'
When 'Discounted TV 24" with Aerial + Lithium Battery' Then 'TV upgrade'
When 'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023' Then 'TV upgrade'
When 'Discounted TV 24" with Aerial OCT21' Then 'TV upgrade'
When 'Discounted TV 32" with Aerial + Lithium Battery' Then 'TV upgrade'
When 'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023' Then 'TV upgrade'
When 'Discounted TV 32" with Aerial OCT21' Then 'TV upgrade'
When 'Energy Service Fee V0' Then 'faida'
When 'Faida Chap Chap' Then 'faida'
When 'Fan Upgrade' Then 'other Appliances Upgrade'
When 'Flexx10 Cash V3.03.2023' Then 'Flexx 10'
When 'Flexx40 13M 3B v2.11.2022' Then 'Flexx 40'
When 'Flexx40 13M 3BR v2.11.2022' Then 'Flexx 40'
When 'Flexx40 21M 3B v2.11.2022' Then 'Flexx 40'
When 'Flexx40 21M 3B V3.03.2023' Then 'Flexx 40'
When 'Flexx40 21M 3BR v2.11.2022' Then 'Flexx 40'
When 'Flexx40 21M 3BR v3.03.2023' Then 'Flexx 40'
When 'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3B cash v1.11.2022' Then 'Flexx 40'
When 'Flexx40 3B Cash V2.03.2023' Then 'Flexx 40'
When 'Flexx40 3B v3.03.2023' Then 'Flexx 40'
When 'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)' Then 'Flexx 40'
When 'Flexx40 3BR cash v1.11.2022' Then 'Flexx 40'
When 'Flexx40 3BR v3.03.2023' Then 'Flexx 40'
When 'LED Bulb Set' Then 'other Appliances Upgrade'
When 'Light bulb upgrade v3.03.2023' Then 'other Appliances Upgrade'
When 'LPG discounted 36 Months' Then 'other Appliances Upgrade'
When 'LPG Upgrade 18 OCT21' Then 'other Appliances Upgrade'
When 'Mdosi 4BRT v3.03.2023' Then 'Bpower Lights'
When 'Mdosi 5BR v3.03.2023' Then 'Bpower Lights'
When 'Mdosi 5BT v3.03.2023' Then 'Bpower Lights'
When 'Mdosi Cash 4BRT JUN22' Then 'Bpower Lights'
When 'Mdosi Cash 4BRT v3.03.2023' Then 'Bpower Lights'
When 'Mdosi Cash 5BR JUN22' Then 'Bpower Lights'
When 'Mdosi Cash TV24 4BR JUN22' Then 'TV sales'
When 'Mdosi Lights Radio' Then 'Bpower Lights'
When 'Mdosi Lights RT' Then 'Bpower Lights'
When 'Mdosi TV 24" 4BR v3.03.2023' Then 'TV sales'
When 'Mdosi TV 24" 4BT v3.03.2023' Then 'TV sales'
When 'Mdosi TV 24" 5B v3.03.2023' Then 'Tv sales'
When 'Mdosi TV 32" 4BR V3.03.2023' Then 'TV sales'
When 'Mdosi TV 32" 4BT V3.03.2023' Then 'TV sales'
When 'Mdosi TV 32" 5B v3.03.2023' Then 'TV sales'
When 'Mdosi TV Radio' Then 'TV sales'
When 'Mdosi TV Torch' Then 'TV sales'
When 'Mwanzo 3BR 18M JUN22' Then 'Bpower Lights'
When 'Mwanzo 3BR 18M v1.03.2023' Then 'Bpower Lights'
When 'Mwanzo 3BT 18M JUN22' Then 'Bpower Lights'
When 'Mwanzo 4B 18M JUN22' Then 'Bpower Lights'
When 'Mwanzo Cash 3BT JUN22' Then 'Bpower Lights'
When 'Optimised 24" TV with Aerial v3.03.2023' Then 'TV sales'
When 'Other 24" TV Repair OCT22 out of warraty' Then 'Repair/Maintenance'
When 'OtherCU-BatteryRepair OCT22out of waraty' Then 'Repair/Maintenance'
When 'Promo 24” TV V2 with Aerial_JUL21' Then 'TV upgrade'
When 'Promo Flexx10 Cash JUN22' Then 'Flexx 40'
When 'Promo Flexx40 Lights APR22' Then 'Flexx 40'
When 'Promo Flexx40 Radio JUN22' Then 'Flexx 40'
When 'Repair CU OCT21' Then 'Repair/Maintenance'
When 'Repair Radio V4 OCT21' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (in warranty' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (out of warranty)' Then 'Repair/Maintenance'
When 'Solar panel 50W upgrade' Then 'other Appliances Upgrade'
When 'SPHN_Discounted Samsung A13 v1.03.2023' Then 'Connect'
When 'SPHN_SAgent_Samsung A03 Core' Then 'Connect'
When 'SPHN_Samsung A03 Core' Then 'Connect'
When 'SPHN_Samsung A03 Core bundled Offer v1.12.22' Then 'Connect'
When 'SPHN_Samsung A03 Core v1.03.2023_test' Then 'Connect'
When 'SPHN_Samsung A03 Core v3.10.2022' Then 'Connect'
When 'SPHN_Samsung A13 bundled Offer v1.12.22' Then 'Connect'
When 'SPHN_Samsung A13 v3.10.2022' Then 'Connect'
When 'SPHN_Samsung A14 v1.07.2023' Then 'Connect'
When 'StarTimes Nova with Subscription' Then 'other Appliances Upgrade'
When 'StarTimes Nova with Subscription v2.03.2023' Then 'other Appliances Upgrade'
When 'SureChill Fridge v3.03.2023' Then 'Surechill'
When 'Taa Imara 5BR – High DP Pilot (Kakuma & Isiolo)' Then 'Taa Imara'
When 'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)' Then 'Taa Imara'
When 'Taa Imara 5BR v1.03.2023' Then 'Taa Imara'
When 'Taa Imara 5BT – High DP Pilot (Kakuma & Isiolo)' Then 'Taa Imara'
When 'Taa Imara 5BT – Low DP Pilot (Kibwezi & Wote)' Then 'Taa Imara'
When 'Taa Imara 5BT v1.03.2023' Then 'Taa Imara'
When 'Torch' Then 'other Appliances Upgrade'
When 'Torch V3' Then 'other Appliances Upgrade'
When 'TV 15'''' with Aerial' Then 'Faida'
When 'TV 24'''' with Aerial' Then 'TV upgrade'
When 'TV 24" with Aerial + Lithium Battery V2.03.2023' Then 'TV upgrade'
When 'TV 32" with Aerial + Lithium Battery v2.03.2023' Then 'TV upgrade'
When 'Unilever Retailer' Then 'other Appliances Upgrade'
When 'Upfront Multiple USB Charger Repair OCT22' Then 'Repair/Maintenance'
When 'Upgrade Fan v3.03.2023' Then 'other Appliances Upgrade'
When 'Upgrade Light bulb set' Then 'other Appliances Upgrade'
When 'Upgrade of Radio' Then 'other Appliances Upgrade'
When 'Upgrade Power Bank 10000mAh' Then 'other Appliances Upgrade'
When 'Upgrade Shaver v2.03.2023' Then 'other Appliances Upgrade'
When 'Upgrade Shaver v3.03.2023' Then 'other Appliances Upgrade'
When 'Upgrade Subwoofer' Then 'other Appliances Upgrade'
When 'Upgrade Subwoofer V1.03.2023' Then 'other Appliances Upgrade'
When 'Upgrade Subwoofer  V1.03.2023' Then 'other Appliances Upgrade'
When 'Upgrade Torch' Then 'other Appliances Upgrade'
When 'Welcome Pack V1' Then 'faida'
When 'Welcome Pack V2 Bulb' Then 'faida'
When 'Welcome Pack V2 Radio V3' Then 'faida'
When 'Welcome Pack V2 Radio V4' Then 'faida'
When 'Welcome Pack V2 Torch' Then 'faida'
When 'ZUKU Satellite TV Kit with Subscription' Then 'other Appliances Upgrade'
When 'ZUKU Satellite TV Kit with Subscription v2.03.2023' Then 'other Appliances Upgrade'
When 'Upgrade Subwoofer V1.03.2023' Then 'Subwoofer'
When 'Upgrade Subwoofer V1.03.2023' Then 'other Appliances Upgrade'
When 'Flexx40 3BR v3.09.2023' Then 'Flexx 40'
When 'Flexx40 3B v3.09.2023' Then 'Flexx 40'
When 'Flexx40 3BR v3.09.2023' Then 'Bpower Lights'
When 'Flexx40 3B v3.09.2023' Then 'Bpower Lights'
When 'Mdosi TV 32" 4BT v3.09.2023' Then 'TV sales'
When '39” PAYGO TV v1.08.2023' Then 'TV sales'
When 'Taa Imara 5BT v1.09.2023' Then 'Taa Imara'
When 'Taa Imara 5BR v1.09.2023' Then 'Taa Imara'
When 'Mdosi TV 24" 4BR v3.09.2023' Then 'TV sales'
When 'SPHN_Samsung A14 v2.09.2023' Then 'Connect'
when 'Infinix Smart 7 HD 2+64GB' then 'Connect'
when 'Tecno Pop 7 Pro 4+64GB' then 'Connect'
When 'Chap Chap Mdosi 4BRT' Then 'Bpower Lights'
When 'Taa Imara 4BRT v1.09.2023' Then 'Taa Imara'
when 'Mdosi TV 32" 4BR v3.09.2023' then 'TV sales'
when 'Mdosi TV 24" 4BT v3.09.2023' then 'TV sales'
When 'Mdosi TV 24" 5B v3.09.2023' then 'TV sales'
When 'Mdosi TV 32" 5B v3.09.2023' then 'TV sales'
When 'bPower 160 TV 32" 4BR v1.10.2023' then 'TV sales'
When 'Mdosi TV 24" 4BR + Fan v3.09.2023' then 'TV sales'
When 'Flexx 12 v1.11.2023' then 'Flexx 12'
When 'Mwananchi TV 24" 4BT v1.10.2023' then 'TV sales'
When 'Sonko TV 39" 5B + Fan v1.10.2023' then 'TV sales'
when 'Tosha TV 32" 4BT v1.10.2023' then 'TV sales'
when 'Tosha TV 32" 4BR v1.10.2023' then 'TV sales'
when 'Tosha Upgrade TV 32" v1.11.2023' then 'TV upgrade'
when 'Tosha Upgrade TV 32" 4BR v1.11.2023' then 'TV upgrade'
When 'Tosha Upgrade TV 32" v1.11.2023' Then 'TV upgrade'
When 'Tosha Upgrade TV 32" 4BR  v1.11.2023' Then 'TV upgrade'
when 'Mwananchi TV 24" 4BR v1.10.2023' then 'TV sales'
when 'Mwananchi Upgrade TV 24" v1.11.2023' then 'TV upgrade'
when 'Power Bank 10000mAh' then 'other Appliances Upgrade'
when 'Samsung A14' then 'Connect'
when 'Samsung A14' then 'Connect'
when 'Samsung A03 Core' then 'Connect'
when '12W Solar Panel of Flexx40' then 'other Appliances Upgrade'
when 'bP60 to bPower120 + 24" TV upgrade v1.11.23' then 'TV upgrade'
when 'Sonko TV 39" 5B + Woofer v1.10.2023'then 'TV sales'
when 'CU Lithium 9.9Ah Upgrade V1.03.2023' then 'other Appliances Upgrade'
When 'Flexx40 3B v4.03.2024' Then 'Flexx 40'
When 'Flexx40 3BR v4.03.2024' Then 'Flexx 40'
When 'Taa Imara 4BRT v2.03.2024' Then 'Taa Imara'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'TV upgrade'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'TV sales'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'TV sales'
When 'Taa Imara 5BR v2.03.2024' Then 'Taa Imara'
When 'CU Lithium 9.9Ah Upgrade V2.03.2024' Then 'other Appliances Upgrade'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'TV upgrade'
When 'Flexx 12 v2.03.2024' Then 'Flexx 12'
When 'Flexx40 3B v4.03.2024' Then 'Flexx 40'
When 'Flexx40 3BR v4.03.2024' Then 'Flexx 40'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'TV sales'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'TV sales'
When 'Taa Imara 4BRT v2.03.2024' Then 'Taa Imara'
When 'Taa Imara 5BR v2.03.2024' Then 'Taa Imara'
When 'Taa Imara 5BT v2.03.2024' Then 'Taa Imara'
When 'TV 24" with Aerial + Lithium Battery V3.03.2024' Then 'TV upgrade'
end as product_package,
case trim(product_name)
When 'Mwanzo 3BT 18M V1.03.2023' Then 'Bpower'
When 'Upgrade of Radio v3.03.2023' Then 'SHS Upgrade'
When 'Upgrade of Torch v3.03.2023' Then 'SHS Upgrade'
When '21M Mdosi 4BRT JUN22' Then 'Bpower'
When '21M Mdosi 5BR JUN22' Then 'Bpower'
When '21M Mdosi 5BT JUN22' Then 'Bpower'
When '21M Mdosi TV24 4BR JUN22' Then 'Tv sales'
When '21M Mdosi TV24 4BR v3.03.2023' Then 'Tv sales'
When '21M Mdosi TV24 4BT JUN22' Then 'Tv sales'
When '21M Mdosi TV24 4BT v3.03.2023' Then 'Tv sales'
When '21M Mdosi TV24 5B JUN22' Then 'Tv sales'
When '21M Mdosi TV32 3BR NOV21' Then 'Tv sales'
When '21M Mdosi TV32 3BT NOV21' Then 'Tv sales'
When '21M Mdosi TV32 4BR JUN22' Then 'Tv sales'
When '21M Mdosi TV32 4BR v3.03.2023' Then 'Tv sales'
When '21M Mdosi TV32 4BT JUN22' Then 'Tv sales'
When '21M Mdosi TV32 4BT v3.03.2023' Then 'Tv sales'
When '21M Mdosi TV32 5B JUN22' Then 'Tv sales'
When '21M Optimised 24" TV with Aerial' Then 'Tv sales'
When '21M SureChill Fridge OCT22' Then 'Bpower'
When '24" TV Screen Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When '24" TV Screen Repair OCT22out of warraty' Then 'TV upgrade'
When '24" TV V2 with Aerial + Lithium Battery' Then 'TV upgrade'
When '24" TV V2 with Aerial NOV21' Then 'TV upgrade'
When '24" TV V2 with Aerial v3.03.2023' Then 'TV upgrade'
When '24″ TV V2 with Aerial' Then 'TV upgrade'
When '32" TV Screen Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When '32" TV with Aerial + Lithium Battery' Then 'TV upgrade'
When '36M Optimised 24" TV with Aerial' Then 'Tv sales'
When '36M Optimised 24" TV with Aerial v3.03.2023' Then 'Tv sales'
When 'Bboxx Faida (bP50 Lights)' Then 'faida'
When 'BBOXX Faida TV' Then 'faida'
When 'Bboxx Subwoofer with PVC leather' Then 'SHS Upgrade'
When 'bPower50 TV Maintenance' Then 'Repair/Maintenance'
When 'Cash Optimised 24" TV with Aerial v3.03.2023' Then 'Tv sales'
When 'Chap Chap Mdosi 4BRT MAY21' Then 'Bpower'
When 'Chap Chap Mdosi 4BRT OCT21' Then 'Bpower'
When 'Chap Chap Mdosi 5BT MAY21' Then 'Bpower'
When 'Chap Chap Mdosi TV 4BR_JUL21' Then 'Tv sales'
When 'Chap Chap Mdosi TV32 3BR OCT21' Then 'Tv sales'
When 'Chap Chap Mdosi TV32 3BT OCT21' Then 'Tv sales'
When 'Chap Chap TV 4BR' Then 'Tv sales'
When 'DC Radio (V4)' Then 'SHS Upgrade'
When 'DC Radio (V4.1)' Then 'SHS Upgrade'
When 'DC Shaver' Then 'SHS Upgrade'
When 'Discounted bP20 to Lithium battery + 24" TV v1.03.2023' Then 'TV upgrade'
When 'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023' Then 'SHS Upgrade'
When 'Discounted Fan upgrade v3.03.2023' Then 'SHS Upgrade'
When 'Discounted shaver OCT21' Then 'SHS Upgrade'
When 'Discounted subwoofer OCT21' Then 'SHS Upgrade'
When 'Discounted Sub-woofer upgrade v3.03.2023' Then 'SHS Upgrade'
When 'Discounted TV 24" with Aerial + Lithium Battery' Then 'TV upgrade'
When 'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023' Then 'TV upgrade'
When 'Discounted TV 24" with Aerial OCT21' Then 'TV upgrade'
When 'Discounted TV 32" with Aerial + Lithium Battery' Then 'TV upgrade'
When 'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023' Then 'TV upgrade'
When 'Discounted TV 32" with Aerial OCT21' Then 'TV upgrade'
When 'Energy Service Fee V0' Then 'faida'
When 'Faida Chap Chap' Then 'faida'
When 'Fan Upgrade' Then 'SHS Upgrade'
When 'Flexx10 Cash V3.03.2023' Then 'Flexx Sales'
When 'Flexx40 13M 3B v2.11.2022' Then 'Flexx Sales'
When 'Flexx40 13M 3BR v2.11.2022' Then 'Flexx Sales'
When 'Flexx40 21M 3B v2.11.2022' Then 'Flexx Sales'
When 'Flexx40 21M 3B V3.03.2023' Then 'Flexx Sales'
When 'Flexx40 21M 3BR v2.11.2022' Then 'Flexx Sales'
When 'Flexx40 21M 3BR v3.03.2023' Then 'Flexx Sales'
When 'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)' Then 'Flexx Sales'
When 'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)' Then 'Flexx Sales'
When 'Flexx40 3B cash v1.11.2022' Then 'Flexx Sales'
When 'Flexx40 3B Cash V2.03.2023' Then 'Flexx Sales'
When 'Flexx40 3B v3.03.2023' Then 'Flexx Sales'
When 'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)' Then 'Flexx Sales'
When 'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)' Then 'Flexx Sales'
When 'Flexx40 3BR cash v1.11.2022' Then 'Flexx Sales'
When 'Flexx40 3BR v3.03.2023' Then 'Flexx Sales'
When 'LED Bulb Set' Then 'SHS Upgrade'
When 'Light bulb upgrade v3.03.2023' Then 'SHS Upgrade'
When 'LPG discounted 36 Months' Then 'SHS Upgrade'
When 'LPG Upgrade 18 OCT21' Then 'SHS Upgrade'
When 'Mdosi 4BRT v3.03.2023' Then 'Bpower'
When 'Mdosi 5BR v3.03.2023' Then 'Bpower'
When 'Mdosi 5BT v3.03.2023' Then 'Bpower'
When 'Mdosi Cash 4BRT JUN22' Then 'Bpower'
When 'Mdosi Cash 4BRT v3.03.2023' Then 'Bpower'
When 'Mdosi Cash 5BR JUN22' Then 'Bpower'
When 'Mdosi Cash TV24 4BR JUN22' Then 'Tv sales'
When 'Mdosi Lights Radio' Then 'Bpower'
When 'Mdosi Lights RT' Then 'Bpower'
When 'Mdosi TV 24" 4BR v3.03.2023' Then 'Tv sales'
When 'Mdosi TV 24" 4BT v3.03.2023' Then 'Tv sales'
When 'Mdosi TV 24" 5B v3.03.2023' Then 'Tv sales'
When 'Mdosi TV 32" 4BR V3.03.2023' Then 'Tv sales'
When 'Mdosi TV 32" 4BT V3.03.2023' Then 'Tv sales'
When 'Mdosi TV 32" 5B v3.03.2023' Then 'Tv sales'
When 'Mdosi TV Radio' Then 'Tv sales'
When 'Mdosi TV Torch' Then 'Tv sales'
When 'Mwanzo 3BR 18M JUN22' Then 'Bpower'
When 'Mwanzo 3BR 18M v1.03.2023' Then 'Bpower'
When 'Mwanzo 3BT 18M JUN22' Then 'Bpower'
When 'Mwanzo 4B 18M JUN22' Then 'Bpower'
When 'Mwanzo Cash 3BT JUN22' Then 'Bpower'
When 'Optimised 24" TV with Aerial v3.03.2023' Then 'Tv sales'
When 'Other 24" TV Repair OCT22 out of warraty' Then 'Repair/Maintenance'
When 'OtherCU-BatteryRepair OCT22out of waraty' Then 'Repair/Maintenance'
When 'Promo 24” TV V2 with Aerial_JUL21' Then 'TV upgrade'
When 'Promo Flexx10 Cash JUN22' Then 'Flexx Sales'
When 'Promo Flexx40 Lights APR22' Then 'Flexx Sales'
When 'Promo Flexx40 Radio JUN22' Then 'Flexx Sales'
When 'Repair CU OCT21' Then 'Repair/Maintenance'
When 'Repair Radio V4 OCT21' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (in warranty' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (in warranty)' Then 'Repair/Maintenance'
When 'Shaver Repair OCT22 (out of warranty)' Then 'Repair/Maintenance'
When 'Solar panel 50W upgrade' Then 'SHS Upgrade'
When 'SPHN_Discounted Samsung A13 v1.03.2023' Then 'Connect'
When 'SPHN_SAgent_Samsung A03 Core' Then 'Connect'
When 'SPHN_Samsung A03 Core' Then 'Connect'
When 'SPHN_Samsung A03 Core bundled Offer v1.12.22' Then 'Connect'
When 'SPHN_Samsung A03 Core v1.03.2023_test' Then 'Connect'
When 'SPHN_Samsung A03 Core v3.10.2022' Then 'Connect'
When 'SPHN_Samsung A13 bundled Offer v1.12.22' Then 'Connect'
When 'SPHN_Samsung A13 v3.10.2022' Then 'Connect'
When 'SPHN_Samsung A14 v1.07.2023' Then 'Connect'
When 'StarTimes Nova with Subscription' Then 'SHS Upgrade'
When 'StarTimes Nova with Subscription v2.03.2023' Then 'SHS Upgrade'
When 'SureChill Fridge v3.03.2023' Then 'Bpower'
When 'Taa Imara 5BR – High DP Pilot (Kakuma & Isiolo)' Then 'Bpower'
When 'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)' Then 'Bpower'
When 'Taa Imara 5BR v1.03.2023' Then 'Bpower'
When 'Taa Imara 5BT – High DP Pilot (Kakuma & Isiolo)' Then 'Bpower'
When 'Taa Imara 5BT – Low DP Pilot (Kibwezi & Wote)' Then 'Bpower'
When 'Taa Imara 5BT v1.03.2023' Then 'Bpower'
When 'Torch' Then 'SHS Upgrade'
When 'Torch V3' Then 'SHS Upgrade'
When 'TV 15'''' with Aerial' Then 'Faida'
When 'TV 24'''' with Aerial' Then 'TV upgrade'
When 'TV 24" with Aerial + Lithium Battery V2.03.2023' Then 'TV upgrade'
When 'TV 32" with Aerial + Lithium Battery v2.03.2023' Then 'TV upgrade'
When 'Unilever Retailer' Then 'SHS Upgrade'
When 'Upfront Multiple USB Charger Repair OCT22' Then 'Repair/Maintenance'
When 'Upgrade Fan v3.03.2023' Then 'SHS Upgrade'
When 'Upgrade Light bulb set' Then 'SHS Upgrade'
When 'Upgrade of Radio' Then 'SHS Upgrade'
When 'Upgrade Power Bank 10000mAh' Then 'SHS Upgrade'
When 'Upgrade Shaver v2.03.2023' Then 'SHS Upgrade'
When 'Upgrade Shaver v3.03.2023' Then 'SHS Upgrade'
When 'Upgrade Subwoofer' Then 'SHS Upgrade'
When 'Upgrade Subwoofer V1.03.2023' Then 'SHS Upgrade'
When 'Upgrade Subwoofer  V1.03.2023' Then 'SHS Upgrade'
When 'Upgrade Torch' Then 'SHS Upgrade'
When 'Welcome Pack V1' Then 'faida'
When 'Welcome Pack V2 Bulb' Then 'faida'
When 'Welcome Pack V2 Radio V3' Then 'faida'
When 'Welcome Pack V2 Radio V4' Then 'faida'
When 'Welcome Pack V2 Torch' Then 'faida'
When 'ZUKU Satellite TV Kit with Subscription' Then 'SHS Upgrade'
When 'ZUKU Satellite TV Kit with Subscription v2.03.2023' Then 'SHS Upgrade'
When 'Upgrade Subwoofer V1.03.2023' Then 'SHS Upgrade'
When 'Flexx40 3BR v3.09.2023' Then 'Flexx Sales'
When 'Flexx40 3B v3.09.2023' Then 'Flexx Sales'
When 'Mdosi TV 32" 4BT v3.09.2023' Then 'Tv sales'
When '39” PAYGO TV v1.08.2023' Then 'Tv sales'
When 'Taa Imara 5BT v1.09.2023' Then 'Bpower'
When 'Taa Imara 5BR v1.09.2023' Then 'Bpower'
When 'Mdosi TV 24" 4BR v3.09.2023' Then 'Tv sales'
When 'Mdosi TV 32" 5B v3.09.2023' then 'Tv sales'
When 'SPHN_Samsung A14 v2.09.2023' Then 'Connect'
When 'Chap Chap Mdosi 4BRT' Then 'Bpower'
When 'Taa Imara 4BRT v1.09.2023' Then 'Bpower'
when 'Infinix Smart 7 HD 2+64GB' then 'Connect'
when 'Tecno Pop 7 Pro 4+64GB' then 'Connect'
when 'Mdosi TV 32" 4BR v3.09.2023' then 'Tv sales'
when 'Mdosi TV 24" 4BT v3.09.2023' then 'TV sales'
When 'Mdosi TV 24" 5B v3.09.2023' then 'Tv sales'
When 'Mdosi TV 32" 5B v3.09.2023' then 'Tv sales'
When 'bPower 160 TV 32" 4BR v1.10.2023' then 'Tv sales'
When 'Mdosi TV 24" 4BR + Fan v3.09.2023' then 'Tv sales'
When 'Flexx 12 v1.11.2023' then 'Flexx sales'
When 'Mwananchi TV 24" 4BT v1.10.2023' then 'TV sales'
When 'Sonko TV 39" 5B + Fan v1.10.2023' then 'TV sales'
when 'Tosha TV 32" 4BT v1.10.2023' then 'TV sales'
when 'Tosha TV 32" 4BR v1.10.2023' then 'TV sales'
when 'Tosha Upgrade TV 32" v1.11.2023' then 'TV upgrade'
when 'Tosha Upgrade TV 32" 4BR v1.11.2023' then 'TV upgrade'
When 'Tosha Upgrade TV 32" v1.11.2023' Then 'TV upgrade'
When 'Tosha Upgrade TV 32" 4BR  v1.11.2023' Then 'TV upgrade'
when 'Mwananchi TV 24" 4BR v1.10.2023' then 'TV sales'
when 'Mwananchi Upgrade TV 24" v1.11.2023' then 'TV upgrade'
when 'Power Bank 10000mAh' then 'SHS Upgrade'
when 'Samsung A14' then 'Connect'
when 'Samsung A03 Core' then 'Connect'
when '12W Solar Panel of Flexx40' then 'SHS Upgrade'
when 'bP60 to bPower120 + 24" TV upgrade v1.11.23' then 'TV upgrade'
when 'Sonko TV 39" 5B + Woofer v1.10.2023'then 'TV sales'
when 'CU Lithium 9.9Ah Upgrade V1.03.2023' then 'SHS Upgrade'
When 'Flexx40 3B v4.03.2024' Then 'Flexx Sales'
When 'Flexx40 3BR v4.03.2024' Then 'Flexx Sales'
When 'Taa Imara 4BRT v2.03.2024' Then 'Bpower'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'TV upgrade'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'TV sales'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'TV sales'
When 'Taa Imara 5BR v2.03.2024' Then 'Bpower'
When 'CU Lithium 9.9Ah Upgrade V2.03.2024' Then 'SHS Upgrade'
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 'TV upgrade'
When 'Flexx 12 v2.03.2024' Then 'Flexx sales'
When 'Flexx40 3B v4.03.2024' Then 'Flexx Sales'
When 'Flexx40 3BR v4.03.2024' Then 'Flexx Sales'
When 'Mdosi TV 24" 4BR v4.03.2024' Then 'Tv sales'
When 'Mdosi TV 24" 4BT v4.03.2024' Then 'Tv sales'
When 'Taa Imara 4BRT v2.03.2024' Then 'Bpower'
When 'Taa Imara 5BR v2.03.2024' Then 'Bpower'
When 'Taa Imara 5BT v2.03.2024' Then 'Bpower'
When 'TV 24" with Aerial + Lithium Battery V3.03.2024' Then 'TV upgrade'
end as MD,
case trim(product_name)
when '12W Solar Panel of Flexx40'  Then 0
when '21M Mdosi 4BRT JUN22'  Then 1300
when '21M Mdosi 5BR JUN22'  Then 1300
when '21M Mdosi 5BT JUN22'  Then 1300
when '21M Mdosi TV24 4BR JUN22'  Then 1820
when '21M Mdosi TV24 4BR v3.03.2023'  Then 1820
when '21M Mdosi TV24 4BT JUN22'  Then 1820
when '21M Mdosi TV24 4BT v3.03.2023'  Then 1820
when '21M Mdosi TV24 5B JUN22'  Then 1820
when '21M Mdosi TV32 3BR NOV21'  Then 2210
when '21M Mdosi TV32 3BT NOV21'  Then 2210
when '21M Mdosi TV32 4BR JUN22'  Then 2210
when '21M Mdosi TV32 4BR v3.03.2023'  Then 2210
when '21M Mdosi TV32 4BT JUN22'  Then 2210
when '21M Mdosi TV32 4BT v3.03.2023'  Then 2210
when '21M Mdosi TV32 5B JUN22'  Then 2210
when '21M Optimised 24" TV with Aerial'  Then 1560
when '21M SureChill Fridge OCT22'  Then 0
when '24" TV V2 with Aerial + Lithium Battery'  Then 910
when '24" TV V2 with Aerial NOV21'  Then 910
when '24" TV V2 with Aerial v3.03.2023'  Then 910
when '24″ TV V2 with Aerial'  Then 910
when '32" TV with Aerial + Lithium Battery'  Then 1092
when '36M Optimised 24" TV with Aerial'  Then 1560
when '36M Optimised 24" TV with Aerial v3.03.2023'  Then 1560
when '39” PAYGO TV v1.08.2023'  Then 1700
when 'Bboxx Subwoofer with PVC leather'  Then 560
when 'bP60 to bPower120 + 24" TV upgrade v1.11.23'  Then 910
when 'Cash Optimised 24" TV with Aerial v3.03.2023'  Then 3120
when 'Chap Chap Mdosi 4BRT'  Then 1300
when 'Chap Chap Mdosi 4BRT MAY21'  Then 1000
when 'Chap Chap Mdosi 4BRT OCT21'  Then 1300
when 'Chap Chap Mdosi 5BT MAY21'  Then 1000
when 'Chap Chap Mdosi TV 4BR_JUL21'  Then 1820
when 'Chap Chap Mdosi TV32 3BR OCT21'  Then 2210
when 'Chap Chap Mdosi TV32 3BT OCT21'  Then 2210
when 'Chap Chap TV 4BR'  Then 1820
when 'CU Lithium 9.9Ah Upgrade V1.03.2023'  Then 650
when 'DC Radio (V4)'  Then 105
when 'DC Radio (V4.1)'  Then 105
when 'DC Shaver'  Then 175
when 'Discounted bP20 to Lithium battery + 24" TV v1.03.2023'  Then 0
when 'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023'  Then 650
when 'Discounted Fan upgrade v3.03.2023'  Then 455
when 'Discounted shaver OCT21'  Then 227.5
when 'Discounted subwoofer OCT21'  Then 728
when 'Discounted Sub-woofer upgrade v3.03.2023'  Then 728
when 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024'  Then 700
when 'Discounted TV 24" with Aerial + Lithium Battery'  Then 910
when 'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023'  Then 910
when 'Discounted TV 24" with Aerial OCT21'  Then 910
when 'Discounted TV 32" with Aerial + Lithium Battery'  Then 1092
when 'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023'  Then 1092
when 'Discounted TV 32" with Aerial OCT21'  Then 1092
when 'Fan Upgrade'  Then 455
when 'Flexx 12 v1.11.2023'  Then 390
when 'Flexx10 Cash V3.03.2023'  Then 910
when 'Flexx40 13M 3B v2.11.2022'  Then 910
when 'Flexx40 13M 3BR v2.11.2022'  Then 910
when 'Flexx40 21M 3B v2.11.2022'  Then 910
when 'Flexx40 21M 3B V3.03.2023'  Then 715
when 'Flexx40 21M 3BR v2.11.2022'  Then 910
when 'Flexx40 21M 3BR v3.03.2023'  Then 910
when 'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)'  Then 650
when 'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)'  Then 650
when 'Flexx40 3B cash v1.11.2022'  Then 1430
when 'Flexx40 3B Cash V2.03.2023'  Then 1430
when 'Flexx40 3B v3.03.2023'  Then 715
when 'Flexx40 3B v3.09.2023'  Then 715
when 'Flexx40 3B v4.03.2024'  Then 800
when 'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)'  Then 910
when 'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)'  Then 910
when 'Flexx40 3BR cash v1.11.2022'  Then 910
when 'Flexx40 3BR v3.03.2023'  Then 910
when 'Flexx40 3BR v3.09.2023'  Then 910
when 'Flexx40 3BR v4.03.2024'  Then 1000
when 'Infinix Smart 7 HD 2+64GB'  Then 650
when 'LED Bulb Set'  Then 136.5
when 'Light bulb upgrade v3.03.2023'  Then 136.5
when 'LPG Upgrade 18 OCT21'  Then 500
when 'Mdosi 4BRT v3.03.2023'  Then 1300
when 'Mdosi 5BR v3.03.2023'  Then 1300
when 'Mdosi 5BT v3.03.2023'  Then 1300
when 'Mdosi Cash 4BRT JUN22'  Then 1000
when 'Mdosi Cash 4BRT v3.03.2023'  Then 2600
when 'Mdosi Cash 5BR JUN22'  Then 1000
when 'Mdosi Cash TV24 4BR JUN22'  Then 1820
when 'Mdosi Lights Radio'  Then 1000
when 'Mdosi Lights RT'  Then 1300
when 'Mdosi TV 24" 4BR + Fan v3.09.2023'  Then 1700
when 'Mdosi TV 24" 4BR v3.03.2023'  Then 1820
when 'Mdosi TV 24" 4BR v3.09.2023'  Then 1820
when 'Mdosi TV 24" 4BR v4.03.2024'  Then 2100
when 'Mdosi TV 24" 4BT v3.03.2023'  Then 1820
when 'Mdosi TV 24" 4BT v3.09.2023'  Then 1820
when 'Mdosi TV 24" 4BT v4.03.2024'  Then 2100
when 'Mdosi TV 24" 5B v3.03.2023'  Then 1820
when 'Mdosi TV 24" 5B v3.09.2023'  Then 1820
when 'Mdosi TV 32" 4BR V3.03.2023'  Then 2210
when 'Mdosi TV 32" 4BR v3.09.2023'  Then 2210
when 'Mdosi TV 32" 4BT V3.03.2023'  Then 2210
when 'Mdosi TV 32" 4BT v3.09.2023'  Then 2210
when 'Mdosi TV 32" 5B v3.03.2023'  Then 2210
when 'Mdosi TV 32" 5B v3.09.2023'  Then 2210
when 'Mdosi TV Radio'  Then 1820
when 'Mdosi TV Torch'  Then 1820
when 'Mwananchi TV 24" 4BR v1.10.2023'  Then 2080
when 'Mwananchi TV 24" 4BT v1.10.2023'  Then 2080
when 'Mwananchi Upgrade TV 24" v1.11.2023'  Then 910
when 'Mwanzo 3BR 18M JUN22'  Then 1105
when 'Mwanzo 3BR 18M v1.03.2023'  Then 1105
when 'Mwanzo 3BT 18M JUN22'  Then 850
when 'Mwanzo 3BT 18M V1.03.2023'  Then 1105
when 'Mwanzo 4B 18M JUN22'  Then 850
when 'Mwanzo Cash 3BT JUN22'  Then 1700
when 'Optimised 24" TV with Aerial v3.03.2023'  Then 1560
when 'Power Bank 10000mAh'  Then 325
when 'Promo 24” TV V2 with Aerial_JUL21'  Then 910
when 'Promo Flexx10 Cash JUN22'  Then 300
when 'Promo Flexx40 Lights APR22'  Then 650
when 'Promo Flexx40 Radio JUN22'  Then 910
when 'Samsung A03 Core'  Then 0
when 'Samsung A14'  Then 1130
when 'Solar panel 50W upgrade'  Then 123.5
when 'Sonko TV 39" 5B + Fan v1.10.2023'  Then 1820
when 'Sonko TV 39" 5B + Woofer v1.10.2023'  Then 2600
when 'SPHN_Discounted Samsung A13 v1.03.2023'  Then 910
when 'SPHN_SAgent_Samsung A03 Core'  Then 0
when 'SPHN_Samsung A03 Core'  Then 650
when 'SPHN_Samsung A03 Core bundled Offer v1.12.22'  Then 780
when 'SPHN_Samsung A03 Core v1.03.2023_test'  Then 0
when 'SPHN_Samsung A03 Core v3.10.2022'  Then 650
when 'SPHN_Samsung A13 bundled Offer v1.12.22'  Then 1040
when 'SPHN_Samsung A13 v3.10.2022'  Then 910
when 'SPHN_Samsung A14 v1.07.2023'  Then 1130
when 'SPHN_Samsung A14 v2.09.2023'  Then 1130
when 'StarTimes Nova with Subscription'  Then 350
when 'StarTimes Nova with Subscription v2.03.2023'  Then 455
when 'SureChill Fridge v3.03.2023'  Then 0
when 'Taa Imara 4BRT v1.09.2023'  Then 1300
when 'Taa Imara 4BRT v2.03.2024'  Then 1400
when 'Taa Imara 5BR – High DP Pilot (Kakuma & Isiolo)'  Then 1560
when 'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)'  Then 1300
when 'Taa Imara 5BR v1.03.2023'  Then 1300
when 'Taa Imara 5BR v1.09.2023'  Then 1300
when 'Taa Imara 5BR v2.03.2024'  Then 1400
when 'Taa Imara 5BT – High DP Pilot (Kakuma & Isiolo)'  Then 1560
when 'Taa Imara 5BT – Low DP Pilot (Kibwezi & Wote)'  Then 1300
when 'Taa Imara 5BT v1.03.2023'  Then 1300
when 'Taa Imara 5BT v1.09.2023'  Then 1300
when 'Tecno Pop 7 Pro 4+64GB'  Then 700
when 'Torch'  Then 136.5
when 'Torch V3'  Then 136.5
when 'Tosha TV 32" 4BR v1.10.2023'  Then 2340
when 'Tosha TV 32" 4BT v1.10.2023'  Then 2340
when 'Tosha Upgrade TV 32" 4BR v1.11.2023'  Then 1091
when 'Tosha Upgrade TV 32" v1.11.2023'  Then 1091
when 'TV 24'' with Aerial'  Then 910
when 'TV 24" with Aerial + Lithium Battery V2.03.2023'  Then 910
when 'TV 32" with Aerial + Lithium Battery v2.03.2023'  Then 1092
when 'Unilever Retailer'  Then 0
when 'Upgrade Fan v3.03.2023'  Then 455
when 'Upgrade Light bulb set'  Then 136.5
when 'Upgrade of Radio'  Then 136.5
when 'Upgrade of Radio v3.03.2023'  Then 136.5
when 'Upgrade of Torch v3.03.2023'  Then 136.5
when 'Upgrade Power Bank 10000mAh'  Then 325
when 'Upgrade Shaver v2.03.2023'  Then 227.5
when 'Upgrade Shaver v3.03.2023'  Then 227.5
when 'Upgrade Subwoofer'  Then 728
when 'Upgrade Subwoofer V1.03.2023'  Then 728
when 'Upgrade Torch'  Then 136.5
when 'ZUKU Satellite TV Kit with Subscription'  Then 350
when 'ZUKU Satellite TV Kit with Subscription v2.03.2023'  Then 455
When 'CU Lithium 9.9Ah Upgrade V2.03.2024' Then 650
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 700
When 'Flexx 12 v2.03.2024' Then 420
When 'Flexx40 3B v4.03.2024' Then 800
When 'Flexx40 3BR v4.03.2024' Then 1000
When 'Mdosi TV 24" 4BR v4.03.2024' Then 2100
When 'Mdosi TV 24" 4BT v4.03.2024' Then 2100
When 'Taa Imara 4BRT v2.03.2024' Then 1400
When 'Taa Imara 5BR v2.03.2024' Then 1400
When 'Taa Imara 5BT v2.03.2024' Then 1400
When 'TV 24" with Aerial + Lithium Battery V3.03.2024' Then 700
when 'Mdosi TV 32" 4BR v4.03.2024'  Then 2500
end as total_Commissions,
case trim(product_name)
when '12W Solar Panel of Flexx40'  Then 0
when '21M Mdosi 4BRT JUN22'  Then 390
when '21M Mdosi 5BR JUN22'  Then 390
when '21M Mdosi 5BT JUN22'  Then 390
when '21M Mdosi TV24 4BR JUN22'  Then 1820
when '21M Mdosi TV24 4BR v3.03.2023'  Then 1820
when '21M Mdosi TV24 4BT JUN22'  Then 1820
when '21M Mdosi TV24 4BT v3.03.2023'  Then 1820
when '21M Mdosi TV24 5B JUN22'  Then 1820
when '21M Mdosi TV32 3BR NOV21'  Then 2210
when '21M Mdosi TV32 3BT NOV21'  Then 2210
when '21M Mdosi TV32 4BR JUN22'  Then 2210
when '21M Mdosi TV32 4BR v3.03.2023'  Then 2210
when '21M Mdosi TV32 4BT JUN22'  Then 2210
when '21M Mdosi TV32 4BT v3.03.2023'  Then 2210
when '21M Mdosi TV32 5B JUN22'  Then 2210
when '21M Optimised 24" TV with Aerial'  Then 1560
when '21M SureChill Fridge OCT22'  Then 0
when '24" TV V2 with Aerial + Lithium Battery'  Then 910
when '24" TV V2 with Aerial NOV21'  Then 910
when '24" TV V2 with Aerial v3.03.2023'  Then 910
when '24″ TV V2 with Aerial'  Then 273
when '32" TV with Aerial + Lithium Battery'  Then 1092
when '36M Optimised 24" TV with Aerial'  Then 1560
when '36M Optimised 24" TV with Aerial v3.03.2023'  Then 1560
when '39” PAYGO TV v1.08.2023'  Then 510
when 'Bboxx Subwoofer with PVC leather'  Then 168
when 'bP60 to bPower120 + 24" TV upgrade v1.11.23'  Then 910
when 'Cash Optimised 24" TV with Aerial v3.03.2023'  Then 3120
when 'Chap Chap Mdosi 4BRT'  Then 390
when 'Chap Chap Mdosi 4BRT MAY21'  Then 300
when 'Chap Chap Mdosi 4BRT OCT21'  Then 390
when 'Chap Chap Mdosi 5BT MAY21'  Then 300
when 'Chap Chap Mdosi TV 4BR_JUL21'  Then 1820
when 'Chap Chap Mdosi TV32 3BR OCT21'  Then 2210
when 'Chap Chap Mdosi TV32 3BT OCT21'  Then 2210
when 'Chap Chap TV 4BR'  Then 1820
when 'CU Lithium 9.9Ah Upgrade V1.03.2023'  Then 195
when 'DC Radio (V4)'  Then 31.5
when 'DC Radio (V4.1)'  Then 31.5
when 'DC Shaver'  Then 52.5
when 'Discounted bP20 to Lithium battery + 24" TV v1.03.2023'  Then 0
when 'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023'  Then 195
when 'Discounted Fan upgrade v3.03.2023'  Then 136.5
when 'Discounted shaver OCT21'  Then 68.25
when 'Discounted subwoofer OCT21'  Then 218.4
when 'Discounted Sub-woofer upgrade v3.03.2023'  Then 218.4
when 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024'  Then 700
when 'Discounted TV 24" with Aerial + Lithium Battery'  Then 910
when 'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023'  Then 910
when 'Discounted TV 24" with Aerial OCT21'  Then 910
when 'Discounted TV 32" with Aerial + Lithium Battery'  Then 1092
when 'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023'  Then 1092
when 'Discounted TV 32" with Aerial OCT21'  Then 1092
when 'Fan Upgrade'  Then 136.5
when 'Flexx 12 v1.11.2023'  Then 117
when 'Flexx10 Cash V3.03.2023'  Then 273
when 'Flexx40 13M 3B v2.11.2022'  Then 273
when 'Flexx40 13M 3BR v2.11.2022'  Then 273
when 'Flexx40 21M 3B v2.11.2022'  Then 273
when 'Flexx40 21M 3B V3.03.2023'  Then 214.5
when 'Flexx40 21M 3BR v2.11.2022'  Then 273
when 'Flexx40 21M 3BR v3.03.2023'  Then 273
when 'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)'  Then 195
when 'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)'  Then 195
when 'Flexx40 3B cash v1.11.2022'  Then 429
when 'Flexx40 3B Cash V2.03.2023'  Then 429
when 'Flexx40 3B v3.03.2023'  Then 214.5
when 'Flexx40 3B v3.09.2023'  Then 214.5
when 'Flexx40 3B v4.03.2024'  Then 240
when 'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)'  Then 273
when 'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)'  Then 273
when 'Flexx40 3BR cash v1.11.2022'  Then 273
when 'Flexx40 3BR v3.03.2023'  Then 273
when 'Flexx40 3BR v3.09.2023'  Then 273
when 'Flexx40 3BR v4.03.2024'  Then 300
when 'Infinix Smart 7 HD 2+64GB'  Then 195
when 'LED Bulb Set'  Then 40.95
when 'Light bulb upgrade v3.03.2023'  Then 40.95
when 'LPG Upgrade 18 OCT21'  Then 150
when 'Mdosi 4BRT v3.03.2023'  Then 390
when 'Mdosi 5BR v3.03.2023'  Then 390
when 'Mdosi 5BT v3.03.2023'  Then 390
when 'Mdosi Cash 4BRT JUN22'  Then 300
when 'Mdosi Cash 4BRT v3.03.2023'  Then 780
when 'Mdosi Cash 5BR JUN22'  Then 300
when 'Mdosi Cash TV24 4BR JUN22'  Then 1820
when 'Mdosi Lights Radio'  Then 300
when 'Mdosi Lights RT'  Then 390
when 'Mdosi TV 24" 4BR + Fan v3.09.2023'  Then 1700
when 'Mdosi TV 24" 4BR v3.03.2023'  Then 1820
when 'Mdosi TV 24" 4BR v3.09.2023'  Then 1820
when 'Mdosi TV 24" 4BR v4.03.2024'  Then 2100
when 'Mdosi TV 24" 4BT v3.03.2023'  Then 1820
when 'Mdosi TV 24" 4BT v3.09.2023'  Then 1820
when 'Mdosi TV 24" 4BT v4.03.2024'  Then 2100
when 'Mdosi TV 24" 5B v3.03.2023'  Then 1820
when 'Mdosi TV 24" 5B v3.09.2023'  Then 1820
when 'Mdosi TV 32" 4BR V3.03.2023'  Then 2210
when 'Mdosi TV 32" 4BR v3.09.2023'  Then 2210
when 'Mdosi TV 32" 4BT V3.03.2023'  Then 2210
when 'Mdosi TV 32" 4BT v3.09.2023'  Then 2210
when 'Mdosi TV 32" 5B v3.03.2023'  Then 2210
when 'Mdosi TV 32" 5B v3.09.2023'  Then 2210
when 'Mdosi TV Radio'  Then 1820
when 'Mdosi TV Torch'  Then 1820
when 'Mwananchi TV 24" 4BR v1.10.2023'  Then 2080
when 'Mwananchi TV 24" 4BT v1.10.2023'  Then 2080
when 'Mwananchi Upgrade TV 24" v1.11.2023'  Then 910
when 'Mwanzo 3BR 18M JUN22'  Then 331.5
when 'Mwanzo 3BR 18M v1.03.2023'  Then 331.5
when 'Mwanzo 3BT 18M JUN22'  Then 255
when 'Mwanzo 3BT 18M V1.03.2023'  Then 331.5
when 'Mwanzo 4B 18M JUN22'  Then 255
when 'Mwanzo Cash 3BT JUN22'  Then 510
when 'Optimised 24" TV with Aerial v3.03.2023'  Then 1560
when 'Power Bank 10000mAh'  Then 97.5
when 'Promo 24” TV V2 with Aerial_JUL21'  Then 273
when 'Promo Flexx10 Cash JUN22'  Then 90
when 'Promo Flexx40 Lights APR22'  Then 195
when 'Promo Flexx40 Radio JUN22'  Then 273
when 'Samsung A03 Core'  Then 0
when 'Samsung A14'  Then 339
when 'Solar panel 50W upgrade'  Then 37.05
when 'Sonko TV 39" 5B + Fan v1.10.2023'  Then 1820
when 'Sonko TV 39" 5B + Woofer v1.10.2023'  Then 2600
when 'SPHN_Discounted Samsung A13 v1.03.2023'  Then 273
when 'SPHN_SAgent_Samsung A03 Core'  Then 0
when 'SPHN_Samsung A03 Core'  Then 195
when 'SPHN_Samsung A03 Core bundled Offer v1.12.22'  Then 234
when 'SPHN_Samsung A03 Core v1.03.2023_test'  Then 0
when 'SPHN_Samsung A03 Core v3.10.2022'  Then 195
when 'SPHN_Samsung A13 bundled Offer v1.12.22'  Then 312
when 'SPHN_Samsung A13 v3.10.2022'  Then 273
when 'SPHN_Samsung A14 v1.07.2023'  Then 339
when 'SPHN_Samsung A14 v2.09.2023'  Then 339
when 'StarTimes Nova with Subscription'  Then 105
when 'StarTimes Nova with Subscription v2.03.2023'  Then 136.5
when 'SureChill Fridge v3.03.2023'  Then 0
when 'Taa Imara 4BRT v1.09.2023'  Then 390
when 'Taa Imara 4BRT v2.03.2024'  Then 420
when 'Taa Imara 5BR – High DP Pilot (Kakuma & Isiolo)'  Then 468
when 'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)'  Then 390
when 'Taa Imara 5BR v1.03.2023'  Then 390
when 'Taa Imara 5BR v1.09.2023'  Then 390
when 'Taa Imara 5BR v2.03.2024'  Then 420
when 'Taa Imara 5BT – High DP Pilot (Kakuma & Isiolo)'  Then 468
when 'Taa Imara 5BT – Low DP Pilot (Kibwezi & Wote)'  Then 390
when 'Taa Imara 5BT v1.03.2023'  Then 390
when 'Taa Imara 5BT v1.09.2023'  Then 390
when 'Tecno Pop 7 Pro 4+64GB'  Then 210
when 'Torch'  Then 40.95
when 'Torch V3'  Then 40.95
when 'Tosha TV 32" 4BR v1.10.2023'  Then 2340
when 'Tosha TV 32" 4BT v1.10.2023'  Then 2340
when 'Tosha Upgrade TV 32" 4BR v1.11.2023'  Then 1091
when 'Tosha Upgrade TV 32" v1.11.2023'  Then 1091
when 'TV 24'' with Aerial'  Then 910
when 'TV 24" with Aerial + Lithium Battery V2.03.2023'  Then 910
when 'TV 32" with Aerial + Lithium Battery v2.03.2023'  Then 1092
when 'Unilever Retailer'  Then 0
when 'Upgrade Fan v3.03.2023'  Then 136.5
when 'Upgrade Light bulb set'  Then 40.95
when 'Upgrade of Radio'  Then 40.95
when 'Upgrade of Radio v3.03.2023'  Then 40.95
when 'Upgrade of Torch v3.03.2023'  Then 40.95
when 'Upgrade Power Bank 10000mAh'  Then 97.5
when 'Upgrade Shaver v2.03.2023'  Then 68.25
when 'Upgrade Shaver v3.03.2023'  Then 68.25
when 'Upgrade Subwoofer'  Then 218.4
when 'Upgrade Subwoofer V1.03.2023'  Then 218.4
when 'Upgrade Torch'  Then 40.95
when 'ZUKU Satellite TV Kit with Subscription'  Then 105
when 'ZUKU Satellite TV Kit with Subscription v2.03.2023'  Then 136.5
When 'CU Lithium 9.9Ah Upgrade V2.03.2024' Then 195
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 700
When 'Flexx 12 v2.03.2024' Then 126
When 'Flexx40 3B v4.03.2024' Then 240
When 'Flexx40 3BR v4.03.2024' Then 300
When 'Mdosi TV 24" 4BR v4.03.2024' Then 2100
When 'Mdosi TV 24" 4BT v4.03.2024' Then 2100
When 'Taa Imara 4BRT v2.03.2024' Then 420
When 'Taa Imara 5BR v2.03.2024' Then 420
When 'Taa Imara 5BT v2.03.2024' Then 420
When 'TV 24" with Aerial + Lithium Battery V3.03.2024' Then 700
when 'Mdosi TV 32" 4BR v4.03.2024'  Then 2500
end as next_day_Commissions,
case trim(product_name)
when '12W Solar Panel of Flexx40'  Then 0
when '21M Mdosi 4BRT JUN22'  Then 910
when '21M Mdosi 5BR JUN22'  Then 910
when '21M Mdosi 5BT JUN22'  Then 910
when '21M Mdosi TV24 4BR JUN22'  Then 0
when '21M Mdosi TV24 4BR v3.03.2023'  Then 0
when '21M Mdosi TV24 4BT JUN22'  Then 0
when '21M Mdosi TV24 4BT v3.03.2023'  Then 0
when '21M Mdosi TV24 5B JUN22'  Then 0
when '21M Mdosi TV32 3BR NOV21'  Then 0
when '21M Mdosi TV32 3BT NOV21'  Then 0
when '21M Mdosi TV32 4BR JUN22'  Then 0
when '21M Mdosi TV32 4BR v3.03.2023'  Then 0
when '21M Mdosi TV32 4BT JUN22'  Then 0
when '21M Mdosi TV32 4BT v3.03.2023'  Then 0
when '21M Mdosi TV32 5B JUN22'  Then 0
when '21M Optimised 24" TV with Aerial'  Then 0
when '21M SureChill Fridge OCT22'  Then 0
when '24" TV V2 with Aerial + Lithium Battery'  Then 0
when '24" TV V2 with Aerial NOV21'  Then 0
when '24" TV V2 with Aerial v3.03.2023'  Then 0
when '24″ TV V2 with Aerial'  Then 637
when '32" TV with Aerial + Lithium Battery'  Then 0
when '36M Optimised 24" TV with Aerial'  Then 0
when '36M Optimised 24" TV with Aerial v3.03.2023'  Then 0
when '39” PAYGO TV v1.08.2023'  Then 1190
when 'Bboxx Subwoofer with PVC leather'  Then 392
when 'bP60 to bPower120 + 24" TV upgrade v1.11.23'  Then 0
when 'Cash Optimised 24" TV with Aerial v3.03.2023'  Then 0
when 'Chap Chap Mdosi 4BRT'  Then 910
when 'Chap Chap Mdosi 4BRT MAY21'  Then 700
when 'Chap Chap Mdosi 4BRT OCT21'  Then 910
when 'Chap Chap Mdosi 5BT MAY21'  Then 700
when 'Chap Chap Mdosi TV 4BR_JUL21'  Then 0
when 'Chap Chap Mdosi TV32 3BR OCT21'  Then 0
when 'Chap Chap Mdosi TV32 3BT OCT21'  Then 0
when 'Chap Chap TV 4BR'  Then 0
when 'CU Lithium 9.9Ah Upgrade V1.03.2023'  Then 455
when 'DC Radio (V4)'  Then 73.5
when 'DC Radio (V4.1)'  Then 73.5
when 'DC Shaver'  Then 122.5
when 'Discounted bP20 to Lithium battery + 24" TV v1.03.2023'  Then 0
when 'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023'  Then 455
when 'Discounted Fan upgrade v3.03.2023'  Then 318.5
when 'Discounted shaver OCT21'  Then 159.25
when 'Discounted subwoofer OCT21'  Then 509.6
when 'Discounted Sub-woofer upgrade v3.03.2023'  Then 509.6
when 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024'  Then 0
when 'Discounted TV 24" with Aerial + Lithium Battery'  Then 0
when 'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023'  Then 0
when 'Discounted TV 24" with Aerial OCT21'  Then 0
when 'Discounted TV 32" with Aerial + Lithium Battery'  Then 0
when 'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023'  Then 0
when 'Discounted TV 32" with Aerial OCT21'  Then 0
when 'Fan Upgrade'  Then 318.5
when 'Flexx 12 v1.11.2023'  Then 273
when 'Flexx10 Cash V3.03.2023'  Then 637
when 'Flexx40 13M 3B v2.11.2022'  Then 637
when 'Flexx40 13M 3BR v2.11.2022'  Then 637
when 'Flexx40 21M 3B v2.11.2022'  Then 637
when 'Flexx40 21M 3B V3.03.2023'  Then 500.5
when 'Flexx40 21M 3BR v2.11.2022'  Then 637
when 'Flexx40 21M 3BR v3.03.2023'  Then 637
when 'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)'  Then 455
when 'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)'  Then 455
when 'Flexx40 3B cash v1.11.2022'  Then 1001
when 'Flexx40 3B Cash V2.03.2023'  Then 1001
when 'Flexx40 3B v3.03.2023'  Then 500.5
when 'Flexx40 3B v3.09.2023'  Then 500.5
when 'Flexx40 3B v4.03.2024'  Then 560
when 'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)'  Then 637
when 'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)'  Then 637
when 'Flexx40 3BR cash v1.11.2022'  Then 637
when 'Flexx40 3BR v3.03.2023'  Then 637
when 'Flexx40 3BR v3.09.2023'  Then 637
when 'Flexx40 3BR v4.03.2024'  Then 700
when 'Infinix Smart 7 HD 2+64GB'  Then 455
when 'LED Bulb Set'  Then 95.55
when 'Light bulb upgrade v3.03.2023'  Then 95.55
when 'LPG Upgrade 18 OCT21'  Then 350
when 'Mdosi 4BRT v3.03.2023'  Then 910
when 'Mdosi 5BR v3.03.2023'  Then 910
when 'Mdosi 5BT v3.03.2023'  Then 910
when 'Mdosi Cash 4BRT JUN22'  Then 700
when 'Mdosi Cash 4BRT v3.03.2023'  Then 1820
when 'Mdosi Cash 5BR JUN22'  Then 700
when 'Mdosi Cash TV24 4BR JUN22'  Then 0
when 'Mdosi Lights Radio'  Then 700
when 'Mdosi Lights RT'  Then 910
when 'Mdosi TV 24" 4BR + Fan v3.09.2023'  Then 0
when 'Mdosi TV 24" 4BR v3.03.2023'  Then 0
when 'Mdosi TV 24" 4BR v3.09.2023'  Then 0
when 'Mdosi TV 24" 4BR v4.03.2024'  Then 0
when 'Mdosi TV 24" 4BT v3.03.2023'  Then 0
when 'Mdosi TV 24" 4BT v3.09.2023'  Then 0
when 'Mdosi TV 24" 4BT v4.03.2024'  Then 0
when 'Mdosi TV 24" 5B v3.03.2023'  Then 0
when 'Mdosi TV 24" 5B v3.09.2023'  Then 0
when 'Mdosi TV 32" 4BR V3.03.2023'  Then 0
when 'Mdosi TV 32" 4BR v3.09.2023'  Then 0
when 'Mdosi TV 32" 4BT V3.03.2023'  Then 0
when 'Mdosi TV 32" 4BT v3.09.2023'  Then 0
when 'Mdosi TV 32" 5B v3.03.2023'  Then 0
when 'Mdosi TV 32" 5B v3.09.2023'  Then 0
when 'Mdosi TV Radio'  Then 0
when 'Mdosi TV Torch'  Then 0
when 'Mwananchi TV 24" 4BR v1.10.2023'  Then 0
when 'Mwananchi TV 24" 4BT v1.10.2023'  Then 0
when 'Mwananchi Upgrade TV 24" v1.11.2023'  Then 0
when 'Mwanzo 3BR 18M JUN22'  Then 773.5
when 'Mwanzo 3BR 18M v1.03.2023'  Then 773.5
when 'Mwanzo 3BT 18M JUN22'  Then 595
when 'Mwanzo 3BT 18M V1.03.2023'  Then 773.5
when 'Mwanzo 4B 18M JUN22'  Then 595
when 'Mwanzo Cash 3BT JUN22'  Then 1190
when 'Optimised 24" TV with Aerial v3.03.2023'  Then 0
when 'Power Bank 10000mAh'  Then 227.5
when 'Promo 24” TV V2 with Aerial_JUL21'  Then 637
when 'Promo Flexx10 Cash JUN22'  Then 210
when 'Promo Flexx40 Lights APR22'  Then 455
when 'Promo Flexx40 Radio JUN22'  Then 637
when 'Samsung A03 Core'  Then 0
when 'Samsung A14'  Then 791
when 'Solar panel 50W upgrade'  Then 86.45
when 'Sonko TV 39" 5B + Fan v1.10.2023'  Then 0
when 'Sonko TV 39" 5B + Woofer v1.10.2023'  Then 0
when 'SPHN_Discounted Samsung A13 v1.03.2023'  Then 637
when 'SPHN_SAgent_Samsung A03 Core'  Then 0
when 'SPHN_Samsung A03 Core'  Then 455
when 'SPHN_Samsung A03 Core bundled Offer v1.12.22'  Then 546
when 'SPHN_Samsung A03 Core v1.03.2023_test'  Then 0
when 'SPHN_Samsung A03 Core v3.10.2022'  Then 455
when 'SPHN_Samsung A13 bundled Offer v1.12.22'  Then 728
when 'SPHN_Samsung A13 v3.10.2022'  Then 637
when 'SPHN_Samsung A14 v1.07.2023'  Then 791
when 'SPHN_Samsung A14 v2.09.2023'  Then 791
when 'StarTimes Nova with Subscription'  Then 245
when 'StarTimes Nova with Subscription v2.03.2023'  Then 318.5
when 'SureChill Fridge v3.03.2023'  Then 0
when 'Taa Imara 4BRT v1.09.2023'  Then 910
when 'Taa Imara 4BRT v2.03.2024'  Then 980
when 'Taa Imara 5BR – High DP Pilot (Kakuma & Isiolo)'  Then 1092
when 'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)'  Then 910
when 'Taa Imara 5BR v1.03.2023'  Then 910
when 'Taa Imara 5BR v1.09.2023'  Then 910
when 'Taa Imara 5BR v2.03.2024'  Then 980
when 'Taa Imara 5BT – High DP Pilot (Kakuma & Isiolo)'  Then 1092
when 'Taa Imara 5BT – Low DP Pilot (Kibwezi & Wote)'  Then 910
when 'Taa Imara 5BT v1.03.2023'  Then 910
when 'Taa Imara 5BT v1.09.2023'  Then 910
when 'Tecno Pop 7 Pro 4+64GB'  Then 490
when 'Torch'  Then 95.55
when 'Torch V3'  Then 95.55
when 'Tosha TV 32" 4BR v1.10.2023'  Then 0
when 'Tosha TV 32" 4BT v1.10.2023'  Then 0
when 'Tosha Upgrade TV 32" 4BR v1.11.2023'  Then 0
when 'Tosha Upgrade TV 32" v1.11.2023'  Then 0
when 'TV 24'' with Aerial'  Then 0
when 'TV 24" with Aerial + Lithium Battery V2.03.2023'  Then 0
when 'TV 32" with Aerial + Lithium Battery v2.03.2023'  Then 0
when 'Unilever Retailer'  Then 0
when 'Upgrade Fan v3.03.2023'  Then 318.5
when 'Upgrade Light bulb set'  Then 95.55
when 'Upgrade of Radio'  Then 95.55
when 'Upgrade of Radio v3.03.2023'  Then 95.55
when 'Upgrade of Torch v3.03.2023'  Then 95.55
when 'Upgrade Power Bank 10000mAh'  Then 227.5
when 'Upgrade Shaver v2.03.2023'  Then 159.25
when 'Upgrade Shaver v3.03.2023'  Then 159.25
when 'Upgrade Subwoofer'  Then 509.6
when 'Upgrade Subwoofer V1.03.2023'  Then 509.6
when 'Upgrade Torch'  Then 95.55
when 'ZUKU Satellite TV Kit with Subscription'  Then 245
when 'ZUKU Satellite TV Kit with Subscription v2.03.2023'  Then 318.5
When 'CU Lithium 9.9Ah Upgrade V2.03.2024' Then 455
When 'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024' Then 0
When 'Flexx 12 v2.03.2024' Then 294
When 'Flexx40 3B v4.03.2024' Then 560
When 'Flexx40 3BR v4.03.2024' Then 700
When 'Mdosi TV 24" 4BR v4.03.2024' Then 0
When 'Mdosi TV 24" 4BT v4.03.2024' Then 0
When 'Taa Imara 4BRT v2.03.2024' Then 980
When 'Taa Imara 5BR v2.03.2024' Then 980
When 'Taa Imara 5BT v2.03.2024' Then 980
When 'TV 24" with Aerial + Lithium Battery V3.03.2024' Then 0
when 'Mdosi TV 32" 4BR v4.03.2024'  Then 0
end as End_week_pay,
case when sales_person is null then 'Walkin'
when substring(sales_person, 1,6) not like 'ke____' then 'Walkin'
else substring(sales_person, 1,6) end as agent_code
from rp_retail_sales rrs 
where downpayment_date >= '2023-01-01' and product_name not like '%ESF%' 
and product_name 
not in ('Welcome Pack V2 Radio V4','Welcome Pack V2 Torch','Welcome Pack V2 Bulb','Welcome Pack V2 Radio V3',
'Faida Chap Chap','Bboxx Faida (bP50 Lights)','Welcome Pack V1','BBOXX Faida TV','TV 15'''' with Aerial',
'24" TV Screen Repair OCT22 (in warranty)','Energy Service Fee V0',
'Shaver Repair OCT22 (in warranty)','bPower50 TV Maintenance','Shaver Repair OCT22 (out of warranty)',
'24" TV Screen Repair OCT22out of warraty','Upfront Multiple USB Charger Repair OCT22',
'Shaver Repair OCT22 (in warranty','Other 24" TV Repair OCT22 out of warraty',
'32" TV Screen Repair OCT22 (in warranty)','Repair CU OCT21','OtherCU-BatteryRepair OCT22out of waraty',
'Repair Radio V4 OCT21','DONT USE Energy Service Fee V1','(Home) Radio','Repair TV 24'''' OCT21')
and product_name not like '%Repair%'