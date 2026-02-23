# Time Travel and Optimization in Delta Lake

## Context
- In Databricks with Delta tables (Delta Lake), each change does not overwrite previous data.

- Delta maintains a transactional log (Delta Log) with a complete history.

- Time travel is derived from this history.

---

## What is Time Travel?

**Definition:** Delta Lake functionality for querying a table at a specific point in the past

- Uses version number 🧮
- Uses timestamp 🗓️

### Key Features
- Each operation (INSERT, UPDATE, DELETE, MERGE) creates a new version in the transaction log

- Does not overwrite previous data

- Allows for the reconstruction of consistent state at any point within the retention period

---

## What does 'time travel' mean?

- **Current State:** View the current state table

- **By Version:** View a specific past version

- **By Date/Time:** View a specific date and time state

- **Consistent Snapshots:** Each operation leaves a consistent snapshot

---

## Time Travel - SQL Examples

- **Query by Date:**
```SQL
SELECT *
FROM customers
TIMESTAMP AS OF '2026-02-17 10:00:00';
```

```SQL
SELECT *
FROM product_info@20260217100000;
```

- **Query by Version:**
```SQL
SELECT *
FROM product_info
VERSION AS OF 2;
```

```SQL
SELECT *
FROM product_info@v2;
```

---

## Full Rollback

- **Restore by Version:**
Restores the table to the specified version.
```SQL
RESTORE TABLE customers
TO VERSION AS OF 0;
```

- **Restore by Timestamp:**
Restores the table to the state at the specified date and time.

```SQL
RESTORE TABLE customers
TO TIMESTAMP AS OF '2026-02-17 10:00:00';
```

> **Important:** This creates a new version that replicates the previous state.

---

## Optimizing Delta Lake Tables

### What is optimization?
The process of physically reorganizing Parquet files
> Goal: Improve read performance and reduce fragmentation

**The problem:**
- INSERT, UPDATE, DELETE, and MERGE operations generate many small files
- Increases scheduling overhead in Spark
- Degrades performance in analytical queries

---

## File Composition

- Delta Lake generates many small files (streaming, frequent uploads)
- Reading 1,000 1MB files is slower than reading one 1GB file

> ### `OPTIMIZE` Command
> Merges small files into efficient larger files (~1GB)

**Benefit:**
Reduces metadata overhead and improves read speed

### Example of Fragmentation
```
part-00001.snappy.parquet (1MB)
part-00002.snappy.parquet (800KB)
part-00003.snappy.parquet (2MB)
```

> Can result in thousands of small files

---

## Why is fragmentation bad?

> Spark processes partitions and tasks, not files

### Many small files =
- More metadata
- More tasks
- More overhead
- More scheduling time
- Worse scan performance

> The problem isn't total size, it's fragmentation

---

## What does OPTIMIZE do?

Syntax
`OPTIMIZE table_name;`

Internal Process
1. Reads many small files
2. Combines them
3. Writes new, larger files (~128MB)
4. Marks the small files as removed in the log

> It's intelligent compaction. It doesn't change data, it only physically reorganizes files.

---

## What is Z-ORDER?

**A technique for physically reorganizing data within Parquet files**
Similar values ​​are placed close together.
>✖️It is NOT:
> - It is not an index
> - It is not a partition
> - It is not a new table
It is a physical reordering of storage.

**Example table:**
| id 	| customer_id 	| product_id 	|
|:--:	|:-----------:	|:----------:	|
|  1 	|      50     	|      9     	|
|  2 	|     2000    	|      4     	|
|  3 	|      51     	|     10     	|
|  4 	|     1999    	|      3     	|

`OPTIMIZE table ZORDER BY (customer_id)`

**Before:**
File A → 50, 2000, 51, 1999

**After:**
File A → 50, 51 | File B → 1999, 2000

---

## Why Does Z-ORDER Matter?

> **Statistics by File:** Delta saves statistics by file (min, max) to skip data.

With query:
`WHERE customer_id=50`

- **File A:** min=50 max=51 → read
- **File B:** min=1999 max=2000 → skip

> **Result:** Faster query by reading less data

> **Simple Definition:** Z-ORDER co-locates related data to improve the efficiency of data skipping.

---

## Z-ORDER Limits

### Practical Limit
Practical rather than technical limit
- In production: 1 to 3 columns maximum
- 4 columns dilute the benefit

### Many columns:
- Loses effectiveness
- Disperses location
- Does not improve data skipping

---

## Real-World Rule

**Use Z-ORDER in:**
- High-cardinality columns
- Columns frequently used in filters
- Columns used together in queries

### Good example: ✅
`ZORDER BY (customer_id, date)`
> High cardinality, frequently used in filters

### Bad example: ✖️
`ZORDER BY (country, gender)`
> Low cardinality, little benefit (if they have low cardinality)