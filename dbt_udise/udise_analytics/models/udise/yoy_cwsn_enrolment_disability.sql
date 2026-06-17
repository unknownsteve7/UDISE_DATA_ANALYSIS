-- ============================================================
-- Year-on-Year: CWSN Enrolment by Disability Type
-- ============================================================

WITH enroll_2324 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        e.item_id AS disability_type_id,
        CASE 
            WHEN e.item_id = 1 THEN 'Blindness'
            WHEN e.item_id = 2 THEN 'Low-Vision'
            WHEN e.item_id = 3 THEN 'Hearing impairment (deaf and hard of hearing)'
            WHEN e.item_id = 4 THEN 'Speech and Language'
            WHEN e.item_id = 5 THEN 'Locomotor Disability'
            WHEN e.item_id = 6 THEN 'Mental illness'
            WHEN e.item_id = 7 THEN 'Specific Learning Disabilities'
            WHEN e.item_id = 8 THEN 'Cerebral palsy'
            WHEN e.item_id = 9 THEN 'Autism Spectrum Disorder'
            WHEN e.item_id = 10 THEN 'Multiple Disability including deaf, blindness'
            WHEN e.item_id = 11 THEN 'Leprosy Cured students'
            WHEN e.item_id = 12 THEN 'Dwarfism'
            WHEN e.item_id = 13 THEN 'Intellectual Disability'
            WHEN e.item_id = 14 THEN 'Muscular Dystrophy'
            WHEN e.item_id = 15 THEN 'Chronic Neurological conditions'
            WHEN e.item_id = 16 THEN 'Multiple Sclerosis'
            WHEN e.item_id = 17 THEN 'Thalassemia'
            WHEN e.item_id = 18 THEN 'Hemophilia'
            WHEN e.item_id = 19 THEN 'Sickle Cell disease'
            WHEN e.item_id = 20 THEN 'Acid Attack victim'
            WHEN e.item_id = 21 THEN 'Parkinson''s Disease'
            ELSE 'Other CWSN'
        END AS disability_type,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.cpp_b + e.c1_b + e.c2_b + e.c3_b + e.c4_b + e.c5_b + e.c6_b + e.c7_b + e.c8_b + e.c9_b + e.c10_b + e.c11_b + e.c12_b) AS boys_cwsn,
        SUM(e.cpp_g + e.c1_g + e.c2_g + e.c3_g + e.c4_g + e.c5_g + e.c6_g + e.c7_g + e.c8_g + e.c9_g + e.c10_g + e.c11_g + e.c12_g) AS girls_cwsn,
        '2023-24' AS academic_year
    FROM {{ source('public', 'profile1') }} p
    JOIN {{ source('public', 'enrollment1') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 4
    GROUP BY 1,2,3,4,5,6,7
),

enroll_2425 AS (
    SELECT
        p.state, p.district, p.school_category, p.managment, p.rural_urban,
        e.item_id AS disability_type_id,
        CASE 
            WHEN e.item_id = 1 THEN 'Blindness'
            WHEN e.item_id = 2 THEN 'Low-Vision'
            WHEN e.item_id = 3 THEN 'Hearing impairment (deaf and hard of hearing)'
            WHEN e.item_id = 4 THEN 'Speech and Language'
            WHEN e.item_id = 5 THEN 'Locomotor Disability'
            WHEN e.item_id = 6 THEN 'Mental illness'
            WHEN e.item_id = 7 THEN 'Specific Learning Disabilities'
            WHEN e.item_id = 8 THEN 'Cerebral palsy'
            WHEN e.item_id = 9 THEN 'Autism Spectrum Disorder'
            WHEN e.item_id = 10 THEN 'Multiple Disability including deaf, blindness'
            WHEN e.item_id = 11 THEN 'Leprosy Cured students'
            WHEN e.item_id = 12 THEN 'Dwarfism'
            WHEN e.item_id = 13 THEN 'Intellectual Disability'
            WHEN e.item_id = 14 THEN 'Muscular Dystrophy'
            WHEN e.item_id = 15 THEN 'Chronic Neurological conditions'
            WHEN e.item_id = 16 THEN 'Multiple Sclerosis'
            WHEN e.item_id = 17 THEN 'Thalassemia'
            WHEN e.item_id = 18 THEN 'Hemophilia'
            WHEN e.item_id = 19 THEN 'Sickle Cell disease'
            WHEN e.item_id = 20 THEN 'Acid Attack victim'
            WHEN e.item_id = 21 THEN 'Parkinson''s Disease'
            ELSE 'Other CWSN'
        END AS disability_type,
        COUNT(DISTINCT p.pseudocode) AS school_count,
        SUM(e.cpp_b + e.c1_b + e.c2_b + e.c3_b + e.c4_b + e.c5_b + e.c6_b + e.c7_b + e.c8_b + e.c9_b + e.c10_b + e.c11_b + e.c12_b) AS boys_cwsn,
        SUM(e.cpp_g + e.c1_g + e.c2_g + e.c3_g + e.c4_g + e.c5_g + e.c6_g + e.c7_g + e.c8_g + e.c9_g + e.c10_g + e.c11_g + e.c12_g) AS girls_cwsn,
        '2024-25' AS academic_year
    FROM {{ source('public_2425', 'profile1_2425') }} p
    JOIN {{ source('public_2425', 'enrollment1_2425') }} e ON p.pseudocode = e.pseudocode AND e.item_group = 4
    GROUP BY 1,2,3,4,5,6,7
)

SELECT * FROM enroll_2324
UNION ALL
SELECT * FROM enroll_2425
