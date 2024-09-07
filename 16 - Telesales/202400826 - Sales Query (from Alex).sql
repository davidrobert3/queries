with sales_data as 
	(select distinct unique_account_id,region as customer_region,
	 CASE 
	        WHEN shop IN ('Isiolo', 'Kabarnet', 'Muranga', 'Nakuru')
	            THEN 'Central'
	        WHEN shop IN ('Hola', 'Kilifi', 'Kinango', 'Kwale', 'Malindi')
	            THEN 'Coast'
	        WHEN shop IN ('Kibwezi', 'Oloitoktok', 'Voi', 'Wote')
	            THEN 'Eastern 1'
	        WHEN shop IN ('Kajiado', 'Kitui', 'Machakos', 'Matuu')
	            THEN 'Eastern 2'
	        WHEN shop IN ('Eldoret', 'Kakuma', 'Kapenguria', 'Kapsabet', 'Kipkaren', 'Kitale')
	            THEN 'North Rift'
	        WHEN shop IN ('Homa Bay', 'Kendu Bay', 'Magunga', 'Mbita')
	            THEN 'Nyanza 1'
	        WHEN shop IN ('Migori', 'Ndhiwa', 'Rongo')
	            THEN 'Nyanza 2'
	        WHEN shop IN ('Chepseon', 'Katito', 'Kipsitet', 'Oyugis')
	            THEN 'South Rift 1'
	        WHEN shop IN ('Bomet', 'Narok', 'Nyangusu')
	            THEN 'South Rift 2'
	        WHEN shop IN ('Bungoma', 'Butere', 'Kakamega', 'Luanda')
	            THEN 'Western 1'
	        WHEN shop IN ('Bondo', 'Bumala', 'Busia', 'Siaya')
	            THEN 'Western 2'
	    END AS new_regions,shop as customer_shop,downpayment_date,
	    DATE_PART('week',downpayment_date) as week_of_year,
	    
	    CASE 
	        WHEN shop IN ('Bondo',	'Siaya',	'Luanda',	'Butere',	'Homa Bay',	'Mbita',	'Rongo',	'Ndhiwa',	'Migori',	'Katito',	'Oyugis',	'Narok',	'Kapsabet',	'Kipkaren',	'Kakuma',	'Wote',	'Matuu',	'Machakos',	'Malindi',	'Kilifi')
	            THEN 'Selling'
	    	WHEN shop IN ('Bomet','Hola',	'Bumala',	'Bungoma',	'Chepseon',	'Isiolo',	'Kabarnet',	'Kajiado',	'Kakamega',	'Kapenguria',	'Kendu Bay',	'Kibwezi',	'Kipsitet',	'Kitale',	'Kitui',	'Kwale',	'Magunga',	'Muranga',	'Nakuru',	'Nyangusu',	'Oloitoktok',	'Tharaka Nithi',	'Voi')
	    		THEN 'Service Center'
	     END as Shop_Status,
	     
		date_part('day',downpayment_date) as _day,
		to_char(downpayment_date, 'day') as day_name,
		product_name,
		CASE 
            WHEN product_name IN (
                ' Mwananchi TV 24" 4BT v1.10.2023', ' Mwanzo 3BT 18M V1.03.2023', 'Tecno Pop 8 v1.06.2024', 'Mdosi Lights 4BRT Jun 2024',  '21M Mdosi 4BRT JUN22', '21M Mdosi 5BR JUN22',  '21M Mdosi 5BT JUN22',  '21M Mdosi TV24 4BR JUN22', '21M Mdosi TV24 4BR NOV21', '21M Mdosi TV24 4BR v3.03.2023',    '21M Mdosi TV24 4BT JUN22', '21M Mdosi TV24 4BT N0V21', '21M Mdosi TV24 4BT v3.03.2023',    '21M Mdosi TV24 5B JUN22',  '21M Mdosi TV24 5B NOV21',  '21M Mdosi TV32 3BR NOV21', '21M Mdosi TV32 3BT NOV21', '21M Mdosi TV32 4B NOV21',  '21M Mdosi TV32 4BR JUN22', '21M Mdosi TV32 4BR v3.03.2023',    '21M Mdosi TV32 4BT JUN22', '21M Mdosi TV32 4BT v3.03.2023',    '21M Mdosi TV32 5B JUN22',  '21M Optimised 24" TV with Aerial', '36M Optimised 24" TV with Aerial', '36M Optimised 24" TV with Aerial v3.03.2023',  '39â€ PAYGO TV v1.08.2023',    'Accelerated TV 24" with Aerial JUN22', 'Advantage Mdosi 4BRT MAY21',   'Advantage Mdosi 4BRT OCT21',   'Advantage Mdosi 5BR MAY21',    'Advantage Mdosi 5BR OCT21',    'Advantage Mdosi 5BT MAY21',    'Advantage Mdosi 5BT OCT21',    'Advantage Mdosi TV Bulbs_JUL21',   'Advantage Mdosi TV Radio_JUL21',   'Advantage Mdosi TV Torch_JUL21',   'Advantage Mdosi TV32 3BR', 'Advantage Mdosi TV32 3BR OCT21',   'Advantage Mdosi TV32 3BR_JUL21',   'Advantage Mdosi TV32 3BT', 'Advantage Mdosi TV32 3BT OCT21',   'Advantage Mdosi TV32 3BT_JUL21',   'Advantage Mdosi TV32 4B',  'Advantage Mdosi TV32 4B OCT21',    'Advantage Mdosi TV32 4B_JUL21',    'Cash Optimised 24" TV with Aerial v3.03.2023', 'Chap Chap Mdosi 4BRT', 'Chap Chap Mdosi 4BRT MAY21',   'Chap Chap Mdosi 4BRT OCT21',   'Chap Chap Mdosi 5BR',  'Chap Chap Mdosi 5BR MAY21',    'Chap Chap Mdosi 5BR OCT21',    'Chap Chap Mdosi 5BT',  'Chap Chap Mdosi 5BT MAY21',    'Chap Chap Mdosi 5BT OCT21',    'Chap Chap Mdosi TV 4BR_JUL21', 'Chap Chap Mdosi TV 4BT_JUL21', 'Chap Chap Mdosi TV 5B_JUL21',  'Chap Chap Mdosi TV32 3BR', 'Chap Chap Mdosi TV32 3BR OCT21',   'Chap Chap Mdosi TV32 3BR_JUL21',   'Chap Chap Mdosi TV32 3BT', 'Chap Chap Mdosi TV32 3BT OCT21',   'Chap Chap Mdosi TV32 3BT_JUL21',   'Chap Chap Mdosi TV32 4B',  'Chap Chap Mdosi TV32 4B OCT21',    'Chap Chap Mdosi TV32 4B_JUL21',    'Chap Chap Mwanzo 3BR', 'Chap Chap Mwanzo 3BR AUG21',   'Chap Chap Mwanzo 3BT', 'Chap Chap Mwanzo 3BT AUG21',   'Chap Chap Mwanzo 4B',  'Chap Chap Mwanzo 4B AUG21',    'Chap Chap TV 4BR', 'Chap Chap TV 4BT', 'Chap Chap TV 5B',  'ChapChap TV Zuku 4BR', 'ChapChap TV Zuku 4BT', 'Flexx 12 v1.11.2023',  'Flexx 12 v2.03.2024',  'Flexx10 Cash V3.03.2023',  'Flexx10 Cash V4.04.2024',  'Flexx40 13M 3B v2.11.2022',    'Flexx40 13M 3BR v2.11.2022',   'Flexx40 21M 3B v2.11.2022',    'Flexx40 21M 3B V3.03.2023',    'Flexx40 21M 3BR v2.11.2022',   'Flexx40 21M 3BR v3.03.2023',   'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)',   'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)',   'Flexx40 3B Cash V2.03.2023',   'Flexx40 3B v3.03.2023',    'Flexx40 3B v3.09.2023',    'Flexx40 3B v4.03.2024',    'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)',  'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)',  'Flexx40 3BR v3.03.2023',   'Flexx40 3BR v3.09.2023',   'Flexx40 3BR v4.03.2024',   'Flexx40 Lights MAR22', 'Flexx40 Radio Cash JUN22', 'Flexx40 Radio MAR22',  'Infinix Smart 7 HD 2+64GB',    'Maraphones S', 'Mdosi 4BRT v3.03.2023',    'Mdosi 5BR v3.03.2023', 'Mdosi 5BT v3.03.2023', 'Mdosi Cash 4BRT JUN22',    'Mdosi Cash 4BRT v3.03.2023',   'Mdosi Cash 5BR JUN22', 'Mdosi Cash 5BT JUN22', 'Mdosi Cash TV24 4BR JUN22',    'Mdosi Cash TV24 4BT JUN22',    'Mdosi Cash TV32 4BR JUN22',    'Mdosi Lights Radio',   'Mdosi Lights Radio Torch', 'Mdosi Lights RT',  'Mdosi Lights Torch',   'Mdosi TV 24" 4BR + Fan v3.09.2023',    'Mdosi TV 24" 4BR v3.03.2023',  'Mdosi TV 24" 4BR v3.09.2023',  'Mdosi TV 24" 4BR v4.03.2024',  'Mdosi TV 24" 4BT v3.03.2023',  'Mdosi TV 24" 4BT v3.09.2023',  'Mdosi TV 24" 4BT v4.03.2024',  'Mdosi TV 24" 5B v3.03.2023',   'Mdosi TV 24" 5B v3.09.2023',   'Mdosi TV 24" 5B v4.03.2024',   'Mdosi TV 32" 4BR V3.03.2023',  'Mdosi TV 32" 4BR v3.09.2023',  'Mdosi TV 32" 4BR v4.03.2024',  'Mdosi TV 32" 4BT V3.03.2023',  'Mdosi TV 32" 4BT v3.09.2023',  'Mdosi TV 32" 4BT v4.03.2024',  'Mdosi TV 32" 5B v3.03.2023',   'Mdosi TV 32" 5B v3.09.2023',   'Mdosi TV Bulb',    'Mdosi TV Bulbs',   'Mdosi TV Bulbs Zuku',  'Mdosi TV Radio',   'Mdosi TV Radio Zuku',  'Mdosi TV Torch',   'Mdosi TV Torch Zuku',  'Mwananchi TV 24" 4BR v1.10.2023',  'Mwanzo 3BR 18M JUN22', 'Mwanzo 3BR 18M v1.03.2023',    'Mwanzo 3BR 18M_AUG21', 'Mwanzo 3BT 18M JUN22', 'Mwanzo 3BT 18M_AUG21', 'Mwanzo 4B 18M JUN22',  'Mwanzo 4B 18M_AUG21',  'Mwanzo Cash 3BT JUN22',    'Mwanzo Radio', 'Mwanzo Torch', 'Nokia C10',    'Optimised 24" TV with Aerial v3.03.2023',  'Promo Advantage Mwanzo Lights',    'Promo Advantage Mwanzo Radio', 'Promo Advantage Mwanzo Torch', 'Promo Chap Chap Mwanzo 3BR',   'Promo Chap Chap Mwanzo 3BT',   'Promo Chap Chap Mwanzo 4B',    'Promo Flexx10 Cash JUN22', 'Promo Flexx40 Lights APR22',   'Promo Flexx40 Lights JUN22',   'Promo Flexx40 Radio APR22',    'Promo Flexx40 Radio JUN22',    'Samsung A03',  'Samsung A03 Core', 'Samsung A03s', 'Samsung A14',  'Sonko TV 39" 5B + Fan v1.10.2023', 'Sonko TV 39" 5B + Woofer v1.10.2023',  'SPHN_Discounted Samsung A13 v1.03.2023',   'SPHN_SAgent_Samsung A03 Core', 'SPHN_Samsung A03', 'SPHN_Samsung A03 Core',    'SPHN_Samsung A03 Core bundled Offer v1.12.22', 'SPHN_Samsung A03 Core v1.03.2023_test',    'SPHN_Samsung A03 Core v3.10.2022', 'SPHN_Samsung A13', 'SPHN_Samsung A13 bundled Offer v1.12.22',  'SPHN_Samsung A13 v3.10.2022',  'SPHN_Samsung A14 v1.07.2023',  'SPHN_Samsung A14 v2.09.2023',  'Taa Imara 4BRT v1.09.2023',    'Taa Imara 4BRT v2.03.2024',    'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)',    'Taa Imara 5BR â€“ High DP Pilot (Kakuma & Isiolo)',    'Taa Imara 5BR v1.03.2023', 'Taa Imara 5BR v1.09.2023', 'Taa Imara 5BR v2.03.2024', 'Taa Imara 5BT â€“ High DP Pilot (Kakuma & Isiolo)',    'Taa Imara 5BT â€“ Low DP Pilot (Kibwezi & Wote)',  'Taa Imara 5BT v1.03.2023', 'Taa Imara 5BT v1.09.2023', 'Taa Imara 5BT v2.03.2024', 'Tecno Pop 5',  'Tecno Pop 7 Pro 4+64GB',   'Tosha TV 32" 4BR v1.10.2023',  'Tosha TV 32" 4BT v1.10.2023',  'Welcome Pack V1',  'Welcome Pack V2 Bulb', 'Welcome Pack V2 Radio V3', 'Welcome Pack V2 Radio V4', 'Welcome Pack V2 Torch'
                )
                THEN 'Sale'
                
            when product_name IN (
                ' Upgrade of Radio v3.03.2023', ' Upgrade of Torch v3.03.2023', '24" TV V2 with Aerial + Lithium Battery',  '24" TV V2 with Aerial NOV21',  '24" TV V2 with Aerial v3.03.2023', '24â€³ TV V2 with Aerial',  '32" TV with Aerial',   '32" TV with Aerial + Lithium Battery', '32" TV with Aerial NOV21', 'Bboxx Subwoofer with PVC leather', 'bP60 to bPower120 + 24" TV upgrade v1.11.23',  'CU Lithium 9.9Ah Upgrade V1.03.2023',  'CU Lithium 9.9Ah Upgrade V2.03.2024',  'DC Radio (V4)',    'DC Radio (V4.1)',  'DC Shaver',    'Discounted bP20 to Lithium battery + 24" TV v1.03.2023',   'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023',   'Discounted DC Solar Shaver',   'Discounted Fan upgrade v3.03.2023',    'Discounted shaver OCT21',  'Discounted Shaver_APR21',  'Discounted Subwoofer', 'Discounted subwoofer OCT21',   'Discounted Sub-woofer upgrade v3.03.2023', 'Discounted Subwoofer_APR21',   'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',    'Discounted TV 24" with Aerial + Lithium Battery',  'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',   'Discounted TV 24" with Aerial OCT21',  'Discounted TV 32" with Aerial + Lithium Battery',  'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023',   'Discounted TV 32" with Aerial OCT21',  'Discounted TV24'' with Aerial',    'Fan Upgrade',  'LED Bulb Set', 'Light Bulb Set',   'Light bulb upgrade v3.03.2023',    'LPG discounted 18 Months', 'LPG discounted 36 Months', 'LPG Upgrade 18 OCT21', 'LPG Upgrade 36 OCT21', 'Mwananchi Upgrade TV 24" v1.11.2023',  'Promo 24â€ TV V2 with Aerial_JUL21',  'StarTimes Nova with Subscription', 'StarTimes Nova with Subscription v2.03.2023',  'StarTimes Smart with Subscription',    'StarTimes Super with Subscription',    'Torch',    'Torch V2', 'Torch V3', 'Tosha Upgrade TV 32" 4BR  v1.11.2023', 'Tosha Upgrade TV 32" v1.11.2023',  'TV 24'' with Aerial',  'TV 24" with Aerial + Lithium Battery V2.03.2023',  'TV 24" with Aerial + Lithium Battery V3.03.2024',  'TV 32" with Aerial + Lithium Battery v2.03.2023',  'Upgrade (Light bulb set & shade)', 'Upgrade Fan v3.03.2023',   'Upgrade Light bulb set',   'Upgrade of Radio', 'Upgrade Power Bank 10000mAh',  'Upgrade Shaver v2.03.2023',    'Upgrade Shaver v3.03.2023',    'Upgrade Subwoofer',    'Upgrade Subwoofer  V1.03.2023',    'Upgrade Torch',    'ZUKU Satellite TV Kit with Subscription',  'ZUKU Satellite TV Kit with Subscription v2.03.2023'
                )
                THEN 'Upgrade'
                
            ELSE 'Other'
            
          END AS sale_type,  
          
        CASE  
	        WHEN product_name IN ('Light bulb upgrade v3.03.2023',	'LED Bulb Set',	'Upgrade Light bulb set') 
         		THEN 'Bulb'
         	WHEN product_name IN ('Solar panel 50W upgrade',	'CU Lithium 9.9Ah Upgrade V1.03.2023',	'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023',	'CU Lithium 9.9Ah Upgrade V2.03.2024') 
         		THEN 'CU_Upgrade'
         	WHEN product_name IN ('Discounted bP20 to Lithium battery + 24" TV v1.03.2023',	'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',	'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',	'24" TV V2 with Aerial NOV21',	'24" TV V2 with Aerial v3.03.2023',	'24â€³ TV V2 with Aerial',	'Promo 24â€ TV V2 with Aerial_JUL21',	'bP60 to bPower120 + 24" TV upgrade v1.11.23',	'24" TV V2 with Aerial + Lithium Battery',	'Discounted TV 24" with Aerial + Lithium Battery',	'TV 24" with Aerial + Lithium Battery V3.03.2024',	'TV 24" with Aerial + Lithium Battery V2.03.2023',	'Discounted TV 24" with Aerial OCT21',	'TV 24'' with Aerial') 
         		THEN 'TV upgrade 24"'
         	WHEN product_name IN ('Upgrade Fan v3.03.2023',	'Discounted Fan upgrade v3.03.2023',	'Fan Upgrade') 
         		THEN 'Fan'	
         	WHEN product_name IN ('Flexx10 Cash V4.04.2024',	'Flexx10 Cash V3.03.2023',	'Promo Flexx10 Cash JUN22') 
         		THEN 'Flexx 10'
         	WHEN product_name IN ('Flexx 12 v1.11.2023',	'Flexx 12 v2.03.2024') 
         		THEN 'Flexx 12'	
         	WHEN product_name IN ('Flexx40 21M 3B V3.03.2023',	'Flexx40 3B Cash V2.03.2023',	'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)',	'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR v3.03.2023',	'Flexx40 3B v3.03.2023',	'Flexx40 3BR v4.03.2024',	'Flexx40 13M 3B v2.11.2022',	'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR v3.09.2023',	'Flexx40 21M 3B v2.11.2022',	'Flexx40 13M 3BR v2.11.2022',	'Flexx40 3B v3.09.2023',	'Flexx40 3B v4.03.2024',	'Flexx40 21M 3BR v2.11.2022',	'Flexx40 21M 3BR v3.03.2023',	'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)',	'Promo Flexx40 Radio JUN22',	'Promo Flexx40 Lights APR22') 
         		THEN 'Flexx 40'
         	WHEN product_name IN ('LPG Upgrade 18 OCT21') 
         		THEN 'LPG'	
         	WHEN product_name IN ('Mdosi 5BT v3.03.2023',	'Mdosi Lights RT',	'Chap Chap Mdosi 4BRT',	'21M Mdosi 4BRT JUN22',	'Chap Chap Mdosi 5BT MAY21',	'Mdosi Lights Radio',	'Chap Chap Mdosi 4BRT MAY21',	'Mdosi 4BRT v3.03.2023',	'21M Mdosi 5BT JUN22',	'Mdosi Cash 4BRT v3.03.2023',	'Chap Chap Mdosi 4BRT OCT21',	'Mdosi Cash 4BRT JUN22',	'21M Mdosi 5BR JUN22',	'Mdosi 5BR v3.03.2023',	'Mdosi Cash 5BR JUN22') 
         		THEN 'Mdosi Lights'
         	WHEN product_name IN ('Optimised 24" TV with Aerial v3.03.2023',	'Mdosi TV Radio',	'Mdosi TV 24" 5B v3.03.2023',	'Mdosi TV 24" 4BR v3.03.2023',	'21M Mdosi TV24 4BT JUN22',	'21M Mdosi TV24 4BT v3.03.2023',	'Mdosi TV 24" 5B v4.03.2024',	'Mdosi TV 24" 4BR + Fan v3.09.2023',	'Mdosi TV 24" 5B v3.09.2023',	'21M Mdosi TV24 5B JUN22',	'Chap Chap TV 4BR',	'Mdosi TV 24" 4BR v4.03.2024',	'21M Mdosi TV24 4BR JUN22',	'36M Optimised 24" TV with Aerial',	'Mdosi TV 24" 4BT v3.03.2023',	'Mdosi TV 24" 4BT v4.03.2024',	'21M Optimised 24" TV with Aerial',	'Mdosi Cash TV24 4BR JUN22',	'36M Optimised 24" TV with Aerial v3.03.2023',	'Cash Optimised 24" TV with Aerial v3.03.2023',	'Mdosi TV 24" 4BR v3.09.2023',	'Mdosi TV 24" 4BT v3.09.2023',	'21M Mdosi TV24 4BR v3.03.2023',	'Mdosi TV Torch',	'Chap Chap Mdosi TV 4BR_JUL21') 
         		THEN 'Mdosi Tv 24"'	
         	WHEN product_name IN ('Mdosi TV 32" 4BT V3.03.2023',	'21M Mdosi TV32 4BR JUN22',	'Mdosi TV 32" 5B v3.03.2023',	'Mdosi TV 32" 4BT v4.03.2024',	'Mdosi TV 32" 4BR v4.03.2024',	'Mdosi TV 32" 5B v3.09.2023',	'Mdosi TV 32" 4BR v3.09.2023',	'21M Mdosi TV32 4BR v3.03.2023',	'Chap Chap Mdosi TV32 3BT OCT21',	'21M Mdosi TV32 4BT v3.03.2023',	'21M Mdosi TV32 3BT NOV21',	'Mdosi TV 32" 4BT v3.09.2023',	'21M Mdosi TV32 5B JUN22',	'Mdosi TV 32" 4BR V3.03.2023',	'Chap Chap Mdosi TV32 3BR OCT21',	'21M Mdosi TV32 4BT JUN22',	'21M Mdosi TV32 3BR NOV21') 
         		THEN 'Mdosi TV 32"'
         	WHEN product_name IN (' Mwanzo 3BT 18M V1.03.2023',	'Mwanzo Cash 3BT JUN22',	'Mwanzo 3BR 18M v1.03.2023',	'Mwanzo 3BT 18M JUN22',	'Mwanzo 4B 18M JUN22',	'Mwanzo 3BR 18M JUN22') 
         		THEN 'Mwanzo'	
         	WHEN product_name IN ('Tosha TV 32" 4BR v1.10.2023',	'Tosha TV 32" 4BT v1.10.2023',	'Sonko TV 39" 5B + Woofer v1.10.2023',	'Sonko TV 39" 5B + Fan v1.10.2023',	'Mwananchi TV 24" 4BR v1.10.2023',	' Mwananchi TV 24" 4BT v1.10.2023',	'39â€ PAYGO TV v1.08.2023',	'Mwananchi Upgrade TV 24" v1.11.2023') 
         		THEN 'Paygo TV'
         	WHEN product_name IN ('Power Bank 10000mAh',	'Upgrade Power Bank 10000mAh') 
         		THEN 'Power Bank'	
         	WHEN product_name IN (' Upgrade of Radio v3.03.2023',	'Upgrade of Radio',	'DC Radio (V4.1)',	'DC Radio (V4)') 
         		THEN 'Radio'
         	WHEN product_name IN ('Upgrade Shaver v2.03.2023',	'DC Shaver',	'Upgrade Shaver v3.03.2023',	'Discounted shaver OCT21') 
         		THEN 'Shaver'	
         	WHEN product_name IN ('SPHN_Samsung A03 Core v3.10.2022', 'Tecno Pop 8 v1.06.2024',	'Infinix Smart 7 HD 2+64GB',	'Samsung A14',	'SPHN_Samsung A03 Core',	'SPHN_Samsung A14 v2.09.2023',	'SPHN_Samsung A14 v1.07.2023',	'SPHN_Discounted Samsung A13 v1.03.2023',	'Samsung A03 Core',	'SPHN_Samsung A13 v3.10.2022',	'Tecno Pop 7 Pro 4+64GB',	'SPHN_Samsung A13 bundled Offer v1.12.22',	'SPHN_Samsung A03 Core v1.03.2023_test',	'SPHN_SAgent_Samsung A03 Core',	'SPHN_Samsung A03 Core bundled Offer v1.12.22') 
         		THEN 'Smartphone'
         	WHEN product_name IN ('StarTimes Nova with Subscription v2.03.2023',	'StarTimes Nova with Subscription') 
         		THEN 'StarTimes'	
         	WHEN product_name IN ('Bboxx Subwoofer with PVC leather',	'Upgrade Subwoofer',	'Upgrade Subwoofer  V1.03.2023',	'Discounted subwoofer OCT21',	'Discounted Sub-woofer upgrade v3.03.2023') 
         		THEN 'Subwoofer'
         	WHEN product_name IN ('21M SureChill Fridge OCT22',	'SureChill Fridge v3.03.2023') 
         		THEN 'SureChill'	
         	WHEN product_name IN ('Taa Imara 5BT v1.09.2023',	'Taa Imara 5BT â€“ Low DP Pilot (Kibwezi & Wote)',	'Taa Imara 4BRT v2.03.2024',	'Taa Imara 5BR v2.03.2024',	'Taa Imara 5BT v2.03.2024',	'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)',	'Taa Imara 5BR v1.03.2023',	'Taa Imara 5BR â€“ High DP Pilot (Kakuma & Isiolo)',	'Taa Imara 5BT v1.03.2023',	'Taa Imara 4BRT v1.09.2023',	'Taa Imara 5BR v1.09.2023',	'Taa Imara 5BT â€“ High DP Pilot (Kakuma & Isiolo)') 
         		THEN 'Taa Imara'
         	WHEN product_name IN (' Upgrade of Torch v3.03.2023',	'Upgrade Torch',	'Torch V3',	'Torch',	'12W Solar Panel of Flexx40') 
         		THEN 'Torch'	
         	WHEN product_name IN ('Discounted bP20 to Lithium battery + 24" TV v1.03.2023',	'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',	'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',	'24" TV V2 with Aerial NOV21',	'24" TV V2 with Aerial v3.03.2023',	'24â€³ TV V2 with Aerial',	'Promo 24â€ TV V2 with Aerial_JUL21',	'bP60 to bPower120 + 24" TV upgrade v1.11.23',	'24" TV V2 with Aerial + Lithium Battery',	'Discounted TV 24" with Aerial + Lithium Battery',	'TV 24" with Aerial + Lithium Battery V3.03.2024',	'TV 24" with Aerial + Lithium Battery V2.03.2023',	'Discounted TV 24" with Aerial OCT21',	'TV 24'' with Aerial') 
         		THEN 'TV upgrade 24"'
         	WHEN product_name IN ('32" TV with Aerial + Lithium Battery',	'Discounted TV 32" with Aerial OCT21',	'Tosha Upgrade TV 32" v1.11.2023',	'Tosha Upgrade TV 32" 4BR  v1.11.2023',	'TV 32" with Aerial + Lithium Battery v2.03.2023',	'Discounted TV 32" with Aerial + Lithium Battery',	'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023') 
         		THEN 'TV upgrade 32"'	
         	WHEN product_name IN ('Unilever Retailer') 
         		THEN 'Unilever'
         	WHEN product_name IN ('ZUKU Satellite TV Kit with Subscription v2.03.2023',	'ZUKU Satellite TV Kit with Subscription') 
         		THEN 'Zuku'   
         	when product_name IN ('Mdosi Lights 4BRT Jun 2024')
         		then 'Mdosi Lights'
         	ELSE 'Other' 
       
        END as Package,  
     
        CASE  
	        WHEN product_name IN ('Mdosi 5BT v3.03.2023',	'Mdosi Lights RT',	'Chap Chap Mdosi 4BRT',	'21M Mdosi 4BRT JUN22',	'Chap Chap Mdosi 5BT MAY21',	'Mdosi Lights Radio',	'Chap Chap Mdosi 4BRT MAY21',	'Mdosi 4BRT v3.03.2023',	'21M Mdosi 5BT JUN22',	'Mdosi Cash 4BRT v3.03.2023',	'Chap Chap Mdosi 4BRT OCT21',	'Mdosi Cash 4BRT JUN22',	'21M Mdosi 5BR JUN22',	'Mdosi 5BR v3.03.2023',	'Mdosi Cash 5BR JUN22',	' Mwanzo 3BT 18M V1.03.2023',	'Mwanzo Cash 3BT JUN22',	'Mwanzo 3BR 18M v1.03.2023',	'Mwanzo 3BT 18M JUN22',	'Mwanzo 4B 18M JUN22',	'Mwanzo 3BR 18M JUN22'
	        ) THEN 'Bpower Lights'
	        WHEN product_name IN ('SPHN_Samsung A03 Core v3.10.2022', 'Tecno Pop 8 v1.06.2024',	'Infinix Smart 7 HD 2+64GB',	'Samsung A14',	'SPHN_Samsung A03 Core',	'SPHN_Samsung A14 v2.09.2023',	'SPHN_Samsung A14 v1.07.2023',	'SPHN_Discounted Samsung A13 v1.03.2023',	'Samsung A03 Core',	'SPHN_Samsung A13 v3.10.2022',	'Tecno Pop 7 Pro 4+64GB',	'SPHN_Samsung A13 bundled Offer v1.12.22',	'SPHN_Samsung A03 Core v1.03.2023_test',	'SPHN_SAgent_Samsung A03 Core',	'SPHN_Samsung A03 Core bundled Offer v1.12.22'
	        ) THEN 'Connect'
	        WHEN product_name IN ('Flexx10 Cash V4.04.2024',	'Flexx10 Cash V3.03.2023',	'Promo Flexx10 Cash JUN22'
	        ) THEN 'Flexx 10'
	        WHEN product_name IN ('Flexx 12 v1.11.2023',	'Flexx 12 v2.03.2024'
	        ) THEN 'Flexx 12'
	        WHEN product_name IN ('Flexx40 21M 3B V3.03.2023',	'Flexx40 3B Cash V2.03.2023',	'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)',	'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR v3.03.2023',	'Flexx40 3B v3.03.2023',	'Flexx40 3BR v4.03.2024',	'Flexx40 13M 3B v2.11.2022',	'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR v3.09.2023',	'Flexx40 21M 3B v2.11.2022',	'Flexx40 13M 3BR v2.11.2022',	'Flexx40 3B v3.09.2023',	'Flexx40 3B v4.03.2024',	'Flexx40 21M 3BR v2.11.2022',	'Flexx40 21M 3BR v3.03.2023',	'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)',	'Promo Flexx40 Radio JUN22',	'Promo Flexx40 Lights APR22'
	        ) THEN 'Flexx 40'
	        WHEN product_name IN ('Light bulb upgrade v3.03.2023',	'LED Bulb Set',	'Upgrade Light bulb set',	'Solar panel 50W upgrade',	'CU Lithium 9.9Ah Upgrade V1.03.2023',	'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023',	'CU Lithium 9.9Ah Upgrade V2.03.2024',	'Upgrade Fan v3.03.2023',	'Discounted Fan upgrade v3.03.2023',	'Fan Upgrade',	'LPG Upgrade 18 OCT21',	'Power Bank 10000mAh',	'Upgrade Power Bank 10000mAh',	' Upgrade of Radio v3.03.2023',	'Upgrade of Radio',	'DC Radio (V4.1)',	'DC Radio (V4)',	'Upgrade Shaver v2.03.2023',	'DC Shaver',	'Upgrade Shaver v3.03.2023',	'Discounted shaver OCT21',	'StarTimes Nova with Subscription v2.03.2023',	'StarTimes Nova with Subscription',	'Bboxx Subwoofer with PVC leather',	'Upgrade Subwoofer',	'Upgrade Subwoofer  V1.03.2023',	'Discounted subwoofer OCT21',	'Discounted Sub-woofer upgrade v3.03.2023',	' Upgrade of Torch v3.03.2023',	'Upgrade Torch',	'Torch V3',	'Torch',	'12W Solar Panel of Flexx40',	'Unilever Retailer',	'ZUKU Satellite TV Kit with Subscription v2.03.2023',	'ZUKU Satellite TV Kit with Subscription'
	        ) THEN 'other Appliances Upgrade'
	        WHEN product_name IN ('21M SureChill Fridge OCT22',	'SureChill Fridge v3.03.2023'
	        ) THEN 'Surechill'
	        WHEN product_name IN ('Taa Imara 5BT v1.09.2023', 'Mdosi Lights 4BRT Jun 2024',	'Taa Imara 5BT â€“ Low DP Pilot (Kibwezi & Wote)',	'Taa Imara 4BRT v2.03.2024',	'Taa Imara 5BR v2.03.2024',	'Taa Imara 5BT v2.03.2024',	'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)',	'Taa Imara 5BR v1.03.2023',	'Taa Imara 5BR â€“ High DP Pilot (Kakuma & Isiolo)',	'Taa Imara 5BT v1.03.2023',	'Taa Imara 4BRT v1.09.2023',	'Taa Imara 5BR v1.09.2023',	'Taa Imara 5BT â€“ High DP Pilot (Kakuma & Isiolo)'
	        ) THEN 'Taa Imara'
	        WHEN product_name IN ('Optimised 24" TV with Aerial v3.03.2023',	'Mdosi TV Radio',	'Mdosi TV 24" 5B v3.03.2023',	'Mdosi TV 24" 4BR v3.03.2023',	'21M Mdosi TV24 4BT JUN22',	'21M Mdosi TV24 4BT v3.03.2023',	'Mdosi TV 24" 5B v4.03.2024',	'Mdosi TV 24" 4BR + Fan v3.09.2023',	'Mdosi TV 24" 5B v3.09.2023',	'21M Mdosi TV24 5B JUN22',	'Chap Chap TV 4BR',	'Mdosi TV 24" 4BR v4.03.2024',	'21M Mdosi TV24 4BR JUN22',	'36M Optimised 24" TV with Aerial',	'Mdosi TV 24" 4BT v3.03.2023',	'Mdosi TV 24" 4BT v4.03.2024',	'21M Optimised 24" TV with Aerial',	'Mdosi Cash TV24 4BR JUN22',	'36M Optimised 24" TV with Aerial v3.03.2023',	'Cash Optimised 24" TV with Aerial v3.03.2023',	'Mdosi TV 24" 4BR v3.09.2023',	'Mdosi TV 24" 4BT v3.09.2023',	'21M Mdosi TV24 4BR v3.03.2023',	'Mdosi TV Torch',	'Chap Chap Mdosi TV 4BR_JUL21',	'Mdosi TV 32" 4BT V3.03.2023',	'21M Mdosi TV32 4BR JUN22',	'Mdosi TV 32" 5B v3.03.2023',	'Mdosi TV 32" 4BT v4.03.2024',	'Mdosi TV 32" 4BR v4.03.2024',	'Mdosi TV 32" 5B v3.09.2023',	'Mdosi TV 32" 4BR v3.09.2023',	'21M Mdosi TV32 4BR v3.03.2023',	'Chap Chap Mdosi TV32 3BT OCT21',	'21M Mdosi TV32 4BT v3.03.2023',	'21M Mdosi TV32 3BT NOV21',	'Mdosi TV 32" 4BT v3.09.2023',	'21M Mdosi TV32 5B JUN22',	'Mdosi TV 32" 4BR V3.03.2023',	'Chap Chap Mdosi TV32 3BR OCT21',	'21M Mdosi TV32 4BT JUN22',	'21M Mdosi TV32 3BR NOV21',	'Tosha TV 32" 4BR v1.10.2023',	'Tosha TV 32" 4BT v1.10.2023',	'Sonko TV 39" 5B + Woofer v1.10.2023',	'Sonko TV 39" 5B + Fan v1.10.2023',	'Mwananchi TV 24" 4BR v1.10.2023',	' Mwananchi TV 24" 4BT v1.10.2023',	'39â€ PAYGO TV v1.08.2023'
	        ) THEN 'TV sales'
	        WHEN product_name IN ('Discounted bP20 to Lithium battery + 24" TV v1.03.2023',	'Mwananchi Upgrade TV 24" v1.11.2023',	'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',	'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',	'24" TV V2 with Aerial NOV21',	'24" TV V2 with Aerial v3.03.2023',	'24â€³ TV V2 with Aerial',	'Promo 24â€ TV V2 with Aerial_JUL21',	'bP60 to bPower120 + 24" TV upgrade v1.11.23',	'24" TV V2 with Aerial + Lithium Battery',	'Discounted TV 24" with Aerial + Lithium Battery',	'TV 24" with Aerial + Lithium Battery V3.03.2024',	'TV 24" with Aerial + Lithium Battery V2.03.2023',	'Discounted TV 24" with Aerial OCT21',	'TV 24'' with Aerial',	'32" TV with Aerial + Lithium Battery',	'Discounted TV 32" with Aerial OCT21',	'Tosha Upgrade TV 32" v1.11.2023',	'Tosha Upgrade TV 32" 4BR  v1.11.2023',	'TV 32" with Aerial + Lithium Battery v2.03.2023',	'Discounted TV 32" with Aerial + Lithium Battery',	'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023'
	        ) THEN 'TV upgrade'
	        
	       ELSE 'Other' 
       
        END as Product_Package,
        
        CASE 
           WHEN product_name IN ( 'Mdosi 5BT v3.03.2023',	'Mdosi Lights RT',	'Chap Chap Mdosi 4BRT','Mdosi Lights 4BRT Jun 2024',	'21M Mdosi 4BRT JUN22',	'Chap Chap Mdosi 5BT MAY21',	'Mdosi Lights Radio',	'Chap Chap Mdosi 4BRT MAY21',	'Mdosi 4BRT v3.03.2023',	'21M Mdosi 5BT JUN22',	'Mdosi Cash 4BRT v3.03.2023',	'Chap Chap Mdosi 4BRT OCT21',	'Mdosi Cash 4BRT JUN22',	'21M Mdosi 5BR JUN22',	'Mdosi 5BR v3.03.2023',	'Mdosi Cash 5BR JUN22',	' Mwanzo 3BT 18M V1.03.2023',	'Mwanzo Cash 3BT JUN22',	'Mwanzo 3BR 18M v1.03.2023',	'Mwanzo 3BT 18M JUN22',	'Mwanzo 4B 18M JUN22',	'Mwanzo 3BR 18M JUN22',	'21M SureChill Fridge OCT22',	'SureChill Fridge v3.03.2023',	'Taa Imara 5BT v1.09.2023',	'Taa Imara 5BT â€“ Low DP Pilot (Kibwezi & Wote)',	'Taa Imara 4BRT v2.03.2024',	'Taa Imara 5BR v2.03.2024',	'Taa Imara 5BT v2.03.2024',	'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)',	'Taa Imara 5BR v1.03.2023',	'Taa Imara 5BR â€“ High DP Pilot (Kakuma & Isiolo)',	'Taa Imara 5BT v1.03.2023',	'Taa Imara 4BRT v1.09.2023',	'Taa Imara 5BR v1.09.2023',	'Taa Imara 5BT â€“ High DP Pilot (Kakuma & Isiolo)'
            ) THEN 'Bpower'
            
           WHEN product_name IN ('SPHN_Samsung A03 Core v3.10.2022', 'Tecno Pop 8 v1.06.2024',	'Infinix Smart 7 HD 2+64GB',	'Samsung A14',	'SPHN_Samsung A03 Core',	'SPHN_Samsung A14 v2.09.2023',	'SPHN_Samsung A14 v1.07.2023',	'SPHN_Discounted Samsung A13 v1.03.2023',	'Samsung A03 Core',	'SPHN_Samsung A13 v3.10.2022',	'Tecno Pop 7 Pro 4+64GB',	'SPHN_Samsung A13 bundled Offer v1.12.22',	'SPHN_Samsung A03 Core v1.03.2023_test',	'SPHN_SAgent_Samsung A03 Core',	'SPHN_Samsung A03 Core bundled Offer v1.12.22'
            ) THEN 'Connect'
            
           WHEN product_name IN ('Flexx10 Cash V4.04.2024',	'Flexx10 Cash V3.03.2023',	'Flexx 12 v1.11.2023',	'Flexx 12 v2.03.2024',	'Promo Flexx10 Cash JUN22',	'Flexx40 21M 3B V3.03.2023',	'Flexx40 3B Cash V2.03.2023',	'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)',	'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR v3.03.2023',	'Flexx40 3B v3.03.2023',	'Flexx40 3BR v4.03.2024',	'Flexx40 13M 3B v2.11.2022',	'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR v3.09.2023',	'Flexx40 21M 3B v2.11.2022',	'Flexx40 13M 3BR v2.11.2022',	'Flexx40 3B v3.09.2023',	'Flexx40 3B v4.03.2024',	'Flexx40 21M 3BR v2.11.2022',	'Flexx40 21M 3BR v3.03.2023',	'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)',	'Promo Flexx40 Radio JUN22',	'Promo Flexx40 Lights APR22'               
            ) THEN 'Flexx Sales'

           WHEN product_name IN ('Light bulb upgrade v3.03.2023','LED Bulb Set',	'Upgrade Light bulb set',	'Solar panel 50W upgrade',	'CU Lithium 9.9Ah Upgrade V1.03.2023',	'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023',	'CU Lithium 9.9Ah Upgrade V2.03.2024',	'Upgrade Fan v3.03.2023',	'Discounted Fan upgrade v3.03.2023',	'Fan Upgrade',	'LPG Upgrade 18 OCT21',	'Power Bank 10000mAh',	'Upgrade Power Bank 10000mAh',	' Upgrade of Radio v3.03.2023',	'Upgrade of Radio',	'DC Radio (V4.1)',	'DC Radio (V4)',	'Upgrade Shaver v2.03.2023',	'DC Shaver',	'Upgrade Shaver v3.03.2023',	'Discounted shaver OCT21',	'StarTimes Nova with Subscription v2.03.2023',	'StarTimes Nova with Subscription',	'Bboxx Subwoofer with PVC leather',	'Upgrade Subwoofer',	'Upgrade Subwoofer  V1.03.2023',	'Discounted subwoofer OCT21',	'Discounted Sub-woofer upgrade v3.03.2023',	' Upgrade of Torch v3.03.2023',	'Upgrade Torch',	'Torch V3',	'Torch',	'12W Solar Panel of Flexx40',	'Unilever Retailer',	'ZUKU Satellite TV Kit with Subscription v2.03.2023',	'ZUKU Satellite TV Kit with Subscription'
               
            ) THEN 'SHS Upgrade'

           WHEN product_name IN ('Optimised 24" TV with Aerial v3.03.2023',	'Mdosi TV Radio',	'Mdosi TV 24" 5B v3.03.2023',	'Mdosi TV 24" 4BR v3.03.2023',	'21M Mdosi TV24 4BT JUN22',	'21M Mdosi TV24 4BT v3.03.2023',	'Mdosi TV 24" 5B v4.03.2024',	'Mdosi TV 24" 4BR + Fan v3.09.2023',	'Mdosi TV 24" 5B v3.09.2023',	'21M Mdosi TV24 5B JUN22',	'Chap Chap TV 4BR',	'Mdosi TV 24" 4BR v4.03.2024',	'21M Mdosi TV24 4BR JUN22',	'36M Optimised 24" TV with Aerial',	'Mdosi TV 24" 4BT v3.03.2023',	'Mdosi TV 24" 4BT v4.03.2024',	'21M Optimised 24" TV with Aerial',	'Mdosi Cash TV24 4BR JUN22',	'36M Optimised 24" TV with Aerial v3.03.2023',	'Cash Optimised 24" TV with Aerial v3.03.2023',	'Mdosi TV 24" 4BR v3.09.2023',	'Mdosi TV 24" 4BT v3.09.2023',	'21M Mdosi TV24 4BR v3.03.2023',	'Mdosi TV Torch',	'Chap Chap Mdosi TV 4BR_JUL21',	'Mdosi TV 32" 4BT V3.03.2023',	'21M Mdosi TV32 4BR JUN22',	'Mdosi TV 32" 5B v3.03.2023',	'Mdosi TV 32" 4BT v4.03.2024',	'Mdosi TV 32" 4BR v4.03.2024',	'Mdosi TV 32" 5B v3.09.2023',	'Mdosi TV 32" 4BR v3.09.2023',	'21M Mdosi TV32 4BR v3.03.2023',	'Chap Chap Mdosi TV32 3BT OCT21',	'21M Mdosi TV32 4BT v3.03.2023',	'21M Mdosi TV32 3BT NOV21',	'Mdosi TV 32" 4BT v3.09.2023',	'21M Mdosi TV32 5B JUN22',	'Mdosi TV 32" 4BR V3.03.2023',	'Chap Chap Mdosi TV32 3BR OCT21',	'21M Mdosi TV32 4BT JUN22',	'21M Mdosi TV32 3BR NOV21',	'Tosha TV 32" 4BR v1.10.2023',	'Tosha TV 32" 4BT v1.10.2023',	'Sonko TV 39" 5B + Woofer v1.10.2023',	'Sonko TV 39" 5B + Fan v1.10.2023',	'Mwananchi TV 24" 4BR v1.10.2023',	' Mwananchi TV 24" 4BT v1.10.2023',	'39â€ PAYGO TV v1.08.2023'               
            ) THEN 'Tv sales'

           WHEN product_name IN ('Discounted bP20 to Lithium battery + 24" TV v1.03.2023',	'Mwananchi Upgrade TV 24" v1.11.2023',	'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',	'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',	'24" TV V2 with Aerial NOV21',	'24" TV V2 with Aerial v3.03.2023',	'24â€³ TV V2 with Aerial',	'Promo 24â€ TV V2 with Aerial_JUL21',	'bP60 to bPower120 + 24" TV upgrade v1.11.23',	'24" TV V2 with Aerial + Lithium Battery',	'Discounted TV 24" with Aerial + Lithium Battery',	'TV 24" with Aerial + Lithium Battery V3.03.2024',	'TV 24" with Aerial + Lithium Battery V2.03.2023',	'Discounted TV 24" with Aerial OCT21',	'TV 24'' with Aerial',	'32" TV with Aerial + Lithium Battery',	'Discounted TV 32" with Aerial OCT21',	'Tosha Upgrade TV 32" v1.11.2023',	'Tosha Upgrade TV 32" 4BR  v1.11.2023',	'TV 32" with Aerial + Lithium Battery v2.03.2023',	'Discounted TV 32" with Aerial + Lithium Battery',	'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023'               
            ) THEN 'TV upgrade'
           
         	ELSE 'Other'
           
         END AS MD, 
         
         CASE 
        	WHEN contract_length IS NULL 
            	THEN NULL 
       		ELSE (contract_length/30)::INT
    	END AS contract_tenure_months,
    
    	total_downpayment DP_Amount,
    	
    	 case
	    	 WHEN product_name IN ('DC Radio (V4)',	'DC Radio (V4.1)'
                ) THEN 105
             WHEN product_name IN ('Solar panel 50W upgrade'
                ) THEN 123.5  
             WHEN product_name IN (' Upgrade of Radio v3.03.2023',	' Upgrade of Torch v3.03.2023',	'LED Bulb Set',	'Light bulb upgrade v3.03.2023',	'Torch',	'Torch V3',	'Upgrade Light bulb set',	'Upgrade of Radio',	'Upgrade Torch'
                ) THEN 136.5
    	 	 WHEN product_name IN ('DC Shaver'
                ) THEN 175 
             WHEN product_name IN ('Discounted shaver OCT21',	'Upgrade Shaver v2.03.2023',	'Upgrade Shaver v3.03.2023'
                ) THEN 227.5    
             WHEN product_name IN ('Flexx10 Cash V4.04.2024',	'Promo Flexx10 Cash JUN22'
                ) THEN 300    
             WHEN product_name IN ('Power Bank 10000mAh',	'Upgrade Power Bank 10000mAh'
                ) THEN 325   
             WHEN product_name IN ('StarTimes Nova with Subscription',	'ZUKU Satellite TV Kit with Subscription'
                ) THEN 350  
             WHEN product_name IN ('Flexx 12 v1.11.2023',	'Flexx 12 v2.03.2024'
                ) THEN 420  
             WHEN product_name IN ('Discounted Fan upgrade v3.03.2023',	'Fan Upgrade',	'StarTimes Nova with Subscription v2.03.2023',	'Upgrade Fan v3.03.2023',	'ZUKU Satellite TV Kit with Subscription v2.03.2023'
                ) THEN 455 
             WHEN product_name IN ('LPG Upgrade 18 OCT21'
                ) THEN 500  
             WHEN product_name IN ('Bboxx Subwoofer with PVC leather'
                ) THEN 560   
             WHEN product_name IN ('CU Lithium 9.9Ah Upgrade V1.03.2023',	'CU Lithium 9.9Ah Upgrade V2.03.2024',	'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023',	'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)',	'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)',	'Promo Flexx40 Lights APR22',	'SPHN_Samsung A03 Core',	'SPHN_Samsung A03 Core v3.10.2022'
                ) THEN 650    
             WHEN product_name IN ('Discounted subwoofer OCT21',	'Discounted Sub-woofer upgrade v3.03.2023',	'Upgrade Subwoofer',	'Upgrade Subwoofer  V1.03.2023'
                ) THEN 728    
             WHEN product_name IN ('Infinix Smart 7 HD 2+64GB'
                ) THEN 750 
             WHEN product_name IN ('SPHN_Samsung A03 Core bundled Offer v1.12.22'
                ) THEN 780   
             WHEN product_name IN ('Flexx40 21M 3B V3.03.2023',	'Flexx40 3B v3.03.2023',	'Flexx40 3B v3.09.2023',	'Flexx40 3B v4.03.2024'
                ) THEN 800    
             WHEN product_name IN ('Mwanzo 3BT 18M JUN22',	'Mwanzo 4B 18M JUN22',	'Tecno Pop 7 Pro 4+64GB','Samsung A03 Core'
                ) THEN 850   
             WHEN product_name IN ('Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',	'Discounted TV 24" with Aerial + Lithium Battery',	'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',	'Discounted TV 24" with Aerial OCT21',	'Flexx10 Cash V3.03.2023',	'Flexx40 13M 3B v2.11.2022',	'Flexx40 13M 3BR v2.11.2022',	'Flexx40 21M 3B v2.11.2022',	'Flexx40 21M 3BR v2.11.2022',	'Flexx40 21M 3BR v3.03.2023',	'Promo 24â€ TV V2 with Aerial_JUL21',	'Promo Flexx40 Radio JUN22',	'SPHN_Discounted Samsung A13 v1.03.2023',	'SPHN_Samsung A13 v3.10.2022',	'TV 24" with Aerial + Lithium Battery V3.03.2024'
                ) THEN 910    
             WHEN product_name IN ('Chap Chap Mdosi 4BRT MAY21','Tecno Pop 8 v1.06.2024',	'Chap Chap Mdosi 5BT MAY21',	'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)',	'Flexx40 3BR v3.03.2023',	'Flexx40 3BR v3.09.2023',	'Flexx40 3BR v4.03.2024',	'Mdosi Cash 4BRT JUN22',	'Mdosi Cash 5BR JUN22',	'Mdosi Lights Radio'
                ) THEN 1000   
             WHEN product_name IN ('SPHN_Samsung A13 bundled Offer v1.12.22'
                ) THEN 1040    
             WHEN product_name IN ('Discounted TV 32" with Aerial + Lithium Battery',	'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023',	'Discounted TV 32" with Aerial OCT21'
                ) THEN 1092  
             WHEN product_name IN (' Mwanzo 3BT 18M V1.03.2023',	'Mwanzo 3BR 18M JUN22',	'Mwanzo 3BR 18M v1.03.2023'
                ) THEN 1105  
             WHEN product_name IN ('24" TV V2 with Aerial + Lithium Battery',	'24" TV V2 with Aerial NOV21',	'24" TV V2 with Aerial v3.03.2023',	'24â€³ TV V2 with Aerial',	'32" TV with Aerial + Lithium Battery',	'bP60 to bPower120 + 24" TV upgrade v1.11.23',	'Mwananchi Upgrade TV 24" v1.11.2023',	'Tosha Upgrade TV 32" v1.11.2023',	'TV 24" with Aerial + Lithium Battery V2.03.2023',	'TV 32" with Aerial + Lithium Battery v2.03.2023'
                ) THEN 1200   
             WHEN product_name IN ('21M Mdosi 4BRT JUN22',	'21M Mdosi 5BR JUN22',	'21M Mdosi 5BT JUN22',	'Chap Chap Mdosi 4BRT',	'Chap Chap Mdosi 4BRT OCT21',	'Mdosi 4BRT v3.03.2023',	'Mdosi 5BR v3.03.2023',	'Mdosi 5BT v3.03.2023',	'Mdosi Lights RT',	'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)'
                ) THEN 1300    
             WHEN product_name IN ('Samsung A14',	'SPHN_Samsung A14 v1.07.2023',	'SPHN_Samsung A14 v2.09.2023', 'Mdosi Lights 4BRT Jun 2024',	'Taa Imara 4BRT v1.09.2023',	'Taa Imara 4BRT v2.03.2024',	'Taa Imara 5BR v1.03.2023',	'Taa Imara 5BR v1.09.2023',	'Taa Imara 5BR v2.03.2024',	'Taa Imara 5BT â€“ Low DP Pilot (Kibwezi & Wote)',	'Taa Imara 5BT v1.03.2023',	'Taa Imara 5BT v1.09.2023',	'Taa Imara 5BT v2.03.2024'
                ) THEN 1400
             WHEN product_name IN ('Flexx40 3B Cash V2.03.2023'
                ) THEN 1430   
             WHEN product_name IN ('21M Optimised 24" TV with Aerial',	'36M Optimised 24" TV with Aerial',	'36M Optimised 24" TV with Aerial v3.03.2023',	'Optimised 24" TV with Aerial v3.03.2023',	'Taa Imara 5BR â€“ High DP Pilot (Kakuma & Isiolo)',	'Taa Imara 5BT â€“ High DP Pilot (Kakuma & Isiolo)'
                ) THEN 1560
             WHEN product_name IN ('39â€ PAYGO TV v1.08.2023',	'Mdosi TV 24" 4BR + Fan v3.09.2023',	'Mwanzo Cash 3BT JUN22'
                ) THEN 1700    
             WHEN product_name IN ('Chap Chap Mdosi TV 4BR_JUL21',	'Chap Chap TV 4BR',	'Mdosi Cash TV24 4BR JUN22',	'Mdosi TV Radio',	'Mdosi TV Torch'
                ) THEN 1820   
             WHEN product_name IN ('Mdosi TV 24" 5B v4.03.2024',' Mwananchi TV 24" 4BT v1.10.2023',	'21M Mdosi TV24 4BR JUN22',	'21M Mdosi TV24 4BR v3.03.2023',	'21M Mdosi TV24 4BT JUN22',	'21M Mdosi TV24 4BT v3.03.2023',	'21M Mdosi TV24 5B JUN22',	'Mdosi TV 24" 4BR v3.03.2023',	'Mdosi TV 24" 4BR v3.09.2023',	'Mdosi TV 24" 4BR v4.03.2024',	'Mdosi TV 24" 4BT v3.03.2023',	'Mdosi TV 24" 4BT v3.09.2023',	'Mdosi TV 24" 4BT v4.03.2024',	'Mdosi TV 24" 5B v3.03.2023',	'Mdosi TV 24" 5B v3.09.2023',	'Mwananchi TV 24" 4BR v1.10.2023'
                ) THEN 2100    
             WHEN product_name IN ('21M Mdosi TV32 3BR NOV21',	'21M Mdosi TV32 3BT NOV21',	'21M Mdosi TV32 4BR JUN22',	'21M Mdosi TV32 4BR v3.03.2023',	'21M Mdosi TV32 4BT JUN22',	'21M Mdosi TV32 4BT v3.03.2023',	'21M Mdosi TV32 5B JUN22',	'Chap Chap Mdosi TV32 3BR OCT21',	'Chap Chap Mdosi TV32 3BT OCT21',	'Mdosi TV 32" 4BR V3.03.2023',	'Mdosi TV 32" 4BR v3.09.2023',	'Mdosi TV 32" 4BR v4.03.2024',	'Mdosi TV 32" 4BT V3.03.2023',	'Mdosi TV 32" 4BT v3.09.2023',	'Mdosi TV 32" 4BT v4.03.2024',	'Mdosi TV 32" 5B v3.03.2023',	'Mdosi TV 32" 5B v3.09.2023',	'Tosha TV 32" 4BR v1.10.2023',	'Tosha TV 32" 4BT v1.10.2023'
                ) THEN 2500   
             WHEN product_name IN ('Mdosi Cash 4BRT v3.03.2023',	'Sonko TV 39" 5B + Fan v1.10.2023',	'Sonko TV 39" 5B + Woofer v1.10.2023'
                ) THEN 2600    
             WHEN product_name IN ('Cash Optimised 24" TV with Aerial v3.03.2023'
                ) THEN 3120    
            
             ELSE   0
    	 END AS agent_commission,
         
        CASE WHEN sales_person is null then 'Walkin'
			WHEN substring(sales_person, 1,6) not like 'ke____' then 'Walkin'
			else substring(sales_person, 1,6) 
		END AS agent_code,
        
        CASE 
            WHEN product_name IN (
                ' Mwanzo 3BT 18M V1.03.2023',   'Chap Chap Mwanzo 3BR', 'Chap Chap Mwanzo 3BR AUG21',   'Chap Chap Mwanzo 3BT', 'Chap Chap Mwanzo 3BT AUG21',   'Chap Chap Mwanzo 4B',  'Chap Chap Mwanzo 4B AUG21',    'Mwanzo 3BR 18M JUN22', 'Mwanzo 3BR 18M v1.03.2023',    'Mwanzo 3BR 18M_AUG21', 'Mwanzo 3BT 18M JUN22', 'Mwanzo 3BT 18M_AUG21', 'Mwanzo 4B 18M JUN22',  'Mwanzo 4B 18M_AUG21',  'Mwanzo Cash 3BT JUN22',    'Mwanzo Radio', 'Mwanzo Torch', 'Promo Advantage Mwanzo Lights',    'Promo Advantage Mwanzo Radio', 'Promo Advantage Mwanzo Torch', 'Promo Chap Chap Mwanzo 3BR',   'Promo Chap Chap Mwanzo 3BT',   'Promo Chap Chap Mwanzo 4B',    'Taa Imara 4BRT v1.09.2023',    'Taa Imara 4BRT v2.03.2024',    'Taa Imara 5BR - Low DP Pilot (Kibwezi & Wote)',    'Taa Imara 5BR â€“ High DP Pilot (Kakuma & Isiolo)',    'Taa Imara 5BR v1.03.2023', 'Taa Imara 5BR v1.09.2023', 'Taa Imara 5BR v2.03.2024', 'Taa Imara 5BT â€“ High DP Pilot (Kakuma & Isiolo)',    'Taa Imara 5BT â€“ Low DP Pilot (Kibwezi & Wote)',  'Taa Imara 5BT v1.03.2023', 'Taa Imara 5BT v1.09.2023', 'Taa Imara 5BT v2.03.2024', 'Welcome Pack V1',  'Welcome Pack V2 Bulb', 'Welcome Pack V2 Radio V3', 'Welcome Pack V2 Radio V4', 'Welcome Pack V2 Torch'
                ) THEN 'bPower20'
                
            WHEN product_name LIKE '%Taa Imara 5B%'
                THEN 'bPower20'
                
            WHEN product_name IN (
                '21M Mdosi 4BRT JUN22', '21M Mdosi 5BR JUN22',  '21M Mdosi 5BT JUN22', 'Mdosi Lights 4BRT Jun 2024', 'Advantage Mdosi 4BRT MAY21',   'Advantage Mdosi 4BRT OCT21',   'Advantage Mdosi 5BR MAY21',    'Advantage Mdosi 5BR OCT21',    'Advantage Mdosi 5BT MAY21',    'Advantage Mdosi 5BT OCT21',    'Chap Chap Mdosi 4BRT', 'Chap Chap Mdosi 4BRT MAY21',   'Chap Chap Mdosi 4BRT OCT21',   'Chap Chap Mdosi 5BR',  'Chap Chap Mdosi 5BR MAY21',    'Chap Chap Mdosi 5BR OCT21',    'Chap Chap Mdosi 5BT',  'Chap Chap Mdosi 5BT MAY21',    'Chap Chap Mdosi 5BT OCT21',    'Mdosi 4BRT v3.03.2023',    'Mdosi 5BR v3.03.2023', 'Mdosi 5BT v3.03.2023', 'Mdosi Cash 4BRT JUN22',    'Mdosi Cash 4BRT v3.03.2023',   'Mdosi Cash 5BR JUN22', 'Mdosi Cash 5BT JUN22', 'Mdosi Lights Radio',   'Mdosi Lights Radio Torch', 'Mdosi Lights RT',  'Mdosi Lights Torch'
                ) THEN 'bPower50'
                
            WHEN product_name IN (
                ' Mwananchi TV 24" 4BT v1.10.2023', '21M Mdosi TV24 4BR JUN22', '21M Mdosi TV24 4BR NOV21', '21M Mdosi TV24 4BR v3.03.2023',    '21M Mdosi TV24 4BT JUN22', '21M Mdosi TV24 4BT N0V21', '21M Mdosi TV24 4BT v3.03.2023',    '21M Mdosi TV24 5B JUN22',  '21M Mdosi TV24 5B NOV21',  '21M Optimised 24" TV with Aerial', '36M Optimised 24" TV with Aerial', '36M Optimised 24" TV with Aerial v3.03.2023',  'Accelerated TV 24" with Aerial JUN22', 'Advantage Mdosi TV Bulbs_JUL21',   'Advantage Mdosi TV Radio_JUL21',   'Advantage Mdosi TV Torch_JUL21',   'Cash Optimised 24" TV with Aerial v3.03.2023', 'Chap Chap Mdosi TV 4BR_JUL21', 'Chap Chap Mdosi TV 4BT_JUL21', 'Chap Chap Mdosi TV 5B_JUL21',  'Chap Chap TV 4BR', 'Chap Chap TV 4BT', 'Chap Chap TV 5B',  'ChapChap TV Zuku 4BR', 'ChapChap TV Zuku 4BT', 'Mdosi Cash TV24 4BR JUN22',    'Mdosi Cash TV24 4BT JUN22',    'Mdosi TV 24" 4BR + Fan v3.09.2023',    'Mdosi TV 24" 4BR v3.03.2023',  'Mdosi TV 24" 4BR v3.09.2023',  'Mdosi TV 24" 4BR v4.03.2024',  'Mdosi TV 24" 4BT v3.03.2023',  'Mdosi TV 24" 4BT v3.09.2023',  'Mdosi TV 24" 4BT v4.03.2024',  'Mdosi TV 24" 5B v3.03.2023',   'Mdosi TV 24" 5B v3.09.2023',   'Mdosi TV 24" 5B v4.03.2024',   'Mdosi TV Bulb',    'Mdosi TV Bulbs',   'Mdosi TV Bulbs Zuku',  'Mdosi TV Radio',   'Mdosi TV Radio Zuku',  'Mdosi TV Torch',   'Mdosi TV Torch Zuku',  'Mwananchi TV 24" 4BR v1.10.2023',  'Optimised 24" TV with Aerial v3.03.2023'
                ) THEN 'bPower120 - B07 - TV 24'
            
            WHEN product_name IN (
                '21M Mdosi TV32 3BR NOV21', '21M Mdosi TV32 3BT NOV21', '21M Mdosi TV32 4B NOV21',  '21M Mdosi TV32 4BR JUN22', '21M Mdosi TV32 4BR v3.03.2023',    '21M Mdosi TV32 4BT JUN22', '21M Mdosi TV32 4BT v3.03.2023',    '21M Mdosi TV32 5B JUN22',  'Advantage Mdosi TV32 3BR', 'Advantage Mdosi TV32 3BR OCT21',   'Advantage Mdosi TV32 3BR_JUL21',   'Advantage Mdosi TV32 3BT', 'Advantage Mdosi TV32 3BT OCT21',   'Advantage Mdosi TV32 3BT_JUL21',   'Advantage Mdosi TV32 4B',  'Advantage Mdosi TV32 4B OCT21',    'Advantage Mdosi TV32 4B_JUL21',    'Chap Chap Mdosi TV32 3BR', 'Chap Chap Mdosi TV32 3BR OCT21',   'Chap Chap Mdosi TV32 3BR_JUL21',   'Chap Chap Mdosi TV32 3BT', 'Chap Chap Mdosi TV32 3BT OCT21',   'Chap Chap Mdosi TV32 3BT_JUL21',   'Chap Chap Mdosi TV32 4B',  'Chap Chap Mdosi TV32 4B OCT21',    'Chap Chap Mdosi TV32 4B_JUL21',    'Mdosi Cash TV32 4BR JUN22',    'Mdosi TV 32" 4BR V3.03.2023',  'Mdosi TV 32" 4BR v3.09.2023',  'Mdosi TV 32" 4BR v4.03.2024',  'Mdosi TV 32" 4BT V3.03.2023',  'Mdosi TV 32" 4BT v3.09.2023',  'Mdosi TV 32" 4BT v4.03.2024',  'Mdosi TV 32" 5B v3.03.2023',   'Mdosi TV 32" 5B v3.09.2023',   'Tosha TV 32" 4BR v1.10.2023',  'Tosha TV 32" 4BT v1.10.2023'               
                ) THEN 'bPower160 - B05 - TV 32'
               
            WHEN product_name IN (
                '39â€ PAYGO TV v1.08.2023',    'Sonko TV 39" 5B + Fan v1.10.2023', 'Sonko TV 39" 5B + Woofer v1.10.2023'
                ) THEN 'bPower240 TV 39'
               
            WHEN product_name IN (
                'Infinix Smart 7 HD 2+64GB'
                ) THEN 'Infinix Smart 7'
               
            WHEN product_name IN (
                'Maraphones S'
                ) THEN 'Maraphone'
            
            WHEN product_name IN (
                'Nokia C10'
                ) THEN 'Nokia C10'
                
            WHEN product_name IN (
                'Samsung A03',  'Samsung A03 Core', 'Samsung A03s', 'SPHN_SAgent_Samsung A03 Core', 'SPHN_Samsung A03', 'SPHN_Samsung A03 Core',    'SPHN_Samsung A03 Core bundled Offer v1.12.22', 'SPHN_Samsung A03 Core v1.03.2023_test',    'SPHN_Samsung A03 Core v3.10.2022'
                ) THEN 'Samsung A03'
                
            WHEN product_name IN (
                'SPHN_Discounted Samsung A13 v1.03.2023',   'SPHN_Samsung A13', 'SPHN_Samsung A13 bundled Offer v1.12.22',  'SPHN_Samsung A13 v3.10.2022'
                ) THEN 'Samsung A13'
                
            WHEN product_name IN (
                'Samsung A14',  'SPHN_Samsung A14 v1.07.2023',  'SPHN_Samsung A14 v2.09.2023'
                ) THEN 'Samsung A14'
                
            WHEN product_name IN (
                'Tecno Pop 5' 
                ) THEN 'Tecno Pop 5'
                
            WHEN product_name IN (
                'Tecno Pop 7 Pro 4+64GB'
                ) THEN 'Tecno Pop 7'
                
            WHEN product_name IN (
                'Flexx10 Cash V3.03.2023',  'Flexx10 Cash V4.04.2024',  'Promo Flexx10 Cash JUN22'
                ) THEN 'Flexx 10'
                
            WHEN product_name IN (
                'Flexx 12 v1.11.2023',  'Flexx 12 v2.03.2024'
                ) THEN 'Flexx 12'
                
            WHEN product_name IN (
                'Flexx40 13M 3B v2.11.2022',    'Flexx40 13M 3BR v2.11.2022',   'Flexx40 21M 3B v2.11.2022',    'Flexx40 21M 3B V3.03.2023',    'Flexx40 21M 3BR v2.11.2022',   'Flexx40 21M 3BR v3.03.2023',   'Flexx40 3B 13M v1.112022 (To be signed up at CSCC)',   'Flexx40 3B 21M v1.112022 (To be signed up at CSCC)',   'Flexx40 3B Cash V2.03.2023',   'Flexx40 3B v3.03.2023',    'Flexx40 3B v3.09.2023',    'Flexx40 3B v4.03.2024',    'Flexx40 3BR 13M v1.112022 (To be signed up at CSCC)',  'Flexx40 3BR 21M v1.112022 (To be signed up at CSCC)',  'Flexx40 3BR v3.03.2023',   'Flexx40 3BR v3.09.2023',   'Flexx40 3BR v4.03.2024',   'Flexx40 Lights MAR22', 'Flexx40 Radio Cash JUN22', 'Flexx40 Radio MAR22',  'Promo Flexx40 Lights APR22',   'Promo Flexx40 Lights JUN22',   'Promo Flexx40 Radio APR22',    'Promo Flexx40 Radio JUN22'
                ) THEN 'Flexx 40'
            
            WHEN product_name IN (
                'Solar panel 50W upgrade',' Upgrade of Radio v3.03.2023', ' Upgrade of Torch v3.03.2023', 'Bboxx Subwoofer with PVC leather', 'CU Lithium 9.9Ah Upgrade V1.03.2023',  'CU Lithium 9.9Ah Upgrade V2.03.2024',  'DC Radio (V4)',    'DC Radio (V4.1)',  'DC Shaver',    'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023',   'Discounted DC Solar Shaver',   'Discounted Fan upgrade v3.03.2023',    'Discounted shaver OCT21',  'Discounted Shaver_APR21',  'Discounted Subwoofer', 'Discounted subwoofer OCT21',   'Discounted Sub-woofer upgrade v3.03.2023', 'Discounted Subwoofer_APR21',   'Fan Upgrade',  'LED Bulb Set', 'Light Bulb Set',   'Light bulb upgrade v3.03.2023',    'LPG discounted 18 Months', 'LPG discounted 36 Months', 'LPG Upgrade 18 OCT21', 'LPG Upgrade 36 OCT21', 'StarTimes Nova with Subscription', 'StarTimes Nova with Subscription v2.03.2023',  'StarTimes Smart with Subscription',    'StarTimes Super with Subscription',    'Torch',    'Torch V2', 'Torch V3', 'Upgrade (Light bulb set & shade)', 'Upgrade Fan v3.03.2023',   'Upgrade Light bulb set',   'Upgrade of Radio', 'Upgrade Power Bank 10000mAh',  'Upgrade Shaver v2.03.2023',    'Upgrade Shaver v3.03.2023',    'Upgrade Subwoofer',    'Upgrade Subwoofer  V1.03.2023',    'Upgrade Torch',    'ZUKU Satellite TV Kit with Subscription',  'ZUKU Satellite TV Kit with Subscription v2.03.2023'
                ) THEN 'SHS Upgrades'
            WHEN product_name LIKE  '%TV 24__ with Aerial%'
                THEN 'TV Upgrade 24'
            WHEN product_name IN (
                '24â€³ TV V2 with Aerial',  'Promo 24â€ TV V2 with Aerial_JUL21',
                '24" TV V2 with Aerial + Lithium Battery',  '24" TV V2 with Aerial NOV21',  '24" TV V2 with Aerial v3.03.2023', '24â€³ TV V2 with Aerial',  'bP60 to bPower120 + 24" TV upgrade v1.11.23',  'Discounted bP20 to Lithium battery + 24" TV v1.03.2023',   'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',    'Discounted TV 24" with Aerial + Lithium Battery',  'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',   'Discounted TV 24" with Aerial OCT21',  'Discounted TV24'' with Aerial',    'Mwananchi Upgrade TV 24" v1.11.2023',  'Promo 24â€ TV V2 with Aerial_JUL21',  'TV 24'' with Aerial',  'TV 24" with Aerial + Lithium Battery V2.03.2023',  'TV 24" with Aerial + Lithium Battery V3.03.2024'
                ) THEN 'TV Upgrade 24' 
            WHEN product_name IN (
                '32" TV with Aerial',   '32" TV with Aerial + Lithium Battery', '32" TV with Aerial NOV21', 'Discounted TV 32" with Aerial + Lithium Battery',  'Discounted TV 32" with Aerial + Lithium Battery v3.03.2023',   'Discounted TV 32" with Aerial OCT21',  'Tosha Upgrade TV 32" 4BR  v1.11.2023', 'Tosha Upgrade TV 32" v1.11.2023',  'TV 32" with Aerial + Lithium Battery v2.03.2023'
                ) THEN 'TV Upgrade 32'   
            ELSE 'Uncategorized Product Name'
        END AS Bboxx_Pack,
        
        CASE 
            WHEN product_name IN ('Light bulb upgrade v3.03.2023'
        	) THEN 'Bulb' 
        	
        	 WHEN product_name IN ('CU Lithium 9.9Ah Upgrade V1.03.2023',	'CU Lithium 9.9Ah Upgrade V2.03.2024',	'Discounted CU Lithium 9.9Ah Upgrade v1.03.2023'
        	) THEN 'CU_Upgrade'
        	WHEN product_name IN ('Discounted Fan upgrade v3.03.2023',	'Upgrade Fan v3.03.2023'
        	) THEN 'Fan' 
        	
        	 WHEN product_name IN ('Flexx10 Cash V4.04.2024'
        	) THEN 'Flexx 10'
        	WHEN product_name IN ('Flexx 12 v1.11.2023',	'Flexx 12 v2.03.2024'
        	) THEN 'Flexx 12' 
        	
        	 WHEN product_name IN ('Flexx40 3B v3.03.2023',	'Flexx40 3B v3.09.2023',	'Flexx40 3B v4.03.2024'
        	) THEN 'Flexx 40'
        	WHEN product_name IN ('Flexx40 3BR v3.03.2023',	'Flexx40 3BR v3.09.2023',	'Flexx40 3BR v4.03.2024'
        	) THEN 'Flexx 40R' 
        	
        	 WHEN product_name IN ('Infinix Smart 7 HD 2+64GB'
        	) THEN 'Infinix smart 7'
        	WHEN product_name IN ('Mdosi TV 24" 4BR + Fan v3.09.2023',	'Mdosi TV 24" 4BR v3.03.2023',	'Mdosi TV 24" 4BR v3.09.2023',	'Mdosi TV 24" 4BR v4.03.2024',	'Mdosi TV 24" 4BT v3.09.2023',	'Mdosi TV 24" 4BT v4.03.2024',	'Mdosi TV 24" 5B v3.09.2023',	'Mdosi TV 24" 5B v4.03.2024'
        	) THEN 'Mdosi Tv 24"' 
        	
        	 WHEN product_name IN ('Mdosi TV 32" 4BR v3.09.2023',	'Mdosi TV 32" 4BR v4.03.2024',	'Mdosi TV 32" 4BT v3.09.2023',	'Mdosi TV 32" 4BT v4.03.2024'
        	) THEN 'Mdosi Tv 32"'
        	WHEN product_name IN ('Mwananchi Upgrade TV 24" v1.11.2023',	' Mwananchi TV 24" 4BT v1.10.2023',	'Mwananchi TV 24" 4BR v1.10.2023',	'Sonko TV 39" 5B + Fan v1.10.2023',	'Sonko TV 39" 5B + Woofer v1.10.2023',	'Tosha TV 32" 4BR v1.10.2023',	'Tosha TV 32" 4BT v1.10.2023'
        	) THEN 'Paygo TV' 
        	
        	 WHEN product_name IN (' Upgrade of Radio v3.03.2023'
        	) THEN 'Radio'
        	WHEN product_name IN ('Samsung A03 Core'
        	) THEN 'Samsung A034' 
        	
        	 WHEN product_name IN ('SPHN_SAgent_Samsung A03 Core'
        	) THEN 'Samsung A04'
        	WHEN product_name IN ('SPHN_Samsung A03 Core v3.10.2022'
        	) THEN 'Samsung A05' 
        	
        	 WHEN product_name IN ('Samsung A14',	'SPHN_Samsung A14 v2.09.2023'
        	) THEN 'Samsung A14'
        	WHEN product_name IN ('Upgrade Shaver v3.03.2023'
        	) THEN 'Shaver' 
        	
        	 WHEN product_name IN ('StarTimes Nova with Subscription v2.03.2023'
        	) THEN 'StarTimes'
        	WHEN product_name IN ('Upgrade Subwoofer  V1.03.2023'
        	) THEN 'Subwoofer' 
        	
        	 WHEN product_name IN ('Taa Imara 4BRT v1.09.2023',	'Taa Imara 4BRT v2.03.2024',	'Taa Imara 5BR v1.03.2023',	'Taa Imara 5BR v1.09.2023',	'Taa Imara 5BR v2.03.2024',	'Taa Imara 5BT v1.09.2023',	'Taa Imara 5BT v2.03.2024'
        	) THEN 'Taa Imara'
        	 WHEN product_name IN ('Tecno Pop 7 Pro 4+64GB'
        	) THEN 'Tecno Pop 7 Pro'
        	WHEN product_name IN (' Upgrade of Torch v3.03.2023'
        	) THEN 'Torch' 
        	
        	 WHEN product_name IN ('bP60 to bPower120 + 24" TV upgrade v1.11.23',	'Discounted TV 24" with Aerial + CU Upgrade v3.03.2024',	'Discounted TV 24" with Aerial + Lithium Battery v3.03.2023',	'TV 24" with Aerial + Lithium Battery V2.03.2023',	'TV 24" with Aerial + Lithium Battery V3.03.2024'
        	) THEN 'TV Upgrade 24'
        	WHEN product_name IN ('Discounted TV 32" with Aerial + Lithium Battery v3.03.2023',	'Tosha Upgrade TV 32" v1.11.2023',	'TV 32" with Aerial + Lithium Battery v2.03.2023'
        	) THEN 'TV upgrade 32"' 
        	
        	 WHEN product_name IN ('ZUKU Satellite TV Kit with Subscription v2.03.2023'
        	) THEN 'Zuku'
        	
        	ELSE 'Other'
        	
        END AS Finance_Option,
        
        product_name ||' - '|| downpayment as dp_mapping
       
    FROM kenya.rp_retail_sales
    WHERE 
        downpayment_date >= '2022-01-01' )
 
  select sales_data.*, 
  	CASE 
            WHEN unique_account_id IN (
	            SELECT 	rrs.unique_account_id 
				FROM 	rp_retail_sales rrs 
				LEFT JOIN 	payment p
					ON rrs.sales_order_id = p.sales_order_id 
				WHERE 
--					is_down_payment = 'True'
--				unique_account_id = 'BXCK68152928'
--					and 
					third_party_payment_ref_id like '%LOW%'
					) 
			THEN 'Low DP'
			
        	ELSE 'High DP'
	END AS LOW_HIGH_DP
  FROM sales_data
--  where unique_account_id = 'BXCK68241868'
--    limit 4