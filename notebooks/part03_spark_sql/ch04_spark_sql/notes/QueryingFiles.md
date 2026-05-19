# Querying Files: JSON, CSV & TXT

Reading files directly from volumes in the Lakehouse

## What are volumes?

### Definition
Governed storage space within the Lakehouse
> Managed by Unity Catalog, Access Controlled, Auditable

- **Governed:** Unity Catalog controls who accesses the volume
- **Organized:** Hierarchical structure: Catalog > Schema > Volume

- **Auditable:** Complete log of access and operations

---

![alt text](/notebooks/part03_spark_sql/ch04_spark_sql/images/HierarchyInTheLakehouse.png)

---

## Before VS Now

### Before - DBFS
- ✖️ No granular access control
- ✖️ No operational auditing
- ✖️ No integration with Unity Catalog
- ✖️ Difficult to organize at scale
```
dbfs:/FileStore/file.csv
```

### Now - Volumes
- ✅Role-based access control (Unity Catalog)
- ✅Full access auditing
- ✅Integrated enterprise governance
- ✅Structured and scalable organization
```
/Volumes/catalog/schema/volume/file.csv
```

---

## Why do Volumes exist?

### 1. Access Control
Granular permissions by role. Only those who need to have access to the data.

### 2. Organization
Clear structure: Catalog > Schema > Volume > Files.

### 3. Auditing
Automatic logging of who read, wrote, or deleted files.

### 4. Enterprise Environment
Compatible with corporate governance policies.

---

## What can you store on a volume?
Any binary or text file, not just structured data

- JSON: Semi-structured data
- CSV: Flat tabular data
- Parquet: Compressed columnar data
- Images: PNG, JPG, TIFF
- Logs: System logs
- Raw: Unprocessed data

---

## Volumes ≠ Tables

### Volume
**File Storage**
- Files without enforced structure
- Read directly
- Not querable with JOINs
- Layer BEFORE ingestion

### Table (Delta)
**Structured Data**
- Defined schema
- Queryable with full SQL
- Supports JOIN, UPDATE, and DELETE operations
- Layer AFTER ingestion

![alt text](/notebooks/part03_spark_sql/ch04_spark_sql/images/Volumes≠Tables.png)

> Volumes are the starting point, not the final destination.

---
## Querying Data Files (Why?)

### 1. Bronze Layer
Ingests raw data directly from untransformed files.

`Raw files → Bronze table`

### 2. Exploration
Inspects the structure and content of files before processing.

```SQL
SELECT *
FROM json.`...`
```

### 3. Validation
Verifies the quality, format, and completeness of received data.

```SQL
SELECT COUNT(*)
```
FOR AUDITING

---

## Operations: What can you do?

### ✅ YES, you can
- `SELECT` Read and query files
- `JOIN` Combine files with tables
- `WHERE / FILTER` Filter results
- `CREATE TABLE AS` Save results as a Delta table

### ✖️ NO, you can't
- `INSERT INTO` You cannot insert rows into files
- `UPDATE` Files are immutable from SQL
- `DELETE` Does not apply to raw files
- `MERGE` Only to Delta tables

> To modify data: convert the file to a Delta table first

---

## Path Structure

`/Volumes/<catalog>/<schema>/<volume>/<optional_path>`

- **Fixed Prefix:** `/Volumes/`
- **Catalog/Schema/Volume:** `<catalog>/<schema>/<volume>`
- **Folder or File:** `<optional_path>`

### Specific File
`/Volumes/my_catalog/bronze/raw/data.json`

### Entire Folder
`/Volumes/my_catalog/bronze/raw/`

### With Wildcard
`/Volumes/my_catalog/bronze/raw/*.json`

---

## Reading Files by Format

### JSON
```SQL
SELECT * FROM json.`/Volumes/catalog/schema/volume/file.json`
```

### CSV
```SQL
SELECT * FROM csv.`/Volumes/catalog/schema/volume/file.csv
```

### PARQUET
```SQL
SELECT * FROM parquet.`/Volumes/catalog/schema/volume/file.parquet
```

> The format is specified **BEFORE** the backticks: 
> ```SQL
> format.`/path/to/file`
> ```

---

## Wildcards: Read Multiple Files

### Entire Folder
Reads all JSON files within a folder
```SQL
SELECT *
FROM json.`/Volumes/catalog/schema/volume/folder/`
```

### All .json files
Wildcard * filters by extension in the same folder
```SQL
SELECT *
FROM json.`/Volumes/catalog/schema/volume/*.json`
```

### Filter by Name
Combines prefix + wildcard to read files from a specific period
```SQL
FROM json.`/Volumes/catalog/schema/volume/data_2026*.json`
```

## Implicit Partitioning - Apache Hive

### Partition Pruning
When organizing files into folders using `key = value`, Databricks automatically omits partitions that don't match the `WHERE` filter.

```SQL
SELECT *
FROM json.`/Volumes/catalog/schema/volume/`
WHERE year = 2024 AND month = 06
```

> Only reads the folder year = 2024/ month = 06 / - ignores the rest.

```
volume/
├── year=2024/ 
│   ├── month=06/ ← ✅ IT READS 
│   └── month=07/ ← is ignored
└── year=2023 ← is ignored
```

---

# Best Practices

- **Avoid giant folders without filters (performance)**
Without WHERE clauses or wildcards, Databricks will read ALL files. Costly and slow.

- **Use wildcards intentionally (organization)**
Design filename patterns from the start to facilitate filtering.

- **Organize by date using a "Hive" (efficiency)**
Use `year=/month=/day=` to enable automatic partition pruning.

- **Convert to Delta when possible (architecture)**
Files are temporary. The final layer should be a Delta table.

---

