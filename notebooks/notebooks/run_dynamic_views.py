USE ROLE SYSADMIN;
USE DATABASE ACCOUNTADMIN_MGMT;
USE SCHEMA UTILITIES;
USE WAREHOUSE ACCOUNTADMIN_MGMT;

CREATE OR REPLACE PROCEDURE ACCOUNTADMIN_MGMT.UTILITIES.RUN_DYNAMIC_SALESFORCE_VIEWS()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'pandas')
HANDLER = 'main'
COMMENT = 'Created by Luis Fuentes, this procedure runs all multiple schemas in the Stitch Database to refresh Salesforce views'
EXECUTE AS CALLER
AS
$$
import pandas as pd

def main(session):

	database:str = 'STITCH'

	for schema in ['SALESFORCEFSL3']:
		result = session.sql(f"SHOW TABLES IN STITCH.{schema}".format(schema)).collect()
		df = pd.DataFrame(result)
		for table in df['name'].to_list():
			if table != '_SDC_REJECTED':
				create_view_query:str = f"CALL ACCOUNTADMIN_MGMT.UTILITIES.CREATE_DYNAMIC_SALESFORCE_VIEW('{database}', '{schema}', '{table}');".format(database, schema, table)
				session.sql(create_view_query).collect()

	return "Success!"

$$;

-- CALL STORED PROCEDURE
CALL ACCOUNTADMIN_MGMT.UTILITIES.RUN_DYNAMIC_SALESFORCE_VIEWS();
