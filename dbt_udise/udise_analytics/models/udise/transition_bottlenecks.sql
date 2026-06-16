-- Transition Bottlenecks Analysis (Class 8 -> 9 and Class 10 -> 11)

WITH school_enrolment AS (
    SELECT
        pseudocode,
        -- Class 8, 9, 10, 11 total enrolment (boys + girls)
        SUM(c8_b + c8_g) AS c8_total,
        SUM(c9_b + c9_g) AS c9_total,
        SUM(c10_b + c10_g) AS c10_total,
        SUM(c11_b + c11_g) AS c11_total
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block,
        school_category,
        managment
    FROM {{ source('public', 'profile1') }}
)

SELECT
    p.state,
    p.district,
    p.block,
    p.pseudocode,
    p.school_category,
    p.managment,
    e.c8_total,
    e.c9_total,
    e.c10_total,
    e.c11_total,
    
    -- Upper Primary to Secondary Transition (Class 8 -> 9)
    CASE 
        WHEN e.c8_total > 0 THEN ROUND((e.c9_total::numeric / e.c8_total::numeric) * 100, 2)
        ELSE NULL 
    END AS primary_to_secondary_transition_pct,
    
    -- Secondary to Sr. Secondary Transition (Class 10 -> 11)
    CASE 
        WHEN e.c10_total > 0 THEN ROUND((e.c11_total::numeric / e.c10_total::numeric) * 100, 2)
        ELSE NULL 
    END AS secondary_to_sr_secondary_transition_pct
FROM school_profile p
INNER JOIN school_enrolment e ON p.pseudocode = e.pseudocode
WHERE e.c8_total > 0 OR e.c10_total > 0
