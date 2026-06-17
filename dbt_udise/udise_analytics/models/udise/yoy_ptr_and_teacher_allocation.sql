-- ============================================================
-- Year-on-Year: PTR and Teacher Allocation
-- Compares staffing metrics 2023-24 vs 2024-25
-- ============================================================

WITH year_2324 AS (
    SELECT
        p.state,
        p.district,
        p.school_category,
        p.managment,
        p.rural_urban,
        COUNT(DISTINCT p.pseudocode)                          AS school_count,
        SUM(t.total_tch)                                      AS total_teachers,
        SUM(t.female)                                         AS total_female_teachers,
        SUM(e.total_enrollment)                               AS total_students,
        CASE
            WHEN SUM(t.total_tch) > 0
            THEN ROUND(SUM(e.total_enrollment)::numeric / SUM(t.total_tch)::numeric, 2)
            ELSE NULL
        END AS avg_ptr,
        ROUND(SUM(t.female)::numeric / NULLIF(SUM(t.total_tch), 0) * 100, 2) AS female_teacher_pct,
        SUM(CASE WHEN t.total_tch = 0 THEN 1 ELSE 0 END) AS schools_no_teachers,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN (
        SELECT pseudocode,
               SUM(COALESCE(total_tch, 0)) AS total_tch,
               SUM(COALESCE(female, 0)) AS female
        FROM {{ source('public', 'teachers') }}
        GROUP BY pseudocode
    ) t ON p.pseudocode = t.pseudocode
    JOIN (
        SELECT pseudocode,
               SUM(c1_b + c1_g + c2_b + c2_g + c3_b + c3_g + c4_b + c4_g + c5_b + c5_g +
                   c6_b + c6_g + c7_b + c7_g + c8_b + c8_g + c9_b + c9_g + c10_b + c10_g +
                   c11_b + c11_g + c12_b + c12_g) AS total_enrollment
        FROM {{ source('public', 'enrollment1') }}
        WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    GROUP BY 1,2,3,4,5
),

year_2425 AS (
    SELECT
        p.state,
        p.district,
        p.school_category,
        p.managment,
        p.rural_urban,
        COUNT(DISTINCT p.pseudocode)                          AS school_count,
        SUM(t.total_tch)                                      AS total_teachers,
        SUM(t.female)                                         AS total_female_teachers,
        SUM(e.total_enrollment)                               AS total_students,
        CASE
            WHEN SUM(t.total_tch) > 0
            THEN ROUND(SUM(e.total_enrollment)::numeric / SUM(t.total_tch)::numeric, 2)
            ELSE NULL
        END AS avg_ptr,
        ROUND(SUM(t.female)::numeric / NULLIF(SUM(t.total_tch), 0) * 100, 2) AS female_teacher_pct,
        SUM(CASE WHEN t.total_tch = 0 THEN 1 ELSE 0 END) AS schools_no_teachers,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN (
        SELECT pseudocode,
               SUM(COALESCE(total_tch, 0)) AS total_tch,
               SUM(COALESCE(female, 0)) AS female
        FROM {{ source('public_2425', 'teachers_2425') }}
        GROUP BY pseudocode
    ) t ON p.pseudocode = t.pseudocode
    JOIN (
        SELECT pseudocode,
               SUM(c1_b + c1_g + c2_b + c2_g + c3_b + c3_g + c4_b + c4_g + c5_b + c5_g +
                   c6_b + c6_g + c7_b + c7_g + c8_b + c8_g + c9_b + c9_g + c10_b + c10_g +
                   c11_b + c11_g + c12_b + c12_g) AS total_enrollment
        FROM {{ source('public_2425', 'enrollment1_2425') }}
        WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    GROUP BY 1,2,3,4,5
)

SELECT * FROM year_2324
UNION ALL
SELECT * FROM year_2425
