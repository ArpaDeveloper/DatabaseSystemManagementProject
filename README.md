## How to Run the Project

To properly test the functionality of this project, execute the following files **in order**:

1. `Database_Population.sql`  
   *Creates the database schema and triggers.*

2. `database_population.sql`  
   *Populates the database with initial data.*

3. `project_queries.sql`  
   *Runs the main project queries.*

4. `trigger_tests.sql`  
   *Tests the implemented triggers.*

5. `access_control.sql`  
   *Applies access control and permissions.*

---

### Important Notes

- Ensure each script runs successfully before proceeding to the next.
- Running scripts out of order may result in errors due to missing tables, data, or permissions.
