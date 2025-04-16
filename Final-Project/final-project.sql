/*
Relational Databases Final Project

Van Provost
Ashton Ruff
Robert Gareau-Tuck

2024-04-16
*/

USE bks;

-- Task 1: Create Views

-- This view shows the bestselling books ranked by number of copies sold.
-- Includes all book details, author info, and sales metrics.
-- Excludes canceled/returned orders for more accurate numbers.

CREATE VIEW vw_TopSellingBooks AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    CONCAT(a.first_name, ' ', a.last_name) AS author_name,
    g.genre,
    p.name AS publisher_name,
    b.publication_date,
    b.price,
    SUM(od.quantity) AS total_sold,
    (SUM(od.quantity) * b.price) AS total_revenue
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Genres g ON b.genre_id = g.genre_id
JOIN Publishers p ON b.publisher_id = p.publisher_id
JOIN OrderDetails od ON b.book_id = od.book_id
JOIN Orders o ON od.order_id = o.order_id
WHERE o.status != 'Canceled' AND o.status != 'Returned'
GROUP BY b.book_id, b.title, b.isbn, author_name, g.genre, p.name, b.publication_date, b.price
ORDER BY total_sold DESC;

-- Task 2: Create Stored Procedures

-- Stored Procedure to process a customer order.
-- This procedure moves an order from 'Pending' to 'Processing' status and updates the book inventory by reducing stock levels.
DELIMITER //

DROP PROCEDURE IF EXISTS `sp_ProcessOrder` //

CREATE PROCEDURE `sp_ProcessOrder` (
    IN p_order_id INT
)
BEGIN
    DECLARE order_exists INT;
    DECLARE current_status VARCHAR(20);
    
    -- Check if order exists
    SELECT COUNT(*) INTO order_exists 
    FROM Orders 
    WHERE order_id = p_order_id;
    
    -- Validate order existence
    IF order_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Order does not exist';
    END IF;
    
    -- Get order status in a separate query
    SELECT status INTO current_status 
    FROM Orders 
    WHERE order_id = p_order_id;
    
    -- Check if order is in 'Pending' status
    IF current_status != 'Pending' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only Pending orders can be processed';
    END IF;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Update order status to 'Processing'
    UPDATE Orders 
    SET status = 'Processing' 
    WHERE order_id = p_order_id;
    
    -- Update book inventory
    UPDATE Books b
    JOIN OrderDetails od ON b.book_id = od.book_id
    SET b.stock = b.stock - od.quantity
    WHERE od.order_id = p_order_id;
    
    COMMIT;
    
    SELECT CONCAT('Order #', p_order_id, ' has been processed successfully') AS Result;
END //

DELIMITER ;

-- Task 3: This procedure will insert a new invoice into the invoices table. If the insert fails, it will roll back the transaction and return an error message. 
-- If the insert is successful, it will commit the transaction and return a success message. 

DELIMITER //
DROP PROCEDURE ProcessSale;

CREATE PROCEDURE ProcessSale ()
BEGIN
	DECLARE sql_error TINYINT DEFAULT FALSE; 
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
		SET sql_error = TRUE; 
        
	START TRANSACTION; 
    INSERT INTO invoices (invoice_id,vendor_id,invoice_number,invoice_date,invoice_total,terms,invoice_due_date,payment_date)
    VALUES (101, 42, 99987, '2025-07-14', 5250.32, 'Cash on delivery', '2025-07-28', NULL);
    
    IF sql_error = FALSE THEN 
		COMMIT;
        SELECT 'The transaction was committed.';
	ELSE 
		ROLLBACK; 
        SELECT 'The Transaction was rolled back.'; 
	END IF; 
END //

CALL ProcessSale;

--Task 4: Create a trigger that updates the stock of books in the books table when a new invoice is created. 

DELIMITER // 
CREATE TRIGGER update_inv_for_orders
AFTER INSERT ON invoices 
FOR Each ROW 
BEGIN
	UPDATE books.stock 
    SET stock = stock - orderdetails.quantity 
    WHERE books.book_id = orderdetails.book_id 
END;
DELIMITER ; 

-- Task 5:
/*
This function will calculate the total cost of the inventory of a single book. This would be useful to show how 
much money is tied up in single books to see if promotions or events need to be planned to sell through stock
*/

DELIMITER //

CREATE FUNCTION GetTotalInventoryCost(bookId INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalCost DECIMAL(10,2);

    SELECT price * stock
    INTO totalCost
    FROM bks.books
    WHERE book_id = bookId;

    RETURN totalCost;
END //

DELIMITER ;

SELECT GetTotalInventoryCost(1) AS Total_Cost;

DROP FUNCTION IF EXISTS GetTotalInventoryCost;

-- Task 6:
/*
This event will once monthly check to see if any books are way over stock and automatically apply a discount for the store.
This would of course be useful to increase sales of books that don't seem to be meeting expectations.
*/

DELIMITER //

CREATE EVENT DiscountOverstockedBooks
ON SCHEDULE
    EVERY 1 MONTH
    STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY)
DO
BEGIN
    UPDATE bks.books
    SET price = price * 0.90
    WHERE stock > 500;
END //

DELIMITER ;

SHOW EVENTS;

DROP EVENT IF EXISTS DiscountOverstockedBooks;