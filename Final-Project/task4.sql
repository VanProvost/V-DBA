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
    
    
    
    


