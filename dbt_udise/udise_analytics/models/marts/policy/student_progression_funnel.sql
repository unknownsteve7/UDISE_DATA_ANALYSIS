-- Student Progression Funnel

WITH student_progression AS (
    SELECT
        SUM(cpp_b + cpp_g) AS pre_primary,
        SUM(c1_b + c1_g)   AS primary_entry,
        SUM(c5_b + c5_g)   AS primary_exit,
        SUM(c8_b + c8_g)   AS upper_primary_exit,
        SUM(c10_b + c10_g) AS secondary_exit,
        SUM(c12_b + c12_g) AS higher_secondary_exit
    FROM {{ ref('stg_enrollment1') }}
    WHERE item_group = 1
)

SELECT
    pre_primary,
    primary_entry,
    primary_exit,
    upper_primary_exit,
    secondary_exit,
    higher_secondary_exit
FROM student_progression
