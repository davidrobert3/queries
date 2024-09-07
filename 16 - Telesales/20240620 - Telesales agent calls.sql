SELECT
    DISTINCT ccdr.caller_id,
    ccdr.call_time :: DATE,
    ccdr.destination,
    ccdr.status,
    count(ccdr.destination)
FROM
    cscc_3cx_daily_report ccdr
WHERE
    ccdr.caller_id IN (
        'Donna Ohato (036)',
        'Mercylyn Gacheri (062)',
        'Valerie Chepkirui (019)',
        'Whitney Otieno (012)',
        'Ann Mungai (015)'
    )
    AND ccdr.call_time :: DATE >= '20240801'
    AND ccdr.call_time :: DATE <= '20240808'
GROUP BY
    1,
    2,
    3,
    4