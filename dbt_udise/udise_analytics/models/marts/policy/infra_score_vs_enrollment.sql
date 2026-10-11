-- Infrastructure Score vs Enrollment Analysis

WITH school_enrolment AS (
    SELECT
        pseudocode,
        SUM(total_students) AS total_enrolment
    FROM {{ ref('stg_enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_infra AS (
    SELECT
        pseudocode,
        has_electricity,
        has_library,
        has_playground,
        has_internet,
        has_girls_toilet,
        has_boys_toilet,
        has_comp_lab,
        infra_score
    FROM {{ ref('stg_facilities') }}
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
    FROM {{ ref('stg_profile1') }}
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
LEFT JOIN school_infra i ON p.pseudocode = i.pseudocode
