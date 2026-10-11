-- Year-on-Year: Age-Grade Distortion in Class 1

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(CASE WHEN e.student_age < 5 THEN e.c1_students ELSE 0 END) AS underage_c1,
        SUM(CASE WHEN e.student_age IN (5, 6) THEN e.c1_students ELSE 0 END) AS normal_age_c1,
        SUM(CASE WHEN e.student_age > 6 THEN e.c1_students ELSE 0 END) AS overage_c1,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    JOIN {{ ref('stg_enrollment2') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 8
    GROUP BY 1,2,3,4,5
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(CASE WHEN e.student_age < 5 THEN e.c1_students ELSE 0 END) AS underage_c1,
        SUM(CASE WHEN e.student_age IN (5, 6) THEN e.c1_students ELSE 0 END) AS normal_age_c1,
        SUM(CASE WHEN e.student_age > 6 THEN e.c1_students ELSE 0 END) AS overage_c1,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    JOIN {{ ref('stg_enrollment2_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 8
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
