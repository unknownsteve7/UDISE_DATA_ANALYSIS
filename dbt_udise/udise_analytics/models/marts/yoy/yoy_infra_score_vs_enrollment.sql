-- Year-on-Year: Infrastructure Score vs Enrollment

WITH infra_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(f.has_electricity)       AS schools_electricity,
        SUM(f.has_girls_toilet)      AS schools_girls_toilet,
        SUM(f.has_boys_toilet)       AS schools_boys_toilet,
        SUM(f.has_library)           AS schools_library,
        SUM(f.has_playground)        AS schools_playground,
        SUM(f.has_internet)          AS schools_internet,
        SUM(f.has_comp_lab)          AS schools_computer_lab,
        ROUND(AVG(f.infra_score)::numeric, 2) AS avg_infra_score,
        SUM(e.total_enrollment)      AS total_enrollment,
        '2023-24' AS academic_year
    FROM {{ ref('stg_profile1') }} p
    JOIN {{ ref('stg_facilities') }} f ON p.pseudocode = f.pseudocode
    JOIN (
        SELECT pseudocode, SUM(total_students) AS total_enrollment
        FROM {{ ref('stg_enrollment1') }} WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    GROUP BY 1,2,3,4,5
),

infra_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(f.has_electricity)       AS schools_electricity,
        SUM(f.has_girls_toilet)      AS schools_girls_toilet,
        SUM(f.has_boys_toilet)       AS schools_boys_toilet,
        SUM(f.has_library)           AS schools_library,
        SUM(f.has_playground)        AS schools_playground,
        SUM(f.has_internet)          AS schools_internet,
        SUM(f.has_comp_lab)          AS schools_computer_lab,
        ROUND(AVG(f.infra_score)::numeric, 2) AS avg_infra_score,
        SUM(e.total_enrollment)      AS total_enrollment,
        '2024-25' AS academic_year
    FROM {{ ref('stg_profile1_2425') }} p
    JOIN {{ ref('stg_facilities_2425') }} f ON p.pseudocode = f.pseudocode
    JOIN (
        SELECT pseudocode, SUM(total_students) AS total_enrollment
        FROM {{ ref('stg_enrollment1_2425') }} WHERE item_group = 1
        GROUP BY pseudocode
    ) e ON p.pseudocode = e.pseudocode
    GROUP BY 1,2,3,4,5
)

SELECT * FROM infra_2324
UNION ALL
SELECT * FROM infra_2425
