-- SELECT *
-- FROM david.hashed_num hn 
-- WHERE hn.phone_number BETWEEN 254789999999 AND 254799999999
SET
    @ @cte_max_recursion_depth = 60000000;

WITH RECURSIVE phone_range AS (
    -- Start of the range
    SELECT
        254790000000 AS phone_number
    UNION
    ALL -- Increment by 1
    SELECT
        phone_number + 1
    FROM
        phone_range
    WHERE
        phone_number < 254799999999
) -- Select missing numbers
SELECT
    pr.phone_number
FROM
    phone_range pr
    LEFT JOIN david.hashed_num hn ON pr.phone_number = hn.phone_number
WHERE
    hn.phone_number IS NULL
ORDER BY
    pr.phone_number;