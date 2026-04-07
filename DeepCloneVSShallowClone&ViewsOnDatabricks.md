# Cloning tables in Delta Lake, Time Travel, Temporary and Global Views

## Cloning in Delta Lake Tables?

### What is Cloning?

- Creates fast copies of Delta tables
- Without physically copying data (shallow cloning)
- Works with terabytes in seconds
- Ideal for testing, backups, and dataset replication

### Two Types of Cloning
- **Shallow Cloning:** Copies only the metadata, pointing to the original files
- **Deep Cloning:** Copies both metadata and data physically, creating separate tables

---

## Shallow Clone

**Creates a new table that points to the same source data files**

- Only copies the metadata
- Extremely fast, almost zero additional storage
- Depends on the original files

```SQL
CREATE TABLE sales_clone
SHALLOW CLONE sales;

-- With specific location
CREATE TABLE dev.sales_clone
SHALLOW CLONE prod.sales;
LOCATION "/mnt/dev/sales_clone";
```

![alt text](ShallowCloneExample.png)

---

## Deep Clone

**Physically copies data and metadata, creates a completely independent table**

- Copies metadata and data files
- Table independent of the source
- Slower, uses additional storage

```SQL
CREATE TABLE sales_backup
DEEP CLONE sales;

-- With specific location
CREATE TABLE sales_backup
DEEP CLONE sales
LOCATION "/mnt/dev/sales";
```

![alt text](DeepCloneExample.png)

---

| Feature                         | Shallow Clone                                      | Deep Clone                                              |
|---------------------------------|----------------------------------------------------|----------------------------------------------------------|
| Copies physical data            | ❌ No (reuses source files)                        | ✅ Yes (creates new copies of data files)                |
| Copies metadata                 | ✅ Yes                                             | ✅ Yes                                                   |
| Speed                           | ⚡ Very fast (almost instant)                      | 🐢 Slower (depends on data size)                         |
| Storage usage                   | 💾 Minimal (no extra data storage)                 | 💾 High (duplicates all data)                            |
| Independence                    | ❌ Depends on source table                         | ✅ Fully independent                                     |
| Use case                        | Quick testing, dev environments, experimentation   | Backups, migrations, long-term isolation                 |
| Risk if source is deleted       | ⚠️ High (clone breaks if data files are removed)   | ✅ None (data is stored independently)                    |


---

## Time Travel: Cloning Specific Versions

> Delta Lake maintains a version history for each table. You can clone any previous version.

### By Version Number
```SQL
CREATE TABLE sales_v10
DEEP CLONE sales
VERSION AS OF 10;
```

### By Timestamp
```SQL
CREATE TABLE sales_feb
DEEP CLONE sales
TIMESTAMP AS OF '2026-02-01';
```

- **Replay Old Datasets:** Reverts to any previous state of the data.

- **Pipeline Debugging:** Analyzes data exactly at the time of the error.

- **Data Auditing:** Regulatory compliance and traceability

---

## Real-World Uses in Data Engineering

### Pipeline Testing
Clone production to development without affecting production data.
```SQL
CREATE TABLE dev.sales_test
SHALLOW CLONE prod.sales;
```

### Rapid Backup
Complete and independent snapshot before critical transformations.
```SQL
CREATE TABLE
sales_backup_20260401
DEEP CLONE sales;
```

### Error Reproduction
Restore the data to the exact state at the time the error occurred.
```SQL
CREATE TABLE sales_debug
DEEP CLONE sales
VERSION AS OF 42;
```

---

| Aspect            | CTAS (CREATE TABLE AS SELECT)                      | CLONE (Shallow / Deep)                                      |
|-------------------|---------------------------------------------------|-------------------------------------------------------------|
| Mechanism         | Creates a new table from a query result           | Copies an existing table (metadata + optionally data)       |
| Transformation    | ✅ Yes (you can filter, join, transform data)     | ❌ No (exact copy, no changes allowed)                      |
| Structure         | Can be modified (new schema based on query)       | Same as source table (schema is preserved)                  |
| Delta History     | ❌ Not preserved (new table starts fresh)         | ✅ Preserved (inherits source table history)                |
| Speed             | 🐢 Slower (depends on query + data processing)    | ⚡ Faster (especially shallow clone)                         |
| Use case          | Data transformation, aggregations, new datasets   | Backups, testing, environment replication                   |