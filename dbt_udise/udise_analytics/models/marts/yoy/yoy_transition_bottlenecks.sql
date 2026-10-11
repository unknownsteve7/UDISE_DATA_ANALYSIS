-- Year-on-Year: Transition Bottlenecks (Class 8->9 and Class 10->11)

WITH trans_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_b + e.c8_g)   AS total_c8,
        SUM(e.c9_b + e.c9_g)   AS total_c9,
        SUM(e.c10_b + e.c10_g) AS total_c10,
        SUM(e.c11_b + e.c11_g) AS total_c11,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    JOIN {{ ref('stg_enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
),

trans_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_b + e.c8_g)   AS total_c8,
        SUM(e.c9_b + e.c9_g)   AS total_c9,
        SUM(e.c10_b + e.c10_g) AS total_c10,
        SUM(e.c11_b + e.c11_g) AS total_c11,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    JOIN {{ ref('stg_enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
)

SELECT *,
    CASE WHEN total_c8 > 0
         THEN ROUND((total_c9::numeric / total_c8::numeric) * 100, 2)
         ELSE NULL END AS primary_to_sec_transition_pct,
    CASE WHEN total_c10 > 0
         THEN ROUND((total_c11::numeric / total_c10::numeric) * 100, 2)
         ELSE NULL END AS sec_to_hsec_transition_pct
FROM (
    SELECT * FROM trans_2324
    UNION ALL
    SELECT * FROM trans_2425
) combined
