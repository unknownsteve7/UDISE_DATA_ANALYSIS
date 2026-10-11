-- Staging Model: 2023-24 School Profiles
WITH source AS (
    SELECT * FROM {{ source('public', 'profile1') }}
)
SELECT
    pseudocode,
    state,
    district,
    block,
    rural_urban,
    CASE 
        WHEN rural_urban = 1 THEN 'Rural'
        WHEN rural_urban = 2 THEN 'Urban'
        ELSE 'Unknown'
    END AS rural_urban_label,
    school_category,
    school_type,
    managment,
    CASE 
        WHEN managment IN (1, 2, 3, 6) THEN 'Government'
        WHEN managment = 4 THEN 'Private Aided'
        WHEN managment = 5 THEN 'Private Unaided'
        ELSE 'Other'
    END AS management_type,
    '2023-24' AS academic_year
FROM source
