-- Regional and Social Disparities in Enrollment

WITH school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block,
        CASE 
            WHEN rural_urban = 1 THEN 'Rural'
            WHEN rural_urban = 2 THEN 'Urban'
            ELSE 'Unknown'
        END AS rural_urban_label
    FROM {{ source('public', 'profile1') }}
),

social_enrolment AS (
    SELECT
        pseudocode,
        CASE 
            WHEN item_id = 1 THEN 'General'
            WHEN item_id = 2 THEN 'SC'
            WHEN item_id = 3 THEN 'ST'
            WHEN item_id = 4 THEN 'OBC'
            ELSE 'Other'
        END AS social_category,
        -- Sum boys
        (cpp_b + c1_b + c2_b + c3_b + c4_b + c5_b + c6_b + c7_b + c8_b + c9_b + c10_b + c11_b + c12_b) AS boys_enrolled,
        -- Sum girls
        (cpp_g + c1_g + c2_g + c3_g + c4_g + c5_g + c6_g + c7_g + c8_g + c9_g + c10_g + c11_g + c12_g) AS girls_enrolled
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 1 AND item_id IN (1, 2, 3, 4)
)

SELECT
    p.state,
    p.district,
    p.block,
    p.rural_urban_label,
    e.social_category,
    SUM(e.boys_enrolled) AS total_boys,
    SUM(e.girls_enrolled) AS total_girls,
    SUM(e.boys_enrolled + e.girls_enrolled) AS total_students
FROM school_profile p
INNER JOIN social_enrolment e ON p.pseudocode = e.pseudocode
GROUP BY p.state, p.district, p.block, p.rural_urban_label, e.social_category
