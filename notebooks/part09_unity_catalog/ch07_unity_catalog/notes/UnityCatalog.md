# Unity Catalog

**Unity Catalog is Databricks' central data governance system.**

It helps control:

* **What data exists**
* **Who can access it**
* **What they can do with it**
* **Where the data is stored**
* **How data is accessed and tracked**

## Key Concepts

### Data Governance

The rules that control **who can access data, what they can do with it, and how the data is managed and tracked**.

### Metastore

The **central catalog** that stores information about data assets, such as catalogs, schemas, tables, views, and permissions.

Think of it as the **inventory or directory of your data**.

### Storage Credential

The **identity Databricks uses to authenticate to cloud storage**.

It allows Databricks to access storage such as AWS S3, Azure Data Lake Storage, or Google Cloud Storage.

### External Location

A **secure connection between Unity Catalog and a specific path in cloud storage**.

It defines **which storage path Databricks is allowed to access** and connects that path to a Storage Credential.

### Data Lineage

Shows **where data comes from and where it goes**.

For example:

```text
raw_customers → cleaned_customers → customer_report
```

This helps you understand the impact of changing a table or column.

## Three-Level Namespace

Unity Catalog organizes data using a **three-level namespace**:

```sql
catalog.schema.table
```

For example:

```sql
SELECT *
FROM sales.analytics.customers;
```

* `sales` → **Catalog**
* `analytics` → **Schema**
* `customers` → **Table**

Think of it as:

**Catalog → Schema → Table**

## What happens when you run the query?

```sql
SELECT *
FROM sales.analytics.customers;
```

### 1. Unity Catalog finds the table

`customers` is registered in the **Metastore**.

### 2. Unity Catalog checks permissions

The user must have the required permission, such as:

```text
SELECT
```

### 3. Unity Catalog determines where the data is stored

The table points to a storage path, and the **External Location** defines the authorized path.

### 4. Databricks uses the Storage Credential

The **Storage Credential** provides the identity Databricks uses to authenticate to the cloud storage.

### 5. Spark reads and processes the data

**Spark** accesses the underlying data, processes the query, and returns the result.

## Easy Way to Remember

> **Unity Catalog decides WHO can access WHAT and WHERE.**

* **Metastore** → Where the data is registered
* **Permissions** → What the user can do
* **Storage Credential** → Identity used to access cloud storage
* **External Location** → Authorized storage path
* **Spark** → Reads and processes the data

---

## What is Data Governance?

**Data Governance** is the set of **policies, processes, roles, and technologies** an organization uses to make sure its data is:

* **Secure** → Only authorized people can access it.
* **Reliable** → People can trust the data.
* **Accessible** → The right people can find and use it.
* **High-quality** → The data is accurate, complete, and consistent.
* **Used correctly** → Data is used according to organizational rules and policies.

> **Objective:** Make data a **trusted and valuable asset** for the entire organization.

### Questions Data Governance Helps Answer

* **Who can access the data?**
* **How do we know the data is accurate and reliable?**
* **Who created or modified the data?**
* **Who owns or is responsible for the dataset?**
* **Where does the data come from?**
* **How is sensitive information protected?**

---

## The Bank Case

A simple story that shows **why data governance is necessary** and what can happen when it is missing.

### Act 1 — Day 1

A new analyst joins the bank.

He can access the **customer table**:

| Name           | ID Number  | Salary |
| -------------- | ---------- | -----: |
| Maria Gomez    | 12.345.678 | $2,400 |
| Luis Pardo     | 23.456.789 | $5,100 |
| Ana Rios       | 34.567.890 | $4,500 |
| David Chaparro | 45.678.901 | $3,500 |

There are:

* **No permissions**
* **No roles**
* **No access controls**
* **No access logs**

On his first day, the analyst can see **ID numbers, salaries, and other sensitive customer information**.

Nobody intentionally gave him this access.

**Nobody configured the access rules.**

Six months pass.

---

### Act 2 — The Audit

A regulatory body arrives.

The auditor asks:

> **"Who has accessed customer data during the last 12 months?"**

The bank needs to provide:

* Access history
* User permissions
* Regulatory compliance evidence
* A record of who accessed the data and when

---

### Act 3 — The Answer

The bank checks the audit log:

```sql
SELECT *
FROM audit_log;
```

Result:

```text
0 rows returned

-- No access records exist
```

So the honest answer is:

> **"We don't know."**

Without access records, there is **no evidence** of who accessed the data.

Without evidence, the bank cannot properly demonstrate to the regulator that customer data was controlled and protected.

> **This is exactly what Data Governance is designed to prevent.**

Data governance provides the **rules, controls, ownership, permissions, and visibility** needed to keep sensitive data secure and accountable.

---

## The Pillars of Data Governance (1–3)

The first three pillars focus on **controlling access, trusting the data, and knowing who is responsible for it**.

### Security

**Security** controls **who can access each piece of data** and what they are allowed to do with it.

Not every role should have access to the same information.

**Example — Salary Table:**

| Role            | Access |
| --------------- | ------ |
| Human Resources | ✅      |
| Managers        | ✅      |
| Marketing       | ❌      |
| Interns         | ❌      |

> **In Unity Catalog:** Access is controlled using permissions such as **GRANT** and **REVOKE**, typically assigned to users or groups.

---

### Quality

**Data Quality** ensures that the information is **accurate, valid, complete, and consistent**.

Rules can be used to detect incorrect data and prevent bad records from entering the system.

**Example:**

```text
Incoming record

Name: Caleb       ✅
Age: -10          ⚠️
```

Rule:

```text
Age > 0
```

If the age is `-10`, the record should be **rejected or flagged as invalid**.

> **In Unity Catalog:** Data quality can be supported through **constraints on Delta tables**, along with other data-quality mechanisms.

---

### Ownership

**Ownership** means that every important dataset has a **person or team responsible for it**.

**Example — Customer Table:**

```text
Owner: Sales Team
Created: 2024-03-12
Contact: #sales-data
Last revision: 3 days ago
```

If you find a problem with the data, you know **who is responsible for it and who to contact**.

> **In Unity Catalog:** Data objects can have an assigned **owner**, making responsibility and accountability clear.

---

## The Pillars of Governance (4–6)

The second three pillars focus on **understanding where data comes from, tracking what happens to it, and keeping an organized inventory of data assets**.

### Lineage

**Data Lineage** shows the **complete path of the data**: where it comes from, how it is transformed, and what depends on it.

**Example — Data Path:**

```text
CSV → Bronze → Silver → Gold → Dashboard
```

Lineage helps answer questions such as:

* **Where did this data come from?**
* **What processes transformed the data?**
* **What tables or reports depend on this data?**

For example, if a column in the Silver layer changes, lineage can help identify **which downstream tables or dashboards could be affected**.

> **In Unity Catalog:** Lineage can be automatically captured **table by table and column by column**.

---

### Audit

**Auditing** means keeping a record of **important actions performed on the data**: who did what and when.

**Example:**

```text
10:00  Carlos checks customer data
10:15  Ana modifies permissions
10:30  Pedro deletes a table
```

Audit logs help answer:

* **Who accessed the data?**
* **Who changed something?**
* **What action was performed?**
* **When did it happen?**

This is important for both **security and regulatory compliance**.

> **In Unity Catalog:** Audit logs provide a record of activities and actions performed on data and data assets.

---

### Catalog

A **Data Catalog** is an **organized inventory of the organization's data assets**.

It helps people discover and understand what data is available.

**Example:**

```text
Sales
├── Customers
└── Orders

Marketing
└── Campaigns

Finance
└── Invoices
```

Each data asset can include information such as:

* **Description**
* **Owner**
* **Creation date**
* **Permissions**
* **Tags**

A catalog makes it easier to answer:

> **"What data do we have, and what does it mean?"**

> **In Unity Catalog:** **Catalog Explorer** provides a central place to discover and explore your data assets.

---

## Why Is Data Governance Important?

The same company can have **the same data**, but two completely different realities depending on whether data governance is in place.

### Without Governance

* ❌ **Everyone can access everything**
* ❌ **Multiple versions** of the same table exist
* ❌ Nobody knows **which version is correct**
* ❌ The **origin of the data** is unclear
* ❌ Nobody knows **who is responsible** for the data
* ❌ People **lose trust in the information**

> Without governance, data becomes difficult to **control, understand, and trust**.

### With Data Governance

* ✅ **Controlled access** — People only access the data they need
* ✅ **Reliable data** — Data is accurate and trustworthy
* ✅ **A single source of truth** — Everyone works with the same trusted data
* ✅ **Comprehensive auditing** — Actions can be tracked and reviewed
* ✅ **Regulatory compliance** — The organization can demonstrate that data is properly managed
* ✅ **Better collaboration** — Teams can easily discover, understand, and use shared data

> **Data Governance turns data from something difficult to control into a trusted organizational asset.**
---

## What Is Unity Catalog?

**Unity Catalog is Databricks' centralized data governance solution.**

It provides a single place to **organize, secure, manage, and monitor** data and other resources such as AI models.

It helps answer:

* **Who can access the resource?**
* **What are they allowed to do?**
* **Where is the resource located?**
* **Who used or changed it?**
* **How is the resource being used?**

> **In short:** Unity Catalog is like the **data administrator for Databricks**. It organizes resources, controls permissions, and keeps track of how they are accessed and used.

---

## Why Does Unity Catalog Exist?

Three different teams may work with the **same Data Lake**, but they have different responsibilities and access needs.

### The Teams

* **Data Engineering:** Builds pipelines and performs ETL
* **Data Science:** Builds models and works with features
* **Analytics:** Creates dashboards and runs SQL queries

### The Same Data Lake

All teams can work with the same physical storage:

```text
S3
ADLS
Google Cloud Storage
```

> ⚠️ **There is no need to create separate copies of the data for each team.** Everyone can work with the same data, which makes **access control and governance critical**.

### The Problem

When everyone shares the same Data Lake:

* Not everyone should have access to **all data**
* Some data may be **confidential or sensitive**
* The organization needs a **history of who accessed or changed the data**
* Teams need to know **where the data comes from**
* It should be clear **which dashboards, reports, or models depend on specific data**

> **Unity Catalog solves these governance problems from a centralized place**, while allowing different teams to work with the same underlying data.
---

## The Architecture

**Unity Catalog acts as a governance layer between users and the data.**

A simplified flow looks like this:

```text
User
  ↓
SQL Warehouse / Notebook
  ↓
Unity Catalog
  ├── Metastore: metadata + governance rules
  ├── Permissions
  ├── Storage Credentials
  ├── External Locations
  ├── Managed Storage
  └── Data Lineage
  ↓
Spark
  ↓
S3 / ADLS / GCS
  ↓
Delta / Parquet files
```

### What Happens When a User Runs a Query?

1. **The user launches a query** from a SQL Warehouse or Notebook.
2. **Unity Catalog checks the metadata and access rules.**
3. Unity Catalog determines **whether the user is authorized to access the requested data**.
4. If access is allowed, the appropriate **storage identity and location** are used.
5. **Spark reads the underlying files** from the Data Lake.
6. Spark processes the data and **returns the result to the user**.

### The Most Misunderstood Idea

#### ❌ Unity Catalog Does Not Store Your Data

The actual data remains in your **Data Lake**:

```text
Amazon S3
ADLS
Google Cloud Storage
```

The data is typically stored as formats such as:

```text
Delta
Parquet
```

#### ✅ Unity Catalog Stores Metadata and Governance Rules

Unity Catalog keeps information such as:

* **Where a table is located**
* **Who owns the data**
* **Who has access**
* **What permissions they have**
* **Which storage credentials can be used**
* **Which storage locations are authorized**
* **How data flows between assets**

#### ✅ Spark Is Still the Engine That Reads the Data

Think of the architecture as:

```text
Unity Catalog → Controls and authorizes access
Spark         → Reads and processes the data
Data Lake     → Stores the actual data
```

> **If Unity Catalog does not authorize the access, the compute engine cannot proceed with reading the governed data.**

---

## What Happens When You Execute a `SELECT`?

The complete flow from the **user's query to the actual data**.

```text
User
  ↓
SELECT * FROM sales.analytics.customers;
  ↓
SQL Warehouse / Notebook
  ↓
Unity Catalog
  ├── Does the table exist?        ✅
  ├── Does the user have SELECT?   ✅
  ├── Which identity is used?      → Storage Credential
  └── Which path can be accessed?  → External Location
  ↓
Spark
  ↓
Data Lake
  └── Delta / Parquet files
```

### Step-by-Step

### 1. User Executes the Query

The user runs:

```sql
SELECT *
FROM sales.analytics.customers;
```

### 2. SQL Warehouse or Notebook Receives the Query

The query is sent to a **SQL Warehouse** or executed from a **Notebook**.

### 3. Unity Catalog Checks Access

Unity Catalog checks the **Metastore** and verifies:

* ✅ **The table exists**
* ✅ **The user has `SELECT` permission**
* ✅ **The appropriate storage identity is available**
* ✅ **The requested storage path is authorized**

### 4. Spark Reads the Data

Once access is authorized, **Spark performs the physical read** of the underlying data files.

### 5. The Data Lake Provides the Data

The actual data is stored in the Data Lake, typically as:

```text
Delta / Parquet
```

For example:

```text
Amazon S3
ADLS
Google Cloud Storage
```

> **Simple mental model:**
>
> **User asks → SQL executes → Unity Catalog authorizes → Spark reads → Data Lake provides the data.**

---

## Where Does Managed Storage Fit In?

So far, we have focused on **reading existing data**.

But what happens when you **create a new table**?

### Creating a New Table

Suppose you run:

```sql
CREATE TABLE customers (
    id BIGINT,
    name STRING
);
```

Notice that you **did not specify a storage path**.

So the question is:

> **Where does Databricks store the table?**

The answer depends on whether the table is **external** or **managed**.

### External Location → External Tables

With an **external table**, you **choose the storage path**.

```text
External Location
        ↓
You define the path
        ↓
External Table
```

The data remains in a location that you explicitly configure and control.

### Managed Storage → Managed Tables

With a **managed table**, **Databricks determines the storage location for you** based on the managed storage configuration.

For example, an administrator can configure a managed location at the catalog level:

```sql
CREATE CATALOG sales
MANAGED LOCATION 's3://company-managed-storage/sales/';
```

Then, when you create a table without specifying a path:

```sql
CREATE TABLE customers (
    id BIGINT,
    name STRING
);
```

Databricks automatically stores the table under the configured managed location, for example:

```text
s3://company-managed-storage/
└── sales/
    └── analytics/
        └── customers/
```

### The Key Difference

|                                         | External Table                         | Managed Table                           |
| --------------------------------------- | -------------------------------------- | --------------------------------------- |
| **Who defines the path?**               | You                                    | Databricks                              |
| **Path specified in table definition?** | Typically yes                          | No                                      |
| **Storage controlled by**               | External Location                      | Managed Storage                         |
| **Main idea**                           | "I tell Databricks where the data is." | "Databricks decides where to store it." |

> **Simple mental model:**
>
> **External Location → You choose the path.**
> **Managed Storage → Databricks chooses the path based on the configured location.**

---

## Who Defines All This Configuration?

One of the most important ideas to understand is:

> **The Metastore does not make decisions.**

The **Databricks Administrator** defines the configuration and governance rules.

### Databricks Administrator

The administrator configures these settings, usually as part of the initial setup:

* **Storage Credential:** `aws_prod` → IAM Role
* **External Location:** `ventas_location` → `s3://empresa-data/ventas/`
* **Catalog + Managed Storage:** `ventas` → `s3://company-managed-storage/`
* **Permissions:** Which users or groups can access which objects

These configurations are then **stored in the Metastore**.

### Metastore

The Metastore keeps a record of the configuration:

```text
Storage Credential: aws_prod
External Location: ventas_location
Catalog: ventas
Permissions: Analyst → SELECT
```

Think of the Metastore as a **central configuration and metadata store**.

> **The Metastore does not decide what should happen. It stores the configuration and rules that have been defined.**

### When a Query Arrives

When a user runs a query, **Unity Catalog reads the configuration stored in the Metastore and applies the appropriate rules**.

```text
Administrator
      ↓
Defines configuration and permissions
      ↓
Metastore
      ↓
Stores the configuration
      ↓
Unity Catalog
      ↓
Reads and applies the rules
      ↓
Spark
      ↓
Reads the authorized data
```

> **Simple mental model:**
>
> **Administrator → Defines the rules**
> **Metastore → Remembers the rules**
> **Unity Catalog → Applies the rules**
> **Spark → Reads the data**
>
> **Configure it once. Unity Catalog uses those rules whenever the data is accessed.**


---

## The Three-Level Namespace

The **three-level namespace** is how Unity Catalog identifies and organizes data objects.

The structure is:

```text
catalog.schema.object
```

For example:

```text
sales.analytics.customers
```

### The Three Levels

**Catalog** → The main container for organizing data.

**Schema** → A logical group of related objects. It was traditionally called a **database**.

**Object** → The actual data asset, such as a **table, view, or function**.

### Example: A Real Company

A company might organize its data like this:

```text
marketing
├── bronze
│   └── campaigns
├── silver
│   └── campaigns_clean
└── gold
    └── campaign_metrics

finance
├── bronze
└── gold
    └── monthly_revenue

hr
└── default
    └── employees
```

The full names are:

```text
marketing.gold.campaign_metrics
finance.gold.monthly_revenue
hr.default.employees
```

### Why Is This Useful?

The three-level namespace gives every object a **unique and consistent name** within Unity Catalog.

By reading:

```text
marketing.gold.campaign_metrics
```

you immediately know:

* **Catalog:** `marketing`
* **Schema:** `gold`
* **Object:** `campaign_metrics`

> **Simple mental model:**
>
> **Catalog → Schema → Object**
>
> Think of it like:
>
> **Building → Floor → Room**
>
> The namespace tells you **exactly where the object belongs**, making data easier to organize, find, and govern.

---

## What Does Each Level Represent?

The three-level namespace follows this structure:

```text
catalog.schema.object
```

Each level has a different responsibility:

### Catalog

The **highest-level container** in Unity Catalog.

A catalog usually represents a **business domain, environment, or organizational unit**.

Examples:

```text
dev
qa
prod
marketing
finance
engineering
```

Think of the catalog as the **main container** that separates large areas of your data organization.

---

### Schema

A **schema groups related objects within a catalog**.

This is where organizations often implement the **Medallion Architecture** or other logical data layers.

Examples:

```text
bronze
silver
gold
analytics
staging
reporting
```

For example:

```text
sales.bronze
sales.silver
sales.gold
```

Think of a schema as a **sub-container that organizes related data assets**.

---

### Object

The **actual resource** you work with.

Objects can include:

* **Tables** → `customers`, `orders`
* **Views** → `sales_summary`
* **Functions**
* **Volumes**
* **AI/ML models**

For example:

```text
sales.gold.customers
```

Where:

```text
sales     → Catalog
gold      → Schema
customers → Object
```

> **Simple mental model:**
>
> **Catalog → Schema → Object**
>
> **Big container → Logical group → Actual resource**

---

## Why Did We Move from 2 Levels to 3?

Before Unity Catalog, data was commonly organized using a **two-level namespace**:

```text
database.table
```

Unity Catalog introduced a **three-level namespace**:

```text
catalog.schema.table
```

### The Difference

| Without Unity Catalog                    | With Unity Catalog                                |
| ---------------------------------------- | ------------------------------------------------- |
| `database.table`                         | `catalog.schema.table`                            |
| 2 levels                                 | 3 levels                                          |
| Less isolation                           | Better organization and governance                |
| Permissions mainly at the database level | Permissions at catalog, schema, and object levels |

### Why Add the Third Level?

#### Better Data Organization

The **catalog** provides an additional layer for organizing data by:

* Business domain
* Environment
* Team
* Organizational unit

#### Hierarchical Permissions

Permissions can be managed at different levels:

```text
Catalog
  ↓
Schema
  ↓
Object
```

This gives administrators more **granular control** over access.

#### Avoid Name Conflicts

Different teams can have objects with the same names without creating conflicts.

For example:

```text
marketing.analytics.customers
finance.analytics.customers
```

Both teams can have:

```text
analytics.customers
```

because they belong to **different catalogs**.

### Why Is This Important?

Without the catalog level, organizing a large company's data across many teams and domains becomes more difficult.

With the three-level namespace, the entire organization can share the **same Metastore** while keeping data logically separated:

```text
Metastore
├── marketing
│   └── analytics
│       └── customers
│
└── finance
    └── analytics
        └── customers
```

> **The third level provides an additional layer of isolation, organization, and governance, allowing the entire company to use the same Metastore without naming conflicts.**
