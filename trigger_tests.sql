-- TEST Trigger 1: Prevent deletion of employee assigned to a completed project.
-- Project 'Wayne Tower Network' (PrID=4) is 'Completed'. George (EmpID=7) and Hannah (EmpID=8) worked on it.
-- Hannah was already deleted by the queries block, so we test with George.
-- EXPECTED: EXCEPTION raised, George is NOT deleted.
DELETE FROM Employee WHERE Email = 'george.gill@corp.com';


-- TEST Trigger 2: Prevent inserting an employee into a department with no location.
-- First, insert a department with no LID (NULL location).
-- Then try to insert an employee into it.
-- EXPECTED: EXCEPTION raised, employee is NOT inserted.
INSERT INTO Department (Name, LID) VALUES ('Ghost Dept', NULL);
INSERT INTO Employee (Email, Name, DepID)
VALUES ('ghost.user@corp.com', 'Ghost User', 5); -- DepID=5 has no location


-- TEST Trigger 3: Prevent setting a project deadline to a past date compared to today. (2026)
-- EXPECTED: EXCEPTION raised, project is NOT inserted.
INSERT INTO Project (Name, Budget, CID, startDate, deadline, Status)
VALUES ('Backdated Project', 10000.00::money, 1, '2024-01-01', '2024-06-01', 'Planned');


-- TEST Trigger 4: Auto-set startDate when status moves to Ongoing (only if startDate is NULL).
-- Insert a project with no startDate, then update its status to Ongoing.
-- EXPECTED: startDate is automatically set to CURRENT_DATE.
INSERT INTO Project (Name, Budget, CID, deadline, Status)
VALUES ('Trigger4 Test Project', 50000.00::money, 1, '2027-12-31', 'Planned');

UPDATE Project
SET Status = 'Ongoing'
WHERE Name = 'Trigger4 Test Project';

-- Verify: startDate should now equal today's date
SELECT Name, Status, startDate FROM Project WHERE Name = 'Trigger4 Test Project';


-- TEST Trigger 5: Prevent employee from joining more than 3 active projects.
-- Alice (EmpID=1) is already on PrID=1 and PrID=3 (2 active projects).
-- Add her to a 3rd, then attempt a 4th.
INSERT INTO Works (EmpID, PrID, started) VALUES (1, 2, CURRENT_DATE); -- 3rd project, should succeed
INSERT INTO Works (EmpID, PrID, started) VALUES (1, 5, CURRENT_DATE); -- 4th project, EXPECTED: EXCEPTION


-- TEST Trigger 6: Email normalization to lowercase.
-- EXPECTED: Email stored as all lowercase regardless of input casing.
INSERT INTO Employee (Email, Name, DepID)
VALUES ('UPPERCASE.TEST@CORP.COM', 'Upper Case', 1);

SELECT Email FROM Employee WHERE Name = 'Upper Case';
-- Should return: uppercase.test@corp.com


-- TEST Trigger 7: Works.started cannot be before the project's startDate.
-- 'AI Optimization' (PrID=1) started on 2026-01-10.
-- Try to assign Bob (EmpID=2) to it with a started date before that.
-- EXPECTED: EXCEPTION raised.
INSERT INTO Works (EmpID, PrID, started)
VALUES (2, 3, '2025-12-01'); -- PrID=3 started 2026-02-01, this date is before that
