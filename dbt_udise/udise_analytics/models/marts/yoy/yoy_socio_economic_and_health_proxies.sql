-- Year-on-Year: Socio-Economic and Health Proxies

WITH se_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        COALESCE(SUM(t.total_enrollment), 0) AS total_enrollment,
        COALESCE(SUM(b.bpl_students), 0)     AS bpl_students,
        COALESCE(SUM(w.ews_students), 0)     AS ews_students,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS total_enrollment
        FROM {{ ref('stg_enrollment1') }} WHERE item_group = 1 GROUP BY pseudocode
    ) t ON p.pseudocode = t.pseudocode
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS bpl_students
        FROM {{ ref('stg_enrollment1') }} WHERE item_group = 3 AND item_id = 13 GROUP BY pseudocode
    ) b ON p.pseudocode = b.pseudocode
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS ews_students
        FROM {{ ref('stg_enrollment1') }} WHERE item_group = 10 AND item_id = 32 GROUP BY pseudocode
    ) w ON p.pseudocode = w.pseudocode
    GROUP BY 1,2,3,4,5
),

se_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        COALESCE(SUM(t.total_enrollment), 0) AS total_enrollment,
        COALESCE(SUM(b.bpl_students), 0)     AS bpl_students,
        COALESCE(SUM(w.ews_students), 0)     AS ews_students,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS total_enrollment
        FROM {{ ref('stg_enrollment1_2425') }} WHERE item_group = 1 GROUP BY pseudocode
    ) t ON p.pseudocode = t.pseudocode
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS bpl_students
        FROM {{ ref('stg_enrollment1_2425') }} WHERE item_group = 3 AND item_id = 13 GROUP BY pseudocode
    ) b ON p.pseudocode = b.pseudocode
    LEFT JOIN (
        SELECT pseudocode, SUM(total_students) AS ews_students
        FROM {{ ref('stg_enrollment1_2425') }} WHERE item_group = 10 AND item_id = 32 GROUP BY pseudocode
    ) w ON p.pseudocode = w.pseudocode
    GROUP BY 1,2,3,4,5
)

SELECT *,
    CASE WHEN total_enrollment > 0
         THEN ROUND((bpl_students::numeric / total_enrollment::numeric) * 100, 2)
         ELSE 0 END AS bpl_pct,
    CASE WHEN total_enrollment > 0
         THEN ROUND((ews_students::numeric / total_enrollment::numeric) * 100, 2)
         ELSE 0 END AS ews_pct
FROM (
    SELECT * FROM se_2324
    UNION ALL
    SELECT * FROM se_2425
) combined
