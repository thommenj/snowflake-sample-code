USE ROLE SYSADMIN;
USE DATABASE ACCOUNTADMIN_MGMT;
USE SCHEMA UTILITIES;
USE WAREHOUSE ACCOUNTADMIN_MGMT;

CREATE OR REPLACE PROCEDURE ACCOUNTADMIN_MGMT.UTILITIES.CREATE_DYNAMIC_SALESFORCE_VIEW(db_name string, schema_name string, table_name string)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'numpy')
HANDLER = 'main'
COMMENT = 'Created by Luis Fuentes, this receives a db_name, schema_name and table_name and creates a view with the same name as the table_name + adding _v and casts all VARCHAR columns to 1000 max length'
EXECUTE AS CALLER
AS
$$
import pandas as pd
import numpy as np

def transform_name(name, type, name_alias):
    if isinstance(type, str) and 'VARCHAR' in type:
        return f"CAST(SUBSTR({name},1,10000) AS VARCHAR(10000)) AS {name_alias}".format(name, name_alias)
    else:
        return f"{name} AS {name_alias}".format(name, name_alias)

def main(session, db_name, schema_name, table_name):

	# get table_view_mapping data
	table_view_mapping = session.sql(f"SELECT * FROM ACCOUNTADMIN_MGMT.UTILITIES.SALESFORCE_TABLE_VIEW_MAPPING WHERE NAME_SALESFORCE_ENVIRONMENT = '{schema_name}' AND NAME_SALESFORCE_TABLE_ORIGINAL = '{table_name}'".format(schema_name, table_name)).collect()
	table_view_mapping_dic = [row.asDict() for row in table_view_mapping][0]
	table_name = table_view_mapping_dic['NAME_SALESFORCE_TABLE_ORIGINAL']
	table_for_desc_name = table_view_mapping_dic['NAME_SNOWFLAKE_RESERVED_WORD']
	view_name = table_view_mapping_dic['NAME_SALESFORCE_VIEW_ALIAS']

	# get the table columns
	result_describe_table = [row.as_dict() for row in session.sql(f"DESCRIBE TABLE {db_name}.{schema_name}.{table_for_desc_name};".format(db_name, schema_name, table_for_desc_name)).collect()]

	# create a dataframe from the list of dictionaries AND remove the columns that are not needed
	df_describe_table = pd.DataFrame(result_describe_table)
	df_describe_table.drop(columns=['null?', 'default','primary key', 'unique key','check', 'expression', 'comment', 'policy name'], inplace=True)

	# get mapping table if any
	result_salesforce_mapping = [row.as_dict() for row in session.sql(f"SELECT NAME_SALESFORCE_ATTRIBUTE, NAME_ALIAS FROM ACCOUNTADMIN_MGMT.UTILITIES.SALESFORCE_MAPPING WHERE NAME_SALESFORCE_OBJECT = '{table_name}'".format()).collect()]

	# create a dataframe from the list of dictionaries
	df_salesforce_mapping = pd.DataFrame(result_salesforce_mapping)

	# merge the two dataframes
	if df_salesforce_mapping.empty:
		final_df = df_describe_table
		final_df['NAME_ALIAS'] = final_df['name']
	else:
		final_df = pd.merge(df_describe_table, df_salesforce_mapping, left_on='name', right_on='NAME_SALESFORCE_ATTRIBUTE', how='left')
		final_df['NAME_ALIAS'] = final_df.apply(lambda x: x['name'] if pd.isna(x['NAME_ALIAS']) else x['NAME_ALIAS'], axis=1)

	# apply the transform_name function to create a new column called 'name_new'
	final_df['name_new'] = final_df.apply(lambda x: transform_name(x['name'], x['type'], x['NAME_ALIAS']), axis=1)

	# create a list of the new column names
	column_list:list = final_df['name_new'].to_list()

	# create a string of the new column names
	columns_str:str = ', '.join(column_list)

	# append the final result to something like "CREATE OR REPLACE VIEW {db_name}.{schema_name}}.{table_name} AS SELECT {columns_str} FROM {db_name}.{schema_name}.{table_name};"
	final_query:str = f"CREATE OR REPLACE VIEW {db_name}.{schema_name}.{view_name} AS SELECT {columns_str} FROM {db_name}.{schema_name}.{table_for_desc_name};"

	session.sql(final_query).collect()

	return "Success!"
$$;

-- CALL STORED PROCEDURE
CALL ACCOUNTADMIN_MGMT.UTILITIES.CREATE_DYNAMIC_SALESFORCE_VIEW('STITCH', 'SALESFORCEFSL3', 'CASE');

-- CHECK THE VIEW
SELECT * FROM STITCH.SALESFORCEFSL3.CASE_V LIMIT 10;

-- Check all views in schema
SHOW VIEWS IN SCHEMA STITCH.SALESFORCEFSL3;
