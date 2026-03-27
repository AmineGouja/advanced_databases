-- Exercice 1

-- 1.
SELECT dept_name
FROM department
WHERE budget = (SELECT MAX(budget) FROM department);


-- 2.
SELECT name, salary
FROM teacher
WHERE salary > (SELECT AVG(salary) FROM teacher);


-- 3.
SELECT
    t.ID   AS teacher_id,
    t.name AS teacher_name,
    s.ID   AS student_id,
    s.name AS student_name,
    COUNT(*) AS total_courses
FROM teacher t
JOIN teaches te
  ON te.ID = t.ID
JOIN takes ta
  ON ta.course_id = te.course_id
 AND ta.sec_id = te.sec_id
 AND ta.semester = te.semester
 AND ta.year = te.year
JOIN student s
  ON s.ID = ta.ID
GROUP BY t.ID, t.name, s.ID, s.name
HAVING COUNT(*) > 2
ORDER BY t.name, s.name;


-- 4.
SELECT DISTINCT
    x.teacher_id,
    x.teacher_name,
    x.student_id,
    x.student_name,
    x.total_courses
FROM (
    SELECT
        t.ID   AS teacher_id,
        t.name AS teacher_name,
        s.ID   AS student_id,
        s.name AS student_name,
        COUNT(*) OVER (PARTITION BY t.ID, s.ID) AS total_courses
    FROM teacher t
    JOIN teaches te
      ON te.ID = t.ID
    JOIN takes ta
      ON ta.course_id = te.course_id
     AND ta.sec_id = te.sec_id
     AND ta.semester = te.semester
     AND ta.year = te.year
    JOIN student s
      ON s.ID = ta.ID
) x
WHERE x.total_courses > 2
ORDER BY x.teacher_name, x.student_name;


-- 5.
SELECT s.ID, s.name
FROM student s
WHERE NOT EXISTS (
    SELECT 1
    FROM takes ta
    WHERE ta.ID = s.ID
      AND ta.year < 2010
)
ORDER BY s.ID;


-- 6.
SELECT ID, name
FROM teacher
WHERE name LIKE 'E%'
ORDER BY name;


-- 7.
SELECT name, salary
FROM (
    SELECT
        name,
        salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM teacher
)
WHERE salary_rank = 4
ORDER BY name;


-- 8.
SELECT name, salary
FROM (
    SELECT
        name,
        salary,
        DENSE_RANK() OVER (ORDER BY salary ASC) AS salary_rank
    FROM teacher
)
WHERE salary_rank <= 3
ORDER BY salary DESC, name;


-- 9.
SELECT DISTINCT s.name
FROM student s
WHERE s.ID IN (
    SELECT ta.ID
    FROM takes ta
    WHERE ta.semester = 'Fall'
      AND ta.year = 2009
)
ORDER BY s.name;


-- 10.
SELECT DISTINCT s.name
FROM student s
WHERE s.ID = SOME (
    SELECT ta.ID
    FROM takes ta
    WHERE ta.semester = 'Fall'
      AND ta.year = 2009
)
ORDER BY s.name;


-- 11.
SELECT DISTINCT name
FROM student
NATURAL INNER JOIN takes
WHERE semester = 'Fall'
  AND year = 2009
ORDER BY name;


-- 12.
SELECT DISTINCT s.name
FROM student s
WHERE EXISTS (
    SELECT 1
    FROM takes ta
    WHERE ta.ID = s.ID
      AND ta.semester = 'Fall'
      AND ta.year = 2009
)
ORDER BY s.name;


-- 13.
SELECT DISTINCT
    s1.ID   AS student1_id,
    s1.name AS student1_name,
    s2.ID   AS student2_id,
    s2.name AS student2_name
FROM takes t1
JOIN takes t2
  ON t1.course_id = t2.course_id
 AND t1.sec_id = t2.sec_id
 AND t1.semester = t2.semester
 AND t1.year = t2.year
 AND t1.ID < t2.ID
JOIN student s1
  ON s1.ID = t1.ID
JOIN student s2
  ON s2.ID = t2.ID
ORDER BY s1.ID, s2.ID;


-- 14.
SELECT
    t.ID,
    t.name,
    COUNT(ta.ID) AS total_students_followed_courses
FROM teacher t
JOIN teaches te
  ON te.ID = t.ID
JOIN takes ta
  ON ta.course_id = te.course_id
 AND ta.sec_id = te.sec_id
 AND ta.semester = te.semester
 AND ta.year = te.year
GROUP BY t.ID, t.name
ORDER BY total_students_followed_courses DESC, t.name;


-- 15.
SELECT
    t.ID,
    t.name,
    COUNT(ta.ID) AS total_students_followed_courses
FROM teacher t
LEFT JOIN teaches te
  ON te.ID = t.ID
LEFT JOIN takes ta
  ON ta.course_id = te.course_id
 AND ta.sec_id = te.sec_id
 AND ta.semester = te.semester
 AND ta.year = te.year
GROUP BY t.ID, t.name
ORDER BY total_students_followed_courses DESC, t.name;


-- 16.
SELECT
    t.ID,
    t.name,
    SUM(CASE WHEN ta.grade = 'A' THEN 1 ELSE 0 END) AS total_A_grades
FROM teacher t
LEFT JOIN teaches te
  ON te.ID = t.ID
LEFT JOIN takes ta
  ON ta.course_id = te.course_id
 AND ta.sec_id = te.sec_id
 AND ta.semester = te.semester
 AND ta.year = te.year
GROUP BY t.ID, t.name
ORDER BY t.name;


-- 17.
SELECT
    t.ID   AS teacher_id,
    t.name AS teacher_name,
    s.ID   AS student_id,
    s.name AS student_name,
    COUNT(*) AS times_followed
FROM teacher t
JOIN teaches te
  ON te.ID = t.ID
JOIN takes ta
  ON ta.course_id = te.course_id
 AND ta.sec_id = te.sec_id
 AND ta.semester = te.semester
 AND ta.year = te.year
JOIN student s
  ON s.ID = ta.ID
GROUP BY t.ID, t.name, s.ID, s.name
ORDER BY t.name, s.name;


-- 18.
SELECT
    t.ID   AS teacher_id,
    t.name AS teacher_name,
    s.ID   AS student_id,
    s.name AS student_name,
    COUNT(*) AS times_followed
FROM teacher t
JOIN teaches te
  ON te.ID = t.ID
JOIN takes ta
  ON ta.course_id = te.course_id
 AND ta.sec_id = te.sec_id
 AND ta.semester = te.semester
 AND ta.year = te.year
JOIN student s
  ON s.ID = ta.ID
GROUP BY t.ID, t.name, s.ID, s.name
HAVING COUNT(*) >= 2
ORDER BY t.name, s.name;
