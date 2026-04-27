# Writing strategies in Delta Lake: Overwrite vs MERGE, Type 2 SCD, Medallion Architecture

## Why is OVERWRITE almost always the right choice?

### OVERWRITE
The recommended strategy in Delta Lake
> Presents everything that `DROP` destroys

- **Delta History intact:** `OVERWRITE` generates a new version. `DROP` deletes the entire history.
- **Time travel available:** Retrieve previous versions with `AS OF VERSION` or `TIMESTAMP`.
- **Table ID preserved:** The unique identifier of the table does not change. Lineage and permissions intact.
- **Atomic operation:** Concurrent readers never see the empty table. ACID guaranteed.

---

## DROP & Recreate vs OVERWRITE (Delta Lake - Databricks)

| Aspect                  | DROP & Recreate                              | OVERWRITE (Recommended)                          |
|------------------------|----------------------------------------------|--------------------------------------------------|
| Table History          | ❌ Completely lost                           | ✅ Fully preserved (new version created)         |
| Time Travel            | ❌ Not possible                              | ✅ Supported (VERSION / TIMESTAMP)               |
| Table ID               | ❌ Changes (new table created)               | ✅ Preserved (same table identity)               |
| Lineage & Permissions  | ❌ Lost / need reconfiguration               | ✅ Maintained automatically                     |
| Data Availability      | ❌ Temporary downtime (table disappears)     | ✅ No downtime (atomic operation)                |
| ACID Guarantees        | ❌ Not guaranteed during recreation          | ✅ Fully guaranteed                             |
| Concurrent Reads       | ❌ Can fail or see missing data              | ✅ Safe (never see partial/empty state)          |
| Metadata Consistency   | ❌ Reset                                     | ✅ Consistent                                   |
| Use Case               | Rare (schema reset, full deletion required)  | Standard approach for most pipelines             |
| Performance            | ⚠️ Can be inefficient                        | ✅ Optimized for Delta operations                |

---

## What is a MERGE query?

### MERGE
**An SQL operation that combines INSERT, UPDATE, and DELETE into a single atomic statement.**
Based on a match condition (JOIN) between the source and destination tables.

- INSERT: WHEN NOT MATCHED
- UPDATE: WHEN MATCHED
- DELETE: WHEN MATCHED AND

### SQL (MERGE) Example
```SQL
MERGE INTO silver.clients AS target
USING bronze.clients_raw AS source
ON target.id = source.id

WHEN MATCHED AND 
    sourced.name <> target.name 
    THEN UPDATE SET 
    target.name = source.name, 
    target.valid_to = current_date()

WHEN NOT MATCHED THEN 
INSERT ( 
    id, 
    name, 
    valid_from, 
    is_current 
) 
VALUES ( 
    source.id, 
    source.name, 
    current_date(), 
    true 
)

WHEN NOT MATCHED BY SOURCE
THEN DELETE
```

---

## What is MERGE used for?

1. **Idepotency in ETL:** Running the same pipeline multiple times produces the same result. No duplicates.

2. **System Synchronization:** Keeping destination tables synchronized with the source: `INSERT`, `UPDATES`, and `DELETE` operations propagated.

3. **Event Processing:** Upserts events in streaming or micro-batch. Updates state without rewriting the entire table.

4. **Incremental Loading (SCD):** Applies historical changes to SCD Type 2 dimensions, preserving the complete history.

---

## Benefits of MERGE vs. Other Strategies

### `DROP & Recreate` (Avoid)
- ✖️ Loses Delta history
- ✖️ Breaks lineage
- ✖️ Not atomic
- ✖️ No time travel
- ✖️ Slow and expensive

### `INSERT OVERWRITE` (Recommended)
- ✅ Delta history intact
- ✅ Atomic and fast
- ✅ Time travel
- ⚠️ Replaces ALL content
- ⚠️ Doesn't maintain row history

### `MERGE` (Optimal for changes)
- ✅ Granular row-level operations
- ✅ Delta history intact
- ✅ Supports Type 2 SCD
- ✅ Idempotent
- ✅ No full rewrite

---

## What is SCD? (Slowly Changing Dimensions)

### SCD (Slowly Changing Dimensions)
A data warehousing technique for managing how dimension data changes over time.

> Example: A customer moves to a different city. How do we record this change without losing the history?

### Why is Type 2 the standard?

- Preserves the complete change history
- Enables accurate historical analysis
- Compatible with as-of-date reports
- Standard in Kimball and Data Vault

### SCD Type 2 Example (customer_id = 101)

| customer_id | customer_name | city        | start_date | end_date   | is_current |
|-------------|--------------|-------------|------------|------------|------------|
| 101         | John Doe     | New York    | 2022-01-01 | 2023-05-10 | false      |
| 101         | John Doe     | Chicago     | 2023-05-11 | 2024-02-20 | false      |
| 101         | John Doe     | San Diego   | 2024-02-21 | NULL       | true       |
> Each city change generates a new row; the history is never deleted.

---

## Types of SCD (Comparative)

### Type 1 (Overwrite)
The old value is overwritten with the new one. No trace of the history remains.

- ✅ Simple to implement
- ✅ Doesn't add rows
- ✖️ Loses history
- ✖️ Doesn't allow past analysis
> Use: Correcting typos (Limited use)

### Type 2 (Full History)
Each change generates a new row with effective dates. The previous row is closed.

- ✅ Full history
- ✅ Historical analysis
- ✅ Industry standard
- ⚠️ More rows in the table
- ⚠️ Greater query complexity
> Use: Changes in address, category, price (Recommended)

### Type 3 (Previous Column)
A column is added to store the previous value. Only remembers one change.
- ✅ Quick access to the previous value
- ✅ No additional rows
- ✖️ Only remembers 1 change
- ✖️ Schema grows with columns
> Use: Product category change (Very specific use)

---

# Types of SCD (Simple Examples)

## 1) Type 1 - Overwrite
The old value is replaced by the new one. History is not kept.

### Before
| customer_id | customer_name | city     |
|------------|---------------|----------|
| 101        | John Doe      | New York |

### After
| customer_id | customer_name | city     |
|------------|---------------|----------|
| 101        | John Doe      | Chicago  |

**Key idea:** only the latest value remains.

---

## 2) Type 2 - Full History
Each change creates a new row. History is preserved with dates.

| customer_id | customer_name | city      | start_date | end_date   | is_current |
|------------|---------------|-----------|------------|------------|------------|
| 101        | John Doe      | New York  | 2022-01-01 | 2023-05-10 | false      |
| 101        | John Doe      | Chicago   | 2023-05-11 | 2024-02-20 | false      |
| 101        | John Doe      | San Diego | 2024-02-21 | NULL       | true       |

**Key idea:** every change is stored as a new row.

---

## 3) Type 3 - Previous Column
A new column stores the previous value. Only one previous change is kept.

| customer_id | customer_name | current_city | previous_city |
|------------|---------------|--------------|---------------|
| 101        | John Doe      | Chicago      | New York      |

**Key idea:** you can see the current value and the immediately previous one.

---

## Quick Comparison

| SCD Type | How it works | Keeps history? | Best use case |
|---------|--------------|----------------|---------------|
| Type 1  | Overwrites the old value | No | Correcting typos |
| Type 2  | Adds a new row for each change | Yes, full history | Address, category, price changes |
| Type 3  | Stores the previous value in another column | Partial | One-step comparison only |

---

## SCD Type 2 (Control Columns)
Each row has 4 control columns:
- valid_form `DATE`: Start date of the record's validity
- valid_to `DATE`: End date. 9999-12-31 if it is the active record.

- is_current `BOOLEAN`: TRUE = active record. Only one active row per entity.

- record_hash `STRING`: MD5/SHA hash of the key attributes. Detects if there was an actual change.

### SQL: Merge + SCD Type 2
```SQL
-- 1. Detect changes using record_hash
MERGE INTO silver.dim_clients AS target
USING (
    SELECT id, name, city,
    current_date()  AS valid_from,
    date('9999-12-31') AS valid_to,
    true    AS is_current,
    md5(concat(name, city)) AS record_hash
    FROM bronze.clients_raw
) AS source
ON target.id = source.id AND target.is_current = true

-- 2. If a change has occurred: close the old row
WHEN MATCHED AND target.record_hash <> source.record_hash
THEN UPDATE SET
    target.valid_to = current_date() - 1,
    target.is_current = false

-- 3. If a new record is entered: insert
WHEN NOT MATCHED THEN INSERT *
```

## Full data flow: Bronze → Silver → Gold

1. Bronze Layer: Raw Ingestion (`INSERT` append)
2. Silver Layer: MERGE + SCD Type 2 (Historical Upsert)
3. Gold Layer: Aggregation + KPIS (`INSERT OVERWRITE`)

# Medallion Architecture (Simple Example)

## 1) Example Table (What happens in each layer)

| Layer  | Source                     | Main Operation                  | Result                                  |
|--------|----------------------------|--------------------------------|------------------------------------------|
| Bronze | Kafka, JDBC, files         | INSERT (append only)           | Raw data without transformations         |
| Silver | Bronze tables              | MERGE + SCD Type 2 + record_hash | Clean history with valid_from / valid_to |
| Gold   | Silver tables              | INSERT OVERWRITE / Aggregations | KPIs, metrics, features                  |

---

## 2) Process Explanation Table (Step by step)

| Layer  | What happens?                                                                 | Why is it important?                                  |
|--------|-------------------------------------------------------------------------------|--------------------------------------------------------|
| Bronze | Data is ingested exactly as it arrives (no cleaning, no filtering).           | Keeps original data for traceability and reprocessing. |
| Silver | Data is cleaned, deduplicated, and changes are tracked using SCD Type 2.      | Ensures data quality and preserves history.            |
| Gold   | Data is aggregated and transformed into business-level metrics and features.  | Makes data ready for analytics, dashboards, and ML.    |