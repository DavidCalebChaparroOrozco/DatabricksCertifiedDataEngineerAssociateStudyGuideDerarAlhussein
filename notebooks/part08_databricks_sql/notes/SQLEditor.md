# SQL Editor

The Lakehouse's **SQL & AI** tools: query, prepare data without code, query in natural language, and monitor with alerts

- SQL Editor
- Visual Data Prep
- Genie Agents
- Alerts

```SQL
-- monthly_sales  (Last 30 days)
SELECT country, SUM(sales) AS total
FROM gold.fact_sales
WHERE order_date >= CURRENT_DATE - 30
GROUP BY country 
ORDER BY total DESC;
```

---

## What is the SQL Editor?

The Lakehouse environment designed for working with SQL on your data (without using Python or Scala).

- **Write:** SQL queries with autocomplete on the workspace.

- **Execute:** Directly against the Lakehouse tables.

- **Save:** Reusable and shareable queries with your team.

It's the primary tool for:

Data Analysts, Data Engineers, Business Users

```SQL
SELECT c.country, COUNT(c.id) AS orders
FROM silver.orders o
JOIN gold.dim_customer c
ON o.cust_id = c.id
GROUP BY c.country;
```

**The interface is similar to:**

BigQuery, Azure Data Studio, DBeaver

If you've used any of these, you'll feel right at home from the start.

---

## What can you do with it?

- **Query**: Tables, views, **joins**, aggregations... just the SQL you already know, directly on the Lakehouse.
  - SELECT
  - JOIN
  - GROUP BY
  - CREATE VIEW

- **Save queries**: Store queries for later reuse. **You don't have to rewrite them.**
  - Monthly_Sales
  - Active_Users
  - Revenue_Dashboard

- **Share**: Share with other users in the **workspace** so they can run or modify it.

- **Display**: Create charts directly from the query and add them to your **dashboards**.

---

## SQL Editor — Explore, Analyze, Share

Use it when you...

* Want to **quickly explore and analyze data**
* Only need to write **SQL queries**
* Want to create **dashboards and visualizations**
* Need to **share queries and results** with your team
* Don't need to write application code

> **Ideal for the day-to-day work of a Data Analyst.**

### Notebook — Program, Transform, Automate

Use it when you...

* Need to write code in **Python or Scala**
* Want to build **data transformation pipelines (ETL/ELT)**
* Have **Machine Learning** or advanced analytics needs
* Want to **automate data workflows and processes**
* Need to combine **SQL with Python or Scala**

> **The territory of Data Engineers and Data Scientists.**

---

## Visual Data Prep
A **no-code/low-code** tool for **cleaning, transforming, and preparing data** from a graphical interface (without writing SQL or Python)

### Instead of:
```python
df.dropDuplicates().fillana(0)...
```

### You do:
Click on the column → menu operation

> And if you want, **you can see the generated code** below

Same idea as:
- Power Query
- Alteryx
- Tableau Prep
- Trifacta → Google