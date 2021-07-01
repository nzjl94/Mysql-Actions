DELIMITER $$
CREATE DEFINER=`local_admin`@`localhost` FUNCTION `total_money_in_capital`() RETURNS decimal(10,2)
    NO SQL
BEGIN
	DECLARE sell DECIMAL(10,2);
	DECLARE purches DECIMAL(10,2);
     
	SELECT 
    	sum(`total_price`-(`total_price`*(`total_discount`/100))) into sell 
    FROM 
    	`sell` 
    WHERE 
    	`deleted_at` is null;
    SELECT 
    	sum(`total_price`) into purches 
    FROM 
    	`purches` 
    WHERE 
    	`deleted_at` is null;
        
    RETURN sell-purches;
END$$
DELIMITER ;


/*
	SELECT `total_money_in_capital`() AS `total_money_in_capital`;
*/