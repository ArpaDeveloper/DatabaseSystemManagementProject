-- Step 1: Create Roles
CREATE ROLE project_manager;
CREATE ROLE readonly_staff;
CREATE ROLE db_superuser;

-- Step 2: Grant privileges to roles
-- Project managers can read everything and modify projects or works
GRANT SELECT ON ALL TABLES IN SCHEMA public TO project_manager;
GRANT INSERT, UPDATE, DELETE ON Project, Works TO project_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO project_manager;

-- Readonly staff can only read
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_staff;

-- Superuser can do everything
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_superuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO db_superuser;

-- Step 3: Create users and assign roles
CREATE USER marci_pm WITH PASSWORD 'DD26_pm';
CREATE USER arpa_staff WITH PASSWORD 'ketchup_on_everything';
CREATE USER cristi_superuser WITH PASSWORD 'super_password123';
GRANT db_superuser TO cristi_superuser;

GRANT project_manager TO marci_pm;
GRANT readonly_staff TO arpa_staff;

--------------------------------------------------------------
-- AUTHORIZED ACCESS
--------------------------------------------------------------

-- Marci (project_manager) successfully reads projects
SET ROLE marci_pm;
SELECT Name, Status, Budget FROM Project;

-- Marci successfully updates a project
UPDATE Project SET Status = 'Ongoing' WHERE Name = 'Global Tech Website';

-- Arpa (readonly_staff) successfully reads employees
SET ROLE arpa_staff;
SELECT Name, Email FROM Employee;

---------------------------------------------------------------
-- UNAUTHORIZED ACCESS (these will raise errors)
---------------------------------------------------------------

-- Arpa tries to update a project -> EXPECTED: permission denied
SET ROLE arpa_staff;
UPDATE Project SET Status = 'Cancelled' WHERE PrID = 1;

-- Arpa tries to delete an employee -> EXPECTED: permission denied
DELETE FROM Employee WHERE EmpID = 1;

-- Marci tries to delete an employee (not in his privileges) -> EXPECTED: permission denied
SET ROLE marci_pm;
DELETE FROM Employee WHERE EmpID = 1;

-- Cristi can do everything -> read, write, delete
SET ROLE cristi_superuser;

SELECT Name, Status, Budget FROM Project;

INSERT INTO Project (Name, Budget, CID, startDate, deadline, Status)
VALUES ('Cristi Test Project', 99000.00::money, 1, '2026-05-01', '2027-01-01', 'Planned');

UPDATE Project SET Status = 'Ongoing' WHERE Name = 'Cristi Test Project';

DELETE FROM Project WHERE Name = 'Cristi Test Project';

-- Reset to superuser/session owner
RESET ROLE;
