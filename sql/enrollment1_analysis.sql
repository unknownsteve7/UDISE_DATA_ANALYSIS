

-- Gender Parity Index

WITH gpi AS (
SELECT
    -- Total Boys Calculation (Sum of all _b columns)
    SUM(
        cpp_b + c1_b + c2_b + c3_b + c4_b + c5_b +
        c6_b + c7_b + c8_b + c9_b + c10_b + c11_b + c12_b
    ) AS total_boys,

    -- Total Girls Calculation (Sum of all _g columns)
    SUM(
        cpp_g + c1_g + c2_g + c3_g + c4_g + c5_g +
        c6_g + c7_g + c8_g + c9_g + c10_g + c11_g + c12_g
    ) AS total_girls
FROM enrollment1
WHERE item_group = 1
)

-- Overall Gender Parity Index (GPI)
SELECT ROUND(total_girls::NUMERIC / NULLIF(total_boys,0),3),' :1' FROM gpi;

-- Class wise GPI

WITH class_gpi AS (
    SELECT
        SUM(cpp_g) AS cpp_girls, SUM(cpp_b) AS cpp_boys,
        SUM(c1_g) AS c1_girls,   SUM(c1_b) AS c1_boys,
        SUM(c2_g) AS c2_girls,   SUM(c2_b) AS c2_boys,
        SUM(c3_g) AS c3_girls,   SUM(c3_b) AS c3_boys,
        SUM(c4_g) AS c4_girls,   SUM(c4_b) AS c4_boys,
        SUM(c5_g) AS c5_girls,   SUM(c5_b) AS c5_boys,
        SUM(c6_g) AS c6_girls,   SUM(c6_b) AS c6_boys,
        SUM(c7_g) AS c7_girls,   SUM(c7_b) AS c7_boys,
        SUM(c8_g) AS c8_girls,   SUM(c8_b) AS c8_boys,
        SUM(c9_g) AS c9_girls,   SUM(c9_b) AS c9_boys,
        SUM(c10_g) AS c10_girls, SUM(c10_b) AS c10_boys,
        SUM(c11_g) AS c11_girls, SUM(c11_b) AS c11_boys,
        SUM(c12_g) AS c12_girls, SUM(c12_b) AS c12_boys
    FROM enrollment1
    WHERE item_group = 1
)

SELECT 'CPP'      AS class, ROUND(cpp_girls::NUMERIC / NULLIF(cpp_boys,0),3) AS gpi FROM class_gpi
UNION ALL
SELECT 'Class 1',  ROUND(c1_girls::NUMERIC  / NULLIF(c1_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 2',  ROUND(c2_girls::NUMERIC  / NULLIF(c2_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 3',  ROUND(c3_girls::NUMERIC  / NULLIF(c3_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 4',  ROUND(c4_girls::NUMERIC  / NULLIF(c4_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 5',  ROUND(c5_girls::NUMERIC  / NULLIF(c5_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 6',  ROUND(c6_girls::NUMERIC  / NULLIF(c6_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 7',  ROUND(c7_girls::NUMERIC  / NULLIF(c7_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 8',  ROUND(c8_girls::NUMERIC  / NULLIF(c8_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 9',  ROUND(c9_girls::NUMERIC  / NULLIF(c9_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 10', ROUND(c10_girls::NUMERIC / NULLIF(c10_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 11', ROUND(c11_girls::NUMERIC / NULLIF(c11_boys,0),3) FROM class_gpi
UNION ALL
SELECT 'Class 12', ROUND(c12_girls::NUMERIC / NULLIF(c12_boys,0),3) FROM class_gpi;

-- student progression funnel
WITH student_progression AS (
    SELECT
        SUM(cpp_b + cpp_g) AS pre_primary,
        SUM(c1_b + c1_g)   AS primary_entry,
        SUM(c5_b + c5_g)   AS primary_exit,
        SUM(c8_b + c8_g)   AS upper_primary_exit,
        SUM(c10_b + c10_g) AS secondary_exit,
        SUM(c12_b + c12_g) AS higher_secondary_exit
    FROM enrollment1
    WHERE item_group = 1
)

SELECT
    pre_primary,
    primary_entry,
    primary_exit,
    upper_primary_exit,
    secondary_exit,
    higher_secondary_exit
FROM student_progression;


-- Social Category Share
WITH category_enrollment AS (
    SELECT
        item_id,
        SUM(
            cpp_b + cpp_g + c1_b + c1_g + c2_b + c2_g + c3_b + c3_g +
            c4_b + c4_g + c5_b + c5_g + c6_b + c6_g + c7_b + c7_g +
            c8_b + c8_g + c9_b + c9_g + c10_b + c10_g +
            c11_b + c11_g + c12_b + c12_g
        ) AS total_students
    FROM enrollment1
    WHERE item_group = 1
      AND item_id IN (1,2,3,4)
    GROUP BY item_id
),
overall AS (
    SELECT SUM(total_students) AS grand_total
    FROM category_enrollment
)

SELECT
    CASE
        WHEN item_id = 1 THEN 'General'
        WHEN item_id = 2 THEN 'SC'
        WHEN item_id = 3 THEN 'ST'
        WHEN item_id = 4 THEN 'OBC'
    END AS category,
    total_students,
    ROUND(
        total_students * 100.0 / (SELECT grand_total FROM overall),
        2
    ) AS percentage
FROM category_enrollment
ORDER BY total_students DESC;

-- class wise repeater rate
WITH total_enrollment AS (
    SELECT
        SUM(cpp_b + cpp_g)   AS cpp_total,
        SUM(c1_b + c1_g)     AS c1_total,
        SUM(c2_b + c2_g)     AS c2_total,
        SUM(c3_b + c3_g)     AS c3_total,
        SUM(c4_b + c4_g)     AS c4_total,
        SUM(c5_b + c5_g)     AS c5_total,
        SUM(c6_b + c6_g)     AS c6_total,
        SUM(c7_b + c7_g)     AS c7_total,
        SUM(c8_b + c8_g)     AS c8_total,
        SUM(c9_b + c9_g)     AS c9_total,
        SUM(c10_b + c10_g)   AS c10_total,
        SUM(c11_b + c11_g)   AS c11_total,
        SUM(c12_b + c12_g)   AS c12_total
    FROM enrollment1
    WHERE item_group = 1
),
repeaters AS (
    SELECT
        SUM(cpp_b + cpp_g)   AS cpp_rep,
        SUM(c1_b + c1_g)     AS c1_rep,
        SUM(c2_b + c2_g)     AS c2_rep,
        SUM(c3_b + c3_g)     AS c3_rep,
        SUM(c4_b + c4_g)     AS c4_rep,
        SUM(c5_b + c5_g)     AS c5_rep,
        SUM(c6_b + c6_g)     AS c6_rep,
        SUM(c7_b + c7_g)     AS c7_rep,
        SUM(c8_b + c8_g)     AS c8_rep,
        SUM(c9_b + c9_g)     AS c9_rep,
        SUM(c10_b + c10_g)   AS c10_rep,
        SUM(c11_b + c11_g)   AS c11_rep,
        SUM(c12_b + c12_g)   AS c12_rep
    FROM enrollment1
    WHERE item_group = 5
      AND item_id = 0
)

SELECT 'CPP' AS class,
       ROUND(cpp_rep * 100.0 / NULLIF(cpp_total,0),2) AS repeater_rate
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 1', ROUND(c1_rep * 100.0 / NULLIF(c1_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 2', ROUND(c2_rep * 100.0 / NULLIF(c2_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 3', ROUND(c3_rep * 100.0 / NULLIF(c3_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 4', ROUND(c4_rep * 100.0 / NULLIF(c4_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 5', ROUND(c5_rep * 100.0 / NULLIF(c5_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 6', ROUND(c6_rep * 100.0 / NULLIF(c6_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 7', ROUND(c7_rep * 100.0 / NULLIF(c7_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 8', ROUND(c8_rep * 100.0 / NULLIF(c8_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 9', ROUND(c9_rep * 100.0 / NULLIF(c9_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 10', ROUND(c10_rep * 100.0 / NULLIF(c10_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 11', ROUND(c11_rep * 100.0 / NULLIF(c11_total,0),2)
FROM total_enrollment, repeaters

UNION ALL
SELECT 'Class 12', ROUND(c12_rep * 100.0 / NULLIF(c12_total,0),2)
FROM total_enrollment, repeaters;