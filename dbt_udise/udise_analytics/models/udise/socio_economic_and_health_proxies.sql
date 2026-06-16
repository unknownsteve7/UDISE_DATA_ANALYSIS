-- Socio-economic & Health Proxies Analysis (BPL, EWS and State Anemia Rates)

WITH bpl_enrolment AS (
    SELECT
        pseudocode,
        SUM(cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g + c4_b + c4_g + c5_b + c5_g + c6_b + c6_g + c7_b + c7_g + c8_b + c8_g + c9_b + c9_g + c10_b + c10_g + c11_b + c11_g + c12_b + c12_g) AS bpl_students
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 3 AND item_id = 13
    GROUP BY pseudocode
),

ews_enrolment AS (
    SELECT
        pseudocode,
        SUM(cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g + c4_b + c4_g + c5_b + c5_g + c6_b + c6_g + c7_b + c7_g + c8_b + c8_g + c9_b + c9_g + c10_b + c10_g + c11_b + c11_g + c12_b + c12_g) AS ews_students
    FROM {{ source('public', 'enrollment1') }}
    WHERE item_group = 10 AND item_id = 32
    GROUP BY pseudocode
),

total_enrolment AS (
    SELECT
        pseudocode,
        SUM(cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g + c4_b + c4_g + c5_b + c5_g + c6_b + c6_g + c7_b + c7_g + c8_b + c8_g + c9_b + c9_g + c10_b + c10_g + c11_b + c11_g + c12_b + c12_g) AS total_students
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
        managment
    FROM {{ source('public', 'profile1') }}
),

nfhs_anemia AS (
    SELECT
        state,
        CASE 
            WHEN UPPER(state) = 'ANDAMAN & NICOBAR ISLANDS' THEN 59.0
            WHEN UPPER(state) = 'ANDHRA PRADESH' THEN 63.2
            WHEN UPPER(state) = 'ARUNACHAL PRADESH' THEN 57.5
            WHEN UPPER(state) = 'ASSAM' THEN 68.4
            WHEN UPPER(state) = 'BIHAR' THEN 69.4
            WHEN UPPER(state) = 'CHANDIGARH' THEN 54.6
            WHEN UPPER(state) = 'CHHATTISGARH' THEN 67.2
            WHEN UPPER(state) = 'DADRA & NAGAR HAVELI & DAMAN & DIU' THEN 75.8
            WHEN UPPER(state) = 'DELHI' THEN 69.2
            WHEN UPPER(state) = 'GOA' THEN 53.2
            WHEN UPPER(state) = 'GUJARAT' THEN 79.7
            WHEN UPPER(state) = 'HARYANA' THEN 70.4
            WHEN UPPER(state) = 'HIMACHAL PRADESH' THEN 55.4
            WHEN UPPER(state) = 'JAMMU & KASHMIR' THEN 72.7
            WHEN UPPER(state) = 'JHARKHAND' THEN 67.3
            WHEN UPPER(state) = 'KARNATAKA' THEN 65.5
            WHEN UPPER(state) = 'KERALA' THEN 39.4
            WHEN UPPER(state) = 'LAKSHADWEEP' THEN 52.8
            WHEN UPPER(state) = 'MADHYA PRADESH' THEN 72.7
            WHEN UPPER(state) = 'MAHARASHTRA' THEN 68.9
            WHEN UPPER(state) = 'MANIPUR' THEN 42.8
            WHEN UPPER(state) = 'MEGHALAYA' THEN 46.4
            WHEN UPPER(state) = 'MIZORAM' THEN 34.6
            WHEN UPPER(state) = 'NAGALAND' THEN 42.7
            WHEN UPPER(state) = 'ODISHA' THEN 64.2
            WHEN UPPER(state) = 'PUDUCHERRY' THEN 55.1
            WHEN UPPER(state) = 'PUNJAB' THEN 71.1
            WHEN UPPER(state) = 'RAJASTHAN' THEN 72.4
            WHEN UPPER(state) = 'SIKKIM' THEN 41.1
            WHEN UPPER(state) = 'TAMIL NADU' THEN 57.4
            WHEN UPPER(state) = 'TELANGANA' THEN 70.0
            WHEN UPPER(state) = 'TRIPURA' THEN 64.3
            WHEN UPPER(state) = 'UTTAR PRADESH' THEN 66.4
            WHEN UPPER(state) = 'UTTARAKHAND' THEN 58.8
            WHEN UPPER(state) = 'WEST BENGAL' THEN 69.0
            WHEN UPPER(state) = 'LADAKH' THEN 93.9
            ELSE NULL
        END AS child_anemia_rate_pct
    FROM (SELECT DISTINCT state FROM {{ source('public', 'profile1') }}) s
)

SELECT
    p.state,
    p.district,
    p.block,
    p.pseudocode,
    p.managment,
    COALESCE(t.total_students, 0) AS total_students,
    COALESCE(b.bpl_students, 0) AS bpl_students,
    COALESCE(w.ews_students, 0) AS ews_students,
    a.child_anemia_rate_pct,
    -- Calculate percentages
    CASE 
        WHEN COALESCE(t.total_students, 0) > 0 THEN ROUND((COALESCE(b.bpl_students, 0)::numeric / t.total_students::numeric) * 100, 2)
        ELSE 0 
    END AS bpl_percentage,
    CASE 
        WHEN COALESCE(t.total_students, 0) > 0 THEN ROUND((COALESCE(w.ews_students, 0)::numeric / t.total_students::numeric) * 100, 2)
        ELSE 0 
    END AS ews_percentage
FROM school_profile p
LEFT JOIN total_enrolment t ON p.pseudocode = t.pseudocode
LEFT JOIN bpl_enrolment b ON p.pseudocode = b.pseudocode
LEFT JOIN ews_enrolment w ON p.pseudocode = w.pseudocode
LEFT JOIN nfhs_anemia a ON p.state = a.state
