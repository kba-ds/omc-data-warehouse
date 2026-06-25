
 /*   ## STEP 1:
      ## Create silver layer schema ##*/

CREATE SCHEMA IF NOT EXISTS silver;

/*    ## STEP 2:
      ## Create source file for silver layer
      ## from bronze merged data warehouse for silver layer
      ## schema*/

CREATE TABLE silver.omc_merged_silver AS
SELECT * FROM bronze.omc_merge;

/*    ## Verify that silver layer source data is
      ## same as bronze larger merged database ##*/

SELECT DISTINCT date
FROM silver.omc_merged_silver;

SELECT COUNT(*)
FROM silver.omc_merged_silver;

/*     ## STEP 3:
       ## Create new silver layer table without
       ## overlapping dates and data*/

CREATE TABLE silver.omc_dwh_clean AS
SELECT * FROM silver.omc_merged_silver;

/*   ## Clean original text date COLUMN to actual
     ## sql formatted date*/

ALTER TABLE silver.omc_dwh_clean
ADD COLUMN years TEXT;

ALTER TABLE silver.omc_dwh_clean
ADD COLUMN dates_nolap DATE;

UPDATE silver.omc_dwh_clean
SET dates_nolap = date_clean::DATE;

ALTER TABLE silver.omc_dwh_clean
ADD COLUMN row_num SERIAL;

/*  ## The code below alters name of row_num to row_index.
    ## Indexing is critical to database creation and
    ## addressing the problem of overlapping dates*/

ALTER TABLE silver.omc_dwh_clean
RENAME COLUMN row_num TO row_index;

/* ## verify that row_num column is as created ##*/

SELECT row_num
FROM silver.omc_dwh_clean;

SELECT date, row_num
FROM silver.omc_dwh_clean;

/* ## All data in rows 1 to 26523 belong to 2024 while
   ## those from rows 26524-53297 are for 2025

UPDATE silver.omc_dwh_clean
  SET years = '2024'
   WHERE row_num BETWEEN 1 AND 26523;

UPDATE silver.omc_dwh_clean
  SET years = '2025'
   WHERE row_index BETWEEN 26524 AND 53297;

/* ## |Below is the query to validate whether row_num
   ## syncs with date and years rows - it does*/

SELECT row_index, date, years
FROM silver.omc_dwh_clean
ORDER BY row_index ASC;

/* ## Create new date column with sql format*/

ALTER TABLE silver.omc_dwh_clean
ADD COLUMN format_month TEXT;

UPDATE silver.omc_dwh_clean
  SET format_month =
    (SELECT CASE
	   WHEN SPLIT_PART(date, '.', 3) = 'JAN' THEN '01'
	   WHEN SPLIT_PART(date, '.', 3) = 'FEB' THEN '02'
	   WHEN SPLIT_PART(date, '.', 3) = 'MAR' THEN '03'
	   WHEN SPLIT_PART(date, '.', 3) = 'APR' THEN '04'
	   WHEN SPLIT_PART(date, '.', 3) = 'MAY' THEN '05'
	   WHEN SPLIT_PART(date, '.', 3) = 'JUNE' THEN '06'
	   WHEN SPLIT_PART(date, '.', 3) = 'JULY' THEN '07'
	   WHEN SPLIT_PART(date, '.', 3) = 'AUG' THEN '08'
	   WHEN SPLIT_PART(date, '.', 3) = 'SEPT' THEN '09'
	   WHEN SPLIT_PART(date, '.', 3) = 'OCT' THEN '10'
     WHEN SPLIT_PART(date, '.', 3) = 'NOV' THEN '11'
	   WHEN SPLIT_PART(date, '.', 3) = 'DEC' THEN '12'
	END);

/* ## Date is a PostgreSQL keyword and cannot be used
   ## as a column name.
  ## Therefore, the column name is altered to dates*/

ALTER TABLE silver.omc_dwh_clean
RENAME COLUMN date to dates;

/* ## Create a new column with appropriately formatted date*/

ALTER TABLE silver.omc_dwh_clean
ADD COLUMN date_clean TEXT;

/* ## Update clean_date COLUMN with appropriately 
   ## formatted date but as text*/

UPDATE silver.omc_dwh_clean
  SET date_clean =
    years||'-'||format_month||'-'||SPLIT_PART(dates, '.', 2);

/* ## Convert date_clean to date type*/

ALTER TABLE silver.omc_dwh_clean
ALTER COLUMN date_clean TYPE DATE
USING date_clean::DATE;

/*## To identify overlapping dates, run following sql code below.
  ## If count(date_clean) is greater than 100, it indicates
  ## overlapping dates because there are only 100 stations for which data exists.
  ## The results show that 65 distinct dates overlap.
  ## The overlapping dates are from: 16.04.24-25.04.24; 1.7.24-31.7.24;
  ## 19.11.24-20.11.24; 1.6.25-22.6.25*/

SELECT dates_nolap, COUNT(dates_nolap)
FROM silver.omc_dwh_clean
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY COUNT(dates_nolap) ASC;

/* ## This code below helps identify overlapping row dates in April 2024.
   ## It indicates that everything after 30 April to was incoreectly dated
   ## as April when it should be May 2024. Within the database,
   ## April 2024 only starts on 16 April and ends on 30 April 2024*/

SELECT *
FROM silver.omc_dwh_clean
WHERE dates_nolap BETWEEN DATE '2024-04-01' AND DATE '2024-04-30'
ORDER BY row_index ASC;

/* ## The code below corrects the first set of incorrect dates
   ## from 1.04.2024 - 15.04.2024 to the correct month of May*/

UPDATE silver.omc_dwh_clean
  SET dates_nolap = CASE
     WHEN dates_nolap BETWEEN DATE '2024-04-01' AND DATE '2024-04-15'
	   THEN dates_nolap = INTERVAL '1 month'
	 ELSE dates_nolap
      END;

/* ## There are two sets of daily station level data in the datASET from
   ## from 16 April 2024 to 25 April 2024. One set is correctly dated for April
   ## and the other should be for May. The latter, incorrectly dated, are within
   ## the row_index between numbers 2881 to 3840.
   ## This code corrects second set of incorrect dates from 16.04.2024 - 25.04.2024
   ## to the correct month of May.*/

UPDATE silver.omc_dwh_clean
  SET dates_nolap = CASE
     WHEN (dates_nolap BETWEEN date '2024-04-16' AND date '2024-04-25')
     AND (row_index BETWEEN 2881 AND 3840)
	   THEN dates_nolap + INTERVAL '1 month'
	 ELSE dates_nolap
      END;

/* ## To verify how many more of the dates are incorrectly dated or overlap,
   ## the following code is executed.
   ## The following dates have more than the required 100 rows signifying
   ## excess dates due either to incorrect dating or overlapping data due to
   ## merging of TABLEs: 2024-07-01 to 2024-07-30; 2024-11-19 AND 2024-11-20; 2025-06-01 to 2025-06-22 ## */

SELECT dates_nolap, COUNT(dates_nolap)
FROM silver.omc_dwh_clean
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY COUNT(dates_nolap) ASC;

/*  ## The code below illustrates that all dates in July 2024 
    ## commencing at row_index = 11425 were incorrectly 
    ## dated AS July when they should be for August 2024*/

SELECT dates_nolap, pms_ls, row_index
FROM silver.omc_dwh_clean
WHERE dates_nolap = '2024-07-01'
ORDER BY row_index;

/*  ## The code below illustrates that there are duplicate 
    ## and incorrect dates for July 2024. 
    ## A complete review of these dates illustrates that all dates 
    ## for July 2024 with row_index between 11425 AND 14324 were 
    ## incorrectly dated AS July 2024 ehen they should be August 2024*/

SELECT dates_nolap, pms_ls, row_index
FROM silver.omc_dwh_clean
WHERE dates_nolap BETWEEN DATE '2024-07-01' AND DATE '2024-07-31'
ORDER BY row_index;

/*  ## TESTING: This code updates one set of monthly dates 
    ## for July to August 2024*/

UPDATE silver.omc_dwh_clean
  SET dates_nolap = CASE
     WHEN dates_nolap = DATE '2024-07-31'
       AND (row_index BETWEEN 14325 AND 14421)
	THEN dates_nolap + INTERVAL '1 month'
	 ELSE dates_nolap
      END;

/* ## This code corrects the second SET of dates_nolap 
   ## between 1 July 2024 AND 30 July 2024 to August 2024*/

UPDATE silver.omc_dwh_clean
  SET dates_nolap = dates_nolap + INTERVAL '1 month'
  WHERE row_index BETWEEN 11425 AND 14324;

/*  ## This code reviews the remaining overlapping dates. 
    ## It illustrates that dates between 2024-07-24 to 2024-07-31;
    ## 2024-11-19 AND 2024-11-20; 2024-08-03 AND 2024-08-04;
    ## 2025-06-01 to 2025-06-22*/

SELECT dates_nolap, COUNT(dates_nolap)
FROM silver.omc_dwh_clean
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY dates_nolap ASC;

/*  ## This code reviews the first set of remaining overlapping dates
    ## between 2024-07-24 to 2024-07-31. 
    ## The first set is relates to row_index equal 9505 to 10272.
    ## The second set between 10657 to 11424*/

SELECT dates_nolap, pms_ls, row_index
FROM silver.omc_dwh_clean
WHERE dates_nolap BETWEEN DATE '2024-07-24' AND DATE '2024-07-31'
ORDER BY row_index;

/*   ## Code below creates new table with cleaned data*/

CREATE TABLE silver.omc_dwh_nolap AS
SELECT * FROM silver.omc_dwh_clean;

/*  ## The code below deletes duplicated dates 
    ## between 2024-07-24 to 2024-07-31*/

DELETE FROM silver.omc_dwh_nolap
WHERE row_index BETWEEN 10657 AND 11424;

/*  ## The code below verifies that the 
    ## deleted duplicate date between 2024-07-24 to 2024-07-31 
    ## have been deleted */

SELECT dates_nolap,
       COUNT(dates_nolap)
FROM silver.omc_dwh_nolap
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY dates_nolap ASC;

/*  ## The code below identifies which of the duplicated date
    ## between 2024-08-03 to 2024-08-04 is a duplicate or errors
    ## and requires deletion. 
    ## It illustrates that data between rows 10465 to 10656 are 
    ## erroneous duplicates that must be deleted*/

SELECT dates_nolap, pms_ls, row_index
FROM silver.omc_dwh_nolap
WHERE dates_nolap BETWEEN DATE '2024-08-03' AND DATE '2024-08-04'
ORDER BY row_index;

/*  ## The code below deletes duplicated dates 
    ## between 2024-08-03 to 2024-08-04*/

DELETE FROM silver.omc_dwh_nolap
WHERE row_index BETWEEN 10465 AND 10656;

/*  ## The code below verifies that the deleted duplicate date
    ## between 2024-07-24 to 2024-07-31 hAS been deleted*/

SELECT dates_nolap, COUNT(dates_nolap)
FROM silver.omc_dwh_nolap
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY dates_nolap ASC;

SELECT dates_nolap,
       pms_ls,
       row_index
FROM silver.omc_dwh_nolap
WHERE dates_nolap
BETWEEN date '2024-11-19' AND date '2024-11-20'
ORDER BY row_index;

/*  ## The code below identifies which of the duplicated date
    ## between 2024-11-19 to 2024-11-20 is a duplicate or errors and must be deleted. 
    ## It illustrates that there are two setts of such data and they are duplicates. 
    ## They range from rows 22114 to 22309 (the first set) and rows 22310 to 22505 (second set)*/

SELECT dates_nolap,
       pms_ls,
      row_index
FROM silver.omc_dwh_nolap
WHERE dates_nolap
BETWEEN date '2024-08-03' AND date '2024-08-04'
ORDER BY row_index;

/*The code below DELETEs duplicated dates between 2024-11-19 to 2024-11-20*/

DELETE FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN 22310 AND 22505;

/*The code highlights the remaining duplicated data between 2025-06-01 to 2025-06-22*/

SELECT dates_nolap,
       COUNT(dates_nolap)
FROM silver.omc_dwh_nolap
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY dates_nolap ASC;

/*  ## The code below illustrates that the first set of data for 2025-06-01
    ## ranges between rows 41394 to 41492 while the second 
    ## set is between rows 43770 to 43868 */

SELECT dates_nolap,
       pms_ls,
      row_index
FROM silver.omc_dwh_nolap
WHERE dates_nolap
= date '2025-06-22'
ORDER BY row_index;

/*  ## A comparison of the two sets of dates for 1 to 22 June 2025 
    ## illustrates that they are not duplicates*/

SELECT dates_nolap,
       pms_ls,
       row_index
FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN 41394 AND 43769
ORDER BY row_index;

SELECT dates_nolap,
       pms_ls,
       row_index
FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN  43770 AND 45947
ORDER BY row_index;

/*   ## The code below deletes duplicated data BETWEEN
     ## 2025-06-01 to 2025-06-22*/

DELETE FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN 43770 AND 45947;

/*   ## A review of the data indicates that data between row index
     ## values 43572 and 43769 are for 2025-06-23 AND 2025-06-24. 
     ## They have to be renamed within column dates_nolap*/

/*   ## The code below updates the dates_nolap column to 2025-05-23 
     ## for row_index between 43572 and 43670*/

UPDATE silver.omc_dwh_nolap
  SET dates_nolap = date '2025-06-23'
  WHERE row_index
  BETWEEN 43572 AND 43670;

UPDATE silver.omc_dwh_nolap
  SET dates_nolap = DATE '2025-06-24'
  WHERE row_index
  BETWEEN 43671 AND 43769;

/*  ## The code below again checks whether there are duplicate dates. 
    ## It finds duplicate dates for only 2025-06-23*/

SELECT dates_nolap, COUNT(dates_nolap)
FROM silver.omc_dwh_nolap
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY dates_nolap ASC;

/*   ## The code below illustrates that there are 
     ## two sets of data for 2025-06-23*/

SELECT dates_nolap, pms_ls, row_index
FROM silver.omc_dwh_nolap
WHERE dates_nolap = date '2025-06-23'
ORDER BY row_index;

/*   ## The code below deteltes the duplicate data 
     ## (second set) for date 2025-06-23*/

DELETE FROM silver.omc_dwh_nolap
WHERE row_index BETWEEN 43770 AND 45947;

/*   ## Finally, the code below again returns zero 
    ## rows indicating no duplicate or overlapping dates*/

SELECT dates_nolap, COUNT(dates_nolap)
FROM silver.omc_dwh_nolap
GROUP BY dates_nolap
HAVING COUNT(dates_nolap) > 100
ORDER BY dates_nolap ASC;

/*    ## The final concern with dates concerns csaes
      ## where dates and dates_nolap are null. These are 390 rows*/

SELECT dates_nolap, COUNT(dates_nolap)
FROM silver.omc_dwh_nolap
GROUP BY dates
HAVING dates_nolap IS NULL
ORDER BY dates ASC;

/*   ## The code below corrects dates_nolap*/

UPDATE silver.omc_dwh_nolap
SET dates_nolap = DATE '2024-08-01'
WHERE dates = 'Thurs.1.AUGUST';

UPDATE silver.omc_dwh_nolap
SET dates_nolap = DATE '2024-08-02'
WHERE dates = 'Fri.2.AUGUST';

/*   ## The code below indicates a duplication of data 
     ## for 2026-06-23 AND 2025-06-24*/

SELECT *
FROM silver.omc_dwh_nolap
WHERE dates_nolap IS NULL
ORDER BY row_index;

DELETE FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN 45948 AND 46046;

DELETE FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN 46047 AND 46145;

/*   ## The code below checks whether there are any null dates_nolap. 
     ## It illustrates there are no null values in that COLUMN*/

SELECT *
FROM silver.omc_dwh_nolap
WHERE dates_nolap IS NULL
ORDER BY row_index;

DELETE FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN 11425 AND 11520;

DELETE FROM silver.omc_dwh_nolap
WHERE row_index
BETWEEN 11521 AND 11616;

/*  ## Creating new row_index after cleaning data*/

SELECT *
FROM silver.omc_dwh_nolap
ORDER BY row_index ASC;

SELECT *
FROM silver.omc_dwh_nolap
ORDER BY dates_nolap ASC;

ALTER TABLE silver.omc_dwh_nolap
ADD COLUMN row_new SERIAL;