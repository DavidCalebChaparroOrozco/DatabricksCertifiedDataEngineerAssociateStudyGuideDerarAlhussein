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

## CTAS Limitation (Doesn't allow configuring source file options)

> CTAS doesn't support `OPTIONS`; you can't specify a separator, header, or schema when reading a CSV directly.

- ✖️ THIS DOESN'T WORK
```SQL
-- CTA does not accept OPTIONS
CREATE TABLE sale_delta
AS SELECT *
FROM csv.`/data/sales.csv`
-- There is no way to specify:
-- header = true
-- sep = ','
-- inferSchema = true
```

**Why does it fail?**
- CTAS executes `SELECT` on an already structured result.
- A raw CSV needs parsing instructions.
- Without a header or separator, the columns are incorrect.
- The inferred schema may be incorrect.

> → We need `USING + OPTIONS`

---

## The alternative: `USING + OPTIONS`
Defining external data access

- **USING:** Specifies the format, tells Spark how to read the source: CSV, JSON, JDBC, Parquet, ORC...

- **OPTIONS:** Configures the reading, passes parameters to the reader: header, sep, inferChema, url, dbtable, driver...

- **LOCATION:** Points to the source, defines the path to the file or endpoint of the external database

---

## Create Table from CSV

### `CREATE TABLE USING CSV OPTIONS`

```SQL
CREATE TABLE sales_csv
USING CSV
OPTIONS (
    path    '/mnt/data/sales.csv',
    header  'true',
    sep     ',',
    inferSchema 'true'
);

-- Verify the created table
SELECT *
FROM sales_csv
LIMIT 10;
```

- **Path:** Path to the CSV file in DBFS, S3, ADLS, or GCS.

- **header + sep:** header = true → first row as column names
sep = ',' → delimiter
- **inferSchema:** Spark reads the file and automatically infers the data types of each column.