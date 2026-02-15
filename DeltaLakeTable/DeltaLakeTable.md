# Advanced transactional data management

## Hierarchical Table Structure
The Fundamental Organization in Databricks

Tables are organized as follows:
Catalog > Schema > Table

All data in Databricks must reside within this hierarchy. "Independent" tables are not allowed.

### Three-Level Hierarchy
Catalog: Highest level. Example: production_catalog

Schema: Groups tables. Example: sales_schema

Table: Contains data. Example: customer_orders

> production_catalog.sales_schema.customer_orders

---

## Catalog: The Top Level

### What is a Catalog?

The highest level for grouping data in Databricks.

- Central point of data governance
- Granular permission control
- Logical data isolation
- Facilitates large-scale management

### Separating Environments
- dev_catalog
- qa_catalog
- prod_catalog
> Complete isolation between environments

### Business Domains
- finance_catalog
- marketing_catalog
- operations_catalog
> Organization by functional area

### Separating by Teams
- team_data_science
- team_analytics
- team_engineering
> Team-specific permissions

---

## hive_metastore
The default catalog in Databricks

### Features
- Default catalog in Databricks
- Does not require Unity Catalog
- All tables reside here
- A single global namespace

### Typical structure
hive_metastore.default.my_table

- Catalog: hive_metastore (fixed)
- Schema: default (or custom)
- Table: my_table

---

## Hive Metastore vs. Unity Catalog: A Visual Comparison of Architectures

### With Hive Metastore (Legacy)
**SINGLE CATALOG**

_**hive_metastore**_

- default:
users orders

- analytics:
reports metrics

- staging:
raw data

⚠️ All in a single namespace

## With Unity Catalog (Modern)
**MULTIPLE CATALOGS**

- dev_catalog:
default testing

- prod_catalog:
sales analytics

- finance_catalog:
reports audit

✅ Isolation and granular governance
---
## Creating Delta Tables
SQL Syntax for Creating Tables in Delta Lake Format

🌟 Example: Creating a Users Table with Different Data Types

### CREATE TABLE using Delta format
``` sql
CREATE TABLE workspace.default.users (
id INT,
name STRING,
email STRING,
age INT,
created_at TIMESTAMP
) USING DELTA; -- USING DELTA is what converts a regular table into a Delta Lake table
```

---

## Insert in Delta Lake
ACID Transactions in Each Operation

### Atomic Transactions
**Each operation is a complete and isolated transaction (ACID).**
- Guaranteed isolation between operations.
- Ability to roll back using Time Travel.

## Log Transactions (_delta_log)
**Each transaction generates a new commit in the log.**
- Immutable record of all changes.
- Each commit creates a new version of the table.

## What Happens in an INSERT?

1. INSERT Executed: Command sent to Delta
2. Parquet Write: New data files
3. Commit to Log: JSON in _delta_log/
4. New Version: The table advances to vN+1

---

### Insert Data
``` sql
%sql
INSERT INTO workspace.default.users VALUES(
    1,
    'Caleb',
    'caleb@gmail.com',
    28,
    current_timestamp() -- Function to get the current timestamp
)

%sql
INSERT INTO workspace.default.users VALUES
    (2, 'Bender', 'bender@gmail.com', 30, current_timestamp()),
    (3, 'Jane', 'jane@gmail.com', 25, current_timestamp()),
    (4, 'Mike', 'mike@gmail.com', 35, current_timestamp());
```

### How do we look at it?
``` sql
%sql
SELECT *
FROM workspace.default.users
```

### Update Data
``` sql
%sql
UPDATE workspace.default.users
SET email = "caleb@outlook.com"
where id = 1
```

---
## Transaction Log in Detail
Anatomy of the _delta_log Directory

### What does _delta_log contain?
**Numbered JSON Files**
Each transaction = one JSON file (e.g., 00000.json).

**Operation Metadata**
Records which files were added, deleted, or modified.

**Data Statistics**
Min/max values, row counts to optimize queries.

**Checkpoints**
A checkpoint is created every 10 commits to speed up reads.

> The transaction log is the single source of truth.

## File Structure (3 INSERTs)
> /mnt/delta/users/

### Parquet Files (Data)
- part-00000.snappy.parquet: INSERT data 1
- part-00001.snappy.parquet INSERT Data 2
- part-00002.snappy.parquet INSERT Data 3

### _delta_log/
- 00000.json CREATE TABLE
- 00001.json INSERT v1
- 00002.json INSERT v2
- 00003.json INSERT v3

> Current version: 3

---

## Describe Detail
Technical information and metadata of the table

🌟 This does not display the data itself, but rather information about how the table is stored.

|  **Field**  	|      **Description**      	|           **Example**           	|
|:-----------:	|:-------------------------:	|:-------------------------------:	|
|   location  	| Physical storage location 	| dbfs:/user/hive/warehouse/users 	|
|    format   	|       Storage format      	|              delta              	|
|   numFiles  	|      Number of files      	|                15               	|
| sizeInBytes 	|      Total table size     	|             2847392             	|
|  createdAt  	|     Creation timestamp    	|       2026-01-15T10:30:00Z      	|

---

## What is DESCRIBE DETAIL used for?
Practical use cases in daily work

🌟 It's useful for validating, diagnosing, and optimizing Delta tables without querying the data.

### View physical location
Confirms the storage path for migrations or backups.

### Determine size
Verifies the total size for managing costs and storage.

### Confirm it's Delta
Validates that the table is in Delta format and supports ACID and time travel properties.

### Time audit
Reviews creation/modification dates to detect obsolete tables.

---
## DESCRIBE HISTORY
Complete transaction audit of the table

```
DESCRIBE HISTORY users;
```

📊 Displays the complete history of operations that changed the table. It does not show data, but rather the operations: CREATE, INSERT, UPDATE, DELETE, MERGE, OPTIMIZE.

--- 

## What is DESCRIBE HISTORY used for?
Auditing, traceability, and diagnostics

✅ Every change to a Delta table is permanently recorded.

This allows for complete auditing, change traceability, and error reversal.

### Auditing
**Who modified the data?**
The userName column shows the user or job that executed each operation.
> Useful for compliance and security.

### Traceability
**When did the table change?**
The timestamp column shows the exact time of each transaction.
> Trace when incorrect data was inserted.

### Diagnostics
**Why did it change?**
The operation column shows what type of change was made (INSERT, UPDATE, etc.).
> Detect suspicious or unexpected operations.

### Time Travel
Can I go back?
Use version to read data from previous versions or revert changes.
> Retrieve data before a DELETE operation.