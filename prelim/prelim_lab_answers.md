## PRELIM LAB EXAM - TASK 5 ##

## PART A - What is Wrong with the Query? ##

The Given Query:

sql
SELECT name, tool_name
FROM MEMBER, TOOL
WHERE MEMBER.member_id = LOAN.member_id;

Why It Fails:

The query uses  LOAN.member_id  in the WHERE clause, but the LOAN table is NOT listed in the FROM part. MySQL cannot find the LOAN table, so it throws an error. It also does not properly connect the MEMBER, LOAN, and TOOL tables together.

## PART B - Corrected Queries ##

Query 1: Show Currently Active Loans

sql
SELECT MEMBER.name, TOOL.tool_name, LOAN.loan_date
FROM MEMBER
JOIN LOAN ON MEMBER.member_id = LOAN.member_id
JOIN TOOL ON LOAN.tool_id = TOOL.tool_id
WHERE LOAN.return_date IS NULL;


Query 2: Count Tools in Each Category

sql
SELECT CATEGORY.category_name, COUNT(TOOL.tool_id) AS total_tools
FROM CATEGORY
LEFT JOIN TOOL ON CATEGORY.category_id = TOOL.category_id
GROUP BY CATEGORY.category_name;

## PART C - Explanations ##

JOIN
JOIN connects rows from different tables by using matching columns like member_id. It lets you pull related information from multiple tables and show them together in one result.

IS NULL
IS NULL checks if a field has no value yet. We use it here to find tools that are still on loan — when return_date is empty, that means the tool has not been brought back.

GROUP BY
GROUP BY puts rows that have the same value into groups. When we use it with COUNT, it calculates totals for each group separately, such as counting how many tools belong to each category.

Foreign Key
A foreign key is a column in one table that links to the primary key of another table. It keeps related data connected and makes sure you cannot add references to things that do not exist.
