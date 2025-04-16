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