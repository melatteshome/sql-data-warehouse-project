
USE  Silver;

DROP TABLE IF EXISTS crm_sales_details;
DROP TABLE IF EXISTS crm_prd_info;
DROP TABLE IF EXISTS crm_cust_info;
DROP TABLE IF EXISTS erp_loc_a101;
DROP TABLE IF EXISTS erp_cust_az12;
DROP TABLE IF EXISTS erp_px_cat_g1v2;
    
CREATE TABLE Silver.crm_cust_info(
	cst_id INT,
    cst_key char(50),
    cst_firstname CHAR(50) ,
    cst_lastname CHAR(50),
    cst_marital_status CHAR(50),
    cst_gndr char(50),
    cst_create_date date,
    dwh_create_date DATETIME DEFAULT (NOW())
);

CREATE TABLE Silver.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME,
    dwh_create_date DATETIME DEFAULT (NOW())
);

CREATE TABLE Silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date DATETIME DEFAULT (NOW())
);


CREATE TABLE Silver.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT (NOW())
);


CREATE TABLE Silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT (NOW())
);

CREATE TABLE Silver.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),
	dwh_create_date DATETIME DEFAULT (NOW())
);
