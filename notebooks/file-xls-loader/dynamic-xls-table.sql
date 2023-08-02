USE ROLE SYSADMIN;
USE DATABASE NOTEBOOKS;
USE SCHEMA PUBLIC;
USE WAREHOUSE NOTEBOOKS;

CREATE OR REPLACE DYNAMIC TABLE NOTEBOOKS.PUBLIC.XLS_TABLE
TARGET_LAG = '1 days'
WAREHOUSE = NOTEBOOKS
AS
SELECT CAST("order_date" AS DATE)                                                               AS order_date,
       CASE WHEN "allocation_date" != 'None' THEN CAST("allocation_date" AS DATE) ELSE NULL END AS allocation_date,
       CAST("so_number" AS INT)                                                                 AS so_number,
       "so_line"                                                                                AS so_line,
       "cust_po"                                                                                AS cust_po,
       "end_user_po"                                                                            AS end_user_po,
       CASE WHEN "account_rep" != '' THEN "account_rep" ELSE NULL END                           AS account_rep,
       "p_line"                                                                                 AS p_line,
       "td_pn"                                                                                  AS td_pn,
       "manuf_pn"                                                                               AS manuf_pn
FROM NOTEBOOKS.PUBLIC.XLS_TABLE_STAGE;

ALTER DYNAMIC TABLE NOTEBOOKS.PUBLIC.XLS_TABLE RESUME;

ALTER DYNAMIC TABLE NOTEBOOKS.PUBLIC.XLS_TABLE REFRESH;

SELECT * FROM NOTEBOOKS.PUBLIC.XLS_TABLE;

-- 1.- ADD A NEW FILE TO THE STAGE

-- 2.- RUN THE FOLLOWING COMMANDS
CALL NOTEBOOKS.PUBLIC.XLS_LOADER_SP(BUILD_SCOPED_FILE_URL(@NOTEBOOKS.PUBLIC.XLS_LAKE,'/testing2.xls'));
SELECT * FROM NOTEBOOKS.PUBLIC.XLS_TABLE_STAGE;

-- 3.- REFRESH THE TABLE
ALTER DYNAMIC TABLE NOTEBOOKS.PUBLIC.XLS_TABLE REFRESH;
SELECT * FROM NOTEBOOKS.PUBLIC.XLS_TABLE;

-- 4.- STOP DYNAMIC TABLE
ALTER DYNAMIC TABLE NOTEBOOKS.PUBLIC.XLS_TABLE SUSPEND;