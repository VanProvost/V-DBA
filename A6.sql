USE ap;

-- Question 1

-- a. BEFORE INSERT trigger to verify invoice_total matches the sum of line items
DELIMITER //

CREATE TRIGGER before_invoice_insert
BEFORE INSERT ON invoices
FOR EACH ROW
BEGIN
    DECLARE line_items_sum DECIMAL(9,2);
    
    -- Calculate the sum of line_item_amount for this invoice_id
    SELECT IFNULL(SUM(line_item_amount), 0) INTO line_items_sum
    FROM invoice_line_items
    WHERE invoice_id = NEW.invoice_id;
    
    -- Check if invoice_total is at least equal to the sum of line items
    IF NEW.invoice_total < line_items_sum THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invoice total must be at least equal to the sum of its line items';
    END IF;
END //

-- b. AFTER INSERT trigger to update vendor's default_account_number
CREATE TRIGGER after_invoice_insert
AFTER INSERT ON invoices
FOR EACH ROW
BEGIN
    DECLARE first_line_account_number INT;
    
    -- Get the account_number from the first line item of this invoice
    SELECT account_number INTO first_line_account_number
    FROM invoice_line_items
    WHERE invoice_id = NEW.invoice_id
    ORDER BY invoice_sequence LIMIT 1;
    
    -- Update the vendor's default_account_number if a line item was found
    IF first_line_account_number IS NOT NULL THEN
        UPDATE vendors
        SET default_account_number = first_line_account_number
        WHERE vendor_id = NEW.vendor_id;
    END IF;
END //

DELIMITER ;

-- Question 2

-- Create archive tables if they don't exist
CREATE TABLE IF NOT EXISTS invoice_archive LIKE invoices;
ALTER TABLE invoice_archive ADD archived_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS invoice_line_item_archive LIKE invoice_line_items;
ALTER TABLE invoice_line_item_archive ADD archived_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Make sure event scheduler is enabled
SET GLOBAL event_scheduler = ON;

-- Create monthly scheduled event to archive old invoices
DELIMITER //
CREATE EVENT IF NOT EXISTS monthly_invoice_archive
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE invoice_id_val INT;
    DECLARE invoice_cursor CURSOR FOR 
        SELECT invoice_id 
        FROM invoices 
        WHERE invoice_date < DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Start transaction to ensure data consistency
    START TRANSACTION;
    
    OPEN invoice_cursor;
    
    read_loop: LOOP
        FETCH invoice_cursor INTO invoice_id_val;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Archive invoice line items first (maintain referential integrity)
        INSERT INTO invoice_line_item_archive
        SELECT *, CURRENT_TIMESTAMP 
        FROM invoice_line_items 
        WHERE invoice_id = invoice_id_val;
        
        -- Delete the line items from the original table
        DELETE FROM invoice_line_items 
        WHERE invoice_id = invoice_id_val;
        
        -- Archive the invoice
        INSERT INTO invoice_archive
        SELECT *, CURRENT_TIMESTAMP 
        FROM invoices 
        WHERE invoice_id = invoice_id_val;
        
        -- Delete the invoice from the original table
        DELETE FROM invoices 
        WHERE invoice_id = invoice_id_val;
    END LOOP;
    
    CLOSE invoice_cursor;
    
    -- Commit the transaction
    COMMIT;
END //

DELIMITER ;