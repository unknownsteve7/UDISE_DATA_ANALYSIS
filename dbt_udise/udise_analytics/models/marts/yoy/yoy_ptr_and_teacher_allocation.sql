-- Year-on-Year: PTR and Teacher Allocation

WITH ptr_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.total_enrolment) AS total_enrolment,
        SUM(t.total_teachers) AS total_teachers,
        SUM(t.female_teachers) AS female_teachers,
        SUM(t.male_teachers) AS male_teachers,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    JOIN (
        SELECT pseudocode, SUM(total_students) AS total_enrolment
        FROM {{ ref('stg_enrollment1') }} WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    LEFT JOIN {{ ref('stg_teachers') }} t ON p.pseudocode = t.pseudocode
    GROUP BY 1,2,3,4,5
),

ptr_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.total_enrolment) AS total_enrolment,
        SUM(t.total_teachers) AS total_teachers,
        SUM(t.female_teachers) AS female_teachers,
        SUM(t.male_teachers) AS male_teachers,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    JOIN (
        SELECT pseudocode, SUM(total_students) AS total_enrolment
        FROM {{ ref('stg_enrollment1_2425') }} WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    LEFT JOIN {{ ref('stg_teachers_2425') }} t ON p.pseudocode = t.pseudocode
    GROUP BY 1,2,3,4,5
)

SELECT *,
    CASE WHEN total_teachers > 0
         THEN ROUND((total_enrolment::numeric / total_teachers::numeric), 2)
         ELSE NULL END AS pupil_teacher_ratio,
    CASE WHEN total_teachers > 0
         THEN ROUND((female_teachers::numeric / total_teachers::numeric) * 100, 2)
         ELSE 0 END AS female_teacher_pct
FROM (
    SELECT * FROM ptr_2324
    UNION ALL
    SELECT * FROM ptr_2425
) combined
