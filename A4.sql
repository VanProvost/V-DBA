USE ap;

-- Task 1.1:
-- Can be used to see total amounts paid and owed for each vendor, useful for seeing which vendors have no payments owing.
-- This view aggregates invoice data by vendor to provide a financial summary of each vendor relationship
CREATE OR REPLACE VIEW vendor_invoice_summary AS
SELECT
    vendors.vendor_id,
    vendor_name,
    COUNT(*) AS 'total_number_invoices',
    SUM(invoice_total) AS 'total_invoice_amount',
    SUM(payment_total) AS 'total_payments',
    SUM(credit_total) AS 'total_credits'
FROM
    vendors
    JOIN invoices ON vendors.vendor_id = invoices.vendor_id
GROUP BY
    vendor_name;

SELECT
    *
FROM
    vendor_invoice_summary;

-- Task 1.2:
-- Can be used to see which vendors have an outstanding balance, and how much that
-- outstanding balance is per vendor. Can be used to find which vendors need to be focused on to balance invoices.
-- Filters for only invoices with positive outstanding balances to focus on pending payments
CREATE OR REPLACE VIEW unpaid_invoices AS
SELECT
    invoice_id,
    invoice_number,
    vendor_name,
    invoice_date,
    invoice_due_date,
    invoice_total - payment_total - credit_total AS 'outstanding_balance'
FROM
    invoices
    JOIN vendors ON invoices.vendor_id = vendors.vendor_id
WHERE
    invoice_total - payment_total - credit_total > 0;

SELECT
    *
FROM
    unpaid_invoices;

-- Task 1.3:
-- Can be used to see how much is being spent on each expense, useful for finding areas 
-- that can be more cost efficient
-- Groups expenses by general ledger account to track departmental or categorical spending
CREATE OR REPLACE VIEW account_expenses_summary AS
SELECT
    general_ledger_accounts.account_number,
    account_description,
    SUM(line_item_amount) AS 'total_charged'
FROM
    general_ledger_accounts
    JOIN invoice_line_items ON general_ledger_accounts.account_number = invoice_line_items.account_number
GROUP BY
    account_number;

SELECT
    *
FROM
    account_expenses_summary;

-- Task 2.1:
-- Can be used to quickly check if a specific vendor has an outstanding balance by looking up with vendor_id
-- Function calculates the remaining balance by subtracting payments and credits from the total invoice amount
DELIMITER / / CREATE FUNCTION calculate_outstanding_balance (invoice_id_param INT) RETURNS DECIMAL(9, 2) DETERMINISTIC READS SQL DATA 
BEGIN 
DECLARE outstanding_balance_var DECIMAL(9, 2);

SELECT
    invoice_total - payment_total - credit_total INTO outstanding_balance_var
FROM
    invoices
WHERE
    invoice_id = invoice_id_param;

RETURN outstanding_balance_var;

END / /
SELECT
    calculate_outstanding_balance (89);

-- Task 2.2:
-- Can be used to find when a payment is due for a specific invoice, useful when used in combination with
-- calculate_outstanding_balance
-- Returns negative values for overdue invoices and positive values for invoices due in the future
DELIMITER / / CREATE FUNCTION days_until_due (invoice_id_param INT) RETURNS INT DETERMINISTIC READS SQL DATA 
BEGIN 
DECLARE until_due_var INT;

SELECT
    invoice_due_date - CURDATE () INTO until_due_var
FROM
    invoices
WHERE
    invoice_id = invoice_id_param;

RETURN until_due_var;

END / /
SELECT
    days_until_due (50);

-- Task 2.3:
-- Formats address related columns into a single string, can be used to quickly get the full address of a specific vendor
-- from the vendor_id.
-- Useful for reports and communications that require complete mailing addresses
DELIMITER / / CREATE FUNCTION format_vendor_address (param_vendor_id INT) RETURNS VARCHAR(255) DETERMINISTIC READS SQL DATA 
BEGIN 
DECLARE vendor_addr_var VARCHAR(255);

-- CONCAT_WS joins multiple strings with the specified separator (comma in this case)
SELECT
    CONCAT_WS (
        ', ',
        vendor_address1,
        vendor_address2,
        vendor_city,
        vendor_state,
        vendor_zip_code
    ) INTO vendor_addr_var
FROM
    vendors
WHERE
    vendor_id = param_vendor_id;

RETURN vendor_addr_var;

END / /
SELECT
    format_vendor_address (7);