-- Year-on-Year: Girls Retention in Aspirational Districts (Rural Focus)

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_b) AS c8_boys,
        SUM(e.c8_g) AS c8_girls,
        SUM(e.c9_b) AS c9_boys,
        SUM(e.c9_g) AS c9_girls,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    JOIN {{ ref('stg_enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    WHERE p.rural_urban = 1  -- Rural only
    GROUP BY 1,2,3,4,5
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c8_b) AS c8_boys,
        SUM(e.c8_g) AS c8_girls,
        SUM(e.c9_b) AS c9_boys,
        SUM(e.c9_g) AS c9_girls,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    JOIN {{ ref('stg_enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    WHERE p.rural_urban = 1  -- Rural only
    GROUP BY 1,2,3,4,5
)

SELECT *,
    CASE WHEN c8_boys > 0 THEN ROUND((c8_girls::numeric / c8_boys::numeric), 2) ELSE NULL END AS c8_gpi,
    CASE WHEN c8_girls > 0 THEN ROUND((c9_girls::numeric / c8_girls::numeric) * 100, 2) ELSE NULL END AS girls_transition_pct,
    CASE WHEN c8_boys > 0 THEN ROUND((c9_boys::numeric / c8_boys::numeric) * 100, 2) ELSE NULL END AS boys_transition_pct
FROM (
    SELECT * FROM enroll_2324
    UNION ALL
    SELECT * FROM enroll_2425
) combined
