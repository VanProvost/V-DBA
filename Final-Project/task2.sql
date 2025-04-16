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
