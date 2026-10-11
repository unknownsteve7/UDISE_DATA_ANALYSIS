-- Staging Model: 2023-24 Teachers
WITH source AS (
    SELECT * FROM {{ source('public', 'teachers') }}
)
SELECT
    pseudocode,
    COALESCE(total_tch, 0) AS total_teachers,
    COALESCE(female, 0) AS female_teachers,
    COALESCE(male, 0) AS male_teachers,
    '2023-24' AS academic_year
FROM source
