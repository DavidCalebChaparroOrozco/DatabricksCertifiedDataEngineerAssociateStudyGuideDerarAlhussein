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