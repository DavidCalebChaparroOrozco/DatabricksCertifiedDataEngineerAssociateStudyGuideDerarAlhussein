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

