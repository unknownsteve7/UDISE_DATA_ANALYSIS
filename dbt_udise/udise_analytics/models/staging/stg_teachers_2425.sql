-- Staging Model: 2024-25 Teachers
WITH source AS (
    SELECT * FROM {{ source('public_2425', 'teachers_2425') }}
)
SELECT
    pseudocode,
    COALESCE(total_tch, 0) AS total_teachers,
    COALESCE(female, 0) AS female_teachers,
    COALESCE(male, 0) AS male_teachers,
    '2024-25' AS academic_year
FROM source
