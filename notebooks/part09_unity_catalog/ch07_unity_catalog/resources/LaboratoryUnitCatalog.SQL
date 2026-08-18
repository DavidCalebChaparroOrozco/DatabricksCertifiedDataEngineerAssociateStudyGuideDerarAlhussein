-- Show Catalogs
-- Lists all catalogs that are available to you in the Databricks environment.
-- A catalog is the highest-level data container in Unity Catalog.
-- It defines a major governance boundary for organizing and controlling data.
-- Catalogs can be used to separate data by organization, business unit,
-- environment, or other governance needs.

-- Simple definition to remember
-- Catalog:
-- A catalog is the highest-level container in Unity Catalog. 
-- It helps define a major governance boundary for organizing and controlling data.

-- A simple hierarchy to keep in mind is:
-- Catalog → Schema → Table/View

SHOW CATALOGS;


-- Create a catalog if it does not already exist.
-- A catalog is the highest-level container in Unity Catalog.
-- It defines a major governance boundary for organizing and controlling data.
CREATE CATALOG IF NOT EXISTS demo_hr
COMMENT 'Demo catalog: Human Resources Domain';


-- Set demo_hr as the current catalog.
-- After this, we can reference its schemas and tables without writing the catalog name.
USE CATALOG demo_hr;


-- Create a schema inside the current catalog.
-- Since demo_hr is the current catalog, the schema will be created inside demo_hr.
CREATE SCHEMA IF NOT EXISTS payroll
COMMENT 'Payroll and employee data';


-- Create a table inside the payroll schema.
-- The table contains employee information.
CREATE TABLE IF NOT EXISTS demo_hr.payroll.employees(
    id INT,
    name STRING,
    id_card STRING,
    salary DOUBLE,
    city STRING,
    email STRING
);

-- Because demo_hr is already the current catalog,
-- we can omit the catalog name and use:
CREATE TABLE IF NOT EXISTS payroll.employees(
    id INT,
    name STRING,
    id_card STRING,
    salary DOUBLE,
    city STRING,
    email STRING
);


-- Insert rows into the employees table.
-- INSERT INTO adds new records to an existing table.
INSERT INTO demo_hr.payroll.employees (id, name, id_card, salary, city, email)
VALUES
  (1, 'Rick Sanchez', '123.456.789', 250000.00, 'Seattle', 'rick.sanchez@evil-corp.com'),
  (2, 'Bender Rodriguez', '234.567.890', 1500.50, 'New New York', 'bender.rodriguez@evil-corp.com'),
  (3, 'Luke Sky-Walker', '345.678.901', 85000.00, 'Los Angeles', 'luke.skywalker@evil-corp.com'),
  (4, 'Justin Case', '456.789.012', 65000.75, 'Boston', 'justin.case@evil-corp.com'),
  (5, 'Paige Turner', '567.890.123', 52000.00, 'Chicago', 'paige.turner@evil-corp.com'),
  (6, 'Robin Banks', '678.901.234', 120000.00, 'New York', 'robin.banks@evil-corp.com');


-- Display detailed metadata and information about the table.
-- This includes information about the table's columns,
-- data types, location, properties, and other details.
DESCRIBE EXTENDED demo_hr.payroll.employees;


-- Drop the table.
-- DROP TABLE permanently removes the table from the catalog.
-- In Unity Catalog, a dropped managed table can usually be recovered
-- during its retention period by using UNDROP TABLE.
DROP TABLE demo_hr.payroll.employees;


-- Restore a previously dropped table.
-- UNDROP TABLE restores a dropped table when it is still within
-- the available recovery period.
UNDROP TABLE demo_hr.payroll.employees;

-- Read all rows and columns from the employees table.
-- SELECT is used to retrieve data from a table.
SELECT *
FROM demo_hr.payroll.employees;


-- ============================================================
-- GROUPS AND ACCESS CONTROL
-- ============================================================

-- We create groups in the Databricks workspace/account and use
-- those groups to assign permissions to data objects.
--
-- Example groups:
-- analysts
-- payroll_team
-- national_management
--
-- Groups make permission management easier because we can assign
-- permissions to a group instead of assigning them to individual users.


-- Give the analysts group permission to use the demo_hr catalog.
-- USE CATALOG allows members of the group to access the catalog namespace
-- and reference objects inside the catalog when they also have the
-- required permissions on the schema and objects.
GRANT USE CATALOG ON CATALOG demo_hr TO `analysts`;


-- IMPORTANT:
-- USE CATALOG does NOT give the group permission to read the data.
-- It only allows the group to use the catalog.
--
-- To access a table, the group also needs the appropriate permissions
-- on the schema and the table.


-- Give the analysts group permission to use the payroll schema.
-- USE SCHEMA allows the group to access the schema namespace
-- and reference objects inside the schema.
GRANT USE SCHEMA ON SCHEMA demo_hr.payroll TO `analysts`;


-- Give the analysts group permission to read data from the employees table.
-- SELECT allows the group to read the data stored in the table.
GRANT SELECT ON TABLE demo_hr.payroll.employees TO `analysts`;


-- Verify the permissions granted on the employees table.
SHOW GRANTS ON TABLE demo_hr.payroll.employees;

-- Verify the permissions granted on the demo_hr catalog.
SHOW GRANTS ON CATALOG demo_hr;

SELECT *
FROM demo_hr.payroll.employees;

-- ============================================================
-- ROW-LEVEL FILTERING
-- ============================================================

-- The employees table contains sensitive information.
-- For example, employees from different cities should not necessarily
-- be able to see all employee records.
--
-- A row filter allows us to control which rows a user can see
-- based on the user's identity or group membership.


-- Create a row filter function.
-- national_management can see all rows.
-- Other users can only see rows where city = 'New York'.


CREATE OR REPLACE FUNCTION demo_hr.payroll.regional_filter(city_row STRING)
RETURN
  is_account_group_member('national_management') -- Gerencia lo ve todo
  OR city_row = 'New York';


-- Apply the row filter to the employees table.
-- The function will use the city column to determine
-- which rows each user is allowed to see.
ALTER TABLE demo_hr.payroll.employees
SET ROW FILTER demo_hr.payroll.regional_filter ON (city);

-- Query the table.
-- The row filter is automatically applied when the user queries the table.
SELECT *
FROM demo_hr.payroll.employees;

id	name	id_card	salary	city	email
6	Robin Banks	678.901.234	120000	New York	robin.banks@evil-corp.com


-- ============================================================
-- COLUMN MASKING
-- ============================================================

-- Create a column mask function.
-- Members of payroll_team can see the complete ID card number.
-- Other users will see only the last two characters.
CREATE OR REPLACE FUNCTION demo_hr.payroll.ID_mask(id_card STRING)
RETURN CASE
  WHEN is_account_group_member('payroll_team') THEN id_card
  ELSE CONCAT('******', RIGHT(id_card, 2))
END;


-- Apply the column mask to the id_card column.
-- The value returned to the user will depend on their group membership.
ALTER TABLE demo_hr.payroll.employees
ALTER COLUMN id_card SET MASK demo_hr.payroll.ID_mask;


-- Query the table.
-- The ID card value will be displayed according to the column mask.
SELECT name, id_card, city
FROM demo_hr.payroll.employees;
name	id_card	city
Robin Banks	******34	New York

-- ============================================================
-- DATA LINEAGE
-- ============================================================

-- Data lineage shows the flow and history of data as it moves
-- through different tables, views, and data transformations.
--
-- It helps us understand where the data comes from,
-- how it was transformed, and where it is used.


-- To view the lineage of gold_sales_region:
--
-- 1. Go to Catalog.
-- 2. Open the workspace/catalog where the object is located.
-- 3. Navigate to:
--    workspace → medallion_dbsql → gold_sales_region
-- 4. Open the Lineage option.
-- 5. Select "See lineage graph".
--
-- The lineage graph provides a visual representation of the
-- relationships and data flow between the different data objects.
--
-- It can help us trace the data from the original/raw data,
-- through the different transformations and layers,
-- until it reaches gold_sales_region.
--
-- This allows us to understand how the data was transformed
-- before being used for analysis, reporting, or dashboards.