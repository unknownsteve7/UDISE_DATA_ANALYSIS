-- ============================================================
-- Year-on-Year: Transition Bottlenecks (Class 8->9 and 10->11)
-- ============================================================

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode)                                         AS school_count,
        SUM(e.c8_b + e.c8_g)                                                AS c8_total,
        SUM(e.c9_b + e.c9_g)                                                AS c9_total,
        SUM(e.c10_b + e.c10_g)                                              AS c10_total,
        SUM(e.c11_b + e.c11_g)                                              AS c11_total,
        ROUND(SUM(e.c9_b + e.c9_g)::numeric / NULLIF(SUM(e.c8_b + e.c8_g), 0) * 100, 2)   AS transition_8_to_9_pct,
        ROUND(SUM(e.c11_b + e.c11_g)::numeric / NULLIF(SUM(e.c10_b + e.c10_g), 0) * 100, 2) AS transition_10_to_11_pct,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode)                                         AS school_count,
        SUM(e.c8_b + e.c8_g)                                                AS c8_total,
        SUM(e.c9_b + e.c9_g)                                                AS c9_total,
        SUM(e.c10_b + e.c10_g)                                              AS c10_total,
        SUM(e.c11_b + e.c11_g)                                              AS c11_total,
        ROUND(SUM(e.c9_b + e.c9_g)::numeric / NULLIF(SUM(e.c8_b + e.c8_g), 0) * 100, 2)   AS transition_8_to_9_pct,
        ROUND(SUM(e.c11_b + e.c11_g)::numeric / NULLIF(SUM(e.c10_b + e.c10_g), 0) * 100, 2) AS transition_10_to_11_pct,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
)

SELECT * FROM enroll_2324
UNION ALL
SELECT * FROM enroll_2425
