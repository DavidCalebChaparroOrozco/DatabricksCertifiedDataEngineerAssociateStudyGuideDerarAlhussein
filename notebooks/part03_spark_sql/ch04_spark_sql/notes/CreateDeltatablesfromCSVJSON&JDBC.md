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

---

## Create table from `JDBC`
Connect to external database

```SQL
CREATE TABLE jdbc_clients
USING JDBC
OPTIONS (
    url 'jdbc:postgresql://host:5432/bd',
    dbtable 'public.customers',
    user 'user',
    password 'secret',
    driver 'org.postgresql.Driver'
)

-- Query remote data
SELECT id, name, country
FROM jdbc_clients
WHERE country = 'España'
LIMIT 5;
```

- **url:** JDBC connection string with host, port, and database name.
- **dbtable:** Remote table or view. This can also be a subquery in parentheses.
- **user / password:** Access credentials. In production, this is Databricks Secrets.
- **driver:** Java class of the JDBC driver (must be available in the cluster's classpath).

---

## CTAS vs USING
Materialization vs Access Definition

### CTAS (Materialization)
Executes the `SELECT` statement, copies the data, and saves it as a permanent Delta table.

- Data resides in Delta Lake
- Snapshot at creation time
- ACID, history, time travel
- Source-independent

> Ideal when you want proprietary, auditable, and consistent data

### USING (Access Definition)
Defines how to read the external source. Data is NOT copied; it is accessed on each query.

- Data remains in the source
- Real-time reading
- No Delta history
- Source-dependent

> Ideal when you need direct access without data duplication

---

## Why Does Delta Matter?

A Comparison of 7 Key Aspects

Delta Lake vs. External Tables (USING): Impact on Data Quality, Performance, and Governance

## Delta Lake vs External Tables (USING)

| Aspect                     | Delta Lake Tables (CTAS)                             | External Tables (USING)                     | Impact on Data Quality, Performance & Governance |
|--------------------------|-----------------------------------------------|--------------------------------------------|--------------------------------------------------|
| **Storage Format**        | Delta format (Parquet + transaction log)      | Raw formats (Parquet, CSV, JSON, etc.)     | Delta ensures consistency via transaction logs; external formats lack built-in guarantees |
| **ACID Transactions**     | Fully supported                               | Not supported                              | Delta prevents partial writes and corruption, improving data reliability |
| **Schema Enforcement**    | Enforced (optional evolution)                 | Weak or none                               | Delta reduces schema drift and data inconsistencies |
| **Time Travel**           | Supported (versioning & rollback)             | Not available                              | Enables auditability, debugging, and reproducibility |
| **Performance Optimization** | Built-in (Z-Order, OPTIMIZE, caching)      | Limited (depends on format & partitioning) | Delta improves query speed and scalability significantly |
| **Data Governance**       | Strong (audit logs, version history)          | Limited                                    | Delta provides better traceability and control |
| **Upserts / Deletes**     | Native support (MERGE, UPDATE, DELETE)        | Not supported (append-only patterns)       | Delta enables complex data pipelines and CDC use cases |

---

## Details of each aspect
Why **Delta** is the source of truth

- **Source of truth:** Delta owns the data; you don't depend on the source existing or being available.
- **Consistency:** ACID transactions avoid intermediate states. You never read incomplete data.
- **Cache/performance:** The data is in managed storage. No network latency for each SELECT.
- **History and auditing:** `VERSION AS OF` and `TIMESTAMP AS OF` allow you to travel back in time to any previous version.
- **Atomicity:** An `INSERT` or `DELETE` either completes 100% or rolls back. It never leaves the system in a corrupted state.
- **Reproducibility:** The snapshot is immutable. Your analyses from yesterday on the same version return the same result.
- **Synchronization:** Only trade-off: you must update the Delta table if the source changes. Solution: Scheduled ETL pipeline

---

## The Cache Problem
Outdated External Data

![alt text](/notebooks/part03_spark_sql/ch04_spark_sql/images/TheCacheProblem.png)

### Initial State
``` SQL
-- External table points to the CSV
CREATE TABLE data_ext
USING CSV
OPTIONS(
    path    '/mnt/data/file.csv',
    header  'true'
);

SELECT COUNT(*)
FROM data_ext;
-- Result: 10
```


### After updating the CSV
```SQL
-- The CSV now has 20 rows, but Spark caches the plan
SELECT COUNT(*) 
FROM data_ext;
-- It can return: 10 (cached data)

-- Solution:
REFRESH TABLE data_ext;
```

---

## The Hybrid Approach `USING + CTAS`: The Best of Both Worlds

### ✖️ The Dilemma:
- CTAS doesn't accept OPTIONS → can't read configured CSVs
- USING doesn't materialize → no ACID guarantees or history
> How to obtain both capabilities?

### The 2-Step Solution:
1. Temporary view with `USING`: Defines how to read the CSV with OPTIONS, without materializing data
2. CTAS on the view: Materializes the result as a Delta table with all guarantees
3. Result: Delta table with data from the CSV, ACID, history, and no source dependencies

## Step 1: Temporary View (Define access to the unmaterialized CSV)
```SQL
-- Create a temporary view on the CSV
CREATE OR REPLACE TEMPORARY VIEW
sales_view_csv
USING CSV
OPTIONS (
    path    '/mnt/data/sales.csv',
    header  'true',
    sep     ',',
    inferSchema 'true'
);

-- The view does NOT read data yet, it only defines the reading plan
SELECT *
FROM sales_view_csv
LIMIT 5;
```

### Lazy Evaluation
The view only defines the read plan. Data is read only when a query is executed.

### View Properties
- Exists only in the current session
- Does not persist after a cluster restart
- No data is copied to storage
- Ideal as an intermediate source

> Key: TEMPORARY VIEW = definition, not data

---

## Step 2: Materialize with CTAS (Convert the view into a Delta table)
```SQL
-- CTAS on the temporary view
CREATE TABLE sales_delta
AS SELECT *
FROM sales_view_csv;

-- Databricks internally executes:
-- 1. Reads sales.csv with OPTIONS
-- 2. Infers the schema
-- 3. Saves as Parquet/Delta
-- 4. Logs to transaction log

-- Verify result
DESCRIBE HISTORY sales_delta;
```

### What happens internally?

1. Reads sales.csv using the defined `OPTIONS`
2. ​​Infers and validates the column schema
3. Saves data as optimized Parquet files
4. Records the operation in the transaction log

### Result
- Fully managed Delta table
- Independent of the original CSV
- ACID, Time Travel, and OPTIMIZE available

---

## Hybrid Approach Comparison

Time View vs. Delta Table

Each component of the hybrid approach has a distinct and complementary role

## Hybrid Approach Comparison: Time View vs Delta Table

| Aspect                     | Time View                                           | Delta Table                                         | Role in Hybrid Architecture |
|--------------------------|-----------------------------------------------------|-----------------------------------------------------|-----------------------------|
| **Purpose**               | Logical layer for real-time or latest-state queries | Persistent, reliable storage layer                  | Separation of compute vs storage concerns |
| **Data Freshness**        | Always reflects latest data (dynamic query)         | Snapshot-based (depends on ingestion frequency)     | View = real-time access, Delta = controlled updates |
| **Storage**               | No storage (virtual)                                | Physical storage in Delta format                    | Avoids duplication while ensuring durability |
| **Performance**           | Depends on source system performance                | Optimized (caching, indexing, OPTIMIZE, Z-Order)    | Delta improves heavy workloads; views for lightweight queries |
| **Data Quality**          | No guarantees (depends on source)                   | Strong guarantees (ACID, schema enforcement)        | Delta ensures trusted datasets |
| **Governance & Auditing** | Limited (no history, no lineage persistence)        | Full support (time travel, versioning, auditability)| Delta enables compliance and traceability |
| **Use Cases**             | Exploratory queries, real-time dashboards           | BI, ML, reporting, data pipelines                   | Complementary: speed vs reliability |
