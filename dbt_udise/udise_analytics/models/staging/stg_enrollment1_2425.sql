-- Staging Model: 2024-25 Grade-Wise Enrollment
WITH source AS (
    SELECT * FROM {{ source('public_2425', 'enrollment1_2425') }}
)
SELECT
    pseudocode,
    item_group,
    item_id,
    cpp_b, cpp_g,
    c1_b, c1_g, c2_b, c2_g, c3_b, c3_g, c4_b, c4_g, c5_b, c5_g,
    c6_b, c6_g, c7_b, c7_g, c8_b, c8_g, c9_b, c9_g, c10_b, c10_g,
    c11_b, c11_g, c12_b, c12_g,
    (cpp_b + c1_b + c2_b + c3_b + c4_b + c5_b + c6_b + c7_b + c8_b + c9_b + c10_b + c11_b + c12_b) AS total_boys,
    (cpp_g + c1_g + c2_g + c3_g + c4_g + c5_g + c6_g + c7_g + c8_g + c9_g + c10_g + c11_g + c12_g) AS total_girls,
    (
        cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g + c4_b + c4_g + c5_b + c5_g +
        c6_b + c6_g + c7_b + c7_g + c8_b + c8_g + c9_b + c9_g + c10_b + c10_g + c11_b + c11_g + c12_b + c12_g
    ) AS total_students,
    '2024-25' AS academic_year
FROM source
