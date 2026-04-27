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

