# Midterm Project - Bookstore Database

## Importing current database

- Download import-database.sql and load-mockdata.sql
- Open and run import-database.sql
- Refresh and open the bks schema
- Open and run load-mockdata.sql

### Style Guide

#### Indentation

Use tabs or three spaces for indentation.

#### SQL Keywords

Always write SQL keywords in uppercase (SELECT, INSERT, JOIN, WHERE, etc.).

#### Spacing

Add spaces around operators and keywords for readability (e.g., =, >, AND, OR).

#### Align Clauses

Write each SQL clause on a new line (e.g., SELECT, FROM, WHERE, JOIN).

#### Columns and Tables

List columns and tables on separate lines for readability when selecting multiple fields.
When joining tables, align JOIN clauses with the main query.

#### Subqueries

Indent subqueries by 2 spaces for better clarity.

- Example:

```sql
sql
Copy
Edit
SELECT first_name, last_name
FROM employees
WHERE department = 'Sales'
ORDER BY last_name;
```

- Example with Join:

```sql
Copy
Edit
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
WHERE e.hire_date > '2020-01-01'
ORDER BY e.last_name;
```

- Example with Subquery:

```sql
Copy
Edit
SELECT first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT id FROM departments WHERE department_name = 'Sales'
);
```
