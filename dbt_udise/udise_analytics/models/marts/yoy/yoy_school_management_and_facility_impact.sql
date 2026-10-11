-- Year-on-Year: School Management and Facility Impact

WITH mgmt_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        p.management_type,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        COALESCE(SUM(e.total_students), 0) AS total_students,
        COALESCE(SUM(e.total_girls), 0)    AS total_girls,
        SUM(f.has_library)                 AS schools_with_library,
        SUM(f.has_smart_tv)                AS schools_with_smart_tv,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS total_students, SUM(total_girls) AS total_girls
        FROM {{ ref('stg_enrollment1') }} WHERE item_group = 1 GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    LEFT JOIN {{ ref('stg_facilities') }} f ON p.pseudocode = f.pseudocode
    GROUP BY 1,2,3,4,5,6
),

mgmt_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        p.management_type,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        COALESCE(SUM(e.total_students), 0) AS total_students,
        COALESCE(SUM(e.total_girls), 0)    AS total_girls,
        SUM(f.has_library)                 AS schools_with_library,
        SUM(f.has_smart_tv)                AS schools_with_smart_tv,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS total_students, SUM(total_girls) AS total_girls
        FROM {{ ref('stg_enrollment1_2425') }} WHERE item_group = 1 GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    LEFT JOIN {{ ref('stg_facilities_2425') }} f ON p.pseudocode = f.pseudocode
    GROUP BY 1,2,3,4,5,6
)

SELECT *,
    CASE WHEN total_students > 0
         THEN ROUND((total_girls::numeric / total_students::numeric) * 100, 2)
         ELSE 0 END AS girls_pct
FROM (
    SELECT * FROM mgmt_2324
    UNION ALL
    SELECT * FROM mgmt_2425
) combined
