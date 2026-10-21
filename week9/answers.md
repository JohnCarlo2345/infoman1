# INFOMAN1 – Week 9 Lab Answers

**Name:** John Carlo Valdez
**Student ID:** 2511004
**GitHub repo:** https://github.com/JohnCarlo2345/infoman1
**Date submitted:** October 21, 2026

## Task 1 — INNER JOIN Basics

**Approach / explanation:**
Used INNER JOIN between students and orders tables on student_id. Selected name, program, order ID, and order date, then sorted by order_id. Only students with matching orders appear in the results.

**Code / query used:**
```sql
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s
INNER JOIN orders o
ON s.student_id = o.student_id
ORDER BY o.order_id;

Output:
+--------------+---------+----------+------------+
| student_name | program | order_id | order_date |
+--------------+---------+----------+------------+
| Ana Cruz     | BSIT    |      101 | 2026-08-10 |
| Ana Cruz     | BSIT    |      102 | 2026-08-15 |
| Dan Reyes    | BSIT    |      103 | 2026-08-16 |
+--------------+---------+----------+------------+

Rows: 3

Reflection question:
Why does an INNER JOIN hide students who never ordered, and when is that exactly the behavior a sales report wants?

INNER JOIN only returns rows where matching values exist in both tables. Students without orders have no matching row in the orders table, so they are excluded automatically. This is exactly what you want for a sales report that shows only completed transactions — you don't need to see people who didn't buy anything.

## Task 2 - Finding Missing Relationships

Approach / explanation:
Used LEFT JOIN starting from the students table so every student appears, even those without orders. Query (a) shows all students; Query (b) adds IS NULL to filter for only students who have no orders.

Code / query used:

Query (a):

sql
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o
ON s.student_id = o.student_id;

Output (a):
+--------------+---------+----------+------------+
| student_name | program | order_id | order_date |
+--------------+---------+----------+------------+
| Ana Cruz     | BSIT    |      102 | 2026-08-15 |
| Ana Cruz     | BSIT    |      101 | 2026-08-10 |
| Ben Lim      | BSCS    |     NULL | NULL       |
| Cara Yu      | BSIS    |     NULL | NULL       |
| Dan Reyes    | BSIT    |      103 | 2026-08-16 |
+--------------+---------+----------+------------+

Rows: 5

Query (b):

sql
SELECT s.student_name, s.program
FROM students s
LEFT JOIN orders o
ON s.student_id = o.student_id
WHERE o.order_id IS NULL;

Output (b):
+--------------+---------+
| student_name | program |
+--------------+---------+
| Ben Lim      | BSCS    |
| Cara Yu      | BSIS    |
+--------------+---------+

Rows : 2

Reflection question:
What does NULL mean in the unmatched columns of a LEFT JOIN, and why must you test it with IS NULL instead of equals?

NULL means "no matching value exists." You can't use  = NULL  because NULL isn't equal to anything - not even another NULL. Always use  IS NULL  to check for missing matches.

## Task 3 - Four-Table Canteen Report

Approach / explanation:
Joined all four tables - students, orders, order_items, and menu_items — each with its own ON condition. Calculated line_total as quantity multiplied by price, then ordered by order_id and item_name.

Code / query used:

sql
SELECT
  s.student_name,
  s.program,
  o.order_id,
  m.item_name,
  oi.quantity,
  m.price,
  oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o
  ON s.student_id = o.student_id
INNER JOIN order_items oi
  ON o.order_id = oi.order_id
INNER JOIN menu_items m
  ON oi.menu_id = m.menu_id
ORDER BY o.order_id, m.item_name;

Output:
+--------------+---------+----------+--------------+----------+-------+------------+
| student_name | program | order_id | item_name    | quantity | price | line_total |
+--------------+---------+----------+--------------+----------+-------+------------+
| Ana Cruz     | BSIT    |      101 | Iced Tea     |        1 | 30.00 |      30.00 |
| Ana Cruz     | BSIT    |      101 | Siomai Rice  |        2 | 65.00 |     130.00 |
| Ana Cruz     | BSIT    |      102 | Burger Steak |        1 | 89.00 |      89.00 |
| Dan Reyes    | BSIT    |      103 | Siomai Rice  |        1 | 65.00 |      65.00 |
+--------------+---------+----------+--------------+----------+-------+------------+

Rows : 4

Reflection question:
Why does each JOIN in a multi-table chain need its own ON condition, and what goes wrong when two joins share one?

Each ON clause defines exactly how two tables connect — which columns match. If you share or skip one, SQL can't figure out the relationship correctly and may return way too many incorrect rows (Cartesian product) or throw an error.

## Task 4 - Aliases, Filters, and the Silent Inner Join

Approach / explanation:
Compared two versions. Version 1 uses INNER JOIN — only students with orders appear. Version 2 uses LEFT JOIN but puts the date filter in WHERE — which silently removes students without matching orders because WHERE can't compare NULL values to a date. The fix moves the date filter into the JOIN's ON clause.

Code / query used:

Version 1 — INNER JOIN:

sql
SELECT
  s.student_name,
  o.order_id,
  m.item_name,
  oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o
  ON s.student_id = o.student_id
INNER JOIN order_items oi
  ON o.order_id = oi.order_id
INNER JOIN menu_items m
  ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC;

Output — Version 1:
+--------------+----------+--------------+------------+
| student_name | order_id | item_name    | line_total |
+--------------+----------+--------------+------------+
| Dan Reyes    |      103 | Siomai Rice  |      65.00 |
| Ana Cruz     |      102 | Burger Steak |      89.00 |
| Ana Cruz     |      101 | Siomai Rice  |     130.00 |
| Ana Cruz     |      101 | Iced Tea     |      30.00 |
+--------------+----------+--------------+------------+

Rows returned: 4

Version 2 - LEFT JOIN with WHERE:

sql
SELECT
  s.student_name,
  o.order_id,
  m.item_name,
  oi.quantity * m.price AS line_total
FROM students s
LEFT JOIN orders o
  ON s.student_id = o.student_id
INNER JOIN order_items oi
  ON o.order_id = oi.order_id
INNER JOIN menu_items m
  ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC;

Output - Version 2:
+--------------+----------+--------------+------------+
| student_name | order_id | item_name    | line_total |
+--------------+----------+--------------+------------+
| Dan Reyes    |      103 | Siomai Rice  |      65.00 |
| Ana Cruz     |      102 | Burger Steak |      89.00 |
| Ana Cruz     |      101 | Siomai Rice  |     130.00 |
| Ana Cruz     |      101 | Iced Tea     |      30.00 |
+--------------+----------+--------------+------------+

Rows: 4

Reflection question:
Why does adding WHERE on the right-side table remove the NULL rows a LEFT JOIN just preserved, and where should that rule live instead?

Because  WHERE column >= date  runs after the join is done, and NULL compared to anything is unknown — so those rows get dropped. Put the filter in the ON clause instead - it filters the related rows before the join happens, so your main table rows stay visible.

## Task 5 - Reflection

Approach / explanation:
Explained the key differences between INNER JOIN and LEFT JOIN, when to use each one, and the common mistake of putting WHERE conditions on LEFT JOINed tables.

Evidence:

When working with relational databases, choosing the right join type is critical. Use INNER JOIN when you only want rows that exist in both tables — for example, generating a sales report that lists only completed orders. It automatically removes unmatched data, keeping results clean and focused. Use LEFT JOIN when you need every record from the main table regardless of matches — such as a full student roster that also shows who hasn't placed any orders yet. The most important lesson I learned is that filtering a LEFT JOIN in the WHERE clause silently converts it into INNER JOIN behavior. If you see fewer rows than expected or missing records that should be there, check your filter placement — conditions on related tables belong in the ON clause, not WHERE. This small detail changes everything about what your query actually returns.

Reflection question:
Which join would you choose for an "all students including non-buyers" roster versus a "completed sales only" report, and what single symptom would tell you that you picked the wrong one?

For all students including non-buyers: use LEFT JOIN. If you see fewer rows than total students, you picked the wrong one — you're missing people with no matches.

For completed sales only: use INNER JOIN. If you see NULL values in your order columns, you picked the wrong one — you're including people with no transactions.

Self-Check

All tasks committed with individual, meaningful commit messages
All files placed inside  week9/
This file completed and renamed  answers.md
Repository link pasted into Moodle
