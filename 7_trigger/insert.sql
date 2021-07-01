
CREATE TRIGGER `after_admin_insert` AFTER INSERT ON `admin`
 FOR EACH ROW INSERT INTO system_log(process_type,user_id,table_name) VALUES ('insert',NEW.id,'admin')
/*
    triggerd after we insert into admin table 
*/