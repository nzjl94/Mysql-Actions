DELIMITER $$
CREATE DEFINER=`local_admin`@`localhost` PROCEDURE `execute_table`(IN `table_name` VARCHAR(30), IN `table_limit` SMALLINT(3), IN `table_date` DATE)
BEGIN
 SET @t1 =CONCAT('SELECT * FROM ',table_name,' where deleted_at is null and CAST(created_at as DATE)="',table_date,'" ', 'limit ',table_limit);
 PREPARE stmt3 FROM @t1;
 EXECUTE stmt3;
 DEALLOCATE PREPARE stmt3;
END$$
DELIMITER ;


/*
    this procedure useful to know how many data inserted for each table and each day
    call execute_table("sell",5,"2020-03-24");
*/