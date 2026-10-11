-- School Management and Facility Impact Analysis

WITH school_enrolment AS (
    SELECT
        pseudocode,
        SUM(total_students) AS total_students,
        SUM(total_girls) AS total_girls
    FROM {{ ref('stg_enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_infra AS (
    SELECT
        pseudocode,
        CASE WHEN has_library = 1 THEN 'Yes' ELSE 'No' END AS has_library,
        CASE WHEN has_smart_tv = 1 THEN 'Yes' ELSE 'No' END AS has_smart_tv
    FROM {{ ref('stg_facilities') }}
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block,
        management_type
    FROM {{ ref('stg_profile1') }}
)

SELECT
    p.state,
    p.district,
    p.block,
    p.pseudocode,
    p.management_type,
    i.has_library,
    i.has_smart_tv,
    COALESCE(e.total_students, 0) AS total_students,
    COALESCE(e.total_girls, 0) AS total_girls,
    CASE 
        WHEN COALESCE(e.total_students, 0) > 0 THEN ROUND((COALESCE(e.total_girls, 0)::numeric / e.total_students::numeric) * 100, 2)
        ELSE 0 
    END AS girls_percentage
FROM school_profile p
LEFT JOIN school_enrolment e ON p.pseudocode = e.pseudocode
LEFT JOIN school_infra i ON p.pseudocode = i.pseudocode
