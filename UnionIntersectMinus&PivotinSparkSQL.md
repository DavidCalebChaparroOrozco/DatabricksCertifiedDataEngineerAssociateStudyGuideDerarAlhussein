# `explode()`, `collect_set`, Join Operations, Set Operations, Pivot Tables

## `explode()` Function

A single row from an array
| student_id | name  | course (array) |
|------------|-------|--------|
| S001       | David | C01, C03, C06    |


### `explode(courses)`
One row for each element of the array
| student_id | name  | course |
|------------|-------|--------|
| S001       | David | C01    |
| S001       | David | C03    |
| S001       | David | C06    |

### What does it do?
Converts each element of an array into a separate row
- An array with 3 elements → 3 rows
- Non-array columns are duplicated
- Ideal for de-nesting data
> **Use cases:** Arrays of courses, labels, categories, tags

---

## `explode()` in Action

### BEFORE
Columns 'courses' contain arrays
| student_id | name  | course |
|------------|-------|--------|
| S001       | David | [C01, C03]    |
| S002       | Jhon Wick | [C02, C04, C05]    |
| S003       | Bender | [C01]    |
> 3 rows in total

### `explode(courses)`
by 'courses' column

### AFTER
One row for each element of the array
| student_id | name  | course |
|------------|-------|--------|
| S001       | David | C01    |
| S001       | David | C03    |
| S002       | Jhon Wick | C02    |
| S002       | Jhon Wick | C04    |
| S002       | Jhon Wick | C05    |
| S003       | Bender | C01    |

> 6 rows in total

---

## `collect_set`

### `GROUP BY` + `collect_set`
Multiple rows per group

| student_id | ...  | course |
|------------|-------|--------|
| S001       | → | [C01, C03]    |
| S001       | → | [C03, C06]    |
| S001       | → | [C01, C07]    |

Groups and removes duplicates
| student_id | ...  | course |
|------------|-------|--------|
| S001       | → | [C01, C03, C06, C07]    |
Single row per group → array of unique values

### What does `collect_set` do?
An aggregation function that returns an array with the unique values ​​of one column per group
- Automatically removes duplicates
- Returns an array as a result
- Used in conjunction with `GROUP BY`

### `collect_list` vs `collect_set`
- **`collect_list`:** Keeps all values, including duplicates

- **`collect_set`:** Only unique values, no duplicates.

---

## `collect_set` in Action

### BEFORE
Multiple rows per student

| student_id | ...  | course |
|------------|-------|--------|
| S001       | → | **[C01, C03]**    |
| S001       | → | [**C03**, C06]    |
| S001       | → | [**C01**, C07]    |
| S002       | → | [C02, C05]    |
| S002       | → | [C02, C08]    |

> C01 and C03 appear multiple times in S001

### → `GROUP BY` + `collect_set`
Groups and removes duplicates

### AFTER
One row per student, array of unique values
| student_id | ...  | course |
|------------|-------|--------|
| S001       | → | [C01, C03, C06, C07]    |
| S002       | → | [C02, C05, C08]    |

> Duplicates removed: C01 and C03 appear only once

---

## Join Operations

### Combine **columns** from two tables based on a common condition

![alt text](JoinOperations.png)

---

## Join Operations in Action

### Sample Tables

**Table A: Students**

| id | name   |
| -- | ------ |
| 1  | David  |
| 2  | Maxi   |
| 3  | Andrea |

**Table B: Enrollments**

| student_id | course  |
| ---------- | ------- |
| 1          | Math    |
| 2          | History |
| 4          | Science |

**JOIN condition:**
`A.id = B.student_id`

---

### INNER JOIN

Returns only matching rows in both tables.

| id | name  | course  |
| -- | ----- | ------- |
| 1  | David | Math    |
| 2  | Maxi  | History |

---

### LEFT JOIN (LEFT OUTER JOIN)

Returns all rows from **Table A**, with matches from B (or NULL).

| id | name   | course  |
| -- | ------ | ------- |
| 1  | David  | Math    |
| 2  | Maxi   | History |
| 3  | Andrea | NULL    |

> Andrea (id = 3) has no enrollment

---

### RIGHT JOIN (RIGHT OUTER JOIN)

Returns all rows from **Table B**, with matches from A (or NULL).

| id   | name  | course  |
| ---- | ----- | ------- |
| 1    | David | Math    |
| 2    | Maxi  | History |
| NULL | NULL  | Science |

> student_id = 4 does not exist in Table A

---

### FULL JOIN (FULL OUTER JOIN)

Returns all rows from both tables, matching where possible.

| id   | name   | course  |
| ---- | ------ | ------- |
| 1    | David  | Math    |
| 2    | Maxi   | History |
| 3    | Andrea | NULL    |
| NULL | NULL   | Science |

---

### LEFT ANTI-JOIN

Returns rows from **Table A** that have **no match** in Table B.

| id | name   |
| -- | ------ |
| 3  | Andrea |

---

### RIGHT ANTI-JOIN

Returns rows from **Table B** that have **no match** in Table A.

| student_id | course  |
| ---------- | ------- |
| 4          | Science |

---

## Notes

* INNER JOIN → only matches
* LEFT JOIN → all A + matches
* RIGHT JOIN → all B + matches
* FULL JOIN → everything
* ANTI-JOIN → only non-matching rows

---

## `Set Operations`

### JOIN
Adds columns horizontally

### VS

### SET OPERATIONS
Stacks rows vertically

### UNION ALL
Combines all rows from both tables, including duplicates

### INTERSECT
Returns only the rows common to both tables

### MINUS
Returns rows from the first table that do not appear in the second

> ⚠️ **Mandatory Requirements:**
> - Same number of columns in both tables
> - Compatible data types in each column

---

# Base Tables

### Table A (Students)

| id | name   |
| -- | ------ |
| 1  | David  |
| 2  | Maxi   |
| 3  | Andrea |

### Table B (Enrollments)

| student_id | course  |
| ---------- | ------- |
| 1          | Math    |
| 2          | History |
| 4          | Science |

---

## JOIN (Horizontal Combination)

**JOIN condition:** `A.id = B.student_id`

### INNER JOIN

| id | name  | course  |
| -- | ----- | ------- |
| 1  | David | Math    |
| 2  | Maxi  | History |

---

### LEFT JOIN

| id | name   | course  |
| -- | ------ | ------- |
| 1  | David  | Math    |
| 2  | Maxi   | History |
| 3  | Andrea | NULL    |

---

### RIGHT JOIN

| id   | name  | course  |
| ---- | ----- | ------- |
| 1    | David | Math    |
| 2    | Maxi  | History |
| NULL | NULL  | Science |

---

### FULL JOIN

| id   | name   | course  |
| ---- | ------ | ------- |
| 1    | David  | Math    |
| 2    | Maxi   | History |
| 3    | Andrea | NULL    |
| NULL | NULL   | Science |

---

##  SET OPERATIONS (Vertical Combination)

To apply set operations, both tables must have:

* Same number of columns
* Compatible data types

👉 So we reshape them:

### Table A' (Students)

| id | value  |
| -- | ------ |
| 1  | David  |
| 2  | Maxi   |
| 3  | Andrea |

### Table B' (Enrollments mapped)

| id | value   |
| -- | ------- |
| 1  | Math    |
| 2  | History |
| 4  | Science |

---

### UNION ALL (keeps duplicates)

| id | value   |
| -- | ------- |
| 1  | David   |
| 2  | Maxi    |
| 3  | Andrea  |
| 1  | Math    |
| 2  | History |
| 4  | Science |

---

### INTERSECT (common rows only)

| id                    | value |
| --------------------- | ----- |
| *(no rows in common)* |       |

---

### MINUS (A' - B')

| id | value  |
| -- | ------ |
| 1  | David  |
| 2  | Maxi   |
| 3  | Andrea |

---

Here’s a clean Markdown example that follows your explanation and shows the transformation clearly:

---

##  Pivot Tables

### What is a Pivot Table?

It transforms data from **long format → wide format**.

* **Long Format:** Many rows, few columns
* **Wide Format:** Few rows, many columns

---

### Analogy: The notebook

From a list of grades (long format):

### Long Format (raw data)

| student | subject | grade |
| ------- | ------- | ----- |
| David   | Math    | 4     |
| David   | History | 5     |
| Maxi    | Math    | 3     |
| Maxi    | History | 3     |
| Andrea  | Math    | 5     |

---

### Pivot Transformation

We convert **subjects into columns**.

### Wide Format (pivot result)

| student | Math | History |
| ------- | ---- | ------- |
| David   | 4    | 5       |
| Maxi    | 3    | 3       |
| Andrea  | 5    | NULL    |

---

### What happened?

* Each **student** becomes a row
* Each **subject** becomes a column
* Values are placed in the corresponding cell
* Missing values become `NULL`

---


