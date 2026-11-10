# INFOMAN1 — Week 11 Lab Answers

**Name:** John Carlo Valdez
**Student ID:** 2511004
**GitHub repo:** https://github.com/JohnCarlo2345/infoman1
**Date submitted:** October 28, 2026

---

## Task 1 - Diagnose the Anomalies

**Approach / explanation:**
I started by examining the unnormalized `student_enrollment` table to identify its structural problems. I ran SELECT queries to see how data was stored and where repetition occurred. I then tested what happens when I try to update, insert, or delete records — each operation revealed a different type of anomaly caused by mixing multiple facts in one table.

**Code / query used:**
```sql
-- (a) Update Anomaly
SELECT COUNT(*) AS total_rows_with_D01
FROM student_enrollment
WHERE dept_id = 'D01';

-- (b) Insert Anomaly
-- Cannot insert: IT103, 'Networks', D01 — no student_id available

-- (c) Delete Anomaly
DELETE FROM student_enrollment
WHERE student_id = 101 AND course_id = 'IT102';

Output:
mysql> SELECT COUNT(*) AS total_rows_with_D01
    -> FROM student_enrollment
    -> WHERE dept_id = 'D01';
+---------------------+
| total_rows_with_D01 |
+---------------------+
|                   3 |
+---------------------+
1 row in set (0.134 sec)

mysql> DELETE FROM student_enrollment
    -> WHERE student_id = 101 AND course_id = 'IT102';
Query OK, 1 row affected (0.120 sec)

Reflection question:
Which of the three anomalies surprised you most in the seed table, and what single structural fact causes all three?

The delete anomaly surprised me most — removing one student's enrollment actually deleted the course information entirely. All three anomalies stem from the same root cause: mixing multiple entity types (student, course, department, enrollment) in a single table without unique keys.

## Task 2 - Reach First Normal Form

Approach / explanation:
To achieve 1NF, I split the multi-valued  enrolled_courses  field so each value goes into its own row. Every cell now contains exactly one atomic value. I then added a composite primary key  (student_id, course_id)  so every row can be uniquely identified.

Code / query used:

sql
CREATE TABLE student_enrollment_1nf (
  student_id INT,
  student_name VARCHAR(100),
  course_id VARCHAR(10),
  course_title VARCHAR(100),
  dept_id VARCHAR(10),
  department_name VARCHAR(100),
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_enrollment_1nf VALUES
(101, 'Ana Cruz', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.50),
(101, 'Ana Cruz', 'IT102', 'Web Development', 'D01', 'Computing Studies', 1.25),
(102, 'Ben Lim', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.75);

SELECT student_id, student_name, course_id, course_title 
FROM student_enrollment_1nf;

Output:
mysql> SELECT student_id, student_name, course_id, course_title
    -> FROM student_enrollment_1nf;
+------------+--------------+-----------+------------------+
| student_id | student_name | course_id | course_title     |
+------------+--------------+-----------+------------------+
|        101 | Ana Cruz     | IT101     | Database Systems |
|        101 | Ana Cruz     | IT102     | Web Development  |
|        102 | Ben Lim      | IT101     | Database Systems |
+------------+--------------+-----------+------------------+
3 rows in set (0.009 sec)

Reflection question:
Why does splitting the multi-valued cell still leave student names repeating, and which normal form removes that next?

Splitting only fixes multi-valued cells, not partial dependencies. Student names repeat because  student_name  depends only on  student_id  — part of the composite key. Second Normal Form (2NF) removes this by extracting student data into its own table.

## Task 3 - Reach Second Normal Form

Approach / explanation:
First I identified the functional dependencies:  student_id → student_name ,  course_id → course_title, dept_id , and  (student_id, course_id) → grade . I split the 1NF table into three tables —  students ,  courses , and  enrollments  — so each non-key column depends on the full key or the appropriate part of it. Grade stays in enrollments because it depends on both student and course together.

Code / query used:

sql
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100)
);
INSERT INTO students VALUES (101, 'Ana Cruz'), (102, 'Ben Lim');

CREATE TABLE courses (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100),
  dept_id VARCHAR(10)
);
INSERT INTO courses VALUES ('IT101', 'Database Systems', 'D01'), ('IT102', 'Web Development', 'D01');

CREATE TABLE enrollments (
  student_id INT,
  course_id VARCHAR(10),
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO enrollments VALUES (101, 'IT101', 1.50), (101, 'IT102', 1.25), (102, 'IT101', 1.75);

SELECT s.student_name, c.course_title, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

Output:
mysql> SELECT
    ->   s.student_name,
    ->   c.course_title,
    ->   e.grade
    -> FROM enrollments e
    -> JOIN students s ON e.student_id = s.student_id
    -> JOIN courses c ON e.course_id = c.course_id;
+--------------+------------------+-------+
| student_name | course_title     | grade |
+--------------+------------------+-------+
| Ana Cruz     | Database Systems |  1.50 |
| Ana Cruz     | Web Development  |  1.25 |
| Ben Lim      | Database Systems |  1.75 |
+--------------+------------------+-------+
3 rows in set (0.094 sec)

Reflection question:
How do you tell that student name depends on part of the key while grade depends on the whole key?

One student ID always gives the same name - student_id → student_name . But a grade changes if either student or course changes - you need BOTH  student_id + course_id  to know the grade, so it depends on the whole key.

## Task 4 - Reach Third Normal Form

Approach / explanation:
I noticed that  department_name  doesn't depend on the primary key - it depends on  dept_id , which itself is a non-key attribute. This is a transitive dependency:  course_id → dept_id → department_name . I created a separate  departments  table and kept only  dept_id  inside courses as a foreign key reference. Finally I ran a 4-table JOIN to confirm all original information can still be reconstructed.

Code / query used:

sql
CREATE TABLE departments (
  dept_id VARCHAR(10) PRIMARY KEY,
  department_name VARCHAR(100)
);
INSERT INTO departments VALUES ('D01', 'Computing Studies');

ALTER TABLE courses ADD FOREIGN KEY (dept_id) REFERENCES departments(dept_id);

SELECT s.student_name, c.course_title, d.department_name, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON c.dept_id = d.dept_id;

Output:
mysql> SELECT
    ->   s.student_name,
    ->   c.course_title,
    ->   d.department_name,
    ->   e.grade
    -> FROM enrollments e
    -> JOIN students s ON e.student_id = s.student_id
    -> JOIN courses c ON e.course_id = c.course_id
    -> JOIN departments d ON c.dept_id = d.dept_id;
+--------------+------------------+-------------------+-------+
| student_name | course_title     | department_name   | grade |
+--------------+------------------+-------------------+-------+
| Ana Cruz     | Database Systems | Computing Studies |  1.50 |
| Ana Cruz     | Web Development  | Computing Studies |  1.25 |
| Ben Lim      | Database Systems | Computing Studies |  1.75 |
+--------------+------------------+-------------------+-------+
3 rows in set (0.047 sec)

Reflection question:
What makes the department name indirectly dependent, and how does the final four-table join prove nothing was lost?
 
Department name depends on dept_id, not directly on course_id - that's the indirect/transitive link. The 4-table JOIN returns every column and every row exactly like the original table, which proves all original data is preserved despite splitting everything apart.
 
Normalization Decision Path - Per Table Verdict:
 
- students: Multi-value? NO | Partial? NO | Transitive? NO >> 3NF ✅
- departments: Multi-value? NO | Partial? NO | Transitive? NO >> 3NF ✅
- courses: Multi-value? NO | Partial? NO | Transitive? NO >> 3NF ✅
- enrollments: Multi-value? NO | Partial? NO | Transitive? NO >> 3NF ✅

## Task 5 - Reflection

Approach / explanation:
Normalization isn't always the final answer - sometimes controlled redundancy is actually better for performance. I thought about when to stop normalizing and what trade-offs exist. I also noted one common mistake I made while working through the tasks - confusing what belongs in a table versus what should be referenced.

Reflection question:
When would you keep some denormalized repetition on purpose, and what single symptom tells you a split dropped a key?

When to denormalize on purpose: In read-heavy reporting systems where performance matters more than instant consistency. For example, a student transcript report — denormalizing names and titles means fewer JOINs and faster queries. The trade-off: you accept that updates must happen in sync across copies, and you accept a small risk of inconsistency in exchange for speed.

One mistake I made: Early on, I forgot to carry the foreign key constraint when creating the courses table - I had dept_id in the table but no link back to departments. The symptom: I could enter a dept_id that didn't exist anywhere, and the JOIN wouldn't work properly. I fixed it by adding  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)  so the link is always enforced.

Self-Check
 
All tasks committed with individual, meaningful commit messages
All files placed inside  week11/ 
This file completed and renamed  answers.md 
Repository link pasted into Moodle
