# INFOMAN1 – Week 10 Lab Answers

Name: John Carlo O. Valdez
Student ID: 2511004
GitHub repo: https://github.com/JohnCarlo2345/infoman1
Date submitted: October 29, 2026

## Task 1 – Safe INSERT
**Approach / explanation:**
I used explicit column names for INSERT to avoid relying solely on table order. I added the two required products and ran SELECT statements afterward to confirm the records were saved correctly.

**Code / query used (if applicable):**
```sql
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');

SELECT * FROM products;

Output:
+------------+-----------------------+--------------+--------+----------------+--------+----------------+
| product_id | product_name          | sku          | price  | stock_quantity | status | contact_number |
+------------+-----------------------+--------------+--------+----------------+--------+----------------+
|          1 | Notebook              | NB-001       |  45.00 |            100 | Active | NULL           |
|          2 | Ballpen               | BP-001       |  15.00 |            250 | Active | NULL           |
|          3 | USB Drive             | USB-001      | 350.00 |             30 | Active | NULL           |
|          4 | Ruler                 | RL-001       |  25.00 |             80 | Active | NULL           |
|          6 | Scientific Calculator | CALC-SCI-001 | 875.00 |             20 | Active | NULL           |
|          7 | Compass               | CMP-001      | 120.00 |             50 | Active | NULL           |
|          8 | Pencil                | PEN-001      |  20.00 |            300 | Active | NULL           |
+------------+-----------------------+--------------+--------+----------------+--------+----------------+

Reflection question:
Listing target columns explicitly makes INSERT safer because it does not depend on the exact table order. Auto‑increment and default values automatically fill columns omitted by the user.

## Task 2 – UPDATE & DELETE Without Collateral Damage

Approach / explanation:
I first previewed the exact row using SELECT before executing UPDATE and DELETE. I used a WHERE condition to target only the intended record and re‑ran SELECT afterward to verify changes.

Code / query used (if applicable):

sql
SELECT * FROM products WHERE product_name = 'Scientific Calculator';

UPDATE products
SET price = 875.00
WHERE product_name = 'Scientific Calculator';

SELECT * FROM products WHERE product_name = 'Scientific Calculator';

SELECT * FROM products WHERE product_name = 'Eraser';

DELETE FROM products
WHERE product_name = 'Eraser';

SELECT * FROM products WHERE product_name = 'Eraser';

Evidence:

1. SELECT before UPDATE:
+------------+-----------------------+--------------+--------+----------------+--------+
| product_id | product_name          | sku          | price  | stock_quantity | status |
+------------+-----------------------+--------------+--------+----------------+--------+
|          6 | Scientific Calculator | CALC-SCI-001 | 850.00 |             20 | Active |
+------------+-----------------------+--------------+--------+----------------+--------+

2. UPDATE result output:
mysql> UPDATE products
    -> SET price = 875.00
    -> WHERE product_name = 'Scientific Calculator';
Query OK, 1 row affected (0.217 sec)
Rows matched: 1  Changed: 1  Warnings: 0

3. SELECT after UPDATE:
+------------+-----------------------+--------------+--------+----------------+--------+
| product_id | product_name          | sku          | price  | stock_quantity | status |
+------------+-----------------------+--------------+--------+----------------+--------+
|          6 | Scientific Calculator | CALC-SCI-001 | 875.00 |             20 | Active |
+------------+-----------------------+--------------+--------+----------------+--------+

4. SELECT before DELETE:
+------------+--------------+--------+-------+----------------+--------+
| product_id | product_name | sku    | price | stock_quantity | status |
+------------+--------------+--------+-------+----------------+--------+
|          5 | Eraser       | ER-001 | 10.00 |            200 | Active |
+------------+--------------+--------+-------+----------------+--------+

5. DELETE result output:
mysql> DELETE FROM products
    -> WHERE product_name = 'Eraser';
Query OK, 1 row affected (0.224 sec)

6. SELECT after DELETE:
mysql> SELECT * FROM products WHERE product_name = 'Eraser';
Empty set (0.008 sec)

Reflection question:
Without WHERE, UPDATE and DELETE affect every row in the whole table. A stable identifier (like product_id) is safer than a name because names can duplicate or change.

## Task 3 – Self Join & Cross Join

Approach / explanation:
I created two aliases for the employees table so MySQL could distinguish the two copies. LEFT JOIN preserved employees without managers, while CROSS JOIN intentionally generated all color‑size combinations.

Code / query used (if applicable):

sql
SELECT
  e.employee_name AS Employee,
  m.employee_name AS Manager
FROM employees e
LEFT JOIN employees m
  ON e.manager_id = m.employee_id;

SELECT
  c.color_name,
  s.size_name,
  COUNT(*) AS row_count
FROM colors c
CROSS JOIN sizes s
GROUP BY c.color_name, s.size_name;

Evidence:

1. Self‑Join result:
+-------------+-----------+
| Employee    | Manager   |
+-------------+-----------+
| Lea Ramos   | NULL      |
| Carlo Reyes | Lea Ramos |
| Dana Cruz   | Lea Ramos |
+-------------+-----------+

2. Cross‑Join result:
+------------+-----------+-----------+
| color_name | size_name | row_count |
+------------+-----------+-----------+
| Red        | L         |         1 |
| Green      | L         |         1 |
| Blue       | L         |         1 |
| Red        | M         |         1 |
| Green      | M         |         1 |
| Blue       | M         |         1 |
| Red        | S         |         1 |
| Green      | S         |         1 |
| Blue       | S         |         1 |
+------------+-----------+-----------+

Reflection question:
Self‑join needs two aliases so MySQL can tell the two copies apart. CROSS JOIN is deliberate when you need all combinations, but missing ON accidentally creates unwanted full multiplication.

## Task 4 - Constraints & Table Evolution

Approach / explanation:
I added the contact_number column first. Then I altered the table to enforce NOT NULL, UNIQUE, and CHECK rules. I tested valid and invalid inserts to show how constraints block bad data.

Code / query used:

sql
ALTER TABLE products
ADD COLUMN contact_number VARCHAR(20);

ALTER TABLE products
MODIFY COLUMN product_name VARCHAR(100) NOT NULL;

ALTER TABLE products
ADD CONSTRAINT uk_sku UNIQUE (sku);

ALTER TABLE products
ADD CONSTRAINT chk_price_positive CHECK (price > 0);

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Pencil', 'PEN-001', 20.00, 300, 'Active');

INSERT INTO products (sku, price, stock_quantity, status)
VALUES ('TEST-001', 10, 50, 'Active');

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Pen2', 'PEN-001', 15, 40, 'Active');

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('BadItem', 'BAD-001', -5, 10, 'Active');

DESCRIBE products;

Evidence:

1. ADD COLUMN output:
mysql> ALTER TABLE products
    -> ADD COLUMN contact_number VARCHAR(20);
Query OK, 0 rows affected (0.626 sec)
Records: 0  Duplicates: 0  Warnings: 0

2. MODIFY NOT NULL output:
mysql> ALTER TABLE products
    -> MODIFY COLUMN product_name VARCHAR(100) NOT NULL;
Query OK, 0 rows affected (1.998 sec)
Records: 0  Duplicates: 0  Warnings: 0

3. ADD UNIQUE output:
mysql> ALTER TABLE products
    -> ADD CONSTRAINT uk_sku UNIQUE (sku);
Query OK, 0 rows affected (0.685 sec)
Records: 0  Duplicates: 0  Warnings: 0

4. ADD CHECK output:
mysql> ALTER TABLE products
    -> ADD CONSTRAINT chk_price_positive CHECK (price > 0);
Query OK, 6 rows affected (1.981 sec)
Records: 6  Duplicates: 0  Warnings: 0

5. Valid INSERT output:
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Pencil', 'PEN-001', 20.00, 300, 'Active');
Query OK, 1 row affected (0.165 sec)

6. Invalid Insert #1 error:
mysql> INSERT INTO products (sku, price, stock_quantity, status)
    -> VALUES ('TEST-001', 10, 50, 'Active');
ERROR 1364 (HY000): Field 'product_name' doesn't have a default value

7. Invalid Insert #2 error:
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Pen2', 'PEN-001', 15, 40, 'Active');
ERROR 1062 (23000): Duplicate entry 'PEN-001' for key 'products.uk_sku'

8. Invalid Insert #3 error:
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('BadItem', 'BAD-001', -5, 10, 'Active');
ERROR 3819 (HY000): Check constraint 'chk_price_positive' is violated.

9. DESCRIBE products output:
+----------------+---------------+------+-----+---------+----------------+
| Field          | Type          | Null | Key | Default | Extra          |
+----------------+---------------+------+-----+---------+----------------+
| product_id     | int           | NO   | PRI | NULL    | auto_increment |
| product_name   | varchar(100)  | NO   |     | NULL    |                |
| sku            | varchar(30)   | YES  | UNI | NULL    |                |
| price          | decimal(10,2) | YES  |     | NULL    |                |
| stock_quantity | int           | YES  |     | NULL    |                |
| status         | varchar(20)   | YES  |     | NULL    |                |
| contact_number | varchar(20)   | YES  |     | NULL    |                |
+----------------+---------------+------+-----+---------+----------------+

Reflection question:
Constraints block future bad writes only after existing invalid rows are fixed. Before adding NOT NULL, you must first fill empty values or change those rows so no NULL remains.

## Task 5 - Reflection

Approach / explanation:
This lab taught me the difference between application‑level validation and database‑level integrity for a bookstore database. I learned that careful INSERT, UPDATE, DELETE, and JOIN practices prevent accidental data loss or messy results.

(150‑200 Word Reflection):
When managing bookstore records, I trust application forms first because they give users immediate feedback before data reaches the database. However, database constraints such as NOT NULL, UNIQUE, and CHECK act as the final safety net. From Task 2, I realized how dangerous forgetting the WHERE clause can be; one mistake could update or delete every product at once. Task 3 showed that missing JOIN conditions create accidental cross joins that multiply rows unnecessarily. Task 4 proved that constraints reject invalid entries like negative prices or duplicate SKUs automatically. A clear sign I trusted the wrong layer is when bad data still successfully saves into the table. Application validation guides users, while database constraints protect permanent truth. Both layers must work together so the bookstore database stays clean, accurate, and safe over time.

Reflection question:
I trust application forms for real‑time user validation, but database constraints for permanent integrity. The symptom that the wrong layer is trusted is when invalid data successfully enters the database.

Self‑Check

All tasks committed with individual, meaningful commit messages
All files placed inside  week10/
This file completed and renamed  answers.md
Repository link pasted into Moodle (no files uploaded)
