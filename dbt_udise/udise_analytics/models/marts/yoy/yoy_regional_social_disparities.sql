-- Year-on-Year: Regional and Social Disparities

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        e.item_id AS social_category_id,
        CASE 
            WHEN e.item_id = 1 THEN 'General'
            WHEN e.item_id = 2 THEN 'SC'
            WHEN e.item_id = 3 THEN 'ST'
            WHEN e.item_id = 4 THEN 'OBC'
            ELSE 'Other'
        END AS social_category,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.total_boys) AS boys_enrolled,
        SUM(e.total_girls) AS girls_enrolled,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    JOIN {{ ref('stg_enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1 AND e.item_id IN (1, 2, 3, 4)
    GROUP BY 1,2,3,4,5,6,7
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        e.item_id AS social_category_id,
        CASE 
            WHEN e.item_id = 1 THEN 'General'
            WHEN e.item_id = 2 THEN 'SC'
            WHEN e.item_id = 3 THEN 'ST'
            WHEN e.item_id = 4 THEN 'OBC'
            ELSE 'Other'
        END AS social_category,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.total_boys) AS boys_enrolled,
        SUM(e.total_girls) AS girls_enrolled,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    JOIN {{ ref('stg_enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1 AND e.item_id IN (1, 2, 3, 4)
    GROUP BY 1,2,3,4,5,6,7
)

SELECT *,
    (boys_enrolled + girls_enrolled) AS total_enrolled,
    ROUND((girls_enrolled::numeric / NULLIF(boys_enrolled, 0)), 3) AS gender_parity_index
FROM (
    SELECT * FROM enroll_2324
    UNION ALL
    SELECT * FROM enroll_2425
) combined
