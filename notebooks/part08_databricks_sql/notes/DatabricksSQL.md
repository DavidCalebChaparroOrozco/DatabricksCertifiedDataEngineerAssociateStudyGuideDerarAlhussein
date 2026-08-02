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

---

## Two Worlds, One Lakehouse (Separation of Responsibilities)

### Notebooks, Jobs, DLT (Data Engineers & Data Scientists)
- Build data **pipelines**
- Create **Delta tables** and transform data
- Manage the Lakehouse (Engineering, Data Science, and AI)
> Python, SQL, Scala, R

### SQL Databricks (Data Analysts & Business Users)
- Query data with **SQL**
- Create **dashboards** and perform analysis
- Share **reports** with the business
> **SQL only**, analytics & BI

### The Lakehouse
The same **Delta Lake** tables, governed by **Unity Catalog** (one place for both worlds)

> Delta Lake, Unity Catalog

> ### **In summary:** Databricks SQL is a **BI and analytics** tool from Databricks (the environment where an analyst writes SQL queries, builds dashboards, and shares reports with the business).

## SQL Warehouse (The Engine)
It is a Databricks computing resource dedicated exclusively to executing SQL queries.

> Think of it as the equivalent of a **cluster specializing in SQL.**

### Its sole responsibility
1. Receive SQL queries
2. Process and optimize them
3. Return results as quickly as possible

> It is used by **Data Analysts** and **BI** tools (Power BI, Tableau, ...) every query you launch from Databricks SQL runs here.

![alt text](../images/SQLWarehouseTheSQLExecutionEngine.jpg)


---

## All-Purpose Cluster vs. SQL Warehouse

| Feature | All-Purpose Cluster | SQL Warehouse |
|---------|----------------------|---------------|
| **Primary Purpose** | General-purpose compute for development and data engineering | Dedicated compute optimized for SQL analytics |
| **Supported Languages** | Python, SQL, Scala, and R | SQL only |
| **Typical Workloads** | Notebooks, ETL pipelines, Machine Learning, ad hoc development | SQL queries, dashboards, reporting, and BI analytics |
| **Primary Users** | Data Engineers and Data Scientists | Data Analysts and BI tools (Power BI, Tableau, etc.) |
| **Flexibility** | Supports custom libraries and arbitrary code execution | Optimized exclusively for SQL execution |
| **Performance Focus** | Versatility and development | Fast, scalable, and efficient SQL query processing |

>
> Both compute resources access the **same Lakehouse data**, but they are optimized for different workloads.
>
> - 🚀 **All-Purpose Cluster** → Best for development, ETL, and Machine Learning.
> - ⚡ **SQL Warehouse** → Best for SQL analytics, dashboards, and BI workloads.
>
> **Choose the engine based on the workload—not by habit.**

---

## Why Not Always Use an All-Purpose Cluster? (Analogy)

### What an Analyst Really Needs

```SQL
SELECT country, SUM(sales)
FROM sales
GROUP BY country;
```

- Create dashboards
- Schedule reports
- Share queries
> No Python, pipelines, or libraries

### A Simple Way to Remember
General Purpose: Can run **everything**: Python, SQL, Scala, R, ETL, Machine Learning...

Specialized: Does **only one thing:** execute SQL, very fast and with **high concurrency**.

> For an analyst's work, a **SQL Warehouse consumes resources more efficiently** and is optimized to handle **many simultaneous queries**.

![alt text](../images/ChoosingComputeBasedontheWorkload.jpg)

---

## Cluster size (creating a SQL Warehouse)

Defines **how many workers** (and how large) the cluster processing your queries has.

### Smaller size
- ⬇️ Lower latency: more compute resources per query
- ⬆️ Higher consumption: more DBUs burned per hour.

> Each size **doubles the number of workers** and doubles the DBUs/h.

![alt text](../images/ChoosingtheRightSQLWarehouseSize.jpg)

---

## What is a DBU? (The consumption meter)

**DBU = Databricks Unit:** The abstract unit Databricks uses to measure computation. It's not a direct dollar amount (it works like "credits").

Each cluster size consumes a fixed number of DBUs per hour while the data warehouse is running.

Databricks charges for DBUs with per-second granularity while the warehouse is active.

The price per DBU varies depending on the warehouse type (Classic, Pro, Serverless) and your cloud and region.

### Your actual cost:
$$\text{cost} = \text{DBU consumed} * \text{price per DBU}$$
> size * uptime
> 
> depending on tier, cloud, region

### Cost example
**a Small warehouse in Classic (AWS)**
```text
size = Small → 12 DBU/h
uptime = 30 min
consumption = 12 * 0.5 = 6 DBU
price = $0.22 / DBU (Classic, AWS)
cost = 6 * $0.22 = $1.32 + your cloud VM
```

> Same DBU consumption, different final cost depending on the tier you choose

---

## Scaling for Concurrency (Scaling Min / Max Clusters)
**This is not the cluster size:** it's how many identical clusters run in parallel to handle **simultaneous queries** (Not to accelerate a single query).

- **Min (the floor):** Clusters that remain ready at all times.

- **Max (the ceiling):** Clusters that automatically start up if there's a queue.

> Databricks recommends: **"~1 cluster for every 10 concurrent queries."** If a query waits _5 minutes in the queue_, the data warehouse automatically scales up.

> ⚠️ With `Min = 1 / Max = 1`, you never scale horizontally: only that single cluster running... or shutting down.

### Same size, more clusters (Min = 1; Max = 3) Concurrent queries: 30
![alt text](../images/HorizontalScalingforConcurrentQueries.jpg)

> Scaling horizontally handles **more queries at once**; each individual query continues running at the same speed.

---

## Connection Details (Connecting from outside)
External Clients:
- Power BI
- Tableau
- Python
- Java
- dbt

### 1. Which server do I connect to?

`Server hostname`

### 2. Which SQL Warehouse should I use?

`HTTP Path (ends with the warehouse ID)`

### 3. How do I authenticate?

`Personal Access Token - OAuth`

> ## With these three pieces of information, Databricks knows **exactly which SQL Warehouse to send each query to**.

---

## From Dataset to Visualization (Dashboards)

### Dataset
The **query or table** that feeds data to the dashboard. You write the SQL here or select the tables.

### Visualization
The **graphical widgets.** Each one connects to a dataset from a dropdown menu (by default, it uses the first one and displays as a **bar chart**).

> Key to avoiding duplicate work: **the same dataset feeds multiple charts** without rewriting the query.

### Who uses them:
**Analysts** create them → **Managers** consult them → **Business** decides

> **Pivot tables:** added in the backend (over 64,000 rows without truncation), drill-through, and cross-filtering from 2026
> **Text widgets:** titles, images, and links (render Markdown)
> **Combo, Gantt, Waterfall, and Scatter charts** for specific cases

![alt text](../images/FromDatasettoMultipleVisualizations.jpg)
