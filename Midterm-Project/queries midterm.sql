# this concatinates first name and last name as Full name. 
SELECT vendor_id, concat(vendors.contact_first_name, ' ', vendors.contact_last_name) as 'Full Name', phone			
FROM vendors; 

#select statement
SELECT book_id,author_id, title, genre, price
FROM books; 


#will grab everything from orders if the status is = to paid 
SELECT *
FROM orders
WHERE STATUS = 'paid';			


#Joins payments and orders into one table 
SELECT	orders.order_id	,orders.order_date, payments.payment_date, payments.payment_method			
FROM orders 
LEFT JOIN payments ON orders.order_id=payments.order_id;

#sums invoice total
SELECT SUM(invoice_total) AS total_invoice_amount			
FROM invoices; 

#Counts all orders from order_id where the order is either returned or refunded
SELECT count(*) order_id
FROM orders
WHERE status = 'Returned' OR 'Refunded';

SELECT 
    vendor_id, 
    SUM(invoice_total) AS total_revenue,
    GROUPING(invoice_id) AS group_invoice_id
FROM invoices
GROUP BY vendor_id, invoice_id
WITH ROLLUP
HAVING GROUPING(invoice_id) = 1
ORDER BY vendor_id;





