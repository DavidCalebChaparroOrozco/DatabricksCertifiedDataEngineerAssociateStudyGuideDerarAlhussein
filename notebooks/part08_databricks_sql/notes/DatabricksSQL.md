# Databricks SQL
Query, analyze, and visualize Lakehouse data with standard SQL. (No Python or Scala required)
- SQL Warehouse
- Dashboard
- DBU
- Unity Catalog
- Delta Lake

### **query_editor.sql**
```sql
-- Sales by country, last 30 days
SELECT country, SUM(sales) AS total_sales
FROM sales
GROUP BY country
ORDER BY total_sales DESC;
```

## User Distribution by Country

| Country | Users |
|---------|------:|
| Brazil (BR) | 128k |
| Mexico (MX) | 102k |
| Colombia (CO) | 71k |
| Argentina (AR) | 48k |

**Total rows:** 4

> From **SQL** to the **dashboard**, without leaving Databricks.

---

## What is Databricks SQL?

It's Databricks' service for **querying, analyzing, and visualizing** data using SQL **(without writing Python or Scala)**.

> Analysts and business users query data from **Delta Lake, Unity Catalog**, and other formats using **standard SQL**.

### Main Features
- **SQL queries at scale**: On large volumes of Lakehouse data.

- **Interactive dashboards**: Charts, tables, and filters for business use.
- **Scheduled queries**: Queries that run automatically.

- **Shared reports**: Results accessible to other users.

- **SQL warehouses**: Engines optimized for fast SQL execution.