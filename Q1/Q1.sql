CREATE FUNCTION checkIntegrityOnMajor ()
RETURNS trigger AS $$

BEGIN
-- -- we can uodate a record, so long as mcode stays the same:
-- IF (TG_OP = 'UPDATE' AND OLD.mcode = NEW.mcode) THEN 
-- RETURN NEW;

-- if the row to be deleted or updated is referenced in the student table:
IF(OLD.mcode in (SELECT DISTINCT mcode from student))
THEN 
RAISE EXCEPTION 'Referential Integrity Error : This record is referenced in table STUDENT';
ROLLBACK;
END IF;

-- otherwise, the row is ok to delete. if we were to return null, 0 rows are affected 
-- for the deletion of a row that is not referenced in the student table
RETURN OLD; 

END;
$$ LANGUAGE PLpgSQL;


-- the trigger to check for a violation of the foreign key:
CREATE TRIGGER majorTableIntegrity 
BEFORE DELETE OR UPDATE 
ON MAJOR 
FOR EACH ROW EXECUTE PROCEDURE checkIntegrityOnMajor();


----------------------------------


CREATE FUNCTION checkIntegrityOnStudent ()
RETURNS trigger AS $$

BEGIN

-- check if the row that is updated/inserted has an mcode that exists in the major table:
IF(NEW.mcode NOT in (SELECT DISTINCT mcode from major))
THEN 
RAISE EXCEPTION 'Referential Integrity Error : This record is not referenced in table MAJOR';
ROLLBACK;
END IF;

-- if it is referenced, we're all good to add/update:
RETURN NEW; 

END;
$$ LANGUAGE PLpgSQL;


-- the trigger to check for a violation of the foreign key:
CREATE TRIGGER studentTableIntegrity 
BEFORE INSERT OR UPDATE
ON STUDENT 
FOR EACH ROW EXECUTE PROCEDURE checkIntegrityOnStudent();