USE ROLE SYSADMIN;
USE DATABASE SNOWPROCORE;
USE SCHEMA PUBLIC;
USE WAREHOUSE SNOWPROCORE;

/***** 1.IF NOT SPECIFIED: The standard retention period is 1 day (24 hours) and is automatically
         enabled for all Snowflake accounts
*****/
CREATE OR REPLACE TABLE SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL (
    row_id NUMBER(38,0) IDENTITY (1,1) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    insert_date DATE DEFAULT CURRENT_DATE() NOT NULL
);

-- Is not required to run this line of code as a TRANSACTION but for other use cases might be a good idea
-- Note if you are using the visual studio code copy the query_id
BEGIN;
 INSERT INTO SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL (user_name) VALUES ('Enrique'),('Barry'),('Freddie');
COMMIT;

SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;

SHOW TABLES HISTORY;

SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL BEFORE(STATEMENT => '<<<CHANGE ME WITH QUERY ID>>>');

BEGIN;
 INSERT INTO SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL (user_name) VALUES ('ERIC'),('SARA'),('MARK');
COMMIT;

SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL AT(OFFSET => -60*1);

/***** 2.Time Travel allows to drop objects and restore them back.
         Restore dropped objects with no retention period only persists for the
         length of the session in which the object was dropped.
*****/
DROP TABLE IF EXISTS SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;
SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;
UNDROP TABLE SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;
SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;

/***** 3.Specifying the Data Retention Period for an Object, explicit key word DATA_RETENTION_TIME_IN_DAYS up to 90
         with Enterprise edition +. TRANSIENT tables are the exception since there is no Fail-Safe for them
*****/
CREATE OR REPLACE TEMPORARY TABLE SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL (
    row_id NUMBER(38,0) IDENTITY (1,1) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    insert_date DATE DEFAULT CURRENT_DATE() NOT NULL
) DATA_RETENTION_TIME_IN_DAYS = 1;

SHOW TABLES LIKE 'TEST_NO_EXPLICIT_TIMETRAVEL';

BEGIN;
 INSERT INTO SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL (user_name) VALUES ('Bart'),('Luisa'),('Mariana');
COMMIT;

SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;
DROP TABLE IF EXISTS SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;
SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL;

/***** 4. Creating new table from an specific point in time, If you create or replace
          the table you are time traveling you will drop hidden object id in backend.
          Doing this snowflake will loose its pointers to metadata of that table.
*****/
CREATE OR REPLACE TABLE SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL_2 AS
SELECT *
FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL BEFORE(STATEMENT => '<<<CHANGE ME WITH QUERY ID>>>');
--FROM TEST_NO_EXPLICIT_TIMETRAVEL AT(OFFSET => -60*9)
;
SELECT * FROM SNOWPROCORE.PUBLIC.TEST_NO_EXPLICIT_TIMETRAVEL_2;

/***** 5. Create schema based on another schema with time travel.
*****/
create schema restored_schema clone my_schema at(offset => -3600);

/***** 8. Sintax for time travel
*****/

--creates a clone of a table as of the date and time represented by the specified timestamp:
CREATE TABLE RESTORED_TABLE CLONE MY_TABLE
  AT(TIMESTAMP => 'MON, 09 MAY 2015 01:01:00 +0300'::TIMESTAMP_TZ);

--The following CREATE SCHEMA command creates a clone of a schema and all its
--objects as they existed 1 hour before the current time:
CREATE SCHEMA RESTORED_SCHEMA CLONE MY_SCHEMA AT(OFFSET => -3600);

 --The following CREATE DATABASE command creates a clone of a database and
 --all its objects as they existed prior to the completion of the specified statement:
CREATE DATABASE RESTORED_DB CLONE MY_DB
  BEFORE(STATEMENT => '');