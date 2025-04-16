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