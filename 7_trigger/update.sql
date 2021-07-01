
CREATE TRIGGER `after_admin_update` AFTER UPDATE ON `admin`
 FOR EACH ROW IF (NEW.deleted_at is null) THEN
	INSERT INTO system_log(process_type,user_id,table_name) VALUES ('update',OLD.id,'admin');
END IF
/*
    triggerd after we update into admin table 
*/