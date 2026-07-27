/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process required to populate the
    Silver Layer tables from the Bronze Layer tables.

Actions Performed:
    - Truncates Silver Layer tables.
    - Cleans and transforms Bronze Layer data.
    - Inserts transformed data into Silver Layer tables.
    - Prints execution progress and duration information.

Parameters:
    None.

Usage Example:
    CALL Silver.load_Silver();
===============================================================================
*/

DROP PROCEDURE IF EXISTS Silver.load_Silver;

DELIMITER $$

CREATE PROCEDURE Silver.load_Silver()
BEGIN
    DECLARE v_start_time DATETIME;
    DECLARE v_end_time DATETIME;
    DECLARE v_batch_start_time DATETIME;
    DECLARE v_batch_end_time DATETIME;

    DECLARE v_error_number INT DEFAULT 0;
    DECLARE v_error_state CHAR(5) DEFAULT '00000';
    DECLARE v_error_message TEXT;

  
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_number = MYSQL_ERRNO,
            v_error_state = RETURNED_SQLSTATE,
            v_error_message = MESSAGE_TEXT;

        SELECT '==========================================' AS log_message
        UNION ALL
        SELECT 'ERROR OCCURRED WHILE LOADING Silver LAYER'
        UNION ALL
        SELECT CONCAT('Error Number: ', v_error_number)
        UNION ALL
        SELECT CONCAT('SQL State: ', v_error_state)
        UNION ALL
        SELECT CONCAT('Error Message: ', v_error_message)
        UNION ALL
        SELECT '==========================================';
    END;

    SET v_batch_start_time = NOW();

    SELECT '================================================' AS log_message
    UNION ALL
    SELECT 'Loading Silver Layer'
    UNION ALL
    SELECT '================================================'
    UNION ALL
    SELECT 'Loading CRM Tables'
    UNION ALL
    SELECT '------------------------------------------------';


    /*=========================================================================
      Loading Silver.crm_cust_info
    =========================================================================*/

    SET v_start_time = NOW();

    SELECT '>> Truncating Table: Silver.crm_cust_info' AS log_message;

    TRUNCATE TABLE Silver.crm_cust_info;

    SELECT '>> Inserting Data Into: Silver.crm_cust_info' AS log_message;

    INSERT INTO Silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,

        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,

        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,

        cst_create_date
    FROM
    (
        SELECT
            bronze_customer.*,
            ROW_NUMBER() OVER
            (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last
        FROM bronze.crm_cust_info AS bronze_customer
        WHERE cst_id IS NOT NULL
    ) AS ranked_customer
    WHERE flag_last = 1;

    SET v_end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),
        ' seconds'
    ) AS log_message;

    SELECT '>> -------------' AS log_message;


    /*=========================================================================
      Loading Silver.crm_prd_info
    =========================================================================*/

    SET v_start_time = NOW();

    SELECT '>> Truncating Table: Silver.crm_prd_info' AS log_message;

    TRUNCATE TABLE Silver.crm_prd_info;

    SELECT '>> Inserting Data Into: Silver.crm_prd_info' AS log_message;

    INSERT INTO Silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        REPLACE(
            SUBSTRING(prd_key, 1, 5),
            '-',
            '_'
        ) AS cat_id,

        SUBSTRING(prd_key, 7) AS prd_key,

        prd_nm,

        COALESCE(prd_cost, 0) AS prd_cost,

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        DATE_SUB(
            LEAD(CAST(prd_start_dt AS DATE)) OVER
            (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ),
            INTERVAL 1 DAY
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;

    SET v_end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),
        ' seconds'
    ) AS log_message;

    SELECT '>> -------------' AS log_message;


    /*=========================================================================
      Loading Silver.crm_sales_details
    =========================================================================*/

    SET v_start_time = NOW();

    SELECT '>> Truncating Table: Silver.crm_sales_details' AS log_message;

    TRUNCATE TABLE Silver.crm_sales_details;

    SELECT '>> Inserting Data Into: Silver.crm_sales_details' AS log_message;

    INSERT INTO Silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt IS NULL
                 OR sls_order_dt = 0
                 OR CHAR_LENGTH(CAST(sls_order_dt AS CHAR)) <> 8
                THEN NULL
            ELSE STR_TO_DATE(
                CAST(sls_order_dt AS CHAR),
                '%Y%m%d'
            )
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt IS NULL
                 OR sls_ship_dt = 0
                 OR CHAR_LENGTH(CAST(sls_ship_dt AS CHAR)) <> 8
                THEN NULL
            ELSE STR_TO_DATE(
                CAST(sls_ship_dt AS CHAR),
                '%Y%m%d'
            )
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt IS NULL
                 OR sls_due_dt = 0
                 OR CHAR_LENGTH(CAST(sls_due_dt AS CHAR)) <> 8
                THEN NULL
            ELSE STR_TO_DATE(
                CAST(sls_due_dt AS CHAR),
                '%Y%m%d'
            )
        END AS sls_due_dt,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales <> sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price

    FROM bronze.crm_sales_details;

    SET v_end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),
        ' seconds'
    ) AS log_message;

    SELECT '>> -------------' AS log_message;


    /*=========================================================================
      Loading ERP Tables
    =========================================================================*/

    SELECT '------------------------------------------------' AS log_message
    UNION ALL
    SELECT 'Loading ERP Tables'
    UNION ALL
    SELECT '------------------------------------------------';


    /*=========================================================================
      Loading Silver.erp_cust_az12
    =========================================================================*/

    SET v_start_time = NOW();

    SELECT '>> Truncating Table: Silver.erp_cust_az12' AS log_message;

    TRUNCATE TABLE Silver.erp_cust_az12;

    SELECT '>> Inserting Data Into: Silver.erp_cust_az12' AS log_message;

    INSERT INTO Silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > CURDATE() THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;

    SET v_end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),
        ' seconds'
    ) AS log_message;

    SELECT '>> -------------' AS log_message;


    /*=========================================================================
      Loading Silver.erp_loc_a101
    =========================================================================*/

    SET v_start_time = NOW();

    SELECT '>> Truncating Table: Silver.erp_loc_a101' AS log_message;

    TRUNCATE TABLE Silver.erp_loc_a101;

    SELECT '>> Inserting Data Into: Silver.erp_loc_a101' AS log_message;

    INSERT INTO Silver.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '') AS cid,

        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze.erp_loc_a101;

    SET v_end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),
        ' seconds'
    ) AS log_message;

    SELECT '>> -------------' AS log_message;


    /*=========================================================================
      Loading Silver.erp_px_cat_g1v2
    =========================================================================*/

    SET v_start_time = NOW();

    SELECT '>> Truncating Table: Silver.erp_px_cat_g1v2' AS log_message;

    TRUNCATE TABLE Silver.erp_px_cat_g1v2;

    SELECT '>> Inserting Data Into: Silver.erp_px_cat_g1v2' AS log_message;

    INSERT INTO Silver.erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;

    SET v_end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),
        ' seconds'
    ) AS log_message;

    SELECT '>> -------------' AS log_message;


    /*=========================================================================
      Batch completion
    =========================================================================*/

    SET v_batch_end_time = NOW();

    SELECT '==========================================' AS log_message
    UNION ALL
    SELECT 'Loading Silver Layer is Completed'
    UNION ALL
    SELECT CONCAT(
        'Total Load Duration: ',
        TIMESTAMPDIFF(
            SECOND,
            v_batch_start_time,
            v_batch_end_time
        ),
        ' seconds'
    )
    UNION ALL
    SELECT '==========================================';

END$$

DELIMITER ;
