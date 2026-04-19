--Relational Schema (Database)

-- Un-comment this for testing purposes 
-- DROP TABLE IF EXISTS Location CASCADE;
-- DROP TABLE IF EXISTS UserGroup CASCADE;
-- DROP TABLE IF EXISTS Role CASCADE;
-- DROP TABLE IF EXISTS Customer CASCADE;
-- DROP TABLE IF EXISTS Department CASCADE;
-- DROP TABLE IF EXISTS Project CASCADE;
-- DROP TABLE IF EXISTS Employee CASCADE;
-- DROP TABLE IF EXISTS Works CASCADE;
-- DROP TABLE IF EXISTS PartOf CASCADE;
-- DROP TABLE IF EXISTS Has CASCADE;

--Tables with no dependencies first
CREATE TABLE Location(
	LID INT GENERATED ALWAYS AS IDENTITY,
	Address VARCHAR(255) NOT NULL,
	Country VARCHAR(255) NOT NULL DEFAULT 'Finland',  -- DEFAULT value #1
	PRIMARY KEY(LID)
);

CREATE TABLE UserGroup(
	GrID INT GENERATED ALWAYS AS IDENTITY,
	Name VARCHAR(255) NOT NULL, -- Meaningful constraint #2: Role names must be unique
	PRIMARY KEY(GrID)
);

CREATE TABLE Role(
	RoleID INT GENERATED ALWAYS AS IDENTITY,
	Name VARCHAR(255) NOT NULL UNIQUE, -- Meaningful constraint #2: Role names must be unique
	PRIMARY KEY(RoleID)
);

--Tables relying on onther tables
CREATE TABLE Customer(
	CID INT GENERATED ALWAYS AS IDENTITY,
	Name VARCHAR(255) NOT NULL,
	Email VARCHAR(255) NOT NULL CHECK (Email LIKE '%@%'), -- CHECK constraint #1: basic email validation
	LID INT,
	PRIMARY KEY(CID),
	CONSTRAINT fk_location
		FOREIGN KEY(LID)
			REFERENCES Location(LID)
			ON UPDATE CASCADE
);

CREATE TABLE Department(
	DepID INT GENERATED ALWAYS AS IDENTITY,
	Name VARCHAR(255) NOT NULL,
	LID INT,
	PRIMARY KEY(DepID),
	CONSTRAINT fk_dept_location
		FOREIGN KEY(LID)
			REFERENCES Location(LID)
			ON UPDATE CASCADE
);

CREATE TABLE Project(
	PrID INT GENERATED ALWAYS AS IDENTITY,
	Name VARCHAR(255) NOT NULL,
	Budget MONEY NOT NULL CHECK (Budget > '0' ::MONEY),
	CID INT,
	PRIMARY KEY(PrID),
	CONSTRAINT fk_customer
		FOREIGN KEY(CID)
			REFERENCES Customer(CID)
			ON UPDATE CASCADE
);

CREATE TABLE Employee(
	EmpID INT GENERATED ALWAYS AS IDENTITY,
	Email VARCHAR(255) NOT NULL UNIQUE, -- Meaningful constraint #1: Emails must be unique
	Name VARCHAR(255) NOT NULL,
	DepID INT,
	PRIMARY KEY(EmpID),
	CONSTRAINT fk_department
		FOREIGN KEY(DepID)
			REFERENCES Department(DepID)
			ON UPDATE CASCADE
);

ALTER TABLE Project
ADD COLUMN startDate DATE,
ADD COLUMN deadline DATE,
ADD CONSTRAINT chk_project_dates CHECK (deadline > startDate),  -- CHECK if deadline is after startDate
ADD COLUMN Status VARCHAR(50) DEFAULT 'Planned', --  Added Meaningful Attribute + DEFAULT value #3
ADD CONSTRAINT chk_project_status CHECK (Status IN ('Planned', 'Ongoing', 'Completed', 'Cancelled'));

CREATE TABLE Works(
	EmpID INT,
	PrID INT,
	started DATE DEFAULT CURRENT_DATE, 
	PRIMARY KEY(EmpID,PrID),
	CONSTRAINT fk_works_emp
		FOREIGN KEY(EmpID)
		REFERENCES Employee(EmpID) ON DELETE CASCADE,
	CONSTRAINT fk_works_pr
		FOREIGN KEY(PrID)
		REFERENCES Project(PrID) ON DELETE CASCADE
);

CREATE TABLE PartOf(
	GrID INT,
	EmpID INT,
	PRIMARY KEY(GrID,EmpID),
	CONSTRAINT fk_partof_gr
		FOREIGN KEY(GrID)
		REFERENCES UserGroup(GrID) ON DELETE CASCADE,
	CONSTRAINT fk_partof_emp
		FOREIGN KEY(EmpID)
		REFERENCES Employee(EmpID) ON DELETE CASCADE
);

CREATE TABLE Has(
	EmpID INT,
	RoleID INT,
	Description TEXT,
	PRIMARY KEY(EmpID,RoleID),
	CONSTRAINT fk_has_emp
		FOREIGN KEY(EmpID)
		REFERENCES Employee(EmpID) ON DELETE CASCADE,
	CONSTRAINT fk_has_role
		FOREIGN KEY(RoleID)
		REFERENCES Role(RoleID) ON DELETE CASCADE
);

-- Trigger 1. Prevent Employee Deletion from Completed Projects. This maintains project history and audit.
CREATE OR REPLACE FUNCTION fn_prevent_emp_deletion_completed_projects()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Works w
    JOIN Project p ON w.PrID = p.PrID
    WHERE w.EmpID = OLD.EmpID AND p.Status = 'Completed'
  ) THEN
    RAISE EXCEPTION 'Cannot delete employee %. They are assigned to completed projects.', OLD.Name;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_emp_deletion_completed_projects
BEFORE DELETE ON Employee
FOR EACH ROW EXECUTE FUNCTION fn_prevent_emp_deletion_completed_projects();

-- Trigger 2. Department must have a location before employees are assigned
CREATE OR REPLACE FUNCTION fn_validate_dept_has_location()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Department WHERE DepID = NEW.DepID AND LID IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Department must have a location before assigning employees.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_dept_has_location
BEFORE INSERT ON Employee
FOR EACH ROW EXECUTE FUNCTION fn_validate_dept_has_location();


-- Trigger 3. Prevent setting a project deadline to a past date on INSERT or UPDATE.
CREATE OR REPLACE FUNCTION fn_prevent_past_deadline()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deadline IS NOT NULL AND NEW.deadline < CURRENT_DATE THEN
    RAISE EXCEPTION 'Project deadline cannot be set to a past date (%).', NEW.deadline;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_past_deadline
BEFORE INSERT OR UPDATE ON Project
FOR EACH ROW EXECUTE FUNCTION fn_prevent_past_deadline();

-- Trigger 4. Automatically set startDate to CURRENT_DATE when a project moves to 'Ongoing'.
CREATE OR REPLACE FUNCTION fn_auto_set_start_on_ongoing()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.Status = 'Ongoing' 
     AND (OLD.Status IS DISTINCT FROM 'Ongoing')
     AND NEW.startDate IS NULL THEN
    NEW.startDate := CURRENT_DATE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_set_start_on_ongoing
BEFORE UPDATE ON Project
FOR EACH ROW EXECUTE FUNCTION fn_auto_set_start_on_ongoing();

-- Trigger 5 (Bonus). Prevent an employee from being assigned to more than 3 active projects simultaneously.
-- Avoid burnout.

CREATE OR REPLACE FUNCTION fn_limit_employee_active_projects()
RETURNS TRIGGER AS $$
DECLARE
  active_count INT;
BEGIN
  SELECT COUNT(*) INTO active_count
  FROM Works w
  JOIN Project p ON w.PrID = p.PrID
  WHERE w.EmpID = NEW.EmpID
    AND p.Status IN ('Planned', 'Ongoing');

  IF active_count >= 3 THEN
    RAISE EXCEPTION 'Employee % is already assigned to 3 active projects. Remove them from one before adding more.', NEW.EmpID;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limit_employee_active_projects
BEFORE INSERT ON Works
FOR EACH ROW EXECUTE FUNCTION fn_limit_employee_active_projects();

-- Trigger 6 (Bonus). Normalize employee and customer email to lowercase on insert.
-- Mixed-case duplicates like Cristi@student.lut.fi vs cristi@student.lut.fi
-- would bypass the UNIQUE constraint and break lookups.

CREATE OR REPLACE FUNCTION fn_normalize_email_employee()
RETURNS TRIGGER AS $$
BEGIN
  NEW.Email := LOWER(NEW.Email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalize_email_employee
BEFORE INSERT OR UPDATE ON Employee
FOR EACH ROW EXECUTE FUNCTION fn_normalize_email_employee();

CREATE OR REPLACE FUNCTION fn_normalize_email_customer()
RETURNS TRIGGER AS $$
BEGIN
  NEW.Email := LOWER(NEW.Email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalize_email_customer
BEFORE INSERT OR UPDATE ON Customer
FOR EACH ROW EXECUTE FUNCTION fn_normalize_email_customer();

-- Trigger 7 (Bonus). Enforce that Works.started date is not before the project's own startDate.
-- A typo could place an employee's start before the project even existed, corrupting reporting of the project.

CREATE OR REPLACE FUNCTION fn_validate_works_started_date()
RETURNS TRIGGER AS $$
DECLARE
  proj_start DATE;
BEGIN
  SELECT startDate INTO proj_start FROM Project WHERE PrID = NEW.PrID;
  IF proj_start IS NOT NULL AND NEW.started < proj_start THEN
    RAISE EXCEPTION 'Works.started (%) cannot be before the project start date (%).', NEW.started, proj_start;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_works_started_date
BEFORE INSERT ON Works
FOR EACH ROW EXECUTE FUNCTION fn_validate_works_started_date();
