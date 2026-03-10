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