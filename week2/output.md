Task 1 — Extract Candidate Entities
 
Customer
- A customer is a person who brings one or more cars to the shop for repair. It has its own contact details and exists independently, so it qualifies as an entity rather than an attribute.
 
Car
- Each car has a model, plate number, and color, and belongs to exactly one customer. It is a distinct object with its own unique identity, so it qualifies as an entity rather than an attribute.
 
Mechanic
- A mechanic is an employee of the shop with a name and a specialty. Mechanics perform repair work and exist independently, so it qualifies as an entity rather than an attribute.
 
Service Appointment
- A service appointment is a scheduled repair event with a date and a repair note. It connects a specific car and a specific mechanic at a specific time, so it qualifies as a separate entity rather than an attribute.
 
Task 2 — Define Attributes per Entity
 
Customer
 
- Attributes: customer_id, first_name, last_name, phone_number, email, address
- Primary Key: customer_id — uniquely identifies each customer
- Domains:
- phone_number: text string in valid phone number format
- email: text string in valid email address format
 
Car
 
- Attributes: plate_number, model, color, customer_id
- Primary Key: plate_number — the license plate is naturally unique for every car
- Domains:
- plate_number: text string in license plate format
- model: text string representing car make and model
 
Mechanic
 
- Attributes: mechanic_id, name, specialty
- Primary Key: mechanic_id — uniquely identifies each mechanic
- Domains:
- name: text string for the mechanic's full name
- specialty: text string such as "Engine", "Brakes", or "Electrical"
 
Service Appointment
 
- Attributes: appointment_id, service_date, repair_note, plate_number, mechanic_id
- Primary Key: appointment_id — uniquely identifies each service visit
- Domains:
- service_date: calendar date value
- repair_note: longer text describing the work performed
 
Task 3 — Identify and Classify Relationships
 
Verb phrase: "owns / belongs to" — Customer and Car
 
- One customer can own many cars; each car belongs to exactly one customer.
- Cardinality: One-to-Many (1:N)
- Checked both directions: Customer side = 1, Car side = N
 
Verb phrase: "has / is scheduled for" — Car and Service Appointment
 
- One car can have many service appointments over time; each appointment is for exactly one car
- Cardinality: One-to-Many (1:N)
- Checked both directions: Car side = 1, Service Appointment side = N
 
Verb phrase: "performs / is performed by" — Mechanic and Service Appointment
 
- One mechanic can perform many appointments; each appointment is handled by exactly one mechanic
- Cardinality: One-to-Many (1:N)
- Checked both directions: Mechanic side = 1, Service Appointment side = N
 
Verb phrase: "services / is serviced by" — Mechanic and Car
 
- One mechanic can work on many different cars over time; one car can be serviced by many different mechanics on different visits.
- Cardinality: Many-to-Many (M:N)
- Checked both directions: Mechanic side = N, Car side = N
