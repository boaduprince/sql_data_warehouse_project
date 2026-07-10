

/*DDL SCRIPT: Create Schemas for Different Data Layers and Bronze  Table
  SCRIPT PURPOSE: This script creates schemas for different layers of the data  and creates tables in bronze schema, dropping tables if they already exist */ 

 CREATE SCHEMA bronze;
 CREATE SCHEMA silver;
 CREATE SCHEMA gold;

/*1*/ DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gender VARCHAR(50),
	cst_create_date DATE
 );
 
 
/*2*/ DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
 );
 
/*3*/ DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	sls_ord_number VARCHAR(50),
	sls_prod_key VARCHAR(50),
	slc_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

/*4*/ DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid VARCHAR(50),
	bdate DATE,
	gender VARCHAR(50)
 )
;
 /*5*/ DROP TABLE IF EXISTS  bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
	cid VARCHAR(50),
	cntry VARCHAR(50)
 );

 /*6*/ DROP TABLE IF EXISTS  bronze.erp_px_cat_g1v2;
 CREATE TABLE bronze.erp_px_cat_g1v2(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
 );


