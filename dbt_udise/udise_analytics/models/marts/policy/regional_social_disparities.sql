-- Regional and Social Disparities in Enrollment

WITH school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block,
        rural_urban_label
    FROM {{ ref('stg_profile1') }}
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
        total_boys,
        total_girls,
        total_students
    FROM {{ ref('stg_enrollment1') }}
    WHERE item_group = 1 AND item_id IN (1, 2, 3, 4)
)

SELECT
    p.state,
    p.district,
    p.block,
    p.rural_urban_label,
    e.social_category,
    SUM(e.total_boys) AS total_boys,
    SUM(e.total_girls) AS total_girls,
    SUM(e.total_students) AS total_students
FROM school_profile p
INNER JOIN social_enrolment e ON p.pseudocode = e.pseudocode
GROUP BY p.state, p.district, p.block, p.rural_urban_label, e.social_category
