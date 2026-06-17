-- ============================================================
-- Year-on-Year: Regional and Social Disparities
-- ============================================================

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
        SUM(e.cpp_b + e.c1_b + e.c2_b + e.c3_b + e.c4_b + e.c5_b + e.c6_b + e.c7_b + 
            e.c8_b + e.c9_b + e.c10_b + e.c11_b + e.c12_b) AS total_boys,
        SUM(e.cpp_g + e.c1_g + e.c2_g + e.c3_g + e.c4_g + e.c5_g + e.c6_g + e.c7_g + 
            e.c8_g + e.c9_g + e.c10_g + e.c11_g + e.c12_g) AS total_girls,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1 AND e.item_id IN (1, 2, 3, 4)
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
        SUM(e.cpp_b + e.c1_b + e.c2_b + e.c3_b + e.c4_b + e.c5_b + e.c6_b + e.c7_b + 
            e.c8_b + e.c9_b + e.c10_b + e.c11_b + e.c12_b) AS total_boys,
        SUM(e.cpp_g + e.c1_g + e.c2_g + e.c3_g + e.c4_g + e.c5_g + e.c6_g + e.c7_g + 
            e.c8_g + e.c9_g + e.c10_g + e.c11_g + e.c12_g) AS total_girls,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1 AND e.item_id IN (1, 2, 3, 4)
    GROUP BY 1,2,3,4,5,6,7
)

SELECT * FROM enroll_2324
UNION ALL
SELECT * FROM enroll_2425
