-- changed the table to payments table to kenya.payment
--      The original query had 100865
--      The new query has 113436 which is a 8.8% increase in records.
--      Contributing to a 4% increase in reported collected cash as of 15/02/2024
-- Changed the last_7_day_CR CTE query table from src_odoo13_kenya.account_payment to kenya.payment
--			Rectified the over-reported PB percentage figures.
--			Case:
-- 					BXCK72601546 had a reported 7 days collection rate of 85% in the old query.
--					after the changes, the percentage dropped to 35% consitent.
-- Added a condition to remove opted out customers
-- Test an assumption that the app only returns one entry per customer regardless of whether they have more than one account
WITH downpayments AS (
    SELECT
        customer_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM
        kenya.rp_retail_sales
    WHERE
        downpayment_date :: date >= current_date - INTERVAL '6 MONTH'
    GROUP BY
        1,
        2
),
payments AS (
    SELECT
        payments.sales_order_id AS payg_account_id,
        SUM(amount) - COALESCE(downpayments.total_downpayment, 0) AS repayments,
        downpayments.total_downpayment
    FROM
        kenya.payment AS payments
        LEFT JOIN downpayments AS downpayments ON downpayments.unique_account_id = payments.sales_order_id
        LEFT JOIN kenya.customer AS customer ON customer.unique_account_id = payments.sales_order_id
    WHERE
        payments.is_void IS FALSE
        AND payments.third_party_payment_ref_id NOT LIKE '%BONUS%'
        AND payments.payment_utc_timestamp :: date >= current_date - INTERVAL '6 MONTH'
    GROUP BY
        payments.sales_order_id,
        downpayments.total_downpayment
    ORDER BY
        payments.sales_order_id
),
---------------------------------------------
-- Add agent reassignment/remapping CTE. Add new 
sales_agents as (
    select
        sa.sales_agent_id,
        sa.sales_agent_name,
        upper(substring(sa.username, 0, 7)) as agent_code,
        sa.sales_agent_mobile
    from
        kenya.sales_agent sa
),
rp_sales as (
    select
        sales.unique_account_id,
        case
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0767', 'KE1189') then 'KE2986'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0134', 'KE2785') then 'KE1992'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2784', 'KE2353', 'KE0666') then 'KE0168'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0580') then 'KE7249'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1130', 'KE0617', 'KE1187') then 'KE7311'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0057', 'KE0047', 'KE0501') then 'KE4204'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2508') then 'KE7154'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0035') then 'KE7884'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0858', 'KE3719', 'KE1315', 'KE1331') then 'KE7158'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0861') then 'KE7505'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE5400') then 'KE6434'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0344') then 'KE7417'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0297') then 'KE7414'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4240') then 'KE2552'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4840') then 'KE7332'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1134', 'KE0830') then 'KE1304'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7356', 'KE1329', 'KE1240', 'KE0714') then 'KE5314'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7126') then 'KE7324'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2624') then 'KE7739'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0046') then 'KE7620'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6071') then 'KE7697'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0931') then 'KE4959'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0609') then 'KE7398'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3382') then 'KE7598'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0611') then 'KE4828'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2806') then 'KE3381'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0932') then 'KE2807'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2806') then 'KE3381'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1750') then 'KE1749'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1216') then 'KE1826'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1828', 'KE2733', 'KE2745') then 'KE1893'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1107') then 'KE1372'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2849', 'KE1753') then 'KE1305'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2187') then 'KE5681'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2284') then 'KE7881'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1230') then 'KE7871'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3018') then 'KE4021' -- Transfers done 25th April, 2024
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE3974', 'KE0595', 'KE0648', 'KE1953', 'KE2949', 'KE3513') then 'KE2231'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0139', 'KE0415', 'KE0505', 'KE1167', 'KE2064', 'KE2230', 'KE2954', 'KE0277', 'KE0327', 'KE0438', 'KE0976', 'KE1168', 'KE1959', 'KE2063', 'KE2947', 'KE3011', 'KE3516', 'KE4180', 'KE4312', 'KE0192', 'KE0195', 'KE0198', 'KE0217', 'KE0331', 'KE0340', 'KE0463', 'KE0971', 'KE0978', 'KE1954', 'KE2654', 'KE3012', 'KE3510', 'KE4140') then 'KE2286'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0162', 'KE2647', 'KE0342', 'KE0203', 'KE0366', 'KE0913', 'KE0915', 'KE1845', 'KE1958', 'KE2953', 'KE3508', 'KE3509', 'KE4141') then 'KE0928'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE5647', 'KE7715', 'KE3904', 'KE4145', 'KE7722') then 'KE0582'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7089', 'KE5774', 'KE6239', 'KE7590') then 'KE7889'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7756', 'KE2400', 'KE4601', 'KE5775') then 'KE7088'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE1866', 'KE4672', 'KE4717', 'KE7413', 'KE0206', 'KE0011', 'KE1297') then 'KE1609'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE4673', 'KE4588', 'KE4207', 'KE3912', 'KE7589', 'KE3819', 'KE0821') then 'KE0077'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0040', 'KE1255') then 'KE0218'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0004', 'KE0675', 'KE0006', 'KE1136') then 'KE4150'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4919', 'KE0544', 'KE0024', 'KE0662', 'KE0585') then 'KE7925'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0050', 'KE0085', 'KE0089', 'KE1373') then 'KE2101'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0483', 'KE4499', 'KE2280', 'KE7847', 'KE0774', 'KE3663', 'KE0190', 'KE1469', 'KE4029', 'KE4221') then 'KE4936'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0201', 'KE0402', 'KE0088', 'KE1468', 'KE3664', 'KE3824', 'KE4907', 'KE5119', 'KE7813', 'KE7814', 'KE0826', 'KE2279') then 'KE7693'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0003') then 'KE5206'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0587', 'KE0018') then 'KE6229'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE6630', 'KE4801', 'KE3229', 'KE3765', 'KE2846', 'KE1539') then 'KE2466'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE3314', 'KE2190', 'KE2564', 'KE2558', 'KE3093', 'KE5056', 'KE1596') then 'KE1544'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4493', 'KE5057', 'KE5691', 'KE2376') then 'KE1554'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2211') then 'KE2706'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6896', 'KE6902', 'KE5386') then 'KE3461'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6492') then 'KE6343'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6016', 'KE6501') then 'KE6491'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE3173', 'KE5969', 'KE6900', 'KE6348', 'KE3176', 'KE6350', 'KE3174', 'KE6496', 'KE6895', 'KE3149', 'KE3179', 'KE4814', 'KE6032', 'KE6100', 'KE6498', 'KE7728', 'KE7777', 'KE7845') then 'KE7844'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4822') then 'KE4820'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE7812', 'KE6342') then 'KE7525'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE4819', 'KE6133', 'KE6345', 'KE7453', 'KE3175', 'KE7681') then 'KE6897'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6134') then 'KE6135'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1267', 'KE1240', 'KE4341') then 'KE5319' -- transfer on 29th April, 2024
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1292') then 'KE7377'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3131') then 'KE6840'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1098') then 'KE7924'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1183') then 'KE2979'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0052') then 'KE4498' -- trnsfers on 6th May, 2024
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1379', 'KE2385', 'KE3071', 'KE5247') then 'KE4787'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2489', 'KE1676') then 'KE2386'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3029', 'KE6316', 'KE2731', 'KE2731') then 'KE1837'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1622', 'KE2730') then 'KE4059'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1044') then 'KE4556'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2727', 'KE2490', 'KE3028') then 'KE6319'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1646', 'KE1286', 'KE2178') then 'KE6317'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3073', 'KE1835', 'KE2728') then 'KE7817'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE6916', 'KE6325', 'KE6320', 'KE3871', 'KE3069', 'KE2732', 'KE1841', 'KE1644', 'KE4550', 'KE3868', 'KE2384', 'KE1675', 'KE1643', 'KE6327', 'KE2387') then 'KE7792'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE2177', 'KE6913', 'KE6318', 'KE2333', 'KE3033', 'KE4785', 'KE5249', 'KE6103', 'KE6912', 'KE4604') then 'KE7855' -- transfers done on 23th May, 2024
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE1030', 'KE0898', 'KE1195', 'KE1278', 'KE3046', 'KE1944', 'KE2926', 'KE4336', 'KE1807', 'KE5794', 'KE1374', 'KE1571', 'KE1803', 'KE2133', 'KE2337', 'KE2867', 'KE7666') then 'KE5558'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE2870', 'KE7467', 'KE2946', 'KE1376', 'KE2134', 'KE3923', 'KE3796', 'KE2831', 'KE2874', 'KE2982', 'KE3850', 'KE3909', 'KE2984', 'KE0889', 'KE2019', 'KE2937', 'KE3144', 'KE4886', 'KE4970', 'KE7646') then 'KE3405'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE2857', 'KE2927', 'KE2834', 'KE1026', 'KE2017', 'KE2340', 'KE1933', 'KE2020', 'KE7708', 'KE1042', 'KE7394', 'KE1028') then 'KE7389'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0892', 'KE1319', 'KE3111', 'KE3231', 'KE1029', 'KE1947', 'KE2135', 'KE2138', 'KE0897', 'KE2339', 'KE1934', 'KE1940', 'KE1061', 'KE1569', 'KE1945', 'KE4606', 'KE2021', 'KE2022') then 'KE7393'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0895', 'KE1565', 'KE1942', 'KE2165') then 'KE7466'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3082', 'KE0783', 'KE3792', 'KE0803', 'KE4404') then 'KE0848'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7445', 'KE0828', 'KE7444', 'KE2847', 'KE0879') then 'KE2541'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1347') then 'KE0798'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2766', 'KE0907', 'KE0992', 'KE1527', 'KE6701') then 'KE3880'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1470', 'KE3393', 'KE3786', 'KE6105') then 'KE5294'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3075', 'KE3392', 'KE3080', 'KE2904', 'KE2270') then 'KE7663'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0989', 'KE2735') then 'KE1157'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3153') then 'KE4757'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3075') then 'KE1520'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6597', 'KE6952', 'KE6330', 'KE5575', 'KE5503') then 'KE7832'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7242', 'KE5500') then 'KE7848'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0795', 'KE1121', 'KE2426', 'KE0171', 'KE1279', 'KE0779', 'KE7341', 'KE7539') then 'KE0744'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3020', 'KE0761', 'KE0762', 'KE0749', 'KE3309') then 'KE0747'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE1160', 'KE1457', 'KE0769', 'KE2334', 'KE0745', 'KE1558', 'KE3329', 'KE1927', 'KE7755', 'KE1353', 'KE1760', 'KE1929', 'KE3327', 'KE1559', 'KE7079', 'KE7588', 'KE7092', 'KE3019', 'KE4293', 'KE7094', 'KE2331', 'KE4433', 'KE7334', 'KE7338', 'KE7340', 'KE0748', 'KE1556', 'KE19312', 'KE5460', 'KE3768', 'KE5811', 'KE6340', 'KE7078', 'KE1123', 'KE1613', 'KE3328', 'KE5895', 'KE5924', 'KE6338', 'KE7820', 'KE0780', 'KE1561', 'KE1759', 'KE1928', 'KE4103', 'KE5896', 'KE5902', 'KE7076', 'KE7077', 'KE7091') then 'KE7737' -- transfers on 20th May, 2024
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7400', 'KE6876') then 'KE7748'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0865', 'KE7718') then 'KE7537'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1450', 'KE1217') then 'KE2330'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0710') then 'KE7281'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4639', 'KE2616') then 'KE7488'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1090', 'KE0260', 'KE2809') then 'KE4953'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE3117', 'KE0586', 'KE3439', 'KE5653', 'KE1159', 'KE3115', 'KE1261') then 'KE7754'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2444', 'KE0321', 'KE1064') then 'KE4171'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1226', 'KE1431', 'KE2962', 'KE3120') then 'KE0480'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6031', 'KE5123', 'KE3950', 'KE1057', 'KE3121') then 'KE6625'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6877', 'KE7597', 'KE7611', 'KE7622') then 'KE5539'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6708', 'KE4723', 'KE4305', 'KE4722') then 'KE7883'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0947', 'KE6839', 'KE5201', 'KE0256', 'KE0264', 'KE0273', 'KE0520', 'KE0522', 'KE3116', 'KE3421', 'KE3436', 'KE3949', 'KE4170', 'KE4510', 'KE4675', 'KE6296', 'KE7596') then 'KE7876'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2078', 'KE2963', 'KE0523') then 'KE6094'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1430') then 'KE5935'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3686') then 'KE7916'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0835', 'KE2710') then 'KE1768'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1076') then 'KE5314' -- transfers done on 23rd May
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0020', 'KE0007', 'KE1133') then 'KE0010'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0054', 'KE3269', 'KE7070', 'KE7573', 'KE7637') then 'KE7071'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE3822', 'KE4411', 'KE4509', 'KE6692', 'KE7066', 'KE7806', 'KE7821') then 'KE7615'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0037', 'KE0053', 'KE0086', 'KE0094', 'KE0191', 'KE4854') then 'KE7823'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4459', 'KE4866', 'KE5163', 'KE7638', 'KE7787') then 'KE7893'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1723', 'KE3104') then 'KE0634'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1995') then 'KE0644'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1132', 'KE2076') then 'KE0752'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4806', 'KE1291', 'KE4154', 'KE7028') then 'KE1245'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE2169', 'KE6587', 'KE4622', 'KE0646', 'KE1722', 'KE2608', 'KE3275', 'KE0637', 'KE0863', 'KE1244', 'KE4406', 'KE5108', 'KE2288', 'KE3616', 'KE4476', 'KE5208', 'KE2294', 'KE3107', 'KE3276', 'KE3341', 'KE4475', 'KE4932', 'KE4935') then 'KE6950'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE7419', 'KE0335', 'KE0371', 'KE0571', 'KE1810', 'KE2879', 'KE3682', 'KE0359', 'KE0361', 'KE0370', 'KE1800', 'KE2876', 'KE3015') then 'KE0220'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0306', 'KE0334', 'KE0440', 'KE3013', 'KE3128', 'KE7624') then 'KE0600'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0121', 'KE0305', 'KE0599', 'KE0569', 'KE3014', 'KE3303', 'KE3810') then 'KE1801'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0215', 'KE0099', 'KE2236', 'KE1048', 'KE0096', 'KE0333', 'KE0119', 'KE0357', 'KE0100', 'KE1805', 'KE0408', 'KE3305', 'KE0095', 'KE0116', 'KE0462') then 'KE7562' -- transfers done on 30th May
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7381', 'KE7122', 'KE7123', 'KE7366', 'KE2040') then 'KE1476'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE2408', 'KE2896', 'KE4569', 'KE2897', 'KE6291', 'KE7358', 'KE3544') then 'KE1601'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE3540', 'KE7369', 'KE3346', 'KE6290', 'KE4571', 'KE3344', 'KE7369', 'KE3547', 'KE2799') then 'KE3536'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3541', 'KE2409', 'KE4300', 'KE7240') then 'KE1525'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4298', 'KE6767', 'KE7514', 'KE7614', 'KE1602') then 'KE2895'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2406') then 'KE5613'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE5371', 'KE2043', 'KE6770', 'KE5370') then 'KE5510'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE5272', 'KE2408', 'KE2045', 'KE2801') then 'KE7612'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2042', 'KE1524', 'KE1600', 'KE6767') then 'KE7744'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6768', 'KE1485', 'KE1524') then 'KE3895' -- transfers done on 3rd June
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE5170', 'KE2802', 'KE3539', 'KE1604', 'KE3007', 'KE7263') then 'KE3543'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7650', 'KE6830') then 'KE7801'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6827', 'KE6831', 'KE6198', 'KE7428') then 'KE6631'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7495') then 'KE6584'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7648') then 'KE7496'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE7647', 'KE6194', 'KE7380') then 'KE6200'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6517', 'KE7493', 'KE6199', 'KE6152') then 'KE6632'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6158', 'KE6196', 'KE7379') then 'KE6204'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6164') then 'KE7540' --                Transfers done on 13th and 14th June
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6150', 'KE7427') then 'KE7775'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0952', 'KE0956', 'KE1085', 'KE1109', 'KE1208', 'KE1781', 'KE4449', 'KE6035', 'KE6092', 'KE7652') then 'KE6571'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0955', 'KE3084', 'KE3414', 'KE5948') then 'KE7653'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1083', 'KE6664', 'KE7471') then 'KE1086'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1087', 'KE5964', 'KE7385') then 'KE7382'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1207') then 'KE0004'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1209', 'KE1325') then 'KE1247'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1211') then 'KE1246'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1328', 'KE1782', 'KE1985', 'KE1987', 'KE2966') then 'KE1345'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1783', 'KE1785', 'KE1786', 'KE1988', 'KE2967') then 'KE1784'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1986', 'KE4196', 'KE4201', 'KE6101') then 'KE4004'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE2970', 'KE3166', 'KE4560', 'KE4562', 'KE5919', 'KE6003') then 'KE4649'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3240', 'KE3712', 'KE4450') then 'KE4444'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE3420', 'KE4905') then 'KE6011'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4652') then 'KE6935'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE4901', 'KE4904') then 'KE5091'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6102', 'KE6667', 'KE7241') then 'KE6939'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6669', 'KE6920') then 'KE6037'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0940', 'KE1036', 'KE1382') then 'KE1035'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1272', 'KE0994') then 'KE4767'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE6401') then 'KE2180'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE2853', 'KE2830', 'KE2795', 'KE3450', 'KE5756', 'KE3221', 'KE3047', 'KE3324', 'KE5380', 'KE2487', 'KE3048', 'KE3222', 'KE4111', 'KE4658', 'KE5379', 'KE2998', 'KE2972', 'KE3323', 'KE5383', 'KE3531', 'KE4110', 'KE4113', 'KE2575', 'KE2744', 'KE4370', 'KE289') then 'KE2973'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE2486', 'KE1236', 'KE1112', 'KE1273', 'KE1038') then 'KE3223'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE6399', 'KE6424', 'KE2467', 'KE7468', 'KE7313', 'KE3529', 'KE6398', 'KE1142', 'KE7446', 'KE6425') then 'KE6261'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0849', 'KE1265', 'KE3964') then 'KE0829'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0792', 'KE6699', 'KE1146') then 'KE1219'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0964', 'KE0824', 'KE7707', 'KE1100', 'KE1718', 'KE1335', 'KE2993', 'KE0963', 'KE1058', 'KE2302') then 'KE2148'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE1104') then 'KE7465'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE0805', 'KE0807', 'KE0938', 'KE1110', 'KE1185', 'KE1308', 'KE1972', 'KE3902', 'KE0654', 'KE1461', 'KE0735', 'KE0656', 'KE1460', 'KE3587') then 'KE0658'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE5216', 'KE3588', 'KE1976', 'KE1459', 'KE5520', 'KE0734', 'KE4063', 'KE4351', 'KE1458', 'KE2213', 'KE4061') then 'KE2433'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE4355', 'KE2431', 'KE7186', 'KE7274', 'KE7353', 'KE7740') then 'KE5217'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0797', 'KE1186') then 'KE7292'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0653', 'KE0683', 'KE0655') then 'KE7293'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE0806', 'KE2593', 'KE6774', 'KE7701') then 'KE7355'
            when upper(substring(sales.sales_person, 0, 7)) in ( 'KE5388', 'KE0796', 'KE2218', 'KE3552', 'KE6709', 'KE0736', 'KE3343', 'KE7277', 'KE7296', 'KE2215', 'KE1111', 'KE1285') then 'KE7742'when upper(substring(sales.sales_person, 0, 7)) in ('KE4820', 'KE4822', 'KE6342') then 'KE6898'
            when upper(substring(sales.sales_person, 0, 7)) in ('KE5319',	'KE1154',	'KE1241',	'KE1685',	'KE4610',	'KE7367',	'KE4747',	'KE0715',	'KE4297',	'KE4850',	'KE7555',	'KE5315',	'KE3982',	'KE5067',	'KE0799',	'KE1162',	'KE1188',	'KE1220',	'KE2475',	'KE4296',	'KE7818',	'KE2985',	'KE3315',	'KE4752',	'KE7357',	'KE1686',	'KE3981',	'KE5070',	'KE5312',	'KE6374',	'KE6758',	'KE3317',	'KE4611',	'KE4749',	'KE5313',	'KE0763',	'KE2323',	'KE2850',	'KE2852',	'KE2940',	'KE2991',	'KE3458',	'KE5957',	'KE6759',	'KE7536',	'KE7713',	'KE5319') then 'KE5319'
            else upper(substring(sales.sales_person, 0, 7))
        end as agent_code
    from
        kenya.rp_retail_sales as sales
    where
        sales.sale_type = 'install'
        and sales.sales_order_id = sales.unique_account_id --and sales.unique_account_id= 'BXCK00000131'
),
sales_details AS (
    select
        sales.unique_account_id,
        sales.agent_code as sales_person,
        agent.agent_code as username,
        agent.sales_agent_name,
        agent.sales_agent_mobile
    from
        rp_sales as sales
        left join sales_agents as agent on sales.agent_code = agent.agent_code --      where agent.agent_code = 'KE1292'
        --     limit 6	
),
active AS (
    SELECT
        today.date_timestamp :: date AS activity_date,
        today.customer_id,
        initcap(details.customer_name) as customer_name,
        details.customer_phone_1,
        details.customer_phone_2,
        details.home_address_4 AS locations,
        details.home_address_3 AS constituency,
        customer.location_customer_met_latitude,
        customer.location_customer_met_longitude,
        customer.location_customer_met_accuracy,
        customer.unique_account_id,
        today.consecutive_late_days,
        today.daily_rate,
        sales_details.sales_agent_name,
        sales_details.sales_person,
        sales_details.sales_agent_mobile,
        customer.customer_active_end_date,
        customer.customer_active_start_date :: text :: date AS installation_date,
        LEAST(
            ( (     current_date - (customer.customer_active_start_date :: DATE + 7) ) :: BIGINT),
            180
        ) AS days_expected
    FROM
        kenya.agg_dcs_today AS today
        LEFT JOIN kenya.customer AS customer ON customer.account_id = today.account_id
        LEFT JOIN sales_details AS sales_details ON sales_details.unique_account_id = customer.unique_account_id
        LEFT JOIN kenya.customer_personal_details AS details ON details.account_id = customer.account_id
    WHERE
        customer.customer_final_status IS null
        and UPPER(details.customer_name) not like '%OPT%OUT%' --        and today.date_timestamp::DATE = current_date::DATE
),
collection_rate AS (
    SELECT
        active.activity_date,
        active.customer_id,
        case
            when count(*) over (partition by active.customer_name) > 1 then active.customer_name || ' (' || row_number () over (partition by active.customer_name) || ')'
            else active.customer_name
        end as client_name,
        active.unique_account_id,
        active.customer_phone_1,
        active.customer_phone_2,
        active.locations,
        active.location_customer_met_latitude,
        active.location_customer_met_longitude,
        active.location_customer_met_accuracy,
        active.daily_rate,
        active.customer_active_end_date,
        active.sales_person,
        active.sales_agent_mobile,
        active.sales_agent_name,
        look.shop,
        look.region,
        active.installation_date,
        active.consecutive_late_days,
        active.days_expected,
        COALESCE(repayments.repayments, 0) AS six_month_repayments,
        repayments.repayments / NULLIF((active.days_expected * active.daily_rate), 0) AS six_month_collection_rate,
        ROW_NUMBER() OVER (PARTITION BY active.unique_account_id) AS row_numbers
    FROM
        active AS active
        LEFT JOIN payments AS repayments ON repayments.payg_account_id = active.unique_account_id
        LEFT JOIN kenya.rp_portfolio_customer_lookup AS look ON look.customer_id = active.customer_id
),
last_30_downpayments AS (
    SELECT
        customer_id,
        unique_account_id,
        SUM(total_downpayment) AS total_downpayment
    FROM
        kenya.rp_retail_sales
    WHERE
        downpayment_date :: date BETWEEN current_date - 7
        AND current_date - 1
    GROUP BY
        1,
        2
),
last_7_day_CR AS (
    SELECT
        payments.sales_order_id AS payg_account_id,
        SUM(amount) - (
            COALESCE(last_30_downpayments.total_downpayment, 0)
        ) AS payments
    FROM
        kenya.payment AS payments
        LEFT JOIN last_30_downpayments AS last_30_downpayments ON last_30_downpayments.unique_account_id = payments.sales_order_id
    WHERE
        payments.is_void IS FALSE
        AND payments.third_party_payment_ref_id NOT LIKE '%BONUS%'
        AND payments.payment_utc_timestamp :: DATE BETWEEN current_date - 7
        AND current_date - 1
    GROUP BY
        payments.sales_order_id,
        last_30_downpayments.total_downpayment
),
dataset AS (
    SELECT
        collection_rate.activity_date AS last_refresh_date,
        current_date - 7 || ' to ' || current_date - 1 as period_,
        collection_rate.region,
        collection_rate.shop,
        collection_rate.unique_account_id,
        collection_rate.client_name as customer_name,
        collection_rate.customer_phone_1,
        collection_rate.customer_phone_2,
        collection_rate.locations AS ward,
        collection_rate.location_customer_met_latitude,
        collection_rate.location_customer_met_longitude,
        CASE
            WHEN collection_rate.daily_rate IN (15, 14.46) THEN 1
            ELSE 0
        END AS ESF_only_status,
        collection_rate.sales_agent_name,
        UPPER(SUBSTRING(collection_rate.sales_person, 0, 7)) AS Agent_id,
        0 AS agent_status,
        COALESCE(last_7_day_CR.payments, 0) / NULLIF((collection_rate.daily_rate * 7), 0) AS last_7_day_CR,
        0 AS technician_name,
        collection_rate.daily_rate,
        collection_rate.consecutive_late_days,
        collection_rate.sales_agent_mobile :: TEXT AS sales_agent_mobile,
        COALESCE(collection_rate.six_month_collection_rate, 0) AS six_month_collection_rate,
        collection_rate.installation_date,
        last_7_day_CR.payments AS cash_collected,
        collection_rate.days_expected,
        CASE
            WHEN collection_rate.installation_date + 8 > collection_rate.activity_date THEN 'New Customer'
            ELSE 'Older Customer'
        END AS customer_age_tag
    FROM
        collection_rate AS collection_rate
        LEFT JOIN last_7_day_CR AS last_7_day_CR ON last_7_day_CR.payg_account_id = collection_rate.unique_account_id
    WHERE
        collection_rate.row_numbers = 1
)
SELECT
    *,
    7 * daily_rate AS total_expected_cash,
    CASE
        WHEN dataset.consecutive_late_days >= 0
        AND dataset.consecutive_late_days < 30 THEN 1
        ELSE 0
    END AS PAR_0_29,
    CASE
        WHEN dataset.consecutive_late_days >= 30
        AND dataset.consecutive_late_days < 59 THEN 1
        ELSE 0
    END AS PAR_30_59,
    CASE
        WHEN dataset.consecutive_late_days >= 60
        AND dataset.consecutive_late_days < 120 THEN 1
        ELSE 0
    END AS PAR_60_119,
    CASE
        WHEN dataset.consecutive_late_days > 120 THEN 1
        ELSE 0
    END AS PAR_120,
    CASE
        WHEN dataset.consecutive_late_days >= 0
        AND dataset.consecutive_late_days < 30
        AND (
            dataset.six_month_collection_rate >= 0.66667
            OR ( dataset.six_month_collection_rate < 0.66667 AND dataset.last_7_day_CR >= 0.6667)
        )
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Good Payer'
        WHEN (
            dataset.six_month_collection_rate < 0.66667
            AND dataset.consecutive_late_days < 30
            AND dataset.last_7_day_CR < 0.6667
            AND dataset.customer_age_tag = 'Older Customer'
        )
        OR (
            dataset.six_month_collection_rate < 0.66667
            AND dataset.consecutive_late_days < 30
            AND dataset.customer_age_tag = 'Older Customer'
            AND dataset.last_7_day_CR IS NULL
        ) THEN 'Slow Payer_Locked Rewards'
        WHEN dataset.consecutive_late_days >= 30
        AND dataset.consecutive_late_days < 60
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Late_30-59'
        WHEN dataset.consecutive_late_days >= 60
        AND dataset.consecutive_late_days < 120
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Defaulted_60-119'
        WHEN dataset.consecutive_late_days >= 120
        AND dataset.customer_age_tag = 'Older Customer' THEN 'Legacy Customer'
        WHEN dataset.customer_age_tag = 'New Customer' THEN 'New Customers'
        ELSE 'Unaccounted for bucket'
    END AS CustomerSegment,
    CASE
        WHEN dataset.consecutive_late_days BETWEEN 0
        AND 119
        AND dataset.customer_age_tag = 'Older Customer' THEN 1
        ELSE 0
    END AS eligible
FROM
    dataset AS dataset -- WHERE 
    --    dataset.unique_account_id = 'BXCK72601546'