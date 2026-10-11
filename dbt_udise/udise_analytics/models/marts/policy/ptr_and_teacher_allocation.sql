-- Pupil-Teacher Ratio (PTR) and Teacher Allocation Analysis

WITH school_enrolment AS (
    SELECT
        pseudocode,
        SUM(total_students) AS total_enrolment
    FROM {{ ref('stg_enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_teachers AS (
    SELECT
        pseudocode,
        total_teachers,
        female_teachers,
        male_teachers
    FROM {{ ref('stg_teachers') }}
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block,
        school_category,
        school_type,
        managment
    FROM {{ ref('stg_profile1') }}
)

SELECT
    p.state,
    p.district,
    p.block,
    p.pseudocode,
    p.school_category,
    p.school_type,
    p.managment,
    COALESCE(e.total_enrolment, 0) AS total_enrolment,
    COALESCE(t.total_teachers, 0) AS total_teachers,
    COALESCE(t.female_teachers, 0) AS female_teachers,
    COALESCE(t.male_teachers, 0) AS male_teachers,
    -- Calculate Pupil-Teacher Ratio (PTR)
    CASE 
        WHEN COALESCE(t.total_teachers, 0) > 0 THEN ROUND(COALESCE(e.total_enrolment, 0)::numeric / t.total_teachers::numeric, 2)
        ELSE NULL 
    END AS pupil_teacher_ratio,
    
    -- Categorize based on standard RTE guidelines (PTR > 30 for Primary, PTR > 35 for Secondary)
    CASE 
        WHEN COALESCE(t.total_teachers, 0) = 0 AND COALESCE(e.total_enrolment, 0) > 0 THEN 'No Teachers'
        WHEN p.school_category IN (1, 2) AND (COALESCE(e.total_enrolment, 0)::numeric / NULLIF(t.total_teachers, 0)) > 30 THEN 'Under-staffed (PTR > 30)'
        WHEN p.school_category NOT IN (1, 2) AND (COALESCE(e.total_enrolment, 0)::numeric / NULLIF(t.total_teachers, 0)) > 35 THEN 'Under-staffed (PTR > 35)'
        ELSE 'Well-staffed'
    END AS staffing_status
FROM school_profile p
LEFT JOIN school_enrolment e ON p.pseudocode = e.pseudocode
LEFT JOIN school_teachers t ON p.pseudocode = t.pseudocode
