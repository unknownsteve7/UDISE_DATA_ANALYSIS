-- Age-Grade Distortion in Class 1

WITH age_enrolment AS (
    SELECT
        pseudocode,
        item_id AS student_age,
        (c1_b + c1_g) AS c1_students
    FROM {{ source('public', 'enrollment2') }}
    WHERE item_group = 8
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block
    FROM {{ source('public', 'profile1') }}
)

SELECT
    p.state,
    p.district,
    p.block,
    p.pseudocode,
    -- Group into age distortion categories
    SUM(CASE WHEN e.student_age < 5 THEN e.c1_students ELSE 0 END) AS underage_c1_students,
    SUM(CASE WHEN e.student_age IN (5, 6) THEN e.c1_students ELSE 0 END) AS normal_age_c1_students,
    SUM(CASE WHEN e.student_age > 6 THEN e.c1_students ELSE 0 END) AS overage_c1_students,
    SUM(e.c1_students) AS total_c1_students,
    
    -- Calculate distortion percentages
    CASE 
        WHEN SUM(e.c1_students) > 0 THEN ROUND((SUM(CASE WHEN e.student_age < 5 THEN e.c1_students ELSE 0 END)::numeric / SUM(e.c1_students)::numeric) * 100, 2)
        ELSE 0 
    END AS underage_c1_pct,
    CASE 
        WHEN SUM(e.c1_students) > 0 THEN ROUND((SUM(CASE WHEN e.student_age > 6 THEN e.c1_students ELSE 0 END)::numeric / SUM(e.c1_students)::numeric) * 100, 2)
        ELSE 0 
    END AS overage_c1_pct
FROM school_profile p
INNER JOIN age_enrolment e ON p.pseudocode = e.pseudocode
GROUP BY p.state, p.district, p.block, p.pseudocode
