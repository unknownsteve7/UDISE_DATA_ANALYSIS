-- ============================================================
-- Year-on-Year: CWSN Enrolment by Disability Type
-- ============================================================

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.blind_b + e.blind_g) AS blindness,
        SUM(e.lowvision_b + e.lowvision_g) AS low_vision,
        SUM(e.hearimpair_b + e.hearimpair_g) AS hearing_impairment,
        SUM(e.speechlange_b + e.speechlange_g) AS speech_language,
        SUM(e.locomot_b + e.locomot_g) AS locomotor_disability,
        SUM(e.mentalill_b + e.mentalill_g) AS mental_illness,
        SUM(e.learn_b + e.learn_g) AS specific_learning_disability,
        SUM(e.cerebral_b + e.cerebral_g) AS cerebral_palsy,
        SUM(e.autism_b + e.autism_g) AS autism_spectrum,
        SUM(e.mult_disab_b + e.mult_disab_g) AS multiple_disability,
        SUM(e.blind_b + e.lowvision_b + e.hearimpair_b + e.speechlange_b + e.locomot_b + 
            e.mentalill_b + e.learn_b + e.cerebral_b + e.autism_b + e.mult_disab_b) AS total_cwsn_boys,
        SUM(e.blind_g + e.lowvision_g + e.hearimpair_g + e.speechlange_g + e.locomot_g + 
            e.mentalill_g + e.learn_g + e.cerebral_g + e.autism_g + e.mult_disab_g) AS total_cwsn_girls,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment2') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.blind_b + e.blind_g) AS blindness,
        SUM(e.lowvision_b + e.lowvision_g) AS low_vision,
        SUM(e.hearimpair_b + e.hearimpair_g) AS hearing_impairment,
        SUM(e.speechlange_b + e.speechlange_g) AS speech_language,
        SUM(e.locomot_b + e.locomot_g) AS locomotor_disability,
        SUM(e.mentalill_b + e.mentalill_g) AS mental_illness,
        SUM(e.learn_b + e.learn_g) AS specific_learning_disability,
        SUM(e.cerebral_b + e.cerebral_g) AS cerebral_palsy,
        SUM(e.autism_b + e.autism_g) AS autism_spectrum,
        SUM(e.mult_disab_b + e.mult_disab_g) AS multiple_disability,
        SUM(e.blind_b + e.lowvision_b + e.hearimpair_b + e.speechlange_b + e.locomot_b + 
            e.mentalill_b + e.learn_b + e.cerebral_b + e.autism_b + e.mult_disab_b) AS total_cwsn_boys,
        SUM(e.blind_g + e.lowvision_g + e.hearimpair_g + e.speechlange_g + e.locomot_g + 
            e.mentalill_g + e.learn_g + e.cerebral_g + e.autism_g + e.mult_disab_g) AS total_cwsn_girls,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment2_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 1
    GROUP BY 1,2,3,4,5
)

SELECT * FROM enroll_2324
UNION ALL
SELECT * FROM enroll_2425
