-- ============================================================
-- Year-on-Year: Socio-Economic & Health Proxies (BPL, EWS)
-- ============================================================

WITH enroll_2324_total AS (
    SELECT
        p.pseudocode,
        SUM(e.cpp_b + e.cpp_g + e.c1_b + e.c1_g + e.c2_b + e.c2_g + e.c3_b + e.c3_g + e.c4_b + e.c4_g + 
            e.c5_b + e.c5_g + e.c6_b + e.c6_g + e.c7_b + e.c7_g + e.c8_b + e.c8_g + 
            e.c9_b + e.c9_g + e.c10_b + e.c10_g + e.c11_b + e.c11_g + e.c12_b + e.c12_g) AS total_enrollment
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1
),
enroll_2324_bpl AS (
    SELECT
        p.pseudocode,
        SUM(e.cpp_b + e.cpp_g + e.c1_b + e.c1_g + e.c2_b + e.c2_g + e.c3_b + e.c3_g + e.c4_b + e.c4_g + 
            e.c5_b + e.c5_g + e.c6_b + e.c6_g + e.c7_b + e.c7_g + e.c8_b + e.c8_g + 
            e.c9_b + e.c9_g + e.c10_b + e.c10_g + e.c11_b + e.c11_g + e.c12_b + e.c12_g) AS students_bpl
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 3 AND e.item_id = 13
    GROUP BY 1
),
enroll_2324_ews AS (
    SELECT
        p.pseudocode,
        SUM(e.cpp_b + e.cpp_g + e.c1_b + e.c1_g + e.c2_b + e.c2_g + e.c3_b + e.c3_g + e.c4_b + e.c4_g + 
            e.c5_b + e.c5_g + e.c6_b + e.c6_g + e.c7_b + e.c7_g + e.c8_b + e.c8_g + 
            e.c9_b + e.c9_g + e.c10_b + e.c10_g + e.c11_b + e.c11_g + e.c12_b + e.c12_g) AS students_ews
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 10 AND e.item_id = 32
    GROUP BY 1
),
enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(COALESCE(b.students_bpl, 0)) AS students_bpl,
        SUM(COALESCE(w.students_ews, 0)) AS students_ews,
        SUM(COALESCE(t.total_enrollment, 0)) AS total_enrollment,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    LEFT JOIN enroll_2324_total t ON p.pseudocode = t.pseudocode
    LEFT JOIN enroll_2324_bpl b ON p.pseudocode = b.pseudocode
    LEFT JOIN enroll_2324_ews w ON p.pseudocode = w.pseudocode
    GROUP BY 1,2,3,4,5
),

enroll_2425_total AS (
    SELECT
        p.pseudocode,
        SUM(e.cpp_b + e.cpp_g + e.c1_b + e.c1_g + e.c2_b + e.c2_g + e.c3_b + e.c3_g + e.c4_b + e.c4_g + 
            e.c5_b + e.c5_g + e.c6_b + e.c6_g + e.c7_b + e.c7_g + e.c8_b + e.c8_g + 
            e.c9_b + e.c9_g + e.c10_b + e.c10_g + e.c11_b + e.c11_g + e.c12_b + e.c12_g) AS total_enrollment
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1
),
enroll_2425_bpl AS (
    SELECT
        p.pseudocode,
        SUM(e.cpp_b + e.cpp_g + e.c1_b + e.c1_g + e.c2_b + e.c2_g + e.c3_b + e.c3_g + e.c4_b + e.c4_g + 
            e.c5_b + e.c5_g + e.c6_b + e.c6_g + e.c7_b + e.c7_g + e.c8_b + e.c8_g + 
            e.c9_b + e.c9_g + e.c10_b + e.c10_g + e.c11_b + e.c11_g + e.c12_b + e.c12_g) AS students_bpl
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 3 AND e.item_id = 13
    GROUP BY 1
),
enroll_2425_ews AS (
    SELECT
        p.pseudocode,
        SUM(e.cpp_b + e.cpp_g + e.c1_b + e.c1_g + e.c2_b + e.c2_g + e.c3_b + e.c3_g + e.c4_b + e.c4_g + 
            e.c5_b + e.c5_g + e.c6_b + e.c6_g + e.c7_b + e.c7_g + e.c8_b + e.c8_g + 
            e.c9_b + e.c9_g + e.c10_b + e.c10_g + e.c11_b + e.c11_g + e.c12_b + e.c12_g) AS students_ews
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 10 AND e.item_id = 32
    GROUP BY 1
),
enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(COALESCE(b.students_bpl, 0)) AS students_bpl,
        SUM(COALESCE(w.students_ews, 0)) AS students_ews,
        SUM(COALESCE(t.total_enrollment, 0)) AS total_enrollment,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    LEFT JOIN enroll_2425_total t ON p.pseudocode = t.pseudocode
    LEFT JOIN enroll_2425_bpl b ON p.pseudocode = b.pseudocode
    LEFT JOIN enroll_2425_ews w ON p.pseudocode = w.pseudocode
    GROUP BY 1,2,3,4,5
)

SELECT *,
    ROUND((students_bpl::numeric / NULLIF(total_enrollment, 0)) * 100, 2) AS bpl_pct,
    ROUND((students_ews::numeric / NULLIF(total_enrollment, 0)) * 100, 2) AS ews_pct
FROM (
    SELECT * FROM enroll_2324
    UNION ALL
    SELECT * FROM enroll_2425
) combined
