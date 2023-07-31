
USE ROLE SYSADMIN;

-- In Snowflake create a warehouse call notebooks
CREATE WAREHOUSE IF NOT EXISTS notebooks
  WAREHOUSE_SIZE = 'XSMALL'
  WAREHOUSE_TYPE = 'STANDARD'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 1
  SCALING_POLICY = 'ECONOMY';

-- In Snowflake create a database call notebooks
CREATE DATABASE IF NOT EXISTS notebooks;
