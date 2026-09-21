# project-layoff
A PostgreSQL data analysis project exploring global tech and business layoff trends (2020–2023). Features data cleaning, schema transformation, and multi-level SQL queries.

An end-to-end data analysis project exploring global workforce reductions across various industries, funding stages, and geographic regions. This project covers database schema setup, raw data cleaning, categorical standardization, and multi-level analytical querying using **PostgreSQL**.

---

## Project Overview

The main objective of this project is to uncover patterns behind global layoff events:
* Which industries and geographic regions were hit the hardest?
* How did layoffs accumulate over time (*running totals*)?
* Did raising massive venture capital protect companies from workforce cuts?

### Tech Stack
* **Database Management:** PostgreSQL
* **Querying & Analysis:** DDL, DML, CTEs, Window Functions, Aggregate Functions
* **Data Source:** [Global Layoffs Dataset (Kaggle/GitHub)](https://github.com/ahmedalhelbawy/PortfolioProjects/blob/main/layoffs.csv)

---

## Data Cleaning & Preprocessing

Working with the raw dataset presented several data quality challenges that had to be resolved before conducting analysis:

1. Fixing String-Based `NULL`s & Type Conversion:
   Missing entries were initially loaded as literal text `'NULL'`. These were converted to true SQL `NULL` values before casting columns to their appropriate types (`INTEGER`, `DECIMAL`, `DATE`).

2. Standardizing Categorical Data:
   Categories like `CryptoCurrency` and `Crypto Currency` were unified into a single `Crypto` category to avoid fragmented aggregations.

3. Data Imputation:
   Missing industry fields for key companies (e.g., Airbnb, Juul) were populated based on contextual domain research.

```sql
-- Example: Fixing data types and nulls
UPDATE layoffs
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

ALTER TABLE layoffs
ALTER COLUMN percentage_laid_off
TYPE DECIMAL(5, 2)
USING percentage_laid_off::DECIMAL(5, 2);
