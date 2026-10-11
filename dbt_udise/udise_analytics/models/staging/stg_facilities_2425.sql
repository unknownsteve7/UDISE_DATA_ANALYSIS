-- Staging Model: 2024-25 School Infrastructure & Amenities
WITH source AS (
    SELECT * FROM {{ source('public_2425', 'facilities_2425') }}
)
SELECT
    pseudocode,
    electricity_availability,
    CASE WHEN electricity_availability = 1 THEN 1 ELSE 0 END AS has_electricity,
    library_availability,
    CASE WHEN library_availability = 1 THEN 1 ELSE 0 END AS has_library,
    playground_available,
    CASE WHEN playground_available = 1 THEN 1 ELSE 0 END AS has_playground,
    internet,
    CASE WHEN internet = 1 THEN 1 ELSE 0 END AS has_internet,
    comp_ict_lab_yn,
    CASE WHEN comp_ict_lab_yn = 1 THEN 1 ELSE 0 END AS has_comp_lab,
    total_girls_func_toilet,
    CASE WHEN total_girls_func_toilet > 0 THEN 1 ELSE 0 END AS has_girls_toilet,
    total_boys_func_toilet,
    CASE WHEN total_boys_func_toilet > 0 THEN 1 ELSE 0 END AS has_boys_toilet,
    smart_class_tv_tot,
    CASE WHEN smart_class_tv_tot > 0 THEN 1 ELSE 0 END AS has_smart_tv,
    (
        (CASE WHEN electricity_availability = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN library_availability = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN playground_available = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN internet = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN comp_ict_lab_yn = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN total_girls_func_toilet > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN total_boys_func_toilet > 0 THEN 1 ELSE 0 END)
    ) AS infra_score,
    '2024-25' AS academic_year
FROM source
