  /*    ## STEP 1: The first set of SQL codes create the bronze schema to  
         ## ingest the 4 raw files covering station level operations of an OMC. 
         ## Each file is structured alike having same columns but covering 
         ## different time periods*/

CREATE SCHEMA IF NOT EXISTS bronze;

 /*  ##  STEP 2: Create tables to contain raw data files*/

CREATE TABLE bronze.omc_raw_1
    (
    date                   text,
    station                text,
    pms_ls                 text,
    pms_rtt                text,
    pms_topp               text,
    ago_ls                 text,
    ago_rtt                text,
    ago_topp               text,
    pmscl_stock            text,
    pms_prod               text,
    agocl_stock            text,
    ago_prod               text,
    pms_var    	           text,
    ago_var   	           text
    );

CREATE TABLE bronze.omc_raw_2
  (
    date                   text,
    station                text,
    pms_ls                 text,
    pms_rtt                text,
    pms_topp               text,
    ago_ls                 text,
    ago_rtt                text,
    ago_topp               text,
    pmscl_stock            text,
    pms_prod               text,
    agocl_stock            text,
    ago_prod               text,
    pms_var    	           text,
    ago_var   	           text
    );   

CREATE TABLE bronze.omc_raw_3
    (
    date                   text,
    station                text,
    pms_ls                 text,
    pms_rtt                text,
    pms_topp               text,
    ago_ls                 text,
    ago_rtt                text,
    ago_topp               text,
    pmscl_stock            text,
    pms_prod               text,
    agocl_stock            text,
    ago_prod               text,
    pms_var    	           text,
    ago_var   	           text
    );;

CREATE TABLE bronze.omc_raw_4
    (
    date                   text,
    station                text,
    pms_ls                 text,
    pms_rtt                text,
    pms_topp               text,
    ago_ls                 text,
    ago_rtt                text,
    ago_topp               text,
    pmscl_stock            text,
    pms_prod               text,
    agocl_stock            text,
    ago_prod               text,
    pms_var    	           text,
    ago_var   	           text
    );


  # /*STEP 3: The files to be ingested as csv files. 
  # The following SQL code copies these files into the 
  # above created schema. 
  # They are copied and maintained in their raw format. 
  # No operations are performed on them*/

COPY bronze.omc_raw_1
   (
    date,
    station,
    pms_ls,
    pms_rtt,
    pms_topp,
    ago_ls,
    ago_rtt,
    ago_topp,
    pmscl_stock,
    pms_prod,
    agocl_stock,
    ago_prod,
    pms_var,
    ago_var
    )
FROM '/path/ops1.csv'
DELIMITER ','
CSV HEADER;

UPDATE bronze.omc.raw_1 
SET source_file = 'ops1.csv';

COPY bronze.omc_raw_2
   (
    date,
    station,
    pms_ls,
    pms_rtt,
    pms_topp,
    ago_ls,
    ago_rtt,
    ago_topp,
    pmscl_stock,
    pms_prod,
    agocl_stock,
    ago_prod,
    pms_var,
    ago_var
    )
FROM '/path/ops2.csv'
DELIMITER ','
CSV HEADER;

UPDATE bronze.omc.raw_2 
SET source_file = 'ops2.csv';

COPY bronze.omc_raw_3
   (
    date,
    station,
    pms_ls,
    pms_rtt,
    pms_topp,
    ago_ls,
    ago_rtt,
    ago_topp,
    pmscl_stock,
    pms_prod,
    agocl_stock,
    ago_prod,
    pms_var,
    ago_var
    )
FROM '/path/ops3.csv'
DELIMITER ','
CSV HEADER;

UPDATE bronze.omc.raw_3 
SET source_file = 'ops3.csv';

COPY bronze.omc_raw_1
   (
    date,
    station,
    pms_ls,
    pms_rtt,
    pms_topp,
    ago_ls,
    ago_rtt,
    ago_topp,
    pmscl_stock,
    pms_prod,
    agocl_stock,
    ago_prod,
    pms_var,
    ago_var
    )
FROM '/path/ops4.csv'
DELIMITER ','
CSV HEADER;

UPDATE bronze.omc.raw_4 SET source_file = 'ops4.csv';

  # /*STEP 4: The following SQL code merges all 4 files into
  # a single file stacked vertically onto each other using 
  # the union function*/

CREATE TABLE bronze.omc_merge AS
SELECT * FROM bronze.omc_raw_1
UNION ALL
SELECT * FROM bronze.omc_raw_2
UNION ALL 
SELECT * FROM bronze.omc_raw_3
UNION ALL
SELECT * FROM bronze.omc_raw_4;
