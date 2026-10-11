-- Girls Retention in Aspirational/Rural Districts

WITH rural_school_enrolment AS (
    SELECT
        pseudocode,
        SUM(c8_b) AS c8_boys,
        SUM(c8_g) AS c8_girls,
        SUM(c9_b) AS c9_boys,
        SUM(c9_g) AS c9_girls,
        SUM(total_boys) AS total_boys,
        SUM(total_girls) AS total_girls
    FROM {{ ref('stg_enrollment1') }}
    WHERE item_group = 1
    GROUP BY pseudocode
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block
    FROM {{ ref('stg_profile1') }}
    WHERE rural_urban = 1 -- Rural schools
)

SELECT
    p.state,
    p.district,
    COUNT(p.pseudocode) AS total_rural_schools,
    SUM(e.total_boys) AS rural_boys,
    SUM(e.total_girls) AS rural_girls,
    SUM(e.total_boys + e.total_girls) AS rural_total_enrolment,
    
    ROUND(SUM(e.total_girls)::numeric / NULLIF(SUM(e.total_boys), 0)::numeric, 3) AS rural_gpi,
    
    SUM(e.c8_boys) AS c8_boys_total,
    SUM(e.c8_girls) AS c8_girls_total,
    SUM(e.c9_boys) AS c9_boys_total,
    SUM(e.c9_girls) AS c9_girls_total,
    
    ROUND((SUM(e.c9_boys)::numeric / NULLIF(SUM(e.c8_boys), 0)::numeric) * 100, 2) AS boys_transition_rate_pct,
    ROUND((SUM(e.c9_girls)::numeric / NULLIF(SUM(e.c8_girls), 0)::numeric) * 100, 2) AS girls_transition_rate_pct,
    
    CASE 
        WHEN (SUM(e.total_girls)::numeric / NULLIF(SUM(e.total_boys), 0)::numeric) < 0.95 THEN 'Critical Gender Parity Gap (<0.95)'
        WHEN (SUM(e.c9_girls)::numeric / NULLIF(SUM(e.c8_girls), 0)::numeric) < (SUM(e.c9_boys)::numeric / NULLIF(SUM(e.c8_boys), 0)::numeric) - 5 THEN 'Girls Retention Lagging Behind Boys'
        ELSE 'Normal/Satisfactory'
    END AS gender_gap_status
FROM school_profile p
INNER JOIN rural_school_enrolment e ON p.pseudocode = e.pseudocode
GROUP BY p.state, p.district
