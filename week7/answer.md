## Lab 7 — SQL 3 Answers ##

**Name:** John Carlo Valdez
**Course/Year:** BSIT-2
**Date:** October 5,2026

## Task 1

SELECT first_name, last_name, major
FROM students
WHERE major IN ('Computer Science', 'Information Technology')
  AND last_name LIKE 'S%'
  AND section <> 'Online';

Explanation: Matches students in Computer Science or IT, last name starts with S, not in Online section.

## Task 2 ##

SELECT CONCAT(
  LEFT(first_name, 1), '. ',
  last_name,
  ' ($', ROUND(salary), ')'
) AS Instructor_Details
FROM instructors
LIMIT 5;

Explanation: Combines initial, last name, and rounded salary into one formatted column, shows first 5 rows.

## Task 3 ##

SELECT assignment_name,
  DATEDIFF(due_date, assigned_date) AS Days_To_Complete
FROM assignments
WHERE DATEDIFF(due_date, assigned_date) > 14
ORDER BY Days_To_Complete DESC;

Explanation: Calculates days available to complete, keeps only assignments with more than 14 days, sorts longest first.

## Task 4 ##


SELECT course_code, course_name, credits
FROM courses
WHERE course_code LIKE '%ADV%'
  AND (
    course_description IS NULL
    OR credits BETWEEN 4 AND 6
  )
ORDER BY course_name ASC;

Explanation: Finds courses with ADV in code AND either missing description or 4–6 credits. Parentheses ensure AND/OR logic works correctly. Sorted A–Z.
