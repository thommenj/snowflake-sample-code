USE ROLE ACCOUNTADMIN;

CREATE STORAGE INTEGRATION S3_BUCKET_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = '<iam_role>'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-ep-hackathon/csv/', 's3://snowflake-ep-hackathon/excel/', 's3://snowflake-ep-hackathon/streaming/');