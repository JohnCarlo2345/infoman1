# INFOMAN1 Week 13 - F1 Connected Foundation

## MYSQL QUERY RESULTS SHOWN IN DEMONSTRATION

1. **SELECT * FROM table_1;**

+----+----------+
| id | field    |
+----+----------+
|  1 | Record 1 |
|  2 | Record 2 |
+----+----------+

2. **SELECT * FROM table_2;**

+----+------------+----------+
| id | table_1_id | field    |
+----+------------+----------+
|  1 |          1 | Record A |
|  2 |          2 | Record B |
+----+------------+----------+

3. **SELECT * FROM table_3;**

+----+------------+----------+
| id | table_2_id | field    |
+----+------------+----------+
|  1 |          1 | Record X |
|  2 |          2 | Record Y |
+----+------------+----------+

4. **SELECT * FROM vw_summary_report;**

+-------+----------+-------+----------+-------+----------+
| t1_id | t1_field | t2_id | t2_field | t3_id | t3_field |
+-------+----------+-------+----------+-------+----------+
|     1 | Record 1 |     1 | Record A |     1 | Record X |
|     2 | Record 2 |     2 | Record B |     2 | Record Y |
+-------+----------+-------+----------+-------+----------+

### CHANGE LOG
1. Created the project database
2. Created the three domain tables with foreign key constraints
3. Inserted seed / sample test data
4. Created the join SQL VIEW `vw_summary_report`
5. Ran and verified all SELECT query outputs
