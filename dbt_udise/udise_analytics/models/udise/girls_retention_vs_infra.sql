-- Girls Retention vs School Infrastructure (Girls Toilet and Electricity)

WITH school_enrolment AS (
    SELECT
        pseudocode,
        SUM(c8_g) AS c8_girls,
        SUM(c9_g) AS c9_girls
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_infra AS (
    SELECT
        pseudocode,
        CASE 
            WHEN total_girls_func_toilet > 0 THEN 'Yes' 
            ELSE 'No' 
        END AS has_functional_girls_toilet,
        CASE 
            WHEN electricity_availability = 1 THEN 'Yes' 
            ELSE 'No' 
        END AS has_electricity
    FROM {{ source('public', 'facilities') }}
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
    i.has_functional_girls_toilet,
    i.has_electricity,
    e.c8_girls,
    e.c9_girls,
    -- Calculate transition/survival rate (Class 8 to 9) as a proxy
    CASE 
        WHEN e.c8_girls > 0 THEN ROUND((e.c9_girls::numeric / e.c8_girls::numeric) * 100, 2)
        ELSE NULL 
    END AS girls_transition_rate_pct
FROM school_profile p
INNER JOIN school_enrolment e ON p.pseudocode = e.pseudocode
LEFT JOIN school_infra i ON p.pseudocode = i.pseudocode
WHERE e.c8_girls > 0 -- only include schools that have a cohort of girls in Class 8
