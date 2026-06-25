
/*  ## STEP 1: 
    ## Create gold layer schema  */

CREATE SCHEMA IF NOT EXISTS gold;

/*  ## STEP 2: 
    ## Source or use data FROM silver later */

CREATE TABLE gold.omc_merged_gold AS
SELECT * FROM silver.omc_dwh_clean;

/*  ## STEP 3: 
    ## Clean gold layer master file: Instead of noralizaing master file to
    ## create nomalized table, it is more efficient to clean and 
    ## alter types of the gold layer master dataset 
    ## before normalization to star schema datanbase design */

UPDATE gold.omc_merged_gold
SET pms_ls = NULL
WHERE pms_ls = '#N/A';

UPDATE gold.omc_merged_gold
SET ago_ls = NULL
WHERE ago_ls = '#N/A';

UPDATE gold.omc_merged_gold
SET pms_rtt = NULL
WHERE pms_rtt = '#N/A';

UPDATE gold.omc_merged_gold
SET pms_topp = NULL
WHERE pms_topp = '#N/A';

UPDATE gold.omc_merged_gold
SET ago_rtt = NULL
WHERE ago_rtt = '#N/A';

UPDATE gold.omc_merged_gold
SET ago_topp = NULL
WHERE ago_topp = '#N/A';

UPDATE gold.omc_merged_gold
SET pmscl_stock = NULL
WHERE pmscl_stock = '#N/A';

UPDATE gold.omc_merged_gold
SET pms_prod = NULL
WHERE pms_prod = '#N/A';

UPDATE gold.omc_merged_gold
SET agocl_stock = NULL
WHERE agocl_stock = '#N/A';

UPDATE gold.omc_merged_gold
SET ago_prod = NULL
WHERE ago_prod = '#N/A';

UPDATE gold.omc_merged_gold
SET pms_var = NULL
WHERE pms_var = '#N/A';

UPDATE gold.omc_merged_gold
SET ago_var = NULL
WHERE ago_var = '#N/A';

/*  ## Data cleaning process continued: This set of codes cleaned 
    ## invalid values, '#DIV/0!', by 
    ## replacing them to null as part of the */

UPDATE gold.omc_merged_gold
SET pms_ls = NULL
WHERE pms_ls = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET ago_ls = NULL
WHERE ago_ls = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET pms_rtt = NULL
WHERE pms_rtt = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET pms_topp = NULL
WHERE pms_topp = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET ago_rtt = NULL
WHERE ago_rtt = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET ago_topp = NULL
WHERE ago_topp = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET pmscl_stock = NULL
WHERE pmscl_stock = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET pms_prod = NULL
WHERE pms_prod = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET agocl_stock = NULL
WHERE agocl_stock = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET ago_prod = NULL
WHERE ago_prod = '#DIV/0!';

UPDATE gold.omc_merged_gold
SET pms_var = NULL
WHERE pms_var = '#DIV/0!';


/*  ## Data cleaning process continued: This set of codes 
    ## cleaned invalid values, '#REF!', by 
    ## replacing them to null as part of the data cleaning process*/

UPDATE gold.omc_merged_gold
SET pms_ls = NULL
WHERE pms_ls = '#REF!';

UPDATE gold.omc_merged_gold
SET ago_ls = NULL
WHERE ago_ls = '#REF!';

UPDATE gold.omc_merged_gold
SET pms_rtt = NULL
WHERE pms_rtt = '#REF!';

UPDATE gold.omc_merged_gold
SET pms_topp = NULL
WHERE pms_topp = '#REF!';

UPDATE gold.omc_merged_gold
SET ago_rtt = NULL
WHERE ago_rtt = '#REF';

UPDATE gold.omc_merged_gold
SET ago_topp = NULL
WHERE ago_topp = '#REF!';

UPDATE gold.omc_merged_gold
SET pmscl_stock = NULL
WHERE pmscl_stock = '#REF!';

UPDATE gold.omc_merged_gold
SET pms_prod = NULL
WHERE pms_prod = '#REF!';

UPDATE gold.omc_merged_gold
SET agocl_stock = NULL
WHERE agocl_stock = '#REF!';

UPDATE gold.omc_merged_gold
SET ago_prod = NULL
WHERE ago_prod = '#REF!';

UPDATE gold.omc_merged_gold
SET pms_var = NULL
WHERE pms_var = '#REF!';

UPDATE gold.omc_merged_gold
SET ago_var = NULL
WHERE ago_var = '#REF!';

/*  ## Data cleaning process continued: The code below converts
    ## the selected columns to 
    ## numeric type after cleaning all invalid values*/

ALTER TABLE gold.omc_merged_gold
ALTER COLUMN pms_ls TYPE numeric(10, 2) USING pms_ls::numeric(10, 2),
ALTER COLUMN ago_ls TYPE numeric(10, 2) USING ago_ls::numeric(10, 2),
ALTER COLUMN pms_rtt TYPE numeric(10, 2) USING pms_rtt::numeric(10, 2),
ALTER COLUMN pms_topp TYPE numeric(10, 2) USING pms_topp::numeric(10, 2),
ALTER COLUMN ago_rtt TYPE numeric(10, 2) USING ago_rtt::numeric(10, 2),
ALTER COLUMN ago_topp TYPE numeric(10, 2) USING ago_topp::numeric(10, 2),
ALTER COLUMN pmscl_stock TYPE numeric(10, 2) USING pmscl_stock::numeric(10, 2),
ALTER COLUMN pms_prod TYPE numeric(10, 2) USING pms_prod::numeric(10, 2),
ALTER COLUMN agocl_stock TYPE numeric(10, 2) USING agocl_stock::numeric(10, 2),
ALTER COLUMN ago_prod TYPE numeric(10, 2) USING ago_prod::numeric(10, 2),
ALTER COLUMN pms_var TYPE numeric(10, 2) USING pms_var::numeric(10, 2),
ALTER COLUMN ago_var TYPE numeric(10, 2) USING ago_var::numeric(10, 2);

/*  ## Code below verifies that the selected column values have been converted 
    ## to numeric format. All invalid values have been cleaned. This saves time 
    ## FROM having to later clean each table separately if they had been partitioned */

SELECT *
FROM gold.omc_merged_gold
LIMIT 50;

/*  ## STEP 4: 
    ## Normalization and star schema: Code below creates 7 key tables 
    ## using star scheme detailed in the entity relation diagram,
    ## metadata and readme files*/

/*  ## TABLE 1. 
    ## STATIONS TABLE */

CREATE TABLE gold.stations
        (st_id                 CHAR(6) NOT NULL,
        st_name                VARCHAR(60),
        st_location            VARCHAR(60),
        st_area_id             VARCHAR(30) NOT NULL
        );

INSERT INTO gold.stations
    (st_id, st_name, st_location, st_area_id)
VALUES
    ('st0001', 'odor',   'accra_central', 'GA_AC_01'),
    ('st0002', 'shuku1', 'accra_central', 'GA_AC_01'),
    ('st0003', 'shuku2', 'accra_central', 'GA_AC_01'),
    ('st0004', 'agbo',   'accra_central', 'GA_AC_01'),
    ('st0005', 'nmai',   'accra_central', 'GA_AC_01') ,
    ('st0006', 'oyib',   'accra_central', 'GA_AC_01'),
    ('st0007', 'danf',   'accra_central', 'GA_AC_01'),
    ('st0008', 'taif',   'accra_central', 'GA_AC_01'),
    ('st0009', 'kata',   'accra_central', 'GA_AC_01'),
    ('st0010', 'botw',   'accra_central', 'GA_AC_01'),
    ('st0011', 'asha',   'accra_central', 'GA_AC_01'),
    ('st0012', 'ayik',   'accra_east',    'GA_AC_02'),
    ('st0013', 'odum',   'accra_east',    'GA_AC_02'),
    ('st0014', 'ashal1', 'accra_east',    'GA_AC_02'),
    ('st0015', 'ashal2', 'accra_east',    'GA_AC_02'),
    ('st0016', 'nurse',  'accra_east',    'GA_AC_02'),
    ('st0017', 'mayer',  'accra_east',    'GA_AC_02'),
    ('st0018', 'borts',  'accra_east',    'GA_AC_02'),
    ('st0019', 'ablek',  'accra_east',    'GA_AC_02') ,
    ('st0020', 'danch',  'accra_east',    'GA_AC_02'),
    ('st0021', 'aman',   'accra_east',    'GA_AC_02'),
    ('st0022', 'bego',   'eastern',       'EA_EA_01'),
    ('st0023', 'teach',  'eastern',       'EA_EA_01'),
    ('st0024', 'asiak',  'eastern',       'EA_EA_01'),
    ('st0025', 'adeis',  'eastern',       'EA_EA_01'),
    ('st0026', 'kofo',   'eastern',       'EA_EA_01'),
    ('st0027', 'ason',   'eastern',       'EA_EA_01'),
    ('st0028', 'akiman', 'eastern',       'EA_EA_01'),
    ('st0029', 'asonk',  'ash_central',   'AS_CE_01'),
    ('st0030', 'ynkrum', 'ash_central',   'AS_CE_01'),
    ('st0031', 'essien', 'ash_central',   'AS_CE_01'),
    ('st0032', 'tred',   'ash_central',   'AS_CE_01') ,
    ('st0033', 'paky',   'ash_central',   'AS_CE_01'),
    ('st0034', 'obua',   'ash_central',   'AS_CE_01'),
    ('st0035', 'akapo',  'ash_central',   'AS_CE_01'),
    ('st0036', 'konko',  'ash_central',   'AS_CE_01'),
    ('st0037', 'kodi',   'ash_central',   'AS_CE_01')  ,
    ('st0038', 'hema',   'ash_central',   'AS_CE_01'),
    ('st0039', 'toas',   'ash_north',     'AS_NO_01'),
    ('st0040', 'otaf',   'ash_north',     'AS_NO_01'),
    ('st0041', 'aboab',  'ash_north',     'AS_NO_01') ,
    ('st0042', 'asuos',  'ash_north',     'AS_NO_01'),
    ('st0043', 'akrop',  'ash_north',     'AS_NO_01'),
    ('st0044', 'tep',    'ash_north',     'AS_NO_01'),
    ('st0045', 'anyi',   'ash_north',     'AS_NO_01'),
    ('st0046', 'ahen',   'ash_north',     'AS_NO_01'),
    ('st0047', 'abof1',  'ash_north',     'AS_NO_01'),
    ('st0048', 'nyin',   'ash_north',     'AS_NO_01'),
    ('st0049', 'adank',  'ash_north',     'AS_NO_01'),
    ('st0050', 'aboas',  'ash_south',     'AS_SO_01') ,
    ('st0051', 'atagogo', 'ash_south',    'AS_SO_01'),
    ('st0052', 'wiam',   'ash_south',     'AS_SO_01'),
    ('st0053', 'agon',   'ash_south',     'AS_SO_01'),
    ('st0054', 'droman', 'ash_south',     'AS_SO_01'),
    ('st0055', 'ejur',   'ash_south',     'AS_SO_01')  ,
    ('st0056', 'agon2',  'ba_central',    'BA_CE_01'),
    ('st0057', 'kube',   'ba_central',    'BA_CE_01'),
    ('st0058', 'suny',   'ba_central',    'BA_CE_01'),
    ('st0059', 'yawh',   'ba_central',    'BA_CE_01'),
    ('st0060', 'mantuk', 'ba_central',    'BA_CE_01'),
    ('st0061', 'drob',   'ba_central',    'BA_CE_01'),
    ('st0062', 'afrisi', 'ba_central',    'BA_CE_01'),
    ('st0063', 'ntrotr', 'ba_central',    'BA_CE_01'),
    ('st0064', 'chira',  'bono_east',     'BO_EA_01')  ,
    ('st0065', 'nsoatr', 'bono_east',     'BO_EA_01'),
    ('st0066', 'tnkwae', 'bono_east',     'BO_EA_01'),
    ('st0067', 'tforik', 'central_east',  'CE_EA_01'),
    ('st0068', 'wkoase', 'central_east',  'CE_EA_01'),
    ('st0069', 'mks1',   'central_east',  'CE_EA_01'),
    ('st0070', 'mks2',   'central_east',  'CE_EA_01'),
    ('st0071', 'mks3',   'central_east',  'CE_EA_01'),
    ('st0072', 'mks4',   'central_east',  'CE_EA_01'),
    ('st0073', 'salt1',  'central_east',  'CE_EA_01')  ,
    ('st0074', 'salt2',  'central_south', 'CE_SO_01'),
    ('st0075', 'afosu',  'central_south', 'CE_SO_01'),
    ('st0076', 'asik',   'central_south', 'CE_SO_01'),
    ('st0077', 'ajuk',   'central_south', 'CE_SO_01') ,
    ('st0078', 'jamr',   'central_south', 'CE_SO_01'),
    ('st0079', 'kunt',   'central_south', 'CE_SO_01'),
    ('st0080', 'kas1',   'central_south', 'CE_SO_01'),
    ('st0081', 'kas2',   'central_south', 'CE_SO_01'),
    ('st0082', 'kas3',   'central_south', 'CE_SO_01') ,
    ('st0083', 'fett',   'central_south', 'CE_SO_01'),
    ('st0084', 'apajn',  'central_south', 'CE_SO_01'),
    ('st0085', 'eshie',  'central_west',  'CE_WE_01'),
    ('st0086', 'swed',   'central_west',  'CE_WE_01') ,
    ('st0087', 'ccosat', 'central_west',  'CE_WE_01'),
    ('st0088', 'jukw',   'central_west',  'CE_WE_01'),
    ('st0089', 'ankwant', 'central_west', 'CE_WE_01'),
    ('st0090', 'elub',   'central_west',  'CE_WE_01'),
    ('st0091', 'tako',   'central_west',  'CE_WE_01') ,
    ('st0092', 'daboa',  'west_north',    'WE_NO_01'),
    ('st0093', 'esip',   'west_north',    'WE_NO_01'),
    ('st0094', 'bawd',   'west_north',    'WE_NO_01'),
    ('st0095', 'debi',   'west_north',    'WE_NO_01') ,
    ('st0096', 'anymame', 'west_north',   'WE_NO_01'),
    ('st0097', 'tetr',   'west_north',    'WE_NO_01'),
    ('st0098', 'abokai', 'accra_central', 'GA_AC_01'),
    ('st0099', 'bibia',  'west_north',    'WE_NO_01');

/*  ## TABLE 2. 
    ## AREAS TABLE */

CREATE TABLE gold.areas
       (area_id             CHAR(6) NOT NULL,
       constraint areas_pk  PRIMARY KEY (area_id)
       );

ALTER TABLE gold.areas
ALTER COLUMN areas_id TYPE VARCHAR(8);
 
INSERT INTO gold.areas
    (area_id)
VALUES
    ('GA_AC_01'),
    ('GA_AC_02'),
    ('EA_EA_01'),
    ('AS_CE_01'),
    ('AS_NO_01'),
    ('AS_SO_01'),
    ('BA_CE_01'),
    ('BO_EA_01'),
    ('CE_EA_01'),
    ('CE_SO_01'),
    ('CE_WE_01'),
    ('WE_NO_01');

/* ## TABLE 3. 
   ## SALES TABLE */

CREATE TABLE gold.sales AS
SELECT dates_nolap AS sales_date,
           station,
	        pms_ls,
	        ago_ls
FROM gold.omc_merged_gold;

/*  ## Code below checks for null sales_date in sales table first 
    ## returns 589 rows */

SELECT *
FROM  gold.sales
WHERE sales_date IS NULL;

/* ## TABLE 4. 
   ## STOCKS TABLE */

CREATE TABLE gold.stocks AS
SELECT dates_nolap as stock_date,
               station,
               pmscl_stock,
               agocl_stock
FROM gold.omc_merged_gold;

/*   ## Create opening stock columns */

ALTER TABLE gold.stocks
ADD COLUMN pms_opstock numeric,
ADD COLUMN ago_opstock numeric,
ADD COLUMN pms_op_stock,
ADD COLUMN ago_op_stock; 

/*  ## Use common table expression (CTE) and windows function to update
    ## stocks table with opening stock for ago and pms products. 
    ## In the OMC industry, 
    ## the closing stock for the previous day is the next day's opening stock. 
    ## Opening stock is critical for critical analytics, fraud detection
    ## and management reports */

WITH stock_history AS
     (SELECT station,
                      stock_date,
     LAG(pmscl_stock) OVER(PARTITION BY station ORDER BY stock_date) AS pms_op_stock,
     LAG(agocl_stock) OVER(PARTITION BY station ORDER BY stock_date) AS ago_op_stock
FROM gold.stocks)
UPDATE gold.stocks AS s
SET pms_opstock = sh.pms_op_stock,
        ago_opstock = sh.ago_op_stock
FROM stock_history AS sh
WHERE s.station = sh.station
AND s.stock_date = sh.stock_date;

/*   ## #The following code verifies that the preceding 
     ## code has been correctly created and populated */

SELECT *
FROM gold.stocks
WHERE station = 'adank'
AND (stock_date BETWEEN DATE '2024-04-16' AND DATE '2024-04-30');

SELECT *
FROM gold.stocks
WHERE station = 'droman'
AND (stock_date BETWEEN DATE '2024-04-16' AND DATE '2024-04-30');

/*  ## TABLE 5. 
    ## VARIANCE TABLE*/

CREATE TABLE gold.var AS
SELECT dates_nolap AS var_date,
       station,
       pms_var,
       ago_var
FROM gold.omc_merged_gold;

ALTER TABLE gold.var
ADD COLUMN pms_var_verify = (pms_opstock + pms_prod) - pmscl_stock - pms_ls - pms_rtt;

ALTER TABLE gold.stocks
ADD COLUMN ago_var_verify = (ago_opstock + ago_prod) - agocl_stock - ago_ls - ago_rtt;

/*  ## TABLE 6. 
    ## RTT TABLE */

CREATE TABLE gold.rtt AS
SELECT dates_nolap AS rtt_date,
          station,
          pms_rtt,
          ago_rtt
FROM gold.omc_merged_gold;

/*  ## TABLE 7. 
    ## PRODUCT TABLE */

CREATE TABLE gold.prod_topp AS
SELECT dates_nolap AS prod_date,
               station,
               pms_prod,
               pms_topp,
               ago_prod,
               ago_topp
FROM gold.omc_merged_gold;

/*   ## TABLE 8. 
     ## DATES TABLE */

CREATE TABLE gold.dates_tab
      (dates_id         DATE PRIMARY KEY NOT NULL,
       years_id         INT,       
       months_id        INT,
       days_id          INT);

UPDATE gold.dates_tab 
 SET years_id = EXTRACT(YEAR FROM dates_id)::INT  
   WHERE dates_id IS NOT NULL;

UPDATE gold.dates_tab 
 SET months_id = EXTRACT(MONTH FROM dates_id)::INT  
   WHERE dates_id IS NOT NULL;

UPDATE gold.dates_tab 
 SET days_id = EXTRACT(DAY FROM dates_id)::INT  
   WHERE dates_id IS NOT NULL;

/*  ## Command below provides visual inspection of distinct dates. 
    ## It illustrates that the dates commence FROM '2024-04-16' to '2025-09-04'*/  

SELECT dates_id
FROM gold.dates_tab
ORDER BY dates_id;

/*   ## Command below verifies checks for null values */

SELECT dates_id
FROM gold.dates_tab
WHERE dates_id IS NULL;

INSERT INTO gold.dates_tab (years_id)
   SELECT DISTINCT EXTRACT(YEAR FROM sales_date)::INT AS year_id 
   FROM gold.sales
   WHERE sales_date IS NOT NULL
   ORDER BY sales_date;

/*   ## Code below checks whether there are any missing dates. 
     ## A value of 0 for date_diff means duplicated dates while a value 
     ## greater than 1 implies missing dates. In the gold.dates_tab table, 
     ## there are no duplicated or missing dates as all the date+diff values are 1. 
     ## It further implies that all sales_date null values FROM the gold.sales table 
     ## can be deleted*/ 

SELECT dates_id,
       LAG(dates_id) OVER(ORDER BY dates_id),
       (dates_id - LAG(dates_id) OVER(ORDER BY dates_id)) AS date_diff
FROM gold.dates_tab;

/*   ## Code below deletes all data where sales_date is null */
DELETE FROM gold.sales
WHERE sales_date IS NULL;

DELETE FROM gold.stocks
WHERE stock_date IS NULL;

DELETE FROM gold.var
WHERE var_date IS NULL;

DELETE FROM gold.rtt
WHERE rtt_date IS NULL;

DELETE FROM gold.prod_topp
WHERE prod_date IS NULL;

/*  ## STEP 5:
    ## CREATION OF CONSTRAINTS AND INDICES: 
    ## Update tables with primary and foreign keys as well as index constraints*/

ALTER TABLE stations
ADD CONSTRAINT pk_stations
PRIMARY KEY (st_name);

ALTER TABLE areas
ADD CONSTRAINT pk_areas
PRIMARY KEY (area_id);

ALTER TABLE sales
ADD COLUMN sales_id TEXT;

/*  ## This code creates sales_id field or column 
    ## to be used as primary key for sales table  */ 
UPDATE sales
SET sales_id = sales_date || '-' || station;

/*  ## This code was to create primary key using sales_id column 
    ## but it returns an error as illustrated in screenshot 
    ## saying "no unique index" implying there are duplicate values.
    ## This was one of the reasons why I was removing all such
    ## duplicates in the silver layer in the master table instead of 
    ## now having to remove duplicates in each fact table in the star schema.
    ## Data work is messy  */ 

ALTER TABLE sales
ADD CONSTRAINT pk_sales
PRIMARY KEY (sales_id);

/*  ## PROBLEM SOLVING: Code below identifies duplicate sales_id  
    ## by sales_date. It suggests that these are FROM duplicate records 
    ## FROM the original merged dataset indicating overlapping records  */ 

select *
from gold.sales;

SELECT sales_date,
       COUNT(sales_id)
FROM gold.sales
GROUP BY sales_date, sales_id
HAVING count(sales_id) > 1
ORDER BY sales_date;

/*  ## PROBLEM SOLVING: Random tests to determine if duplicate sales_id also 
    ## have other duplicate records such as pms_ls and ago_ls data  */ 

SELECT count(sales_id)
FROM gold.sales
where sales_id = '2024-04-17-agbo';

SELECT *
FROM gold.sales
WHERE sales_id = '2025-06-19-paky';

/*  ## PROBLEM SOLVING: In order not to mistakenly delete needed data,   
    ## a row_index is created. This enables efficient deletion of duplicate records but   
    ## prevents potential loss of accurate data  */ 


/*  ## Create sales_id column    */
ALTER TABLE gold.sales
ADD COLUMN sales_index INTEGER;

/*  ## Populate sales_index column using windows GROUP BY
    ## function, ensuring it is ordered by sales_date  */

WITH numbered_rows AS 
    (
    SELECT 
          ctid,
          ROW_NUMBER () OVER(ORDER BY sales_date) AS rn 
    FROM gold.sales
    )
UPDATE gold.sales AS s      
SET sales_index = n.rn
FROM numbered_rows AS n
WHERE s.ctid = n.ctid;

/*  ## Code verifies that sales_index has been created and
    ## runs parallel to sales_date    */

SELECT *
FROM gold.sales
ORDER BY sales_index;

/*  ## This previous code is run again to determine the
    ## dates that are duplicated.
    ## It illustrates that the following are duplicated:
    ## 2024-07-24 to 2024-07-31; 
    ## 2024-08-03 to 2024-08-04;
    ## 2024-11-19 to 2024-11-20;
    ## 2025-06-01 to 2025-06-22*/

SELECT sales_date,
       COUNT(sales_id)
FROM gold.sales
GROUP BY sales_date, sales_id
HAVING count(sales_id) > 1
ORDER BY sales_date;

/* REMOVE DUPLICATES: Time to delicately remove duplicates */
SELECT *
FROM gold.sales
WHERE sales_date = '2024-07-24'
ORDER BY sales_index;


select *
from gold.sales;

/*   ## Thsi Is the first delee. A test */
DELETE FROM gold.sales
WHERE sales_index BETWEEN 9601 AND 9696;

/*  ## Before running code to automate deletion of
    ## duplicate, run code below to verify 
    ## the duplicated dates listed above */

SELECT *,
       ROW_NUMBER() OVER(
                         PARTITION BY sales_date, station
                         ORDER BY sales_index)
                         AS rn
FROM gold.sales;                         

/*   ## Code below previews duplicate rows using a CTE */

WITH duplicates AS 
(
    SELECT *,
           ROW_NUMBER() OVER(
                        PARTITION BY 
                        sales_date, station
                        ORDER BY sales_index
                        ) AS rn
    FROM gold.sales
)
SELECT *
FROM gold.sales
WHERE sales_index IN
(
    SELECT sales_index
    FROM duplicates
    WHERE rn > 1
);

/*   ## Code below verifies again that duplicate rows have 
     ## been deleted. Ttotal number o rows have decreased from 
     ## an excess of 52,900 to 49,368 */

SELECT *
FROM gold.sales;

/*  ## Copy of sales table as a copy 
    ## before deleting duplicates from original sales table */
CREATE TABLE gold.sales_copy AS
  SELECT * FROM gold.sales;

/*   ## The code below deletes duplicate rows */

WITH duplicates AS 
    (
    SELECT *,
           ROW_NUMBER() OVER(
                        PARTITION BY 
                        sales_date, station
                        ORDER BY sales_date
                        ) AS rn
    FROM gold.sales
    )
DELETE FROM gold.sales
WHERE sales_index IN
     (
     SELECT sales_index
     FROM duplicates
     WHERE rn > 1
     );

/*  ## I was initially having error messages after running this code.
    ## 1. Had to ensure all primary and foreign key selected were compatible
    ## 2. Checked the number of distinct station rows in gold.sales (100)
    ##    with that in gold.stations (99)*/
ALTER TABLE gold.sales
ADD CONSTRAINT fk_sales_stations
FOREIGN KEY (station)
REFERENCES gold.stations(st_name);

SELECT COUNT(DISTINCT station)
FROM gold.sales

SELECT COUNT(DISTINCT st_name)
FROM gold.stations;

/*   ## Other checks to identify causes of
     ## foreign key problems for sales table  */
select distinct station
from gold.sales;

SELECT column_name,
       data_type
FROM information_schema.columns
WHERE table_schema = 'gold'
AND table_name = 'stations';  

/*  ## Code below confirms that 'abof2' is not in gold.stations table
    ## but is in gold.sales table. This is another reasonw why the 
    ## foreign key is not being created*/
SELECT count(st_name)
FROM gold.stations
where st_name = 'abof2';

/*  ## insert 'abof2' and its realted details into gold.stations table */

INSERT INTO gold.stations
    (st_id, st_name, st_location, st_area_id)
VALUES
 ('st0100', 'abof2', 'ash_north', 'AS_NO_01');

/*  ## Check data type of all tables. Identiy why 
    ## not possible to create foreign key constraint.
    ## Find that string variables are text in fact tables 
    ## but varchar in dimension tables */

/*  ## 2 codes below uses ub-queries to check for values in child table (sales)
    ## that are not in parent table, possible reason 
    ## why foreign key is not being created */

SELECT distinct station
FROM gold.sales
WHERE station NOT IN
  (SELECT st_name
    FROM gold.stations);

SELECT distinct st_name
FROM gold.stations
WHERE st_name NOT IN
  (SELECT DISTINCT station
    FROM gold.sales);

/*  ## Use UPDARE command to change different spellins and errors  
    ## in names for same four stations */

UPDATE gold.stations
SET st_name = 'ccoast'
WHERE st_name = 'ccosat';

UPDATE gold.stations
SET st_name = 'shuk1'
WHERE st_name = 'shuku1';

UPDATE gold.stations
SET st_name = 'shuk2'
WHERE st_name = 'shuku2';

UPDATE gold.sales
SET station = 'taif'
WHERE station = 'TAIF';  

/*   ##      */
ALTER TABLE gold.sales
ALTER COLUMN station TYPE varchar(30); 

ALTER TABLE gold.sales
ALTER COLUMN sales_id TYPE varchar(30);

/*   ## Create primary and foreign keys for stocks table  */

select *
from gold.stocks;

UPDATE sales
SET stock_id = stock_date || '-' || station;

/*  ## This code was to create primary key using sales_id column 
    ## but it returns an error as illustrated in screenshot 
    ## saying "no unique index" implying there are duplicate values.
    ## This was one of the reasons why I was removing all such
    ## duplicates in the silver layer in the master table instead of 
    ## now having to remove duplicates in each fact table in the star schema.
    ## Data work is messy  */ 

ALTER TABLE sales
ADD CONSTRAINT pk_sales
PRIMARY KEY (sales_id);

ALTER TABLE stocks
ADD CONSTRAINT pk_stocks
PRIMARY KEY stock_id(stock_date, station);

ALTER TABLE stocks
ADD CONSTRAINTS fk_stocks_stations
FOREIGN KEY (station)
  REFERENCES stations(st_name);

ALTER TABLE gold.var
ADD CONSTRAINT pk_var
PRIMARY KEY (var_date, station);

ALTER TABLE var
ADD CONSTRAINTS fk_var_stations
FOREIGN KEY (station)
  REFERENCES stations(st_name);

ALTER TABLE gold.rtt
ADD CONSTRAINT pk_var
PRIMARY KEY (var_date, station);

ALTER TABLE rtt
ADD CONSTRAINTS fk_rtt_stations
FOREIGN KEY (station)
  REFERENCES stations(st_name);

ALTER TABLE prod_topp
ADD CONSTRAINTS pk_prod_topp
PRIMARY KEY (prod_date, station);

ALTER TABLE prod_topp
ADD CONSTRAINTS fk_prod_topp_stations
FOREIGN KEY (station)
  REFERENCES stations(st_name);

/*   ## Add unique index to the stations table by making the st_id a unique index*/
