USE ROLE SYSADMIN;
USE DATABASE ACCOUNTADMIN_MGMT;
USE SCHEMA UTILITIES;
USE WAREHOUSE ACCOUNTADMIN_MGMT;

CREATE OR REPLACE PROCEDURE ACCOUNTADMIN_MGMT.UTILITIES.CREATE_DYNAMIC_SALESFORCE_VIEW(db_name string, schema_name string, table_name string)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'pandas')
HANDLER = 'main'
COMMENT = 'Created by Luis Fuentes, this receives a db_name, schema_name and table_name and creates a view with the same name as the table_name + adding _v and casts all VARCHAR columns to 1000 max length'
EXECUTE AS CALLER
AS
$$
import pandas as pd

def transform_name(name, type):
    if isinstance(type, str) and 'VARCHAR' in type:
        #return name + '0007'
        return f"CAST(SUBSTR({name},1,10000) AS VARCHAR(10000)) AS {name}".format(name)
    else:
        return f"{name} AS {name}".format(name)

def main(session, db_name, schema_name, table_name):

	# get the table columns
	result = session.sql(f"DESCRIBE TABLE {db_name}.{schema_name}.{table_name};".format(db_name, schema_name, table_name)).collect()

	# convert all the Snowpark Row elements to dictionaries
	result = [row.as_dict() for row in result]

	# create a dataframe from the list of dictionaries
	df = pd.DataFrame(result)

	# apply the transform_name function to create a new column called 'name_new'
	df['name_new'] = df.apply(lambda x: transform_name(x['name'], x['type']), axis=1)

	# create a list of the new column names
	column_list:list = df['name_new'].to_list()

	# create a string of the new column names
	columns_str:str = ', '.join(column_list)

	# append the final result to something like "CREATE OR REPLACE VIEW {db_name}.{schema_name}}.{table_name}_V AS SELECT {columns_str} FROM {db_name}.{schema_name}.{table_name};"
	final_query:str = f"CREATE OR REPLACE VIEW {db_name}.{schema_name}.{table_name}_V AS SELECT {columns_str} FROM {db_name}.{schema_name}.{table_name};"

	session.sql(final_query).collect()

	return "Success!"

$$;

-- CALL STORED PROCEDURE
CALL ACCOUNTADMIN_MGMT.UTILITIES.CREATE_DYNAMIC_SALESFORCE_VIEW('STITCH', 'SALESFORCEFSL3', 'ASSIGNEDRESOURCE');

-- CHECK THE VIEW
SELECT * FROM STITCH.SALESFORCEFSL3.ACCOUNT_V LIMIT 10;

