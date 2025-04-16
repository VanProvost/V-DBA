*/Task 4: Create a trigger that updates the stock of books in the books table when a new invoice is created. */

delimiter // 
Create Trigger update_inv_for_orders
After Insert ON invoices 
For Each Row 
Begin
	Update books.stock 
    set stock = stock - orderdetails.quantity 
    where books.book_id = orderdetails.book_id 
end;
delimiter ; 
    
    
    
    


