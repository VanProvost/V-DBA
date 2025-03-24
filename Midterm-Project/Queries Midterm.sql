SELECT vendor_id, concat(vendors.contact_first_name, ' ', vendors.contact_last_name) as 'Full Name', phone			# this concatinates first name and last name as Full name. 
FROM vendors; 

SELECT book_id,author_id, title, genre, price
FROM books; 

select *
from orders
where status = 'paid';			#will grab everything from orders if the status is = to paid 

select *
from payments;

#join 
select	orders.order_id	,orders.order_date, payments.payment_date, payments.payment_method			#Joins payments and orders into one table 
from orders 
left join payments ON orders.order_id=payments.order_id;


SELECT SUM(invoice_total) AS total_invoice_amount			#sums invoice total
FROM invoices; 

SELECT count(*) order_id
FROM orders;

SELECT invoice_id, vendor_id, sum(invoice_total) AS total_revenue, 				#sums invoice_total as total_revenue 
		GROUPING(invoice_id) AS group_invoice_id,								# Grouping is used to indicate what collumns have been aggregated in subtotal and grand total rows. when invoice_id/vendor_id grouping returns a 1, the value is part of an aggregate row. 
        GROUPING(vendor_id) AS group_vendor_id
FROM invoices
GROUP BY invoice_id, vendor_id WITH ROLLUP;



