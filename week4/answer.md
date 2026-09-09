## Lab 4: Performance Task Using SQL 1 (DDL & Table Creation) ##

**Name:** John Carlo
**Course/Year:** BSIT-II
**Subject:** Information Management 1

## Task 4 — Schema Verification & Comparison ##

Table 1: owner

Week 3 Design: Regular entity, PK = owner_id, stores owner's full name, address, and contact details
Actual MySQL Structure:
- owner_id INT PRIMARY KEY AUTO_INCREMENT
- first_name VARCHAR(50) NOT NULL
- last_name VARCHAR(50) NOT NULL
- address VARCHAR(100) NOT NULL
- phone VARCHAR(20) NOT NULL
- email VARCHAR(100)
Comparison: MATCH — Matches the design exactly. Full name split into first_name and last_name. All required attributes present with correct data types and constraints.

## Table 2: pet ##

Week 3 Design: Regular entity, PK = pet_id, FK = owner_id referencing owner — one-to-many relationship from owner to pet
Actual MySQL Structure:
- pet_id INT PRIMARY KEY AUTO_INCREMENT
- name VARCHAR(50) NOT NULL
- species VARCHAR(30) NOT NULL
- breed VARCHAR(50)
- gender ENUM('Male','Female') NOT NULL
- birth_date DATE
- owner_id INT NOT NULL, FOREIGN KEY (owner_id) REFERENCES owner(owner_id) ON DELETE CASCADE
Comparison: MATCH - Matches the design exactly. Foreign key correctly established with ON DELETE CASCADE. Enforces exactly one owner per pet.

## Table 3: veterinarian ##

**Week 3 Design:** Regular entity, PK = vet_id, stores vet's name, specialty, and contact info
**Actual MySQL Structure:**
- vet_id INT PRIMARY KEY AUTO_INCREMENT
- first_name VARCHAR(50) NOT NULL
- last_name VARCHAR(50) NOT NULL
- specialization VARCHAR(50) NOT NULL
- license_number VARCHAR(30) NOT NULL UNIQUE
- phone VARCHAR(20) NOT NULL
- email VARCHAR(100)
Comparison: MATCH - Matches the design exactly. All attributes present, license_number set as UNIQUE constraint.

## Table 4: appointment ##

**Week 3 Design:** Junction table resolving many-to-many between pet and veterinarian; PK = appointment_id, FKs = pet_id + vet_id
**Actual MySQL Structure:**
- appointment_id INT PRIMARY KEY AUTO_INCREMENT
- pet_id INT NOT NULL, FOREIGN KEY (pet_id) REFERENCES pet(pet_id) ON DELETE CASCADE
- vet_id INT NOT NULL, FOREIGN KEY (vet_id) REFERENCES veterinarian(vet_id) ON DELETE CASCADE
- appointment_date DATETIME NOT NULL
- reason VARCHAR(200)
- status ENUM('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled'
Comparison: MATCH - Correctly resolves the many-to-many relationship. Both foreign keys present and NOT NULL.

## Table 5: vaccination_record ##

**Week 3 Design:** Weak entity dependent on pet; PK = record_id, FK = pet_id
**Actual MySQL Structure:**
- record_id INT PRIMARY KEY AUTO_INCREMENT
- pet_id INT NOT NULL, FOREIGN KEY (pet_id) REFERENCES pet(pet_id) ON DELETE CASCADE
- vaccine_name VARCHAR(50) NOT NULL
- vaccine_date DATE NOT NULL
- dose VARCHAR(20)
- notes TEXT
Comparison: MATCH - Correctly implemented as a weak entity. Cannot exist without a pet, deletes automatically if the pet is deleted (ON DELETE CASCADE).

## Task 4 Summary ##

All 5 tables were successfully created and verified using `SHOW TABLES` and `DESCRIBE`. Every table matches the Week 3 relational schema design. Primary keys, foreign keys, data types, and constraints are all correctly implemented. No mismatches found.

## Task 5 — Deliberate Mistake: Diagnosis & Correction ##

1. What was the mistake?
I intentionally changed the `phone` column in the `owner` table from `VARCHAR(20)` to data type **INT**. This is incorrect because phone numbers are identifiers — not numeric values. They can contain leading zeros, dashes, parentheses, and country codes that INT cannot store or preserve correctly.

2. How was the mistake revealed?
Running `DESCRIBE owner;` showed:

Field Type Null Key Default Extra
phone int YES  NULL

plaintext
The Type column showed `int`, and the Null column changed to YES — confirming the wrong data type was used.

3. How was it fixed?
```sql
-- Change the column back to the correct data type
ALTER TABLE owner MODIFY COLUMN phone VARCHAR(20) NOT NULL;

4. Corrected column definition

plaintext
phone VARCHAR(20) NOT NULL

Using VARCHAR(20) properly stores all phone number formats, including leading zeros, spaces, parentheses, and hyphens. Setting NOT NULL ensures every owner record must have a phone number.

End of Document
