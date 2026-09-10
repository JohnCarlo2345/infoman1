# Lab 5 — Reflection

**Name:** John Carlo O. Valdez
**Course/Year:** BSIT-2
**Subject:** Information Management 1

## Why SELECT Statements Are Safe to Use ##
A `SELECT` statement only **reads and retrieves** data from the database. It does not modify, add, remove, or change any stored information in any way. Running it multiple times produces the same result and causes no permanent changes, so it is completely safe to use while exploring or learning about the database.

In contrast:
- **DDL (Data Definition Language)** statements such as `CREATE`, `ALTER`, and `DROP` permanently change the structure of the database — they can add or remove tables, change columns, or delete entire structures. These changes cannot be simply undone.
- **DML (Data Manipulation Language)** statements such as `INSERT`, `UPDATE`, and `DELETE` directly change the actual data stored in the tables. They can add new records, modify existing ones, or remove data entirely — and these changes are permanent unless you have a backup.

Because `SELECT` does neither of these, it is the safest type of statement to use when you are just getting to know your data.

## Task 4 — Mismatch, Effect, and Diagnosis ##
In Task 4, I wrote two queries that were almost identical:

**Working query:**
```sql
SELECT pet_name, species, birth_date
FROM pet
WHERE species = 'Cat';
