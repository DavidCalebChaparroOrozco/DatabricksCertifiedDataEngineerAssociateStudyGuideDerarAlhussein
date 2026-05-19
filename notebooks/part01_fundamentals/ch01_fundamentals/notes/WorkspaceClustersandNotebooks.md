## What is Compute?
The engine that makes everything work at Databricks

### Your Processing Engine
Nothing works without an active **Cluster**. Compute is where you configure the
machines (CPU/GPU, RAM) to process your code.

**What is it for?**
It's the engine that runs your notebooks. Without an active cluster, you can't run a single line of code.

**Think of it this way:**
- Notebooks = Cooking recipes
- Catalog = Pantry with ingredients
- Compute = The stove and the chef

_Without Compute, your notebooks are just text_

---

## What is a Cluster?
Distributed Processing Architecture with Apache Spark
_A cluster is a group of computers (nodes) that work together to process data in parallel with Spark._

### Cluster Components:
**Driver** _The 'brain':_
Receives your code, parses it, and distributes the work among the workers.

**Workers** _The 'muscles':_
Do the heavy lifting of processing data in parallel across multiple nodes.

**In Community Edition: A single node acts as both Driver and Worker (15 GB RAM).**

![DataBricksClusterArchitecture](DataBricksClusterArchitecture.png)

---

## Key Concepts When Setting Up a Cluster
What you need to know before creating your first compute

### Databricks Runtime (DBR)
_As the 'Operating System' of the cluster_
Includes Apache Spark and Python/Scala libraries. It's the foundation on which your code will run.

**Best practice: Use the latest LTS (Long Term Support) version for greater stability.**

### ML Runtime
_For Artificial Intelligence and Machine Learning_
Version with pre-installed AI libraries such as TensorFlow, PyTorch, and Scikit-learn.

**TensorFlow / PyTorch / Scikit-learn / XGBoost**

### Auto-termination ESSENTIAL!

Shut down the cluster after inactivity (e.g., 20-30 min) to avoid unnecessary resource consumption.

**In Community Edition:**
It's mandatory and enforced.

**In Businesses:**
Critical for cost control.

**Tip: A cluster that's turned off doesn't generate costs. You can always restart it when needed.**

---

# Databricks Magic Commands – Beginner Cheat Sheet

| Command | Category | Description / Usage |
|--------|----------|---------------------|
| `%python` | Language | Run Python code in the cell (default language in Databricks). |
| `%sql` | Language | Execute SQL queries directly on Delta tables or views. |
| `%scala` | Language | Run Scala code (useful for Spark internals and performance tuning). |
| `%r` | Language | Run R code for analytics and visualization. |
| `%md` | Documentation | Write Markdown to document notebooks (titles, notes, explanations). |
| `%run` | Notebook Management | Run another notebook and import its variables and functions. |
| `%fs ls /path` | File System | List files and directories in DBFS or mounted storage. |
| `%fs head /path/file` | File System | Preview the first lines of a file in DBFS. |
| `%fs rm /path -r` | File System | Delete files or directories (use carefully). |
| `%fs mkdirs /path` | File System | Create directories in DBFS. |
| `%sh` | Shell | Run shell commands (e.g., install packages, inspect system). |
| `%pip install package` | Environment | Install Python packages inside the notebook session. |
| `%conda install package` | Environment | Install Conda packages (less common, but supported). |
| `%sql show tables` | SQL | List all available tables in the current database. |
| `%sql describe table_name` | SQL | Show schema and metadata of a table. |
| `%sql select * from table limit 10` | SQL | Preview data from a table. |
| `%md ### Section Title` | Documentation | Add structured headers for better notebook readability. |
| `%run ./utils` | Reusability | Import shared logic (ETL, configs, helpers) from another notebook. |

---

## Tips for Beginners 🚀
- Use **`%md`** to explain what your notebook does — this is highly valued in teams.
- Combine **`%sql` + `%python`** to explore data and then process it.
- Prefer **Delta tables** when working with `%sql`.
- Be careful with **`%fs rm -r`** — it deletes permanently.