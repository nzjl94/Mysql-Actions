DELIMITER $$
CREATE DEFINER=`local_admin`@`localhost` PROCEDURE `convert_money`(IN `table_name` VARCHAR(50), IN `currency_amount` MEDIUMINT)
BEGIN
IF table_name= "sell" THEN
	SELECT id,(total_price-(total_price*(total_discount/100)))/currency_amount as 'new_currency' FROM `sell` WHERE `deleted_at` is null;
ELSEIF table_name="purches" THEN
	SELECT id,(total_price)/currency_amount as 'new_currency' FROM `purches` WHERE `deleted_at` is null;
END IF;

END$$
DELIMITER ;


/*
    call convert_money("sell",1200);
    call convert_money("purches",1200);
*/