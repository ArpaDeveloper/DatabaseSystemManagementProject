-- Selects
-- Showing all ongoing projects, with deadline and budget (additional info may be added).
SELECT Name AS ProjectName, Budget, deadline, Status FROM Project
WHERE Status = 'Ongoing'
ORDER BY deadline ASC;
-- Show all customers with a valid email address.
SELECT CID, Name AS CustomerName, Email FROM Customer
WHERE Email LIKE '%@%';

-- Joins
-- Show all employees with their Department and Location.
SELECT e.Name AS EmployeeName, e.Email,d.Name AS Department, l.Country AS OfficeLocation FROM Employee e
JOIN Department d ON e.DepID = d.DepID
JOIN Location l ON d.LID = l.LID;
-- Show which employees are working on which project and who are the customers for that project.
SELECT e.Name AS EmployeeName, p.Name AS ProjectName, p.Status, c.Name AS ClientName FROM Employee e
JOIN Works w ON e.EmpID = w.EmpID
JOIN Project p ON w.PrID = p.PrID
JOIN Customer c ON p.CID = c.CID;

-- Show employees with their assigned tasks.
SELECT e.Name AS EmployeeName, r.Name AS RoleTitle, h.Description AS Duties FROM Employee e
JOIN Has h ON e.EmpID = h.EmpID
JOIN Role r ON h.RoleID = r.RoleID;

-- Aggregation queries
-- Show customer names, whose investment in the project was over 100K.
SELECT c.Name AS CustomerName, SUM(p.Budget) AS TotalInvestment FROM Customer c
JOIN Project p ON c.CID = p.CID
GROUP BY c.Name
HAVING SUM(p.Budget) > 100000::money;
-- Find and show departments that have at least 2 employees assigned. (number 2 is interchangeable)
SELECT d.Name AS Department, COUNT(e.EmpID) AS EmployeeCount FROM Department d
JOIN Employee e ON d.DepID = e.DepID
GROUP BY d.Name
HAVING COUNT(e.EmpID) >= 2;

-- View Creation
-- Create a view that gathers information about projects, and shows every detail about them, including the customer name.
-- Can be used with SELECT to filted for example on ongoing projects.
CREATE VIEW vw_ProjectOverview AS
SELECT p.PrID,p.Name AS ProjectName, c.Name AS CustomerName, p.Status, p.Budget, p.startDate, p.deadline FROM Project p
JOIN Customer c ON p.CID = c.CID;

-- DML Updates
-- Initiate a new project (as of the example I have used CID = 4)
INSERT INTO Project (Name, Budget, CID, startDate, deadline, Status) 
VALUES ('Batwing Navigation AI', 850000.00::money, 4, '2026-06-01', '2027-06-01', 'Planned');
-- Update 'Flight Tracker 2.0' status to ongoing.
UPDATE Project
SET Status = 'Ongoing', 
startDate = CURRENT_DATE
WHERE Name = 'Flight Tracker 2.0';
-- Remove an employee from the system based on email address
-- Because of the Delete Rule, ON CASCADE, every information connected with this employee will be deleted.
DELETE FROM Employee
WHERE Email = 'fiona.finn@corp.com';



