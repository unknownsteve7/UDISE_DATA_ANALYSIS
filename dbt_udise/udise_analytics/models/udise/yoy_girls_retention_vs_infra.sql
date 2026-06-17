-- ============================================================
-- Year-on-Year: Girls Retention vs Infrastructure
-- Compares 2023-24 vs 2024-25 transition rates (Class 8 -> 9)
-- ============================================================

WITH year_2324 AS (
    SELECT
        p.state,
        p.district,
        p.school_category,
        p.managment,
        CASE WHEN f.total_girls_func_toilet > 0 THEN 'Yes' ELSE 'No' END AS has_girls_toilet,
        CASE WHEN f.electricity_availability = 1 THEN 'Yes' ELSE 'No' END AS has_electricity,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_g) AS total_c8_girls,
        SUM(e.c9_g) AS total_c9_girls,
        CASE WHEN SUM(e.c8_g) > 0
             THEN ROUND(SUM(e.c9_g)::numeric / SUM(e.c8_g)::numeric * 100, 2)
             ELSE NULL END AS girls_transition_pct,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    LEFT JOIN {{ source('public', 'facilities') }} f ON p.pseudocode = f.pseudocode
    WHERE e.c8_g > 0
    GROUP BY 1,2,3,4,5,6
),

year_2425 AS (
    SELECT
        p.state,
        p.district,
        p.school_category,
        p.managment,
        CASE WHEN f.total_girls_func_toilet > 0 THEN 'Yes' ELSE 'No' END AS has_girls_toilet,
        CASE WHEN f.electricity_availability = 1 THEN 'Yes' ELSE 'No' END AS has_electricity,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_g) AS total_c8_girls,
        SUM(e.c9_g) AS total_c9_girls,
        CASE WHEN SUM(e.c8_g) > 0
             THEN ROUND(SUM(e.c9_g)::numeric / SUM(e.c8_g)::numeric * 100, 2)
             ELSE NULL END AS girls_transition_pct,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    LEFT JOIN {{ source('public_2425', 'facilities_2425') }} f ON p.pseudocode = f.pseudocode
    WHERE e.c8_g > 0
    GROUP BY 1,2,3,4,5,6
)

SELECT * FROM year_2324
UNION ALL
SELECT * FROM year_2425
