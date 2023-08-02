USE ROLE SYSADMIN;

-- Create a warehouse
CREATE OR REPLACE WAREHOUSE NOTEBOOKS
  WAREHOUSE_SIZE = 'XSMALL'
  WAREHOUSE_TYPE = 'STANDARD'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 1
  SCALING_POLICY = 'ECONOMY';

-- Create a database
CREATE OR REPLACE DATABASE NOTEBOOKS;

-- Create interna named stage
CREATE OR REPLACE STAGE NOTEBOOKS.PUBLIC.XLS_LAKE DIRECTORY = (ENABLE = TRUE);

-- Create table to store the data from the XLS file (stage)
CREATE OR REPLACE TABLE NOTEBOOKS.PUBLIC.XLS_TABLE_STAGE
(
    "order_date"      VARCHAR,
    "allocation_date" VARCHAR,
    "so_number"       VARCHAR,
    "so_line"         VARCHAR,
    "cust_po"         VARCHAR,
    "end_user_po"     VARCHAR,
    "account_rep"     VARCHAR,
    "p_line"          VARCHAR,
    "td_pn"           VARCHAR,
    "manuf_pn"        VARCHAR
);

-- Create a final table to store the data from the XLS file from stage
CREATE OR REPLACE TABLE NOTEBOOKS.PUBLIC.XLS_TABLE
(
    order_date      DATE,
    allocation_date DATE,
    so_number       VARCHAR,
    so_line         VARCHAR,
    cust_po         VARCHAR,
    end_user_po     VARCHAR,
    account_rep     VARCHAR,
    p_line          VARCHAR,
    td_pn           VARCHAR,
    manuf_pn        VARCHAR
);

-- Create a stream to track changes in the stage
CREATE OR REPLACE STREAM NOTEBOOKS.PUBLIC.XLS_TABLE_STAGE_STREAM ON TABLE NOTEBOOKS.PUBLIC.XLS_TABLE_STAGE;
