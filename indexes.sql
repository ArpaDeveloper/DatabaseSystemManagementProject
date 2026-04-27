-- Foreign key indexes
-- These optimize lookups when joining tables through foreign keys
CREATE INDEX idx_customer_lid ON Customer(LID);
CREATE INDEX idx_department_lid ON Department(LID);
CREATE INDEX idx_project_cid ON Project(CID);
CREATE INDEX idx_employee_depid ON Employee(DepID);

-- Associative tables (M:N relationships)
-- Improve performance for queries filtering by employee or project/role/group
CREATE INDEX idx_works_empid ON Works(EmpID);
CREATE INDEX idx_works_prid ON Works(PrID);

CREATE INDEX idx_partof_empid ON PartOf(EmpID);
CREATE INDEX idx_partof_grid ON PartOf(GrID);

CREATE INDEX idx_has_empid ON Has(EmpID);
CREATE INDEX idx_has_roleid ON Has(RoleID);

-- Trigger optimization
-- Frequently used in trigger filters for project status checks
CREATE INDEX idx_project_status ON Project(Status);
