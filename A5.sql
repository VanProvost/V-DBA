USE ap;

-- Question 1
DELIMITER //

-- Stored procedure to retrieve all invoices for a specific vendor
-- Useful for accounts payable staff to quickly view a vendor's invoice history
CREATE PROCEDURE get_vendor_invoices
(
    IN p_vendor_id INT 
)
BEGIN
    SELECT 
        invoice_id,
        invoice_number,
        invoice_date,
        invoice_total,
        payment_total
    FROM invoices
    WHERE vendor_id = p_vendor_id
     -- Get most recent invoices first
    ORDER BY invoice_date DESC; 
END//

DELIMITER ;

-- Question 2
DELIMITER //

-- Stored procedure to apply a payment to an invoice with validation
-- Prevents overpayment by checking remaining balance before applying payment
CREATE PROCEDURE apply_payment
(
    -- Invoice ID to apply payment to
    IN p_invoice_id INT,
    -- Amount of payment to apply
    IN p_amount DECIMAL(9,2)
)
BEGIN
    DECLARE current_payment_total DECIMAL(9,2);
    DECLARE invoice_total_amount DECIMAL(9,2);
    DECLARE new_payment_total DECIMAL(9,2);
    DECLARE remaining_balance DECIMAL(9,2);
    
    -- Get the current payment_total and invoice_total
    SELECT payment_total, invoice_total 
    INTO current_payment_total, invoice_total_amount
    FROM invoices
    WHERE invoice_id = p_invoice_id;
    
    -- Calculate the new payment total
    SET new_payment_total = current_payment_total + p_amount;
    
    -- Check if the new payment total exceeds invoice total
    IF new_payment_total <= invoice_total_amount THEN
        -- Update the payment_total
        UPDATE invoices
        SET payment_total = new_payment_total
        WHERE invoice_id = p_invoice_id;
        
        SELECT CONCAT('Payment of $', p_amount, ' applied successfully. New payment total: $', new_payment_total) AS message;
    ELSE
        -- Calculate the remaining balance
        SET remaining_balance = invoice_total_amount - current_payment_total;
        
        SELECT CONCAT('Error: Payment amount ($', p_amount, ') exceeds the remaining balance ($', remaining_balance, '). Payment not applied.') AS message;
    END IF;
END//

DELIMITER ;

-- Question 3
DELIMITER //

-- Stored procedure to insert a new invoice record
-- Automatically sets payment and credit totals to zero and returns the new invoice ID
CREATE PROCEDURE insert_new_invoice
(
    IN p_vendor_id INT,
    IN p_invoice_number VARCHAR(50),
    IN p_invoice_date DATE,
    IN p_invoice_total DECIMAL(9,2),
    IN p_terms_id INT
)
BEGIN
    -- Insert the new invoice with default zero values for payment_total and credit_total
    INSERT INTO invoices
        (vendor_id, invoice_number, invoice_date, invoice_total, payment_total, credit_total, terms_id)
    VALUES
        (p_vendor_id, p_invoice_number, p_invoice_date, p_invoice_total, 0, 0, p_terms_id);
    
    -- Return the ID of the newly inserted invoice
    SELECT LAST_INSERT_ID() AS invoice_id;
END//

DELIMITER ;

