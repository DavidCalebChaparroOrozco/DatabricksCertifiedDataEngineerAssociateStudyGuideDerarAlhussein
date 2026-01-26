## What is a Data Lake?

A centralized repository that stores large volumes of data in its native format, without any pre-structured data.

Maximum flexibility for future use

**Main Features:**
- Centralized storage
- Original format without transformation
- Scalability for large volumes
- Flexible access and use

### Supported Data Types
**Structured**
- Tables, CSV files
- Relational databases

**Semi-structured**
- JSON, XML files
- Server logs

**Unstructured**
- Images, Videos, Audio files
- Free text

---

## What is a Data Warehouse?

A centralized system for storing and querying structured data, processed for analysis and business decision-making.

_It uses an ETL (Extract, Transform, Load) process to ensure data quality_

### Optimized for Analysis
Complex analytical queries, aggregations, and high-performance reports.

### Foundation for Business Intelligence:
Source for dashboards, operational reports, and business metric analysis

### 👍Advantages:
- High data quality and consistency
- Predictable performance for BI
- Strict data governance

### ⚠️ Limitations:
- Less flexible and more expensive
- Not suitable for unstructured data
- Changes require restructuring

## Data Lake VS Data Warehouse

**Two approaches to managing business data**

|                           Data Lake                          	|                Data Warehouse               	|
|:------------------------------------------------------------:	|:-------------------------------------------:	|
|       Data Types: Raw, Semi-structured, and Structured       	|       Data Type: Primarily structured       	|
|               Schema: On-read Schema: Flexible               	|  Schema: Schema-on-write: Defined structure 	|
|         Processing: ETL: Load First, Transform Later         	|  Processing: ETL: Transform before loading  	|
|              Storage: Low Cost, Original Format              	| Storage: Optimized for queries, higher cost 	|
| Use Cases: Machine Learning, Exploratory Analytics, Raw Data 	| Use Cases: BI, reports, historical analysis 	|

---

## What is a Lakehouse?

A lakehouse combines the flexibility of a data lake with the structure and performance of a data warehouse.

_Data Lake Flexibility + Data Warehouse Reliability_

**Data Lake + Data Warehouse = Lakehouse**

### From the Data Lake:
- Flexible and low-cost storage
- Support for all types of data and machine learning

### From the Data Warehouse:
- ACID transactions for reliability
- Data governance, security, and BI support


> ACID defines four properties that ensure database transactions are **reliable, consistent, and secure**, even in the face of failures or concurrent events. 
> * **Atomicity**: The transaction either executes completely or it doesn't execute at all.
> * **Consistency**: Data always adheres to the rules and constraints.
> * **Isolation**: Concurrent transactions do not affect each other.
> * **Durability**: Once committed, changes are not lost.
> 
> ACID is crucial in critical systems such as **banking, RDBMS, and data warehouses**, where data integrity is essential.

---

## Advantages of the Lakehouse
Because it's the future of data architectures.

**A unified platform that eliminates silos and maximizes value**

### Unified Architecture
Eliminates the need to maintain multiple separate systems. A single repository for analytics, data science, and BI.

**Reduces operational complexity and infrastructure costs**

### Optimized Performance
Efficient querying of open-format data. Distributed processing with Apache Spark.

**Fast results without sacrificing flexibility**

### Governance and Security
Centralized access control, auditing, and data lineage. ACID transactions ensure reliability.

**Enterprise-grade regulatory compliance and data quality**

### Cost Optimization
Low-cost storage in open formats. Elastic scaling on demand.

**Pay only for what you use, with no vendor lock-in**

---

## What is Databricks?

A unified data and AI platform designed to efficiently process and analyze large volumes of data.

- **Built on Apache Spark**
- **Based on a lakehouse architecture**
- **Unified analytics, engineering, and ML**

### Main Capabilities
- Ingestion
- Transformation
- Analysis
- ML and AI
- Deployment

### Collaborative Environment
- Teams work simultaneously _(Collaborative Notebooks)_

- Supported Languages ​_​(Python / SQL / Scala / R)_

- Multi-Cloud _(AWS / Azure / GCP) **Automatic Resource Management**_

- Automatic Scaling _Cost optimization without complex management_

---
## Key Components of Databricks
Technology that Powers the Platform

**Three fundamental pillars that integrate reliability, governance, and orchestration**

### Delta Lake
**Reliability in Data Lakes**
Storage layer that provides ACID transactions and reliability to data lakes.

_Key Features:_
- Full ACID transactions
- Data versioning (time travel)
- Schema enforcement and evolution
- Concurrent read and write
- Automatic optimization

_Turns data lakes into enterprise-grade repositories_

### Unity Catalog
**Centralized Governance**
Unified governance system that centralizes the security and control of all data.

_Key Features:_
- Granular access control
- Comprehensive usage auditing
- End-to-end data lineage
- Identity management
- Compliance policies

**Ensures enterprise security and regulatory compliance**

### Workflows & Jobs
**Intelligent Orchestration**
Integrated tools for pipeline orchestration, automation, and monitoring.

_Key Features:_
- Orchestration of complex jobs
- Version control with Git
- Advanced scheduling
- Real-time monitoring
- Alerts and notifications

**Automates and manages end-to-end data pipelines**

---
## Databricks Architecture
Layered Structure

1. Cloud Infrastructure **Storage, Networking, and Virtual Machines (AWS/Azure/GCP)**
2. Databricks Runtime **Optimized Runtime Environment (Spark + Delta Lake)**
3. Governance (Unity Catalog) **Access Control, Security, and Auditing**
4. Databricks Workspace **User Interface and Collaborative Experience**​
---
### Layer 1: Cloud Infrastructure
The foundation of everything.

Databricks runs on cloud providers such as AWS, Azure, or GCP. It does not manage physical infrastructure.

**Key resources in this layer:**
- Storage (Data Lakes, Object Storage)
- Virtual Networks (VPCs)
- Virtual Machines (Compute)

**Provides the power and scalability for Big Data**

### Cloud Providers
Multi-cloud by design
- AWS
    - Storage: Amazon S3
    - Compute: EC2 Instances
    - Network: VPC
- Azure
    - Storage: Azure Data Lake Storage
    - Compute: Virtual Machines
    - Network: Virtual Networks
- GCP
    - Storage: Google Cloud Storage
    - Compute: Compute Engine
    - Network: VPC Networks

### Layer 2: Databricks Runtime
Where Processing Occurs

**Databricks Runtime**
The optimized runtime environment for data processing.

It executes calculations, transformations, and models in a distributed and efficient manner.

_Includes Apache Spark and optimized key components_

**Apache Spark**
Distributed processing engine for big data.

_Key Capabilities:_
- In-memory processing
- Distributed computing
- Batch and streaming
**Foundation for big data processing**

**Delta Lake**
Storage layer for reliable data.

_Key Capabilities:_
- ACID transactions
- Time travel (versioning)
- Schema enforcement
**Enterprise reliability for data lakes**

_This layer combines processing power with reliability guarantees._

## Layer 3: Governance (Unity Catalog)
Centralized Control and Security
**Governance**
_Unity Catalog_
This layer is responsible for bringing order and control to the data. It is the core of the architecture.

It defines who can access what information, what permissions each user or team has, and how data usage is audited.

- **Access Control:** _Granular permissions per user, group, and resource_
- **Auditing:** _Complete logging of all data operations_
- **Data Lineage:** _Complete traceability of the source and transformations_
- **Identity Management:** _Integration with enterprise systems (AD, SSO)_

### Why it's critical
Large organizations
- Prevents unauthorized access
- Maintains regulatory compliance
- Complete visibility of data usage
- Enterprise-grade security

**Databricks can be used securely in large organizations.**

**Compliance with GDPR, HIPAA, SOC 2, and other standards**

## Layer 4: Databricks Workspace
User Interface and Collaboration

**Databricks Workspace**
The interface layer where data engineers, analysts, and data scientists collaborate, run jobs, create pipelines, and visualize results.

**Collaborative environment for working on the same data using multiple languages.**

**Interactive Notebooks**
_Real-time simultaneous editing (Py, SQL, R)._

**Visualizations**
_Built-in dashboards without external tools._

**Jobs and Workflows**
_Orchestration of complex tasks and pipelines._

**Collaboration**
_Shared and unified workspace for teams._

_The layered architecture integrates storage, compute, security, and UI. It is the foundation of the lakehouse approach, eliminating silos and unifying data, analytics, and AI._

---

## Control Plane VS Data Plane
Separation of Responsibilities

Databricks separates its architecture into two to isolate management from execution.

_Control Plane: Manages | Data Plane: Executes_

### Control Plane

Managed by Databricks
Orchestrates, coordinates, and manages the platform without touching your data.

**Components:**
- Web interface and notebooks
- Cluster and job management
- Platform APIs

**Your point of interaction with Databricks**
**Think and coordinate**

### Data Plane
In your own cloud account
Where your data resides and the actual computing takes place.

**Components:**
- Spark Clusters (VMs)
- Storage (S3/ADLS)
- Governed Data (Unity Catalog)

**Your data NEVER leaves your environment.**
**Run and store**

**Advantages of This Separation**
- Data security
- Control and compliance
- Simplified maintenance

---

## What is Apache Spark?
Distributed Processing Engine
A distributed data processing engine for analyzing
large volumes of information quickly and efficiently.

_It processes data in parallel using multiple machines, instead of relying on a single server._

How Does It Work?

- It divides the data into smaller pieces.

- It distributes the pieces among the cluster nodes.

- Each node processes its portion in parallel.

- Spark combines the final results.

**It processes big data much faster than traditional systems**

### In-Memory Processing
One of the keys to Spark's power is its in-memory (RAM) processing capability.

_Instead of reading/writing to disk, Spark keeps data in memory, speeding up access._

**SIGNIFICANTLY accelerates iterative tasks**
Ideal use cases:
- Advanced analytics
- Repetitive queries
- Machine learning models

**Spark is a pillar of the modern data ecosystem.**
**Databricks is built on Apache Spark**

## Features of Apache Spark
Why It's the Big Data Standard

_Spark isn't limited to a single type of processing - it's a versatile and powerful platform_

- **Multi-Language Support**
    It allows you to work with Python, Scala, SQL, Java, and R in the same engine

    _Different technical profiles can use the same platform without learning new tools_

- **High Performance**
    In-memory processing up to 100x faster than MapReduce
    _Results in minutes instead of hours_

- **Real-Time Processing**
    Spark Streaming allows you to process data in real time with low latency
    _Ideal for use cases such as fraud detection or IoT_

- **Unified Processing**
    Batch, streaming, SQL, machine learning - all in the same engine
    _You don't need multiple specialized tools_

- **Massive Scalability**
    Scale from a laptop to clusters of thousands of nodes
    _The same code works in development and production_

- **Rich Ecosystem**
    Integration Supports HDFS, S3, Delta Lake, Kafka, and hundreds of connectors
    _Connect to any data source or destination_

---

## Databricks Filesystem (DBFS)

Storage Abstraction
DBFS is a virtual file system that allows you to interact with data in cloud storage (S3, ADLS, GCS) as if it were a local file system.


It's an abstraction layer, not a standalone storage system.

**How ​​It Works:**
- Unified System:
    _Uniform access to data from notebooks, jobs, and clusters._
- Versatile Storage:
    _Stores files, datasets, models, and logs._

### Why It Matters
- **Simplifies Access**
    _Acts as a bridge, eliminating complex credential configuration for each access._

- **Abstracts Complexity**
    _You don't need to manage cloud storage SDKs or APIs directly._

- **Focus on Analytics**
    _Allows you to concentrate on data processing and analysis, not the infrastructure._

- **Native Spark Integration**
    _Optimized for high-performance distributed reads and writes with Spark._