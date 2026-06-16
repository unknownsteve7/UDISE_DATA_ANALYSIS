-- Infrastructure Score vs Enrollment Analysis

WITH school_enrolment AS (
    SELECT
        pseudocode,
        SUM(
            cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g +
            c4_b + c4_g + c5_b + c5_g + c6_b + c6_g + c7_b + c7_g +
            c8_b + c8_g + c9_b + c9_g + c10_b + c10_g +
            c11_b + c11_g + c12_b + c12_g
        ) AS total_enrolment
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_infra AS (
    SELECT
        pseudocode,
        CASE WHEN electricity_availability = 1 THEN 1 ELSE 0 END AS has_electricity,
        CASE WHEN library_availability = 1 THEN 1 ELSE 0 END AS has_library,
        CASE WHEN playground_available = 1 THEN 1 ELSE 0 END AS has_playground,
        CASE WHEN internet = 1 THEN 1 ELSE 0 END AS has_internet,
        CASE WHEN total_girls_func_toilet > 0 THEN 1 ELSE 0 END AS has_girls_toilet,
        CASE WHEN total_boys_func_toilet > 0 THEN 1 ELSE 0 END AS has_boys_toilet,
        CASE WHEN comp_ict_lab_yn = 1 THEN 1 ELSE 0 END AS has_comp_lab
    FROM {{ source('public', 'facilities') }}
),

calculated_infra_score AS (
    SELECT
        pseudocode,
        has_electricity,
        has_library,
        has_playground,
        has_internet,
        has_girls_toilet,
        has_boys_toilet,
        has_comp_lab,
        (has_electricity + has_library + has_playground + has_internet + has_girls_toilet + has_boys_toilet + has_comp_lab) AS infra_score
    FROM school_infra
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block,
        school_category,
        school_type,
        managment
    FROM {{ source('public', 'profile1') }}
)

SELECT
    p.state,
    p.district,
    p.block,
    p.pseudocode,
    p.school_category,
    p.school_type,
    p.managment,
    COALESCE(e.total_enrolment, 0) AS total_enrolment,
    i.has_electricity,
    i.has_library,
    i.has_playground,
    i.has_internet,
    i.has_girls_toilet,
    i.has_boys_toilet,
    i.has_comp_lab,
    i.infra_score
FROM school_profile p
LEFT JOIN school_enrolment e ON p.pseudocode = e.pseudocode
LEFT JOIN calculated_infra_score i ON p.pseudocode = i.pseudocode
