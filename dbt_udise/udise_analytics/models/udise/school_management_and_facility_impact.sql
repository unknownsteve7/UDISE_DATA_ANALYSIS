-- School Management and Facility Impact Analysis

WITH school_enrolment AS (
    SELECT
        pseudocode,
        SUM(cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g + c4_b + c4_g + c5_b + c5_g + c6_b + c6_g + c7_b + c7_g + c8_b + c8_g + c9_b + c9_g + c10_b + c10_g + c11_b + c11_g + c12_b + c12_g) AS total_students,
        -- Calculate girls ratio
        SUM(cpp_g + c1_g + c2_g + c3_g + c4_g + c5_g + c6_g + c7_g + c8_g + c9_g + c10_g + c11_g + c12_g) AS total_girls
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_infra AS (
    SELECT
        pseudocode,
        CASE WHEN library_availability = 1 THEN 'Yes' ELSE 'No' END AS has_library,
        CASE WHEN smart_class_tv_tot > 0 THEN 'Yes' ELSE 'No' END AS has_smart_tv
    FROM {{ source('public', 'facilities') }}
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block,
        CASE 
            WHEN managment IN (1, 2, 3, 6) THEN 'Government'
            WHEN managment = 4 THEN 'Private Aided'
            WHEN managment = 5 THEN 'Private Unaided'
            ELSE 'Other'
        END AS management_type
    FROM {{ source('public', 'profile1') }}
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
