## Lab: Logical ERD Modeling 2 (Logical ERD to Relational Schema) ##

## Name: John Carlo Valdez ##
## Course/year: BSIT-II ##
## Subject: Infoman1 ##

## Task 1 — Attribute Classification & Weak Entity Identification ##
 
## Attribute Classification ##
 
- Composite Attribute:  full_name  - it can be split into first_name and last_name, so it is made up of smaller parts.
- Multi-valued Attribute: None - all attributes store only one value for each record.
- Derived Attribute: None - no attribute value is calculated from other stored attributes.
 
## Weak Entity - Vaccination Record ##

Vaccination Record is a weak entity. It does not have its own unique identifier, it cannot exist without being linked to a Pet, and it depends entirely on Pet for its identity. It uses a partial key combined with the parent entity's primary key instead of having a primary key of its own.
 
## Task 2 — Cardinality & Participation ##
 
## Owner ↔ Pet ##
 
- Owner to Pet: Zero or Many — an owner may have no pets or multiple pets
- Pet to Owner: Exactly One — every pet must belong to one and only one owner
 
## Pet ↔ Appointment ##
 
- Pet to Appointment: Zero or Many — a pet may have no appointments or multiple appointments
- Appointment to Pet: Exactly One — every appointment is for one specific pet and cannot exist without a pet
 
## Veterinarian ↔ Appointment ##
 
- Veterinarian to Appointment: Zero or Many — a veterinarian may have no appointments or multiple appointments
- Appointment to Veterinarian: Exactly One — every appointment is assigned to one specific veterinarian and cannot exist without one
 
## Pet ↔ Vaccination Record ##
 
- Pet to Vaccination Record: Zero or Many — a pet may have no vaccinations or multiple vaccination records
- Vaccination Record to Pet: Exactly One — every vaccination record belongs to one pet and cannot exist on its own
 
## Task 3 — ERD Design Notes ##
 
## Entities ##
 
- Owner - regular entity, primary key: owner_id
- Pet - regular entity, primary key: pet_id, foreign key: owner_id
- Veterinarian - regular entity, primary key: vet_id
- Appointment - regular entity, primary key: appointment_id, foreign keys: pet_id, vet_id
- Vaccination_Record - weak entity, double-lined box, composite primary key: pet_id + vaccine_name, depends on Pet
 
## Relationships ##
 
- Owner and Pet - one-to-many
- Pet and Appointment - one-to-many
- Veterinarian and Appointment - one-to-many
- Pet and Vaccination Record - one-to-many, weak relationship with dashed line
