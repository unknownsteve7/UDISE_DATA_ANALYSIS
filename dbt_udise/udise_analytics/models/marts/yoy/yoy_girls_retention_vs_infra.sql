-- Year-on-Year: Girls Retention vs Infrastructure

WITH year_2324 AS (
    SELECT
        p.state,
        p.district,
        p.school_category,
        p.managment,
        CASE WHEN f.has_girls_toilet = 1 THEN 'Yes' ELSE 'No' END AS has_girls_toilet,
        CASE WHEN f.has_electricity = 1 THEN 'Yes' ELSE 'No' END AS has_electricity,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_g) AS total_c8_girls,
        SUM(e.c9_g) AS total_c9_girls,
        CASE WHEN SUM(e.c8_g) > 0
             THEN ROUND(SUM(e.c9_g)::numeric / SUM(e.c8_g)::numeric * 100, 2)
             ELSE NULL END AS girls_transition_pct,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    JOIN {{ ref('stg_enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    LEFT JOIN {{ ref('stg_facilities') }} f ON p.pseudocode = f.pseudocode
    WHERE e.c8_g > 0
    GROUP BY 1,2,3,4,5,6
),

year_2425 AS (
    SELECT
        p.state,
        p.district,
        p.school_category,
        p.managment,
        CASE WHEN f.has_girls_toilet = 1 THEN 'Yes' ELSE 'No' END AS has_girls_toilet,
        CASE WHEN f.has_electricity = 1 THEN 'Yes' ELSE 'No' END AS has_electricity,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_g) AS total_c8_girls,
        SUM(e.c9_g) AS total_c9_girls,
        CASE WHEN SUM(e.c8_g) > 0
             THEN ROUND(SUM(e.c9_g)::numeric / SUM(e.c8_g)::numeric * 100, 2)
             ELSE NULL END AS girls_transition_pct,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    JOIN {{ ref('stg_enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    LEFT JOIN {{ ref('stg_facilities_2425') }} f ON p.pseudocode = f.pseudocode
    WHERE e.c8_g > 0
    GROUP BY 1,2,3,4,5,6
)

SELECT * FROM year_2324
UNION ALL
SELECT * FROM year_2425
