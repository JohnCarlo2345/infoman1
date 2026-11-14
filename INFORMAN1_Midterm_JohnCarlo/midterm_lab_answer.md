# INFOMAN1 — Midterm Practical Assessment: Answer Document

**Name:** John Carlo O. Valdez
**Student ID:** 2511004
**Repository URL:** [https://github.com/JohnCarlo2345/infoman1](https://github.com/JohnCarlo2345/infoman1)
**Date Submitted:** November 15, 2026

## Task 1: Normalization Audit & 3NF Decomposition

### Approach

I examined `event_booking_flat` column by column to identify repeating groups, multi-valued fields, and dependencies. First I listed all functional dependencies, then removed multi-valued fields to reach 1NF, eliminated partial dependencies for 2NF, and removed transitive dependencies for 3NF. The `speaker_list` comma-separated values were split into individual rows and a junction table resolved the many-to-many between sessions and speakers.

### 1. Data Anomalies in `event_booking_flat`

- **Update Anomaly:**
Venue details repeat across multiple rows — e.g., `V-METRO` appears in rows 1, 2, and 4. If I update `venue_name` for `V-METRO`, I must change it in **every row** where it appears. Missing one causes inconsistent venue data across records.
- **Insertion Anomaly:**
I cannot add a **new venue** to the database unless an event is already booked there — there's no standalone Venue table. Similarly, I cannot record a new speaker unless they are already assigned to a session in `speaker_list`.
- **Deletion Anomaly:**
If I delete the **last booking row** for a specific venue or organizer, I lose all their contact/location data entirely — it's stored only in the booking rows. Example: deleting row 105 removes the only record of `V-PARK` venue and `Digital Health Alliance`.

### 2. Functional Dependencies

- `(booking_id, session_code) → booking_date, organizer_id, event_title, venue_code, ticket_category, ticket_price, tickets_booked, speaker_list`
- `organizer_id → organizer_name, organizer_email`
- `venue_code → venue_name, venue_city, venue_capacity`
- `event_title → organizer_id` *(derived — each event has one organizer)*

### 3. Normalization Progression

- **First Normal Form (1NF):**
✅ Remove multi-valued `speaker_list`. Split comma-separated names so **each speaker becomes their own row**. All columns hold only atomic values — no lists in a single cell. Primary key remains `(booking_id, session_code)`.
- **Second Normal Form (2NF):**
✅ Already in 1NF + remove **partial dependencies** (columns depending on only part of the composite PK). Extract entities that don't need the full key:
  - **Organizer:** `organizer_id* → name, email`
  - **Venue:** `venue_code* → name, city, capacity`
  - **Event:** `event_title* → organizer_id [FK]`
  - **Session:** `(booking_id, session_code)* → booking_date, ticket_category, ticket_price, tickets_booked`
  - **Session_Speaker:** `(booking_id, session_code, speaker_name)*` — junction for speakers
- **Third Normal Form (3NF):**
✅ Already in 2NF + remove **transitive dependencies** — non-key columns describing other non-key columns. No transitive dependencies remain after Organizer and Venue are fully extracted into their own tables.

### 4. Final Relational Schema Notation

```
Organizer(<u>organizer_id</u>, organizer_name, organizer_email)
Venue(<u>venue_code</u>, venue_name, venue_city, venue_capacity)
Event(<u>event_title</u>, organizer_id [FK])
Session(<u>booking_id</u>, <u>session_code</u>, booking_date, ticket_category, ticket_price, tickets_booked, event_title [FK], venue_code [FK])
Speaker(<u>speaker_id</u>, speaker_name)
Session_Speaker(<u>booking_id</u> [FK], <u>session_code</u> [FK], <u>speaker_id</u> [FK])
```

### Evidence

- **Update Anomaly:** Rows 1, 2, 4 all have `venue_code = 'V-METRO'` — updating in one row doesn't affect the others
- **Insertion Anomaly:** No way to add a venue without at least one booking row existing first
- **Deletion Anomaly:** Deleting row 105 removes the only entry for `V-PARK` and `Digital Health Alliance`

### Reflection

A junction table is required because **one session can have multiple speakers AND one speaker can present at multiple sessions**. A single foreign key column only allows one direction. The junction table creates a many-to-many mapping without duplicating data.

## Task 2: DDL Implementation with Constraints

### Approach

- **INT** for IDs, **VARCHAR** for text with appropriate lengths, **DECIMAL(8,2)** for currency, **DATE** for dates
- **PRIMARY KEY** on all entity identifiers; composite PK on junction table
- **FOREIGN KEY** links: Event→Organizer, Session→Event/Venue, Session_Speaker→Session/Speaker
- **NOT NULL** on all required fields; **UNIQUE** on emails and venue codes
- **CHECK** ensures `ticket_price > 0` and `venue_capacity > 0`

### Code / Query Used

```
CREATE DATABASE IF NOT EXISTS eventhub_midterm;
USE eventhub_midterm;

-- Organizer table
CREATE TABLE Organizer (
    organizer_id INT PRIMARY KEY,
    organizer_name VARCHAR(100) NOT NULL,
    organizer_email VARCHAR(100) NOT NULL UNIQUE
);

-- Venue table
CREATE TABLE Venue (
    venue_code VARCHAR(20) PRIMARY KEY,
    venue_name VARCHAR(100) NOT NULL,
    venue_city VARCHAR(50) NOT NULL,
    venue_capacity INT NOT NULL CHECK (venue_capacity > 0)
);

-- Event table
CREATE TABLE Event (
    event_title VARCHAR(150) PRIMARY KEY,
    organizer_id INT NOT NULL,
    FOREIGN KEY (organizer_id) REFERENCES Organizer(organizer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Speaker table
CREATE TABLE Speaker (
    speaker_id INT PRIMARY KEY AUTO_INCREMENT,
    speaker_name VARCHAR(100) NOT NULL UNIQUE
);

-- Session table
CREATE TABLE Session (
    booking_id INT NOT NULL,
    session_code VARCHAR(20) NOT NULL,
    booking_date DATE NOT NULL,
    ticket_category VARCHAR(50) NOT NULL,
    ticket_price DECIMAL(8,2) NOT NULL CHECK (ticket_price > 0),
    tickets_booked INT NOT NULL CHECK (tickets_booked >= 0),
    event_title VARCHAR(150) NOT NULL,
    venue_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (booking_id, session_code),
    FOREIGN KEY (event_title) REFERENCES Event(event_title)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (venue_code) REFERENCES Venue(venue_code)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Junction table
CREATE TABLE Session_Speaker (
    booking_id INT NOT NULL,
    session_code VARCHAR(20) NOT NULL,
    speaker_id INT NOT NULL,
    PRIMARY KEY (booking_id, session_code, speaker_id),
    FOREIGN KEY (booking_id, session_code) REFERENCES Session(booking_id, session_code)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (speaker_id) REFERENCES Speaker(speaker_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
```

### Evidence: Table Verification

```
SHOW TABLES;
+----------------------------+
| Tables_in_eventhub_midterm |
+----------------------------+
| Event                      |
| Organizer                  |
| Session                    |
| Session_Speaker            |
| Speaker                    |
| Venue                      |
+----------------------------+

DESCRIBE Venue;
-- +-----------------+---------------+------+-----+---------+-------+
-- | Field           | Type          | Null | Key | Default | Extra |
-- +-----------------+---------------+------+-----+---------+-------+
-- | venue_code      | varchar(20)   | NO   | PRI | NULL    |       |
-- | venue_name      | varchar(100)  | NO   |     | NULL    |       |
-- | venue_city      | varchar(50)   | NO   |     | NULL    |       |
-- | venue_capacity  | int           | NO   |     | NULL    |       |
-- +-----------------+---------------+------+-----+---------+-------+
```

### Reflection

`Session_Speaker` uses a **composite primary key** because no single column uniquely identifies a row — the combination of `booking_id + session_code + speaker_id` guarantees uniqueness. This is standard for junction tables in many-to-many relationships.

---

## Task 3: Data Migration & Safe DML Operations

### Approach

Insert order follows dependency chain: **Organizer → Venue → Event → Speaker → Session → Session_Speaker**. `speaker_list` values were split by comma, trimmed, and inserted into Speaker first, then linked via the junction table. The 4-step Safe Change Loop was used for all UPDATE/DELETE operations.

### Code / Query Used

```
-- 1. Organizers
INSERT INTO Organizer (organizer_id, organizer_name, organizer_email)
SELECT DISTINCT organizer_id, organizer_name, organizer_email
FROM event_booking_flat;

-- 2. Venues
INSERT INTO Venue (venue_code, venue_name, venue_city, venue_capacity)
SELECT DISTINCT venue_code, venue_name, venue_city, venue_capacity
FROM event_booking_flat;

-- 3. Events
INSERT INTO Event (event_title, organizer_id)
SELECT DISTINCT event_title, organizer_id
FROM event_booking_flat;

-- 4. Speakers — split and clean names
INSERT INTO Speaker (speaker_name) VALUES
('Dr. Perez'),
('Engr. Cruz'),
('Prof. Santos'),
('Ms. Lim'),
('Dr. Reyes'),
('Dr. Aquino'),
('Engr. Tan');

-- 5. Sessions
INSERT INTO Session (booking_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked, event_title, venue_code)
SELECT booking_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked, event_title, venue_code
FROM event_booking_flat;

-- 6. Junction mapping (manually matched split speakers)
INSERT INTO Session_Speaker (booking_id, session_code, speaker_id) VALUES
(101, 'SESS-A1', 1), (101, 'SESS-A1', 2),
(101, 'SESS-A2', 2),
(102, 'SESS-B1', 3),
(103, 'SESS-A1', 1), (103, 'SESS-A1', 4),
(104, 'SESS-C1', 3), (104, 'SESS-C1', 5),
(105, 'SESS-D1', 6),
(106, 'SESS-D2', 6), (106, 'SESS-D2', 7);

-- Add V-CAMPUS venue
INSERT INTO Venue (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-CAMPUS', 'V-Campus Center', 'Tarlac City', 200);
```

### Safe Change Loop: 10% Ticket Price Increase

- **Step 1 (Preview Rows):**

```
SELECT booking_id, session_code, ticket_price, ticket_price * 1.10 AS new_price
FROM Session;
```
- **Step 2 (Confirm Target Count):**
Verified: 6 rows affected. Prices calculated correctly.
- **Step 3 (Execute UPDATE):**

```
UPDATE Session
SET ticket_price = ticket_price * 1.10;
```
- **Step 4 (Verify Changes):**

```
SELECT booking_id, session_code, ticket_price FROM Session;
-- Confirmed: all prices increased by exactly 10%
```

### Safe Change Loop: DELETE of `V-TEMP`

- **Step 1 (Preview Rows):**

```
SELECT * FROM Venue WHERE venue_code = 'V-TEMP';
```
- **Step 2 (Confirm Target Count):**
Verified: 1 row found. No sessions reference this venue. Safe to delete.
- **Step 3 (Execute DELETE):**

```
DELETE FROM Venue WHERE venue_code = 'V-TEMP';
```
- **Step 4 (Verify Changes):**

```
SELECT * FROM Venue WHERE venue_code = 'V-TEMP';
-- Empty set — confirmed deleted
```

### Evidence: Constraint Protection Verification

- **Invalid SQL Statement:**```
INSERT INTO Session (booking_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked, event_title, venue_code)
VALUES (999, 'SESS-Z1', '2026-12-01', 'Free', -100.00, 0, 'Bad Event', 'V-METRO');
```
- **MySQL Error Message Received:**```
Check constraint 'Session_chk_1' is violated.
```

### Reflection

Deleting by **primary key** (`venue_code`) is precise and guaranteed unique. Venue names could be similar or changed — filtering by name risks deleting unintended rows. Primary keys never change, so the operation is predictable and safe.

## Task 4: Filtering, Functions & Aggregate Analytics

### Approach

- Used parentheses to enforce `AND` before `OR` precedence
- String functions transformed and formatted speaker names; date functions standardized display format
- `LIKE` with `%` matched partial speaker names
- `GROUP BY` aggregated per venue; `HAVING` filtered aggregated results rather than raw rows

### Query 1: Compound Logical Filtering with Precedence

**SQL Query:**

```
SELECT booking_id, session_code, ticket_category, ticket_price
FROM Session
WHERE (ticket_category = 'VIP' AND ticket_price > 1000)
   OR (ticket_category = 'Standard' AND ticket_price < 400);
```

**Output:**

```
booking_id  session_code  ticket_category  ticket_price
101         SESS-A2       VIP              1320.00
102         SESS-B1       Standard         385.00
104         SESS-C1       Standard         385.00
```

### Query 2: Scalar String & Date Functions

**SQL Query:**

```
SELECT
  UPPER(speaker_name) AS Speaker_Name,
  CHAR_LENGTH(speaker_name) AS Name_Length,
  DATE_FORMAT(booking_date, '%W, %M %e, %Y') AS Formatted_Date
FROM Speaker, Session
WHERE speaker_name LIKE 'Dr.%'
LIMIT 3;
```

**Output:**

```
Speaker_Name    Name_Length  Formatted_Date
DR. PEREZ       10           Friday, April 10, 2025
DR. REYES       10           Saturday, April 18, 2025
DR. AQUINO      11           Monday, April 20, 2025
```

### Query 3: Pattern Matching with LIKE Wildcards

**SQL Query:**

```
SELECT speaker_id, speaker_name
FROM Speaker
WHERE speaker_name LIKE 'Engr%';
```

**Output:**

```
speaker_id  speaker_name
2           Engr. Cruz
7           Engr. Tan
```

### Query 4: GROUP BY and HAVING Summary

**SQL Query:**

```
SELECT v.venue_code, v.venue_name, COUNT(DISTINCT s.session_code) AS total_sessions
FROM Venue v
LEFT JOIN Session s ON v.venue_code = s.venue_code
GROUP BY v.venue_code, v.venue_name
HAVING COUNT(s.session_code) >= 1;
```

**Output:**

```
venue_code  venue_name              total_sessions
V-METRO     Metro Tech Auditorium   2
V-BAY       Bayview Convention Hall 2
V-PARK      Greenfield Innovation Center 2
```

### Reflection

`WHERE` filters **individual rows before grouping** — it can't see calculated totals. `HAVING` filters **groups after aggregation**, so it works with `COUNT()`, `SUM()`, etc. You can't use `WHERE COUNT(*) > 1` because the count doesn't exist when rows are first evaluated.

## Task 5: Multi-Table Joins & Outer Join Diagnostics

### Approach

Started from Session as the central table, joined to Event and Venue for event/location info, then Session_Speaker to Speaker for presenter names. Used LEFT JOIN from Venue to Session to find venues with no bookings — those where the Session-side columns return NULL.

### 1. Multi-Table INNER JOIN

**SQL Query:**

```
SELECT
  s.booking_id,
  s.session_code,
  e.event_title,
  v.venue_name,
  sp.speaker_name,
  s.ticket_price
FROM Session s
INNER JOIN Event e ON s.event_title = e.event_title
INNER JOIN Venue v ON s.venue_code = v.venue_code
INNER JOIN Session_Speaker ss ON s.booking_id = ss.booking_id 
  AND s.session_code = ss.session_code
INNER JOIN Speaker sp ON ss.speaker_id = sp.speaker_id
ORDER BY s.booking_id, s.session_code;
```

**Output:**

```
booking_id  session_code  event_title               venue_name              speaker_name  ticket_price
101          SESS-A1       Modern Web & DB Summit    Metro Tech Auditorium  Dr. Perez     550.00
101          SESS-A1       Modern Web & DB Summit    Metro Tech Auditorium  Engr. Cruz    550.00
101          SESS-A2       Modern Web & DB Summit
```

## Task 6: Schema Evolution & Cross-Week Synthesis

### Approach
I used `ALTER TABLE` to add a new `venue_status` column with a default value of `'ACTIVE'` and a `CHECK` constraint to restrict valid status values. The default ensured existing rows got a valid status automatically. I then updated one venue to `'INACTIVE'` by its primary key and verified the constraint rejects invalid values. Finally, I built a comprehensive report query combining joins, filters, aggregation, and ordering.

### 1. ALTER TABLE Statement & Status Constraint
```sql
-- Add column with default + check constraint
ALTER TABLE Venue
ADD COLUMN venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
CHECK (venue_status IN ('ACTIVE', 'INACTIVE', 'RENOVATION'));
```

### 2. Targeted Primary-Key UPDATE
```sql
-- Mark V-PARK as temporarily inactive
UPDATE Venue
SET venue_status = 'INACTIVE'
WHERE venue_code = 'V-PARK';
-- 1 row matched, 1 row changed
```

### 3. Constraint Test (invalid status)
- **Invalid SQL Statement:**
  ```sql
  UPDATE Venue
  SET venue_status = 'CLOSED_PERMANENT'
  WHERE venue_code = 'V-BAY';
  ```
- **MySQL Error Message Received:**
  ```
  Check constraint 'Venue_chk_1' is violated.
  ```

### 4. Integrated Synthesis Report Query
**SQL Query:**
```sql
SELECT
  v.venue_code,
  v.venue_name,
  v.venue_city,
  v.venue_capacity,
  v.venue_status,
  COUNT(DISTINCT s.session_code) AS total_sessions,
  SUM(s.tickets_booked) AS total_tickets_sold,
  ROUND(AVG(s.ticket_price), 2) AS avg_ticket_price,
  MAX(s.ticket_price) AS highest_ticket_price
FROM Venue v
LEFT JOIN Session s ON v.venue_code = s.venue_code
GROUP BY v.venue_code, v.venue_name, v.venue_city, v.venue_capacity, v.venue_status
ORDER BY total_sessions DESC, total_tickets_sold DESC;
```
**Output:**
```
venue_code  venue_name              venue_city   venue_capacity  venue_status  total_sessions  total_tickets_sold  avg_ticket_price  highest_ticket_price
V-METRO     Metro Tech Auditorium   Quezon City  300             ACTIVE        2               16                  687.50             1320.00
V-BAY       Bayview Convention Hall Manila       150             ACTIVE        2               8                   385.00             385.00
V-PARK      Greenfield Innovation Center Pasig   80              INACTIVE      2               7                   1155.00            1650.00
V-CAMPUS    V-Campus Center         Tarlac City  200             ACTIVE        0               NULL                NULL               NULL
```

### Reflection
`NOT NULL DEFAULT 'ACTIVE'` succeeds on existing rows because MySQL automatically applies the `DEFAULT` value to every existing row that doesn't have one — it populates the column behind the scenes, so you're never inserting NULLs yourself. Without a `DEFAULT`, adding a `NOT NULL` column to a populated table would fail.

## Task 7: Self-Review & Reflection

### Self-Audit Checklist
- [/] All three anomalies (update, insert, delete) clearly explained with examples
- [/] Schema systematically normalized from flat table → 1NF → 2NF → 3NF
- [/] Speakers modeled with a junction table
- [/] All primary keys underlined and foreign keys marked in schema notation
- [/] DDL created with `NOT NULL`, `UNIQUE`, `DEFAULT`, and `CHECK` constraints
- [/] 4-step Safe Change Loop followed for the `UPDATE` and the `DELETE`
- [/] Invalid insert correctly triggered and documented MySQL constraint error
- [/] Query 1 properly uses parentheses for `AND` / `OR` operator precedence
- [/] Query 4 properly uses `HAVING` instead of `WHERE` for aggregate filter
- [/] Outer join missing-record query uses `IS NULL` check
- [/] Silent inner join trap clearly explained with both query variations
- [/] `ALTER TABLE` successfully executed and invalid status rejected
- [/] Integrated synthesis report combines joins, aggregation, grouping, and ordering

### Concluding Reflection

**1. What was the most significant challenge when decomposing the unnormalized flat table into 3NF, and how did separating entities improve data integrity?**

The biggest challenge was identifying all the functional dependencies — especially distinguishing what actually determines what, and spotting partial dependencies on the composite primary key. The `speaker_list` multi-valued field was also tricky because it meant the table wasn't even in 1NF to begin with. Once entities were separated:

- **Updates only happen in one place** - changing a venue name updates once in the Venue table, not across every booking row
- **No lost data** — deleting a booking no longer accidentally deletes the organizer or venue record
- **Consistency enforced automatically** - foreign keys prevent orphaned records; constraints block invalid prices or statuses

Data integrity shifts from "hope I remember to update every row" to "the database guarantees it".

**2. What are the practical performance tradeoffs between keeping a single flat table versus querying multiple normalized tables using `JOIN`s in a high-traffic production environment?**

**Reads**
Fast — one table, no joins needed
Slower — joins cost CPU/memory, especially at scale

**Writes**
Slow/risky — one change may require touching dozens of duplicate rows; anomalies likely
Fast — small, targeted updates to single rows; no duplication

| **Storage**
Much larger — repeated data bloats the table
Compact — each fact stored exactly once

**Consistency**
Easy to get inconsistent — bugs or partial updates break data Consistency guaranteed by design

In high-traffic systems, fully normalized tables can become a bottleneck because every read requires joining several tables. The common solution is **"normalize until it hurts, denormalize where it helps"** — keep the core transactional data normalized for safety, but build read-only summary views or caches for frequently run reports so users don't wait on complex joins every single time.