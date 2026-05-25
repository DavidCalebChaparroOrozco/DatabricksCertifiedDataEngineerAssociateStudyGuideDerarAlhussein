# Higher-Order Functions (Filter & Transform) and UDFs

Higher-Order Functions and User-Defined Functions in Spark SQL and PySpark

## What are Higher-Order Functions?

Functions that receive other functions as arguments and apply them to complex data collections.

- arrays
- maps
- structs

### Key Concept `function → argument`
A function receives another function as a parameter.

> Input Function:
> ` x -> x > 3`
> Higher-Order Function:
> ```python
> filter( array, f)
> ```
> Result: [4, 5]

---

## Why do higher-order functions exist?

### The problem
- Modern data isn't flat
- It comes in JSON, arrays, and structures.
- `explode()` breaks the structure
- It generates duplicate rows

### The solution: HOF
- They manipulate data without exploding columns
- They maintain the original structure
- Cleaner and more expressive code
- Compatible with SQL and PySpark

---
## Advantages of Higher-Order Functions

### No explode
Maintain the original structure of arrays, maps, and structs
### Clean code
More readable and easier-to-maintain queries
### Better performance
Optimized for large volumes of data in Spark
### SQL and PySpark
Compatible with both databricks environments

---

## `filter()` (Filtering elements of an array)

Returns a new array containing only the elements that meet a condition.
> General form:
> `filter(array, x -> condition)`

- array: the input collection
- x: each element of the array
- condition: Boolean expression

```SQL
-- Entrance
[1, 2, 3, 4, 5]

-- `filter()` evaluates each element
1 > 3 ✖️
2 > 3 ✖️
3 > 3 ✖️
4 > 3 ✅
5 > 3 ✅

-- Result
[4, 5]
```

---

## Logical SQL Execution Order
> ### Why can't you use a `SELECT` column in `WHERE`?

## `WHERE` executes BEFORE SELECT. 
Columns created in `SELECT` don't yet exist when `WHERE` evaluates its conditions.

1. **`FROM`:** Source tables
2. **`WHERE`:** Row filter
3. **`GROUP BY`:** Grouping
4. **`HAVING`:** Group filters
5. **`SELECT`:** Derived columns
6. **`ORDER BY`:** Sorting

> **`WHERE`** (step 2) occurs before **`SELECT`** (step 5)

---

## `transform()` (Transform each element)

Applies an expression to each element of the array and returns a new array with the results.

> General form:
> `transform(array, x -> expression)`
- array: the input collection
- x: each element of the array
- expression: transformation to apply

```SQL
Input
[1, 2, 3]

Expression
x -> x * 2

transform() applies the expression
1 x 2 = 2
2 x 2 = 4
3 x 3 = 6

Result
[2, 4, 6]
```

---
## The Problem: Derived Column in `WHERE`

> THIS CODE FAILS
> ```SQL
>SELECT *,
> FROM (items, i -> i.price > 100)
> AS expensive_items
> FROM orders
> WHERE size(expensive_items) > 0 -- ERROR!
> ```
> ⚠️ Column 'expensive_items' cannot be resolved

### Why does it fail?

1. `WHERE` evaluates in step 2
2. `SELECT` creates expensive_items in step 5
3. expensive_items does NOT exist yet

> SQL cannot reference what it has not yet created

## Solution: Use a subquery

> ✖️ Without subquery (ERROR)
> ```SQL
> SELECT *,
> filter (items, i -> i price > 100)
> AS expensive_items
> FROM orders
> WHERE size(expensive_items) > 0
> ```

> ✅ With subquery (CORRECT)
> ```SQL
> SELECT *
> FROM (
>   SELECT *,
>    filter(items, i -> i.price > 100)
>    AS expensive_items
>    FROM orders
> ) WHERE size(expensive_items) > 0
> ```

---

## What are SQL UDFs?

User-Defined Functions

> Custom functions that encapsulate reusable SQL logic, created with `CREATE FUNCTION` and used like any native function
> - `CREATE FUNCTION`
> - Reusable
> - Native SQL

- User-defined
- Reusable in any query
- Registered in the Databricks catalog

> General syntax
> ```SQL
> CREATE FUNCTION
> function_name parameter TYPE -- Name and parameters
> RETURNS RETURN_TYPE -- Return rate
> RETURN sql_expression; -- SQL Logic
> ```

## What are UDFs used for?

### Reuse complex logic
Define once, use in any query in the project

### Simplify queries
Replace repetitive `CASE WHEN` blocks with a single call

### Standardize transformations
Ensure consistency across the organization

### Share between teams
Registered in the Unity Catalog, accessible to the entire team

## Real-world example: `classify_price()`
Creating and using a UDF to categorize prices

> Creating the function
> ```SQL
> CREATE FUNCTION classify_price price DOUBLE
> RETURNS STRING
> RETURN CASE
> WHEN price > 50
> THEN 'Economic'
> WHEN price BETWEEN 50 AND 200
> THEN 'Medium'
> ELSE 'PREMIUM'
> END;
> ```

> Using the function
> ```SQL
> SELECT name, price, classify_price(price)
> AS category
> FROM products
> ```

Result:
| Product Name  | Price | Category |
| ------------- | ----- | -------- |
| Mouse         | 25    | Economic |
| Office Chair  | 120   | Medium   |
| Gaming Laptop | 1500  | Premium  |
| Notebook      | 10    | Economic |
