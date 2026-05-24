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
