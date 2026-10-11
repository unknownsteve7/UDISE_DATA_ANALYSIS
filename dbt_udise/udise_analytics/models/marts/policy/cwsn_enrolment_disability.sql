-- CWSN Enrolment by Disability Type

WITH cwsn_enrolment AS (
    SELECT
        pseudocode,
        CASE 
            WHEN item_id = 1 THEN 'Blindness'
            WHEN item_id = 2 THEN 'Low-Vision'
            WHEN item_id = 3 THEN 'Hearing impairment (deaf and hard of hearing)'
            WHEN item_id = 4 THEN 'Speech and Language'
            WHEN item_id = 5 THEN 'Locomotor Disability'
            WHEN item_id = 6 THEN 'Mental illness'
            WHEN item_id = 7 THEN 'Specific Learning Disabilities'
            WHEN item_id = 8 THEN 'Cerebral palsy'
            WHEN item_id = 9 THEN 'Autism Spectrum Disorder'
            WHEN item_id = 10 THEN 'Multiple Disability including deaf, blindness'
            WHEN item_id = 11 THEN 'Leprosy Cured students'
            WHEN item_id = 12 THEN 'Dwarfism'
            WHEN item_id = 13 THEN 'Intellectual Disability'
            WHEN item_id = 14 THEN 'Muscular Dystrophy'
            WHEN item_id = 15 THEN 'Chronic Neurological conditions'
            WHEN item_id = 16 THEN 'Multiple Sclerosis'
            WHEN item_id = 17 THEN 'Thalassemia'
            WHEN item_id = 18 THEN 'Hemophilia'
            WHEN item_id = 19 THEN 'Sickle Cell disease'
            WHEN item_id = 20 THEN 'Acid Attack victim'
            WHEN item_id = 21 THEN 'Parkinson''s Disease'
            ELSE 'Other CWSN'
        END AS disability_type,
        total_boys AS boys_cwsn,
        total_girls AS girls_cwsn
    FROM {{ ref('stg_enrollment1') }}
    WHERE item_group = 4
),

school_profile AS (
    SELECT
        pseudocode,
        state,
        district,
        block
    FROM {{ ref('stg_profile1') }}
)

SELECT
    p.state,
    p.district,
    p.block,
    e.disability_type,
    SUM(e.boys_cwsn) AS total_boys,
    SUM(e.girls_cwsn) AS total_girls,
    SUM(e.boys_cwsn + e.girls_cwsn) AS total_cwsn_students
FROM school_profile p
INNER JOIN cwsn_enrolment e ON p.pseudocode = e.pseudocode
GROUP BY p.state, p.district, p.block, e.disability_type
