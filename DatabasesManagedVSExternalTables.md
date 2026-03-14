# Metastore - Hive VS Unity Catalog - DBFS vs Cloud Storage

## Metastore
Metadata Repository
> Does not store data. Stores information **about** the data.

- ✅ Stores metadata
  - Table name
  - Columns and data types
  - Physical location in storage
  - Format (Delta, Parquet)
  - Partitions and properties
  - Associated permissions

- ✖️ DOES NOT store data
  - Parquet/Delta files come in S3, ADLS, or GSC

---

## Example: Create a table

```SQL
CREATE TABLE sales.transactions (
    id INT,
    amount DECIMAL(10,2),
    date DATE
) USING DELTA;
```

The metastore stores...
- Table name
- Columns and data types
- Physical storage locations
- Format: Delta, Parquet...
- Partitions
- Associated permissions

---

![alt text](DeltaLakeVSMetastore.png)

---

## Hive Architecture

```
Workspace A
└── Hive Metastore A
    └── databases
        └── tables → S3 / DBFS
```
> Workspace B would have its own independent Hive Metastore B

### Features
- One metastore per workspace
- Stores: Databases, Tables, Views, Partitions
- No centralized governance
- Workspaces completely isolated from each other

---

## Unity Catalog Architecture

```
└── Account Level
    └── Unity Catalog Metastore (by region)
        └── Catalog
            └── Schema
                └── Table
```

> Multiple workspaces share the same central metastore

### What Unity Catalog Manages
- Catalogs
- Schemas and Tables
- Volumes and External Locations
- Permissions and Credentials
- Data Lineage
- Shared across multiple workspaces

---

## Hive Structure

```
.
└── Workspace
    └── Metastore (implicit)
        └── Database = Schema
            └── Table
```

- Database and Schema were equivalent
- No visible catalog concept
- Only 2 visible logical levels
> `CREATE DATABASE` creates a folder in dbfs:/user/hive/warehouse/

> ## Namespace before:
``` SQL
SELECT *
FROM sales.transactions;
```

> ### Namespace: database.table
```SQL
sales.transactions
```
> - sales `databases`
> - transactions `table`
> 
> There is nothing above database

---

## New Structure

```
└── Account Level
    └── Metastore (One per region)
        └── Catalog ← New!
            └── Schema
                └── Table
```

- New level: Catalog required (*)
- Schema still exists
- 3 visible levels

### `Namespace now`
``` SQL
SELECT *
FROM company_analytics.sales.transactions;
```

### Namespace: `catalog.schema.table`
```SQL
company_analytics.sales.transactions
```
> - company_analytics `catalog`
> - sales `schema`
> - transactions `table`

### Create Structure

```SQL
CREATE CATALOG company_analytics;

CREATE SCHEMA company_analytics.sales;

CREATE TABLE company_analytics.sales.transactions (...);
```

---

![alt text](HiveMetastoreVSUnityCatalog1.png)

![alt text](HiveMetastoreVSUnityCatalog2.png)

---

## Before vs Now Summary

| **Aspect**              | **Before (Hive)**        | **Now (Unity Catalog)**            |
|---------------------|----------------------|--------------------------------|
| Metastore           | Per workspace        | Account level                  |
| Visible Catalog     | Did not exist        | Required                       |
| Database / Schema   | Equivalent           | Schema still exists            |
| Namespace           | database.table       | catalog.schema.table           |
| Logical Levels      | 2 levels             | 3 levels                       |
| Governance          | No centralized governance | Centralized and shared   |
| Workspace           | Isolated metastores  | Share a metastore              |

---

## What is DBFS?
An abstraction layer over cloud storage

`dbfs:/user/hive/warehouse/` → Actually, it's → `s3://databricks-workspace-bucket/...`

### Physical Storage
- Amazon S3
- Azure ADSL
- Google GCS
> DBFS provides user-friendly paths, but the data always ends up in the cloud.

---

## Example

### Managed Table in Hive

`CREATE TABLE sales.table_1 (...);`

It is automatically saved in:
`dbfs:/user/hive/warehouse/sales.db/table_1`

Which is actually:
`s3://workspace-internal-bucket/user/hive/warehouse/`

### Limitations of the old model
- ⚠️ Bucket owned by the workspace
- ⚠️ Not designed to govern enterprise
- ⚠️ Coupled to the workspace environment
> - Internal bucket: S3/ ADLS / GCS

### Managed Table in Unity Catalog

`CREATE TABLE analytics.ventas.table_1 (...);`

It is saved in the configured managed location:
`s3://company-datastore/uc-managed/analytics/ventas/table_1/`

> Enterprise bucket controlled by the metastore - not the workspace

### Advantages of the new model
- Separates compute from storage
- Centralized data governance
- Clear control of physical location
- Enterprise bucket (not workspace bucket)

---

## Legacy Model: Hive Metastore
The user manually defined the location in DBFS:

```
CREATE SCHEMA db_y
LOCATION 'dbfs:/custom/path/db_y.db';
```

- Schema resided within the workspace
- Metadata in the local hive_metastore
- Physical data stored in DBFS
> Simple, "filesystem-based" model

### Filesystem Structure
DBFS created a `.db` folder with subdirectories for each table:
```
dbfs:/custom/path/
└── db_y.db/
    ├── table_1/
    │   ├── part-00000.parquet
    │   └── part-00001.parquet
    └── table_2/
        └── part-00000.parquet
```
> ⚠️ The user controlled the route - no centralized governance

## Modern Model: Unity Catalog
Simple Code - No Need to Specify LOCATION:

```SQL
CREATE CATALOG analytics;

CREATE SCHEMA  analytics.db_y;
```

The data is stored in the Managed Location:
`s3://datastore/uc-managed/analytics/db_y/`

> The metastore administrator defines the path, not the user.

### Key Advantages
- **No DBFS:** Data goes directly to enterprise cloud storage.
- **Governance with Credentials:** Storage credentials control access to the bucket.
- **External Locations:** Cloud paths are registered and auditable in UC.
- **Managed Locations by Admin:** Configured at the metastore or catalog level.

> From "the user chooses the path" → "the administrator governs the storage"

---

## Managed Table in Unity Catalog
Unity Catalog has full control over the table:
- UC controls the table's **metadata**
- UC controls the **physical location** of the data
- `DROP TABLE` deletes metadata **AND** data

### Physical Location (example)
```
s3://datalakae/uc-managed/analytics/ventas/clientes/
```
> Defined by the metastore configuration, not by the user

## How to create it
SQL code, without defining LOCATION:
```SQL
```CREATE TABLE analytics.ventas.clientes(
    id BIGINT,
    name STRING
) USING DELTA;
```

---

## External Table in Unity Catalog

Concept:
- UC stores metadata
- Data resides in an external location
- `DROP TABLE` does not delete files

### Important Change vs. Hive
- **✖️ Hive (free):**
    ```SQL
    CREATE EXTERNAL TABLE
    table_x
    LOCATION 'dbfs:/my_path/';
    ```
    > Any path, without restriction

- **✅ UC (Governed):**
    Only registered and authorized routes
    > Requires External Location


### How to create it (2 Steps)

**1. Admin creates External Location:**
```SQL
CREATE EXTERNAL LOCATION sales _ext
URL 'S3://data lake/external/sales/'
WITH CREDENTIAL STORAGE
my_credential;
```

**2. User creates External Table:**
```SQL
CREATE TABLE analytics.ventas.tabla ext
LOCATION
's3://data lake/external/ventas/'
```
> Only routes registered and authorized by the administrator
