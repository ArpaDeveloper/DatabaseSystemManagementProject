

-- TABLES WITH NO DEPENDENCIES
INSERT INTO Location (Address, Country) VALUES
('101 Maple Street', 'Canada'),
('202 Oak Avenue', 'USA'),
('303 Pine Lane', 'UK'),
('404 Birch Road', 'Australia'),
('505 Cedar Blvd', 'Germany');
INSERT INTO Location (Address) VALUES ('606 Tech Square'); 

INSERT INTO UserGroup (Name) VALUES
('System Admins'),
('Project Managers'),
('Standard Staff');

INSERT INTO Role (Name) VALUES
('Senior Developer'),
('HR Specialist'),
('Marketing Executive'),
('SysAdmin');
-- TABLES WITH DEPENDENCIES
INSERT INTO Customer (Name, Email, LID) VALUES
('Global Tech', 'contact@globaltech.com', 2),
('Oceanic Airlines', 'info@oceanic.com', 4),
('Stark Industries', 'hello@stark.com', 2),
('Wayne Enterprises', 'bat@wayne.com', 1);

INSERT INTO Department (Name, LID) VALUES
('Research & Development', 2),
('Human Resources', 3),
('Sales & Marketing', 1),
('IT Support', 5);

INSERT INTO Project (Name, Budget, CID, startDate, deadline, Status) VALUES
('AI Optimization', 250000.00::money, 1, '2026-01-10', '2026-11-01', 'Ongoing'),
('Flight Tracker 2.0', 120000.00::money, 2, '2026-03-15', '2026-09-30', 'Planned'),
('Arc Reactor Upgrade', 500000.00::money, 3, '2026-02-01', '2027-02-01', 'Ongoing'),
('Wayne Tower Network', 85000.00::money, 4, '2026-04-01', '2026-08-15', 'Completed');
-- Testing the DEFAULT 'Planned' status
INSERT INTO Project (Name, Budget, CID, startDate, deadline) VALUES
('Global Tech Website', 45000.00::money, 1, '2026-05-01', '2026-07-01');

INSERT INTO Employee (Email, Name, DepID) VALUES
('alice.adams@corp.com', 'Alice Adams', 1),
('bob.baker@corp.com', 'Bob Baker', 1),
('charlie.clark@corp.com', 'Charlie Clark', 1),
('diana.doe@corp.com', 'Diana Doe', 2),
('evan.evans@corp.com', 'Evan Evans', 3),
('fiona.finn@corp.com', 'Fiona Finn', 3),
('george.gill@corp.com', 'George Gill', 4),
('hannah.hill@corp.com', 'Hannah Hill', 4);

-- MAPPING TABLES
INSERT INTO Works (EmpID, PrID, started) VALUES
(1, 1, '2026-01-10'),
(2, 1, '2026-01-15'),
(3, 3, '2026-02-01'),
(1, 3, '2026-02-15'),
(5, 5, '2026-05-01'),
(7, 4, '2026-04-01'),
(8, 4, '2026-04-05');

INSERT INTO PartOf (GrID, EmpID) VALUES
(1, 7), (1, 8),
(2, 1), (2, 5),
(3, 2), (3, 3), (3, 4), (3, 6);

INSERT INTO Has (EmpID, RoleID, Description) VALUES
(1, 1, 'Lead AI Architect'),
(2, 1, 'Backend System Integrator'),
(4, 2, 'Recruitment and Payroll'),
(5, 3, 'Client Acquisition'),
(7, 4, 'Server Maintenance');
