# Medallion Architecture
Three layers **(Bronze, Silver and Gold)** that improve data quality as it moves through the Data Lakehouse.

## What is Medallion Architecture?

A design pattern for organizing data within a **Data Lakehouse** using three successive layers.

Data **improves in quality** and becomes increasingly **business-ready** as it moves between layers.

> ### Data Lakehouse
> Combines the flexibility of a **data lake** with the structure and governance of a **data warehouse**. Medallion is how it's organized internally.

### 1. Bronze (raw data)
Raw data, exactly as it came from the source. The source of truth. 

### (Quality)

### 2. Silver (clean & standardized)
Clean, validated, and reliable data, ready for reuse.

### (Business value)

### 3. Gold (business-ready)
Business-ready KPIs, aggregations, and models.


![alt text](../images/MedallionArchitecture.png)

---

## Bronze Layer (the raw data)
Data enters **exactly as it arrives** from its original source, untouched. Nothing is cleaned or transformed.

> The idea is to have a faithful copy of everything that arrives: your **source of truth**. If something goes wrong later, you can always revert to the original, untouched data.

- Faithful copy of the source (Source of truth)
- Allows **reprocessing** without requesting the data again
- Maintains end-to-end **traceability**.

---

## Dos and Don'ts in Bronze
API → Bronze (without any modifications)
```json
{
    "id": "123",
    "message": "New Project",
    "created_time": "2026-06-27T10:30:00Z",
    "likes": "100" //string
}
```

> Even if `likes` comes as a string and there's inconsistent data, in Bronze, **it's not usually corrected.**

### What IS done
- **Engineer from** APIs, CSV, SFTP, GCS...
- **Maintain the** original schema
- **Add metadata:** ingestion_date, source_file
- Partitioning **to facilitate queries**

### What IS NOT done
- Remove duplicates
- Change data types
- Apply business rules
- Create metrics or aggregations

---

## Silver Layer (Clean and Reliable Data)
The data is no longer raw and becomes **clean, standardized, and reliable data.**
- Bronze: data **as received**
- Silver: data **corrected and ready for reuse**

> This is the **first layer where the data is processed: it is cleaned, validated, and standardized.**

---

## From Bronze to Silver: Clean and Standardize

### Typical Transformations
- Clean null or invalid values
- Convert data types
- Remove duplicates
- Standardize names and formats
- Validate quality rules
- Enrich and create reusable entities

> **For interviews:** Silver is where data is **cleaned, validated, and standardized** to become reliable and reusable.

---

