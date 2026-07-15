-- ============================================================
-- Bronze Layer Data Load Script
-- Source folder inside Docker container: /var/lib/mysql-files/
-- ============================================================


CREATE PROCEDURE Bronze_load_data()
BEGIN
	USE Bronze;

	SELECT' ============================================================
							Load CRM Customer Info
			============================================================ '  AS message;

	TRUNCATE TABLE crm_cust_info;

	TRUNCATE TABLE Bronze.crm_cust_info;

	LOAD DATA INFILE '/var/lib/mysql-files/source_crm/cust_info_valid.csv'
	INTO TABLE Bronze.crm_cust_info
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(
		@cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		@cst_create_date
	)
	SET
		cst_id = NULLIF(@cst_id, ''),
		cst_create_date = NULLIF(@cst_create_date, '');

	SELECT ' ============================================================
								Load CRM Product Info
			 ============================================================ ' AS message;

	TRUNCATE TABLE crm_prd_info;

	LOAD DATA INFILE '/var/lib/mysql-files/source_crm/prd_info.csv'
	INTO TABLE crm_prd_info
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(
		prd_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	);

	SELECT ' ============================================================
							Load CRM Sales Details
			 ============================================================' AS message;

	TRUNCATE TABLE crm_sales_details;

	LOAD DATA INFILE '/var/lib/mysql-files/source_crm/sales_details.csv'
	INTO TABLE crm_sales_details
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
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
	);


	SELECT ' ============================================================
							Load ERP Location Data
			 ============================================================' AS message;


	TRUNCATE TABLE erp_loc_a101;

	LOAD DATA INFILE '/var/lib/mysql-files/source_erp/LOC_A101.csv'
	INTO TABLE erp_loc_a101
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(
		cid,
		cntry
	);

	SELECT ' ============================================================
							Load ERP Customer Data
			 ============================================================' AS message;
			 


	TRUNCATE TABLE erp_cust_az12;

	LOAD DATA INFILE '/var/lib/mysql-files/source_erp/CUST_AZ12.csv'
	INTO TABLE erp_cust_az12
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES
	(
		@cid,
		@bdate,
		@gen
	)
	SET
		cid   = NULLIF(TRIM(@cid), ''),
		bdate = NULLIF(TRIM(@bdate), ''),
		gen   = NULLIF(TRIM(TRAILING '\r' FROM @gen), '');

	SELECT ' ============================================================
							Load ERP Product Category Data
			 ============================================================' AS message;

	TRUNCATE TABLE erp_px_cat_g1v2;

	LOAD DATA INFILE '/var/lib/mysql-files/source_erp/PX_CAT_G1V2.csv'
	INTO TABLE erp_px_cat_g1v2
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(
		id,
		cat,
		subcat,
		maintenance
	);

	SELECT ' ============================================================
							Validate Loaded Row Counts
			 ============================================================' AS message;


	SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count FROM crm_cust_info
	UNION ALL
	SELECT 'crm_prd_info', COUNT(*) FROM crm_prd_info
	UNION ALL
	SELECT 'crm_sales_details', COUNT(*) FROM crm_sales_details
	UNION ALL
	SELECT 'erp_loc_a101', COUNT(*) FROM erp_loc_a101
	UNION ALL
	SELECT 'erp_cust_az12', COUNT(*) FROM erp_cust_az12
	UNION ALL
	SELECT 'erp_px_cat_g1v2', COUNT(*) FROM erp_px_cat_g1v2;
END
