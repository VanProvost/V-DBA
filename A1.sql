-- Van Provost
-- DBA1
-- MySQL Assignment: Fetching Data from Single and Multiple Tables

-- Using ap database unless a question otherwise specifies, make sure to reapply this if a previous question used a different database
USE ap;

-- Question 1:

-- Selecting all columns from vendors
SELECT * FROM vendors
-- Ordering by vendor_id
ORDER BY vendor_id;

-- Question 2:

-- Selecting only the vendor_name, vendor_phone, and vendor_city columns from the vendors table
SELECT vendor_name, vendor_phone, vendor_city FROM vendors
-- Query only the vendors located in 'CA'
WHERE vendor_state = 'CA'
-- Sort the table by vendor name
ORDER BY vendor_name;

-- Question 3:

-- Selecting invoice_id, invoice_total, and invoice_date from the invoices table
SELECT invoice_id, invoice_total, invoice_date FROM invoices
-- Sort by invoice_total in desc order
ORDER BY invoice_total DESC;

-- Question 4:

-- Query all from invoices table
SELECT * FROM invoices
-- Order by invoice_total to get the lowest invoice_total rows to the top of the table
ORDER BY invoice_total
-- Limit by 6 with an offset of 3 to get the 3-9th lowest invoice_totals
LIMIT 6 OFFSET 3;

-- Question 5:

-- Select invoice_id, invoice_total, and payment_total
SELECT invoice_id, invoice_total, payment_total, 
-- Subtract invoice_total and payment_total to get the Remaining Balance
invoice_total - payment_total AS 'Remaining Balance' FROM invoices
-- Sort by invoice_id
ORDER BY invoice_id;

-- Question 6:

-- Query invoice_id, invoice_total, vendor_name, and vendor_phone for all invoices
SELECT invoice_id, invoice_total, vendor_name, vendor_phone FROM invoices
-- Use inner join between invoices and vendors tables to find all instances where columns are identical
INNER JOIN vendors ON invoices.vendor_id = vendors.vendor_id
-- Sort by invoice_id
ORDER BY invoice_id;

-- Question 7:

-- Query vendor_name & invoice_id from vendors table
SELECT vendor_name, invoice_id FROM vendors
-- Use LEFT OUTER JOIN to include vendors without invoices
LEFT OUTER JOIN invoices ON vendors.vendor_id = invoices.invoice_id
-- Sort by the vendor_name
ORDER BY vendors.vendor_name;

-- Question 8:

-- Using the ex database for this question
USE ex;
-- Query department_name and employees last_name
SELECT department_name, last_name FROM employees
-- Use LEFT OUTER JOIN to list all department_names with employees last_name, even if employee does not have a department
LEFT OUTER JOIN departments ON employees.department_number = departments.department_number
-- Sort by department_id
ORDER BY departments.department_number;

-- Question 9:

-- Select & CONCAT first_name and last_name(as FirstName LastName), & select vendor_name
SELECT CONCAT(vendor_contacts.first_name, ' ', vendor_contacts.last_name) AS 'Combined Contact Name', vendor_name
-- Using vendor_contacts & vendors tables
FROM vendor_contacts
-- INNER JOIN to combine the tables, use vendor_id as a common link
INNER JOIN vendors ON vendor_contacts.vendor_id = vendors.vendor_id
-- Sort by Combined Contact Name
ORDER BY 'Combined Contact Name';

-- Question 10:

-- Using ex database for this queston
USE ex;
-- Fetch first_name from employees & sales_reps tables
SELECT first_name FROM employees
-- UNION to combine from two select statements(in this case first_name and rep_first_name)
UNION
SELECT rep_first_name FROM sales_reps
-- Sort by first_name
ORDER BY first_name;

-- Question 11:

-- Fetch invoice_id, invoice_total, vendor_name, and terms_description for all invoices. 
-- For this I am going to use inner join to connect both the terms and vendors table to the invoices table,
-- since we want to query in relation to the invoices. 
SELECT invoice_id, invoice_total, vendor_name, terms_description FROM invoices
-- Inner join both tables
INNER JOIN vendors ON invoices.vendor_id = vendors.vendor_id
-- Using the terms_id since a numerical comparison is more efficient and reliable than a text comparison would be(using descriptions from either table)
INNER JOIN terms ON invoices.terms_id = terms.terms_id
-- Sort by invoice_id
ORDER BY invoice_id;
