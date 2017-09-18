-- populating:
\i ~/Desktop/swen304_a3_q2.sql 

CREATE FUNCTION coursePass (In_sId int, In_cId char, In_year int, In_grade
char, In_graduationDate date) RETURNS VOID AS $$
BEGIN

-- ** to insert into the result table, we must ensure that the sid and cid reference existing records** -- 

-- check if the student id is valid:
IF (In_sId not in (select sid from student)) THEN 
RAISE EXCEPTION 'ERROR : No such Student exists';
ROllBACK;
END IF;

-- check that the course id is valid:
IF (In_cId not in (select cId from course)) THEN 
RAISE EXCEPTION 'ERROR : No such Course exists';
ROllBACK;
END IF;

--** For primary key constraints on the results table: **--
IF ((In_sId,In_cId,In_year) in (select sid,cid,year from result)) THEN
RAISE EXCEPTION 'ERROR : Duplicate records are not permitted in the result table';
ROllBACK;
END IF;

-- if the grade was not a D, 
-- and the student has never passed this course before, then:
--update the amount of points earned by that student:
IF (In_grade < 'D' AND ((select count(*) from result where sid = In_sId AND cid = In_cId AND grade < 'D') = 0)) THEN 
	UPDATE STUDENT SET pointsEarned = pointsEarned + (select points from course where cid = In_cId)
 	WHERE sId = In_sId;
END IF;

-- If the foreign and primary key constraints are satisfied, we are all good to add to the result table:
-- record the result of the students course in the results table:
INSERT INTO RESULT VALUES (In_sId,In_cId,In_year,In_grade);

-- if the student has enough points to graduate, update the graduate table:
IF ((select pointsearned from student where sid = In_sId) >= 360) THEN 
INSERT INTO GRADUATE VALUES (In_sId,In_graduationDate);
END IF;

END;
$$ LANGUAGE PLpgSQL;




-- testing:

\i ~/Desktop/swen304_a3_q2_test.txt 

-- shows the number of times a course (ENGR 101) was passed: 
select count(*) from result where sid = 5003 AND cid = 'COMP103' AND grade < 'D';


DROP TABLE course;
DROP TABLE graduate;
DROP TABLE major;
DROP TABLE result;
DROP TABLE student;

DROP TABLE course;
DROP TABLE major;


DROP FUNCTION coursePass (In_sId int, In_cId char, In_year int, In_grade
char, In_graduationDate date);




