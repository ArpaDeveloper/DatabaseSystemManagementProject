-- Foreign key indexes
-- These optimize lookups when joining tables through foreign keys
CREATE INDEX idx_customer_lid ON Customer(LID);
CREATE INDEX idx_department_lid ON Department(LID);
CREATE INDEX idx_project_cid ON Project(CID);
CREATE INDEX idx_employee_depid ON Employee(DepID);

-- Associative tables (M:N relationships)
-- Improve performance for queries filtering by employee or project/role/group
CREATE INDEX idx_works_empid_prid ON Works(EmpID, PrID);
CREATE INDEX idx_partof_empid_grid ON PartOf(EmpID, GrID);
CREATE INDEX idx_has_empid_roleid ON Has(EmpID, RoleID);

-- Optional reverse index (only if you query by PrID first)
CREATE INDEX idx_works_prid_empid ON Works(PrID, EmpID);

-- Status index (keep if selective / frequently filtered)
CREATE INDEX idx_project_status ON Project(Status);
