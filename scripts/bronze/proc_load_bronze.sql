/* 
-- ============================================================
-- script name: bronze_load_data.sql
-- purpose:
	- This script loads the raw csv file to the bronze layer schema
    - Source folder inside Docker container: /var/lib/mysql-files/
    - The script performs the following 
    - Truncates the bronze tables before loading data 
-- Parameters:
	- This script does not accept any parameters or returns any values.
-- ============================================================
*/

USE Bronze;


    -- ========================================================
    -- Load CRM Customer Info
    -- ========================================================

    SELECT 'Loading CRM Customer Info...' AS message;

    TRUNCATE TABLE Bronze.crm_cust_info;

    LOAD DATA INFILE '/var/lib/mysql-files/source_crm/cust_info_valid.csv'
    INTO TABLE Bronze.crm_cust_info
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
        @cst_id,
        @cst_key,
        @cst_firstname,
        @cst_lastname,
        @cst_marital_status,
        @cst_gndr,
        @cst_create_date
    )
    SET
        cst_id             = NULLIF(TRIM(@cst_id), ''),
        cst_key            = NULLIF(TRIM(@cst_key), ''),
        cst_firstname      = NULLIF(TRIM(@cst_firstname), ''),
        cst_lastname       = NULLIF(TRIM(@cst_lastname), ''),
        cst_marital_status = NULLIF(TRIM(@cst_marital_status), ''),
        cst_gndr           = NULLIF(TRIM(@cst_gndr), ''),
        cst_create_date    = NULLIF(
            TRIM(TRAILING '\r' FROM @cst_create_date),
            ''
        );

    SELECT ROW_COUNT() AS crm_customer_rows_loaded;


    -- ========================================================
    -- Load CRM Product Info
    -- ========================================================

    SELECT 'Loading CRM Product Info...' AS message;

    TRUNCATE TABLE Bronze.crm_prd_info;

    LOAD DATA INFILE '/var/lib/mysql-files/source_crm/prd_info.csv'
    INTO TABLE Bronze.crm_prd_info
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
        @prd_id,
        @prd_key,
        @prd_nm,
        @prd_cost,
        @prd_line,
        @prd_start_dt,
        @prd_end_dt
    )
    SET
        prd_id       = NULLIF(TRIM(@prd_id), ''),
        prd_key      = NULLIF(TRIM(@prd_key), ''),
        prd_nm       = NULLIF(TRIM(@prd_nm), ''),
        prd_cost     = NULLIF(TRIM(@prd_cost), ''),
        prd_line     = NULLIF(TRIM(@prd_line), ''),
        prd_start_dt = NULLIF(TRIM(@prd_start_dt), ''),
        prd_end_dt   = NULLIF(
            TRIM(TRAILING '\r' FROM @prd_end_dt),
            ''
        );

    SELECT ROW_COUNT() AS crm_product_rows_loaded;


    -- ========================================================
    -- Load CRM Sales Details
    -- ========================================================

    SELECT 'Loading CRM Sales Details...' AS message;

    TRUNCATE TABLE Bronze.crm_sales_details;

    LOAD DATA INFILE '/var/lib/mysql-files/source_crm/sales_details.csv'
    INTO TABLE Bronze.crm_sales_details
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
        @sls_ord_num,
        @sls_prd_key,
        @sls_cust_id,
        @sls_order_dt,
        @sls_ship_dt,
        @sls_due_dt,
        @sls_sales,
        @sls_quantity,
        @sls_price
    )
    SET
        sls_ord_num  = NULLIF(TRIM(@sls_ord_num), ''),
        sls_prd_key  = NULLIF(TRIM(@sls_prd_key), ''),
        sls_cust_id  = NULLIF(TRIM(@sls_cust_id), ''),
        sls_order_dt = NULLIF(TRIM(@sls_order_dt), ''),
        sls_ship_dt  = NULLIF(TRIM(@sls_ship_dt), ''),
        sls_due_dt   = NULLIF(TRIM(@sls_due_dt), ''),
        sls_sales    = NULLIF(TRIM(@sls_sales), ''),
        sls_quantity = NULLIF(TRIM(@sls_quantity), ''),
        sls_price    = NULLIF(
            TRIM(TRAILING '\r' FROM @sls_price),
            ''
        );

    SELECT ROW_COUNT() AS crm_sales_rows_loaded;


    -- ========================================================
    -- Load ERP Location Data
    -- ========================================================

    SELECT 'Loading ERP Location Data...' AS message;

    TRUNCATE TABLE Bronze.erp_loc_a101;

    LOAD DATA INFILE '/var/lib/mysql-files/source_erp/LOC_A101.csv'
    INTO TABLE Bronze.erp_loc_a101
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
        @cid,
        @cntry
    )
    SET
        cid   = NULLIF(TRIM(@cid), ''),
        cntry = NULLIF(
            TRIM(TRAILING '\r' FROM @cntry),
            ''
        );

    SELECT ROW_COUNT() AS erp_location_rows_loaded;


    -- ========================================================
    -- Load ERP Customer Data
    -- ========================================================

    SELECT 'Loading ERP Customer Data...' AS message;

    TRUNCATE TABLE Bronze.erp_cust_az12;

    LOAD DATA INFILE '/var/lib/mysql-files/source_erp/CUST_AZ12.csv'
    IGNORE
    INTO TABLE Bronze.erp_cust_az12
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
        @cid,
        @bdate,
        @gen
    )
    SET
        cid   = NULLIF(TRIM(@cid), ''),
        bdate = NULLIF(TRIM(@bdate), ''),
        gen   = NULLIF(
            TRIM(TRAILING '\r' FROM @gen),
            ''
        );

    SELECT ROW_COUNT() AS erp_customer_rows_loaded;


    -- ========================================================
    -- Load ERP Product Category Data
    -- ========================================================

    SELECT 'Loading ERP Product Category Data...' AS message;

    TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

    LOAD DATA INFILE '/var/lib/mysql-files/source_erp/PX_CAT_G1V2.csv'
    INTO TABLE Bronze.erp_px_cat_g1v2
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
        @id,
        @cat,
        @subcat,
        @maintenance
    )
    SET
        id          = NULLIF(TRIM(@id), ''),
        cat         = NULLIF(TRIM(@cat), ''),
        subcat      = NULLIF(TRIM(@subcat), ''),
        maintenance = NULLIF(
            TRIM(TRAILING '\r' FROM @maintenance),
            ''
        );


    -- ========================================================
    -- Validate Loaded Row Counts
    -- ========================================================

    SELECT 'Validating loaded row counts...' AS message;

    SELECT
        'crm_cust_info' AS table_name,
        COUNT(*) AS row_count
    FROM Bronze.crm_cust_info

    UNION ALL

    SELECT
        'crm_prd_info',
        COUNT(*)
    FROM Bronze.crm_prd_info

    UNION ALL

    SELECT
        'crm_sales_details',
        COUNT(*)
    FROM Bronze.crm_sales_details

    UNION ALL

    SELECT
        'erp_loc_a101',
        COUNT(*)
    FROM Bronze.erp_loc_a101

    UNION ALL

    SELECT
        'erp_cust_az12',
        COUNT(*)
    FROM Bronze.erp_cust_az12

    UNION ALL

    SELECT
        'erp_px_cat_g1v2',
        COUNT(*)
    FROM Bronze.erp_px_cat_g1v2;

    SELECT 'Bronze layer data load completed.' AS message;
