-- ============================================================
-- Year-on-Year: Infrastructure Score vs Enrollment
-- Tracks 7-point infra score changes 2023-24 vs 2024-25
-- ============================================================

WITH infra_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        -- 7-point composite infrastructure score
        SUM(CASE WHEN f.electricity_availability = 1 THEN 1 ELSE 0 END)             AS schools_electricity,
        SUM(CASE WHEN f.total_girls_func_toilet > 0 THEN 1 ELSE 0 END)              AS schools_girls_toilet,
        SUM(CASE WHEN f.total_boys_func_toilet > 0 THEN 1 ELSE 0 END)               AS schools_boys_toilet,
        SUM(CASE WHEN f.library_availability = 1 THEN 1 ELSE 0 END)                 AS schools_library,
        SUM(CASE WHEN f.playground_availability = 1 THEN 1 ELSE 0 END)              AS schools_playground,
        SUM(CASE WHEN f.internet_availability = 1 THEN 1 ELSE 0 END)                AS schools_internet,
        SUM(CASE WHEN f.computer_lab_availability = 1 THEN 1 ELSE 0 END)            AS schools_computer_lab,
        ROUND(AVG(
            (CASE WHEN f.electricity_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.total_girls_func_toilet > 0 THEN 1 ELSE 0 END) +
            (CASE WHEN f.total_boys_func_toilet > 0 THEN 1 ELSE 0 END) +
            (CASE WHEN f.library_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.playground_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.internet_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.computer_lab_availability = 1 THEN 1 ELSE 0 END)
        )::numeric, 2) AS avg_infra_score,
        SUM(e.total_enrollment) AS total_enrollment,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'facilities') }} f ON p.pseudocode = f.pseudocode
    JOIN (
        SELECT pseudocode,
               SUM(c1_b+c1_g+c2_b+c2_g+c3_b+c3_g+c4_b+c4_g+c5_b+c5_g+
                   c6_b+c6_g+c7_b+c7_g+c8_b+c8_g+c9_b+c9_g+c10_b+c10_g+
                   c11_b+c11_g+c12_b+c12_g) AS total_enrollment
        FROM {{ source('public', 'enrollment1') }} WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    GROUP BY 1,2,3,4,5
),

infra_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(CASE WHEN f.electricity_availability = 1 THEN 1 ELSE 0 END)             AS schools_electricity,
        SUM(CASE WHEN f.total_girls_func_toilet > 0 THEN 1 ELSE 0 END)              AS schools_girls_toilet,
        SUM(CASE WHEN f.total_boys_func_toilet > 0 THEN 1 ELSE 0 END)               AS schools_boys_toilet,
        SUM(CASE WHEN f.library_availability = 1 THEN 1 ELSE 0 END)                 AS schools_library,
        SUM(CASE WHEN f.playground_availability = 1 THEN 1 ELSE 0 END)              AS schools_playground,
        SUM(CASE WHEN f.internet_availability = 1 THEN 1 ELSE 0 END)                AS schools_internet,
        SUM(CASE WHEN f.computer_lab_availability = 1 THEN 1 ELSE 0 END)            AS schools_computer_lab,
        ROUND(AVG(
            (CASE WHEN f.electricity_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.total_girls_func_toilet > 0 THEN 1 ELSE 0 END) +
            (CASE WHEN f.total_boys_func_toilet > 0 THEN 1 ELSE 0 END) +
            (CASE WHEN f.library_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.playground_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.internet_availability = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN f.computer_lab_availability = 1 THEN 1 ELSE 0 END)
        )::numeric, 2) AS avg_infra_score,
        SUM(e.total_enrollment) AS total_enrollment,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'facilities_2425') }} f ON p.pseudocode = f.pseudocode
    JOIN (
        SELECT pseudocode,
               SUM(c1_b+c1_g+c2_b+c2_g+c3_b+c3_g+c4_b+c4_g+c5_b+c5_g+
                   c6_b+c6_g+c7_b+c7_g+c8_b+c8_g+c9_b+c9_g+c10_b+c10_g+
                   c11_b+c11_g+c12_b+c12_g) AS total_enrollment
        FROM {{ source('public_2425', 'enrollment1_2425') }} WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    GROUP BY 1,2,3,4,5
)

SELECT * FROM infra_2324
UNION ALL
SELECT * FROM infra_2425
