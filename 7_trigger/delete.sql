CREATE TRIGGER `after_admin_delete` AFTER UPDATE ON `admin`
 FOR EACH ROW IF (NEW.deleted_at is not null) THEN
	INSERT INTO system_log(process_type,user_id,table_name) VALUES ('delete',OLD.id,'admin');
END IF


/*
    triggerd after we delete into admin table [we use soft delete in this assignment]
*/