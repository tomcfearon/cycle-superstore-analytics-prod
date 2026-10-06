# Test Data Seeds

This folder contains the synthetic test data (fixtures) used to validate the data warehouse pipeline. 

**The Golden Rule:** Database integration tests seed physical `raw_*` source tables only. Do not seed `int` or `marts` tables in this suite. Those are generated automatically by running the ETL pipeline against this raw data.

**Seed File Structure**
Instead of grouping by source system, our seed files are grouped by business domain (matching our Silver layer). 
* `seed_customer.sql`
* `seed_sales.sql`
* `seed_product.sql`
* (etc.)

**How to Add a New Test Scenario**
1. **Find the domain:** Open the relevant seed file (e.g., `seed_sales.sql`).
2. **Add raw data:** Write deterministic `INSERT` statements for the raw tables involved in your scenario. Ensure parent records (e.g., Customer) are inserted before dependent records (e.g., Invoice).
3. **Write the assertion:** Create a matching validation query in the `../assertions/contracts/` folder to prove the downstream data mart built correctly.
4. **Register the assertion:** Add your new assertion file to `../run_assertions.sql`.