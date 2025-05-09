/* Creating Required Warehouse, Database and Schema for the Snowflake_Downstream_Pipeline - Project */

create or replace warehouse snowflake_downstream_pipeline
warehouse_size = 'XSMALL';

show databases;
create database if not exists development;
use database development;


-- Creating Medallion architecture

show schemas; 
create or replace transient schema landing_schema;  -- Bronze
create or replace transient schema staging_schema;  -- Silver
create or replace transient schema final_schema;    -- Gold
use schema landing_schema;



/* Creating Required Tables in Landing Schema for inital load from source to Snowflake */

show tables;

CREATE OR REPLACE TABLE ORDERS(
    ORDERID VARCHAR(100),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(100),
    SUB_CATEGORY VARCHAR(100)
);

CREATE OR REPLACE TABLE CUSTOMER(
     NAME VARCHAR(30),
     AGE INT
);

CREATE OR REPLACE TABLE LOAN(
    LOAN_ID VARCHAR(30),
    LOAN_STATUS VARCHAR(30),
    PRINCIPAL INT,
    TERMS INT,
    EFFECTIVE_DATE DATE,
    DUE_DATE DATE,
    PAID_OFF_TIME VARCHAR(50),
    PAST_DUE_DAYS INT,
    AGE INT,
    EDUCATION VARCHAR(50),
    GENDER VARCHAR(10)
);

/* Creating and altering file format for required specifications */

create or replace file format aws_csv_file_format
type = csv;

show file formats;

desc file format aws_csv_file_format;

alter file format aws_csv_file_format 
set 
skip_header = 1;



/* Creating Stage to load data from Source 'S3://bucketsnowflakes3' public bucket to snowflake */

create or replace stage aws_landing_stage
url = 's3://bucketsnowflakes3'
file_format = aws_csv_file_format;

desc stage aws_landing_stage;

list @aws_landing_stage;

select S.$1, S.$2, S.$3, S.$4, S.$5, S.$6, S.$7, S.$8, S.$9, S.$10, S.$11, S.$12 from @aws_landing_stage S;

/* Loading data from s3 bucket to landing_schema tables without any transformations */

show tables;

copy into customer(Age, Name)
from @aws_landing_stage
files = ('sampledata.csv');

copy into orders
from @aws_landing_stage
files = ('OrderDetails.csv');

copy into Loan
from @aws_landing_stage
files = ('Loan_payments_data.csv')
on_error = continue;

-- For Confirmation
select * from customer;
select * from orders;
select * from loan;
