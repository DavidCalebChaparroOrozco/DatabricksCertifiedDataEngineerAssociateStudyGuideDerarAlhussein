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

