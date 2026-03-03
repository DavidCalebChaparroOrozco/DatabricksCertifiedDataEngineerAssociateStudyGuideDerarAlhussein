# Efficient storage management in a Data Lake

## What is Vacuum in Databricks?

## `VACUUM`
SQL command that removes obsolete data files from a Delta Lake table.

**Frees up space:** Removes files not referenced by the transaction log

**Maintains security:** Respects a configurable retention period (7 days by default)

**Delta Lake only:** Designed specifically for tables with the following format

---

## Delta Lake Operations and Immutable Files

### Each operation creates new files

`INSERT`
New Parquet files

`UPDATE`
Overwrites modified files

`DELETE`
Marks rows as deleted

`MERGE`
Combines inserts and updates

### Immutable Files
Parquet files in Delta Lake are NEVER modified or automatically deleted.

> Obsolete files accumulate in storage

## ACID Design and Transaction Log

### Delta Lake ACID Guarantees

- **Atomicity:** All or nothing
- **Consistency:** Always valid state
- **Isolation:** Independent transactions
- **Durability:** Changes persist

### Transaction Log `(_delta_log)`
- Records each operation as a JSON entry
- Old files are still referenced for time travel
- VACUUM removes only files that are no longer referenced

> That's why old data doesn't disappear on its own

---

## What exactly does VACUUM do?

### What it DELETES:
- Parquet files not referenced by the transaction log
- Files older than the retention period
- Data from older table versions
- Temporary files from failed operations

### What it PROTECTS:
- Files within the retention period
- Transaction log `(_delta_log)`
- Recent versions for time travel
- Data referenced by active queries

---

## Basic VACUUM Syntax
1. **Simple Command:** A single SQL line to clean the table
2. **`table_name`:** Replace with the actual name of your Delta table
3. **Execute:** In a Databricks notebook or SQL editor

``` SQL
-- Clean obsolete files from a Delta table
VACUUM table_name; 
-- Example with a real table
VACUUM sales;
```

---

## Default Retention Period

>### 7 days
> **168 hours**
> 
> _Default Retention_

 
### What does this mean?

- **Today:** VACUUM is running
- **Last 7 days:** Files are PROTECTED — Time Travel available
- **More than 7 days:** Files are DELETED by VACUUM

### Benefits
- Time Travel up to 7 days back
- Recovery from recent errors
- Balance between space and security

---

## VACUUM with Custom Retention

> Reducing retention below 7 days can prevent time travel and data recovery

### 1. Disable retention checking
```SQL
SET spark.databricks.delta
.retentionDurationCheck
.enabled = false;
```

### 2. Run VACUUM with custom retention
``` SQL
-- Retain only the last 48 hours
VACUUM sales RETAIN 48 HOURS;
```

> The minimum recommended value is 168 hours (7 days) for production environments

---

## Dropping Tables in Delta Lake

### VACUUM
Cleans up obsolete files within an existing table

### DROP TABLE
Deletes the entire table — behavior varies depending on the table type

---

## Managed Tables in Unity Catalog

### Managed Table
> Databricks controls both metadata and physical data
- **Without LOCATION** — Databricks chooses where to store the data
- **DROP TABLE** deletes metadata AND physical data
- **UNDROP TABLE** allows you to retrieve the table

### **Create a Managed Table**
```SQL
-- Managed Table (without LOCATION)
CREATE TABLE sales
USING DELTA;
```

### **Delete Table**
```SQL
DROP TABLE sales;
```

### **Retrieve Table**
```SQL
UNDROP TABLE sales;
```

---

## External Tables in Unity Catalog

### Creating an External Table
```SQL
-- External Table (with LOCATION)
CREATE TABLE sales
USING DELTA
LOCATION 's3://bucket/sales';
```

### When executing DROP TABLE sales:
- ✅Metadata removed from the catalog
- ✖️Physical data in S3 is NOT deleted
> Data remains in external storage (S3, ADLS, GCS)

### External Table
Databricks only controls metadata;

the data lives in external storage

- **LOCATION:** defines the external path
- **DROP TABLE:** does not delete the data
- Compatible with S3, ADLS, GCS

---

## Comparison: VACUUM vs DROP TABLE

| Feature | VACUUM | DROP TABLE (Managed) | DROP TABLE (External) |
|----------|---------|----------------------|------------------------|
| What does it remove? | Obsolete unreferenced files | Metadata + physical data | Metadata only |
| Does the table still exist? | ✓ Yes | ✗ No | ✗ No |
| Are physical files deleted? | Partial (outside retention period) | ✓ Yes, completely | ✗ No, files remain |
| Recoverable? | Not applicable | ✓ UNDROP TABLE | Re-register using LOCATION |
| Affects Time Travel? | Yes, limits older versions | ✗ Table removed | ✗ Table removed |
| Use case | Routine maintenance | Completely remove table | Unregister without deleting data |