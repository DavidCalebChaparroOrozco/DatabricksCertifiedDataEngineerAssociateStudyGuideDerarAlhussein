# Create Tables - Clone Data - Use Views `CTAS, CONSTRAINTS, CLONING, VIEWS`

## What is a CTAS?
```SQL
CREATE TABLE AS SELECT
```

SQL statement that creates a new table from a `SELECT` and materializes the results as physical data in storage.

```SQL
CREATE TABLE <table_name>
[table_options]
AS
SELECT ...
```

1. Execute the logical plan of the `SELECT` statement.
2. Infer the schema from the query result.
3. Create a physical table and write the result in Delta format.

---

## Anatomy of a CTAS ("Complete structure with all its components")

```SQL
CREATE TABLE catalog.schema.table_name
USING DELTA
COMMENT "metadata description"
PARTITIONED BY (col)
LOCATION 'path'
AS
SELECT ...
```

| Component              | Function                                                                 |
|----------------------|-------------------------------------------------------------------------|
| CREATE TABLE         | Defines a new table in the metastore and initializes its metadata.      |
| catalog.schema.table_name | Specifies the fully qualified name of the table, including catalog and schema for proper organization and namespace resolution. |
| USING DELTA          | Declares the storage format of the table. In this case, it uses Delta Lake, which supports ACID transactions and versioning. |
| COMMENT              | Adds a human-readable description to the table metadata for documentation and discoverability. |
| PARTITIONED BY (col) | Organizes the table data into partitions based on the specified column(s), improving query performance and data management. |
| LOCATION             | Specifies the physical storage path where the table data will be stored (e.g., cloud storage like S3, ADLS, or local paths). |
| AS                   | Indicates that the table will be created using the results of a query (CTAS pattern). |
| SELECT ...           | Provides the query that generates the data to populate the new table. This defines both the schema and the initial dataset. |

---

## CTAS vs. Traditional `CREATE TABLE` ("One Operation vs. Two Operations")

### `CREATE TABLE` (2 Operations)
Defines structure, but not data. Requires a subsequent `INSERT` statement.

```SQL
CREATE TABLE users (
    id INT,
    name STRING
)

INSERT INTO users

SELECT ...
```

### CTAS 1 Operation
Defines structure + data in a single operation. Schema inferred from the query

```SQL
CREATE TABLE users
AS 
SELECT id, name
FROM raw_users
```


---

## Transformations in CTAS ("It's Not Just Data Copying")

```SQL
CREATE TABLE silver.users
AS 
SELECT
    user_id,
    lower(email) AS email,
    to_date(created_at) AS signup_date
FROM bronze.users
WHERE is_active = true
```

- **Column Transformation:**
`lower(email), to_date(created_at)`

- **Filtering:**
`WHERE is_active = true`

- **Materialization:**
Resulting table written in Delta Lake

```sql
%sql
-- Create the catalog (top-level namespace)
CREATE CATALOG IF NOT EXISTS analytics;
```

```sql
%sql
-- Switch to the target catalog
USE CATALOG analytics;

-- Create a new schema
CREATE SCHEMA IF NOT EXISTS sales;
```

```sql
%sql

-- Create a new table in the analytics.ventas schema to store cleaned NYC taxi trip data
CREATE TABLE analytics.ventas.nyctaxi_trips_clean

-- Specify Delta Lake as the storage format for reliability, performance, and ACID compliance
USING DELTA

-- Populate the table using the results of the following SELECT query (CTAS pattern)
AS
SELECT
    -- Original pickup timestamp of the trip
    tpep_pickup_datetime,

    -- Original dropoff timestamp of the trip
    tpep_dropoff_datetime,
    
    -- Calculate trip duration in minutes using pickup and dropoff timestamps
    TIMESTAMPDIFF(
        MINUTE,
        tpep_pickup_datetime,
        tpep_dropoff_datetime
    ) AS trip_duration_minutes,
    
    -- Distance traveled during the trip (in miles)
    trip_distance,
    
    -- Compute fare per mile as a derived metric
    -- ROUND is used to limit the result to 2 decimal places for readability
    ROUND(fare_amount / trip_distance, 2) AS fare_per_mile,
    
    -- Pickup location ZIP code
    pickup_zip,

    -- Dropoff location ZIP code
    dropoff_zip
    
-- Source dataset containing raw NYC taxi trip records
FROM samples.nyctaxi.trips

-- Filter out invalid or problematic records:
-- Exclude trips with zero or negative distance to avoid division errors
WHERE trip_distance > 0

-- Exclude trips with zero or negative fare to ensure meaningful metrics
AND fare_amount > 0;
```

---

## Constraints in Delta Lake ("Data Integrity Rule")

> Not all constraints function the same as in a classic RDBMS. Delta Lake defines two clear categories:

### Enforced: `CHECK` - `NOT NULL`
These are strictly validated. Delta rejects rows that violate them.

### Informational: `PRIMARY KEY` - `FOREIGN KEY` - `UNIQUE`
These are used for metadata and query planner optimization, but they are not strictly validated.

---

## Enforced Constraints ("Delta Lake's strongest enforced constraint")
Defines a Boolean condition that each row must meet.

**When creating the table:**
``` SQL
CREATE TABLE users (
    id INT,
    age INT,
    CONSTRAINT age_positive CHECK(age >=0)
)
```

**Add after:**
``` SQL
ALTER TABLE users
ADD CONSTRAINT age_positive
CHECK (age >= 0)
```

**If you try to insert:**
```SQL
INSERT INTO users
VALUES (1, -5)
```

**✖️DELTA LAKE REJECTS IT**

**To check constraints:**
```SQL
DESCRIBE DETAIL users

SHOW TBLPROPERTIES analytics.sales.users
```

---

## `NOT NULL` - `PRIMARY KEY` - `FOREIGN KEY` (Enforced and Informational Constraints)

### `NOT NULL` (ENFORCED)
Inserting `NULL` fails. Works as in any database.
```sql
CREATE TABLE users (
    id INT NOT NULL,
    email STRING NOT NULL
)
```

### `PRIMARY KEY` (INFORMATIONAL)
```sql
CREATE TABLE users (
    id INT,
    CONSTRAINT pk_users
    PRIMARY KEY (id)
)
```
- ✖️ Does not create an index
- ✖️ Does not block duplicates
- ✅ Documentation and optimization

### `FOREIGN KEY` (INFORMATIONAL)
```sql
CREATE TABLE orders (
    order_id INT,
    users_id INT,
    CONSTRAINT fk_users
    FOREIGN KEY (users_id)
    REFERENCES users(id)
)
```
- ✅ Metadata
- ✅ Lineage tool

```sql
INSERT INTO analytics.sales.users_2 VALUES (1, "caleb@gmail.com");
INSERT INTO analytics.sales.users_2 VALUES (1, "david@gmail.com");
INSERT INTO analytics.sales.users_2 VALUES (1, "chaparro@gmail.com");

SELECT * FROM analytics.sales.users_2;
id	email
1	david@gmail.com
1	caleb@gmail.com
1	chaparro@gmail.com
```

---

## UNIQUE & Constraint Examples ("Workarounds and Quick Reference")

### `UNIQUE` (NOT APPLIED)
Not a true constraint. Handle with:
`MERGE`, `Dedup`, `ROW_NUMBER`

```sql
MERGE INTO users t
USING staging_users s
ON t.id = s.id
WHEN NOT MATCHED
THEN INSERT *
```

| Type             | Example                 | Rule                                                                                                                                                  | If Violated                                                                                                          |
| ---------------- | ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Target Table     | `MERGE INTO users t`    | The target table (`users`) is the table where data will be inserted, updated, or deleted. The alias (`t`) is used to reference it later in the query. | If the table does not exist or alias is missing/misused, the query will fail with a table or column reference error. |
| Source Table     | `USING staging_users s` | The source table (`staging_users`) contains the new data to compare against the target. Alias (`s`) is required for clarity and reference.            | If the source table does not exist or alias is incorrect, the query will fail or produce incorrect joins.            |
| Join Condition   | `ON t.id = s.id`        | Defines how records from source and target are matched. Typically uses a primary key or unique identifier.                                            | If the condition is incorrect or missing, it may cause incorrect matches, duplicates, or a runtime error.            |
| Insert Condition | `WHEN NOT MATCHED`      | This condition triggers when a record in the source does not exist in the target table.                                                               | If omitted, new records from the source will not be inserted into the target.                                        |
| Insert Action    | `THEN INSERT *`         | Inserts all columns from the source table into the target table when no match is found. Assumes both tables have compatible schemas.                  | If schemas do not match (column order, count, or types), the query will fail or insert incorrect data.               |

### Other examples
| Type         | Example                                                  | Rule                                                                         | If Violated                                                    |
| ------------ | -------------------------------------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------- |
| NOT NULL     | `name STRING NOT NULL`                                   | The column must always have a value. It cannot be empty or NULL.             | Insert or update will fail if no value is provided.            |
| CHECK Range  | `age INT CHECK (age BETWEEN 18 AND 65)`                  | The value must fall within a specific numeric range.                         | The operation fails if the value is outside the allowed range. |
| CHECK Price  | `price DECIMAL(10,2) CHECK (price > 0)`                  | Ensures the price is always greater than zero.                               | Negative or zero values will cause the insert/update to fail.  |
| CHECK Values | `status STRING CHECK (status IN ('active', 'inactive'))` | Limits the column to a predefined list of valid values.                      | Any value outside the list will be rejected.                   |
| CHECK Length | `username STRING CHECK (length(username) >= 5)`          | Ensures the text meets a minimum length requirement.                         | Values shorter than the required length will fail.             |
| CHECK Dates  | `end_date DATE CHECK (end_date >= start_date)`           | Ensures logical consistency between dates (e.g., end date after start date). | If the condition is not met, the operation will fail.          |
| CHECK Format | `email STRING CHECK (email LIKE '%@%')`                  | Validates a basic format pattern (e.g., must contain '@').                   | Invalid formats will be rejected during insert/update.         |

---

## Cloning in Delta Lake ("Fast Table Copies Without Moving All Data")

### Duplicates Terabytes (in Seconds)
Cloning allows you to create copies of Delta tables without physically copying all the data. Only the metadata—or also the files—depending on the type.

`Shallow Clone`, `Deep Clone`

- Testing
- Experimentation
- Fast Backups
- Performance

---

## `Shallow Clone` ("Metadata solemtnte - same data files")

```sql
CREATE TABLE sales_clone
SHALLOW CLONE sales
```

**Internal structure:**

```
sales/
├── data_files
└── transaction_log
```

```
sales_clone/
└── metadata → It points to the same data files.
```

- Extremely fast
- Takes up almost no additional storage
- ✖️ If you delete files from the source, the clone can break or lose access to the data