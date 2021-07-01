DELIMITER $$
CREATE DEFINER=`local_admin`@`localhost` FUNCTION `total_user_in_system`() RETURNS int
    NO SQL
BEGIN
	 DECLARE v_total INT;
    SELECT SUM(id) INTO v_total FROM admin;
    RETURN v_total;
END$$
DELIMITER ;


/*
    SELECT `total_user_in_system`() AS `total_user_in_system`;
*/