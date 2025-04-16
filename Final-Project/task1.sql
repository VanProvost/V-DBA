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