-- 1.
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'SECTION'
ORDER BY column_id;


-- 2.
SELECT * 
FROM course;


-- 3.
SELECT title, dept_name
FROM course;


-- 4. 
SELECT dept_name, budget
FROM department;


-- 5. 
SELECT name, dept_name
FROM teacher;


-- 6. 
SELECT name
FROM teacher
WHERE salary > 65000;


-- 7. 
SELECT name
FROM teacher
WHERE salary BETWEEN 55000 AND 85000;


-- 8. 
SELECT DISTINCT dept_name
FROM teacher;


-- 9. 
SELECT name
FROM teacher
WHERE dept_name = 'Comp. Sci.'
  AND salary > 65000;


-- 10. 
SELECT *
FROM section
WHERE semester = 'Spring'
  AND year = 2010;


-- 11.
SELECT title
FROM course
WHERE dept_name = 'Comp. Sci.'
  AND credits > 3;


-- 12.
SELECT t.name, d.dept_name, d.building
FROM teacher t
JOIN department d ON t.dept_name = d.dept_name;


-- 13. 
SELECT DISTINCT s.ID, s.name
FROM student s
JOIN takes ta ON s.ID = ta.ID
JOIN course c ON ta.course_id = c.course_id
WHERE c.dept_name = 'Comp. Sci.';


-- 14.
SELECT DISTINCT s.name
FROM student s
JOIN takes ta
  ON s.ID = ta.ID
JOIN teaches te
  ON ta.course_id = te.course_id
 AND ta.sec_id = te.sec_id
 AND ta.semester = te.semester
 AND ta.year = te.year
JOIN teacher t
  ON te.ID = t.ID
WHERE t.name = 'Einstein';


-- 15.
SELECT te.course_id, t.name
FROM teaches te
JOIN teacher t ON te.ID = t.ID;


-- 16. 
SELECT course_id, sec_id, semester, year, COUNT(*) AS nb_inscrits
FROM takes
WHERE semester = 'Spring'
  AND year = 2010
GROUP BY course_id, sec_id, semester, year;


-- 17. 
SELECT dept_name, MAX(salary) AS salaire_max
FROM teacher
GROUP BY dept_name;


-- 18.
SELECT course_id, sec_id, semester, year, COUNT(*) AS nb_inscrits
FROM takes
GROUP BY course_id, sec_id, semester, year;


-- 19.
SELECT building, COUNT(*) AS nb_cours
FROM section
WHERE (semester = 'Fall' AND year = 2009)
   OR (semester = 'Spring' AND year = 2010)
GROUP BY building;


-- 20.
SELECT d.dept_name, COUNT(*) AS nb_cours
FROM department d
JOIN course c ON d.dept_name = c.dept_name
JOIN section s ON c.course_id = s.course_id
WHERE d.building = s.building
GROUP BY d.dept_name;


-- 21.
SELECT c.title, t.name
FROM course c
JOIN teaches te ON c.course_id = te.course_id
JOIN teacher t ON te.ID = t.ID;


-- 22.
SELECT semester, COUNT(*) AS nb_cours
FROM section
WHERE semester IN ('Summer', 'Fall', 'Spring')
GROUP BY semester;


-- 23.
SELECT s.ID, s.name, SUM(c.credits) AS total_credits
FROM student s
JOIN takes ta ON s.ID = ta.ID
JOIN course c ON ta.course_id = c.course_id
WHERE s.dept_name <> c.dept_name
GROUP BY s.ID, s.name;


-- 24.
SELECT d.dept_name, SUM(c.credits) AS total_credits
FROM department d
JOIN course c ON d.dept_name = c.dept_name
JOIN section s ON c.course_id = s.course_id
WHERE d.building = s.building
GROUP BY d.dept_name;