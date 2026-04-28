# Parsing nested data, Conversion to StructType, Flattening structures

## What is Plain JSON?

All fields at the same level
- No hierarchy or internal objects
- Each field has a single value
- Easy to read and process directly

> Simple structure, Spark reads it natively

### Plain JSON (Real Example)
```JSON
{
    "id": 1,
    "name": "Caleb",
    "city": "Medellin",
    "age": 27
}
```

- Key in quotes
- Text value in quotes
- Number without quotes
- {} Separate the object

> All values ​​are single, string or number, without nesting

---

## What is Nested JSON?

Fields with structures inside
- Nested objects: fields with subfields
- Arrays []: Lists of values ​​or objects
- Can have multiple levels of depth

> Real complexity, requires special tools

### Nested JSON (Real Example)
```JSON
{
    "id": 1,
    "name": "Caleb",
    "address": { // ← nested object
        "city": "Medellin",
        "country": "Colombia"
    },
    "purchases": [ // ← arrays of objects
        {"product": "laptop", "price": 800},
        {"product": "mouse", "price": 20}
    ]
}
```

---

## Spark reads nested JSON as plain text

### Input JSON file
```JSON
{
    "first_name": "Bart",
    "last_name": "Simpson",
    "gender": "Male",
    "address": {
        "street":"742 Evergreen Terrace",
        "city": "Springfield",
        "Country": "United States"
    }
}
```
> Complex structure with nested fields

Spark Ingests → Interprets as... ⚠️

### Resulting DataFrame (data_user `STRING`)
```JSON
"{
    \"first_name\":\"Bart\",\"address\":{\"street\":\"742...
}"
```
> ✖️ All JSON is treated as plain text; it cannot be navigated directly.

---

## Colon Syntax for Extracting Fields

### The `:` Operator Navigates JSON as Text
1. STRING Column: The column contains the complete JSON as text
2. First Level: column: field → extracts field from the root object
3. Nested: column: field: subfield → chaining
> Ideal for quickly extracting 1 or 2 fields

### How to Navigate with `:`
user_data = STRING column
- `:` → "name" → "John Wick" (1 level)

Chaining → 2 levels (nested)
- `:` → "location" `:` → "city" → Madrid

---

## The Golden Rule: Colon vs. Period

### `JSON STRING`
**Colon:** The column contains JSON as text. Spark must parse the text each time.

- ✅ Fast for 1-2 fields
- ✅ No prior conversion required
- ✖️ Slower (parsing on each row)
- ✖️ No Catalyst optimization

## VS

### `Native STRUCT`
**Period:** The column is a STRUCT. Spark accesses the binary structure directly.
- ✅ Faster (direct access)
- ✅ Catalyst optimization enabled
- ✅ Works with `WHERE`, `GROUP BY`, etc.

> Use `:` for JSON STRING, use `.` for native STRUCT.
> Convert to STRUCT whenever you use the field more than once.

---

## `StruckType`: Spark's native representation

### `STRUCT`: user
```JSON
id      "LongType"
name    "StringType"
address "StructType"
    - city "StringType"
    - country "StringType"
purchases "ArrayType"
```
> Typed structure recognized by Spark

### Why is it better than STRING?

- **Binary and native:** Spark understands it directly, without parsing text in each operation.
- **Catalyst optimizes it**: The Spark engine can read only the necessary fields (column pruning).
- **Type-safe**: Each field has a defined type. Fewer errors in production.
- **Direct access with a dot (`.`)**: No additional functions to navigate the structure.

---

## The Two Steps to Convert JSON to StructType

![alt text](JSONtoStructType.png)

### Step 1: `schema_of_json`
Parses a sample of the JSON and automatically generates the schema (data types for each field)
- Input: A sample JSON string
- Output: A schema with detected types
> You only need to call it once

### Step 2: `from_json`
Applies the schema to the entire column and converts each row of JSON text into a STRUCT structure
- Input: STRING column + schema
- Output: Typed STRUCT column
> Applies to the entire table

