-- Staging Model: 2023-24 Age-Grade Enrollment
WITH source AS (
    SELECT * FROM {{ source('public', 'enrollment2') }}
)
SELECT
    pseudocode,
    item_group,
    item_id,
    item_id AS student_age,
    cpp_b, cpp_g,
    c1_b, c1_g, c2_b, c2_g, c3_b, c3_g, c4_b, c4_g, c5_b, c5_g,
    c6_b, c6_g, c7_b, c7_g, c8_b, c8_g, c9_b, c9_g, c10_b, c10_g,
    c11_b, c11_g, c12_b, c12_g,
    (c1_b + c1_g) AS c1_students,
    '2023-24' AS academic_year
FROM source
