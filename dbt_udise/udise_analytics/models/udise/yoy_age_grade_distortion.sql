-- ============================================================
-- Year-on-Year: Age-Grade Distortion
-- ============================================================

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        SUM(e.age_u5_b + e.age_u5_g) AS underage_c1,
        SUM(e.age_5_b + e.age_5_g + e.age_6_b + e.age_6_g) AS normal_age_c1,
        SUM(e.age_7_b + e.age_7_g + e.age_8_b + e.age_8_g + e.age_9_b + e.age_9_g + 
            e.age_10_b + e.age_10_g + e.age_11_b + e.age_11_g + e.age_12_b + e.age_12_g + 
            e.age_13_b + e.age_13_g + e.age_14_b + e.age_14_g + e.age_15_b + e.age_15_g + 
            e.age_16_b + e.age_16_g + e.age_17_b + e.age_17_g + e.age_18_b + e.age_18_g + 
            e.age_19_b + e.age_19_g + e.age_20_b + e.age_20_g + e.age_21_b + e.age_21_g + 
            e.age_22_b + e.age_22_g + e.age_a22_b + e.age_a22_g) AS overage_c1,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment2') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        SUM(e.age_u5_b + e.age_u5_g) AS underage_c1,
        SUM(e.age_5_b + e.age_5_g + e.age_6_b + e.age_6_g) AS normal_age_c1,
        SUM(e.age_7_b + e.age_7_g + e.age_8_b + e.age_8_g + e.age_9_b + e.age_9_g + 
            e.age_10_b + e.age_10_g + e.age_11_b + e.age_11_g + e.age_12_b + e.age_12_g + 
            e.age_13_b + e.age_13_g + e.age_14_b + e.age_14_g + e.age_15_b + e.age_15_g + 
            e.age_16_b + e.age_16_g + e.age_17_b + e.age_17_g + e.age_18_b + e.age_18_g + 
            e.age_19_b + e.age_19_g + e.age_20_b + e.age_20_g + e.age_21_b + e.age_21_g + 
            e.age_22_b + e.age_22_g + e.age_a22_b + e.age_a22_g) AS overage_c1,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment2_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
)

SELECT *,
    (underage_c1 + normal_age_c1 + overage_c1) AS total_c1,
    ROUND((underage_c1::numeric / NULLIF(underage_c1 + normal_age_c1 + overage_c1, 0)) * 100, 2) AS underage_pct,
    ROUND((overage_c1::numeric / NULLIF(underage_c1 + normal_age_c1 + overage_c1, 0)) * 100, 2) AS overage_pct
FROM (
    SELECT * FROM enroll_2324
    UNION ALL
    SELECT * FROM enroll_2425
) combined
