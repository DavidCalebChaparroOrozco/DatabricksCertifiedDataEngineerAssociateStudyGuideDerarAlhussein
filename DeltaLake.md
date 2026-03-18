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
