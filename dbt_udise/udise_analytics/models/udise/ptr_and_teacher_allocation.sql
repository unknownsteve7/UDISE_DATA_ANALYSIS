-- Pupil-Teacher Ratio (PTR) and Teacher Allocation Analysis

WITH school_enrolment AS (
    SELECT
        pseudocode,
        SUM(
            cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g +
            c4_b + c4_g + c5_b + c5_g + c6_b + c6_g + c7_b + c7_g +
            c8_b + c8_g + c9_b + c9_g + c10_b + c10_g +
            c11_b + c11_g + c12_b + c12_g
        ) AS total_enrolment
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_teachers AS (
    SELECT
        pseudocode,
        COALESCE(total_tch, 0) AS total_teachers,
        COALESCE(female, 0) AS female_teachers,
        COALESCE(male, 0) AS male_teachers
    FROM {{ source('public', 'teachers') }}
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
    FROM {{ source('public', 'profile1') }}
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
    t.total_teachers,
    t.female_teachers,
    t.male_teachers,
    -- Calculate Pupil-Teacher Ratio (PTR)
    CASE 
        WHEN t.total_teachers > 0 THEN ROUND(COALESCE(e.total_enrolment, 0)::numeric / t.total_teachers::numeric, 2)
        ELSE NULL 
    END AS pupil_teacher_ratio,
    
    -- Categorize based on standard RTE guidelines (PTR > 30 for Primary, PTR > 35 for Secondary)
    CASE 
        WHEN t.total_teachers = 0 AND COALESCE(e.total_enrolment, 0) > 0 THEN 'No Teachers'
        WHEN p.school_category IN (1, 2) AND (COALESCE(e.total_enrolment, 0)::numeric / NULLIF(t.total_teachers, 0)) > 30 THEN 'Under-staffed (PTR > 30)'
        WHEN p.school_category NOT IN (1, 2) AND (COALESCE(e.total_enrolment, 0)::numeric / NULLIF(t.total_teachers, 0)) > 35 THEN 'Under-staffed (PTR > 35)'
        ELSE 'Well-staffed'
    END AS staffing_status
FROM school_profile p
LEFT JOIN school_enrolment e ON p.pseudocode = e.pseudocode
LEFT JOIN school_teachers t ON p.pseudocode = t.pseudocode
