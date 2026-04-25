# Create Delta tables from CSV, JSON & JDBC

## What is CTAS? `CREATE TABLE AS SELECT`

```SQL
-- Create a Delta table from a SELECT query
CREATE TABLE my_delta_table AS 
SELECT *
FROM another_table
WHERE year = 2026;
```

### What does CTAS do?

It executes a `SELECT` statement and persists its result as a new table, in a single SQL statement.

### Benefits
- Concise syntax, a single statement
- Automatically inherits the schema
- Reproducible and declarative
- In Databricks: Delta by default

---

## CTAS in Databricks (`Delta Lake` by default)

### Every CTAS creates a Delta table. 
You don't need to specify the format; Delta Lake is the default storage engine.

**Managed Table**
Databricks manages both the schema and physical storage.

- **Atomicity:** All or nothing
- **Consistency:** Valid state always
- **Isolation:** Concurrent transactions
- **Durability:** Persistent data

**Transaction Log**
Every operation is logged in the Delta Lake log.

---

## Managed Tables and Unity Catalog

- Controlled lifecycle: When a managed table is deleted, Databricks also deletes the physical data. No orphaned data.

- Unity Catalog: Centralized governance: permissions, lineage, auditing, and a unified catalog for all workspaces.

## Predictive Optimization `New`
- Automatic `OPTIMIZE`, no manual intervention
- Intelligent `VACUUM`, cleans up obsolete files
- Continuously updated column statistics
- Lower latency in analytical queries

---

