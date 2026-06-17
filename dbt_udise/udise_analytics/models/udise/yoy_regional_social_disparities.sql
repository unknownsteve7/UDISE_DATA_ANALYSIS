-- ============================================================
-- Year-on-Year: Regional and Social Disparities
-- ============================================================

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c1_b + e.c2_b + e.c3_b + e.c4_b + e.c5_b + e.c6_b + e.c7_b + e.c8_b + 
            e.c9_b + e.c10_b + e.c11_b + e.c12_b) AS boys_general,
        SUM(e.c1_g + e.c2_g + e.c3_g + e.c4_g + e.c5_g + e.c6_g + e.c7_g + e.c8_g + 
            e.c9_g + e.c10_g + e.c11_g + e.c12_g) AS girls_general,
        SUM(e.sc_c1_b + e.sc_c2_b + e.sc_c3_b + e.sc_c4_b + e.sc_c5_b + e.sc_c6_b + 
            e.sc_c7_b + e.sc_c8_b + e.sc_c9_b + e.sc_c10_b + e.sc_c11_b + e.sc_c12_b) AS boys_sc,
        SUM(e.sc_c1_g + e.sc_c2_g + e.sc_c3_g + e.sc_c4_g + e.sc_c5_g + e.sc_c6_g + 
            e.sc_c7_g + e.sc_c8_g + e.sc_c9_g + e.sc_c10_g + e.sc_c11_g + e.sc_c12_g) AS girls_sc,
        SUM(e.st_c1_b + e.st_c2_b + e.st_c3_b + e.st_c4_b + e.st_c5_b + e.st_c6_b + 
            e.st_c7_b + e.st_c8_b + e.st_c9_b + e.st_c10_b + e.st_c11_b + e.st_c12_b) AS boys_st,
        SUM(e.st_c1_g + e.st_c2_g + e.st_c3_g + e.st_c4_g + e.st_c5_g + e.st_c6_g + 
            e.st_c7_g + e.st_c8_g + e.st_c9_g + e.st_c10_g + e.st_c11_g + e.st_c12_g) AS girls_st,
        SUM(e.obc_c1_b + e.obc_c2_b + e.obc_c3_b + e.obc_c4_b + e.obc_c5_b + e.obc_c6_b + 
            e.obc_c7_b + e.obc_c8_b + e.obc_c9_b + e.obc_c10_b + e.obc_c11_b + e.obc_c12_b) AS boys_obc,
        SUM(e.obc_c1_g + e.obc_c2_g + e.obc_c3_g + e.obc_c4_g + e.obc_c5_g + e.obc_c6_g + 
            e.obc_c7_g + e.obc_c8_g + e.obc_c9_g + e.obc_c10_g + e.obc_c11_g + e.obc_c12_g) AS girls_obc,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.c1_b + e.c2_b + e.c3_b + e.c4_b + e.c5_b + e.c6_b + e.c7_b + e.c8_b + 
            e.c9_b + e.c10_b + e.c11_b + e.c12_b) AS boys_general,
        SUM(e.c1_g + e.c2_g + e.c3_g + e.c4_g + e.c5_g + e.c6_g + e.c7_g + e.c8_g + 
            e.c9_g + e.c10_g + e.c11_g + e.c12_g) AS girls_general,
        SUM(e.sc_c1_b + e.sc_c2_b + e.sc_c3_b + e.sc_c4_b + e.sc_c5_b + e.sc_c6_b + 
            e.sc_c7_b + e.sc_c8_b + e.sc_c9_b + e.sc_c10_b + e.sc_c11_b + e.sc_c12_b) AS boys_sc,
        SUM(e.sc_c1_g + e.sc_c2_g + e.sc_c3_g + e.sc_c4_g + e.sc_c5_g + e.sc_c6_g + 
            e.sc_c7_g + e.sc_c8_g + e.sc_c9_g + e.sc_c10_g + e.sc_c11_g + e.sc_c12_g) AS girls_sc,
        SUM(e.st_c1_b + e.st_c2_b + e.st_c3_b + e.st_c4_b + e.st_c5_b + e.st_c6_b + 
            e.st_c7_b + e.st_c8_b + e.st_c9_b + e.st_c10_b + e.st_c11_b + e.st_c12_b) AS boys_st,
        SUM(e.st_c1_g + e.st_c2_g + e.st_c3_g + e.st_c4_g + e.st_c5_g + e.st_c6_g + 
            e.st_c7_g + e.st_c8_g + e.st_c9_g + e.st_c10_g + e.st_c11_g + e.st_c12_g) AS girls_st,
        SUM(e.obc_c1_b + e.obc_c2_b + e.obc_c3_b + e.obc_c4_b + e.obc_c5_b + e.obc_c6_b + 
            e.obc_c7_b + e.obc_c8_b + e.obc_c9_b + e.obc_c10_b + e.obc_c11_b + e.obc_c12_b) AS boys_obc,
        SUM(e.obc_c1_g + e.obc_c2_g + e.obc_c3_g + e.obc_c4_g + e.obc_c5_g + e.obc_c6_g + 
            e.obc_c7_g + e.obc_c8_g + e.obc_c9_g + e.obc_c10_g + e.obc_c11_g + e.obc_c12_g) AS girls_obc,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
)

SELECT * FROM enroll_2324
UNION ALL
SELECT * FROM enroll_2425
