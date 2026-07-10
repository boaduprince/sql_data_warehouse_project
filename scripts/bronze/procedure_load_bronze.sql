/*STORED PROCEDURE: Load Bronze Layer (Source ---> Bronze)
SCRIPT PURPOSE : This stored procedure loads to the bronze schema from external CSV files
                 It performs the following actions:
                    -Truncates the Bronze table before loading data
                    -Uses Bulk Insert command to load data from CSV to bronze tables
  USAGE:
        CALL bronze.load_bronze();*/


CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
		v_message TEXT;
		V_sqlstate TEXT;
		v_start_time TIMESTAMP;
BEGIN 
		V_start_time:= clock_timestamp();
		RAISE NOTICE 'LOADING BRONZE LAYER';
		RAISE NOTICE 'LOADING CRM TABLES';
	
		RAISE NOTICE 'Truncating bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		RAISE NOTICE 'Inserting bronze.crm_cust_info';
		COPY bronze.crm_cust_info
		FROM 'C:\DATA\datasets\source_crm\cust_info.csv'
		CSV HEADER;
	
		RAISE NOTICE 'Truncating bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		RAISE NOTICE 'Inserting bronze.crm_prd_info';
		COPY bronze.crm_prd_info
		FROM 'C:\DATA\datasets\source_crm/prd_info.csv'
		CSV HEADER;
		
		RAISE NOTICE 'Truncating bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		RAISE NOTICE 'Inserting bronze.crm_sales_details';
		COPY bronze.crm_sales_details
		FROM 'C:\DATA\datasets\source_crm/sales_details.csv'
		CSV HEADER;
		
		
		RAISE NOTICE 'LOADING ERP TABLES';
	
		RAISE NOTICE 'Truncating bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		RAISE NOTICE 'Inserting bronze.erp_cust_az12';
		COPY bronze.erp_cust_az12
		FROM 'C:\DATA\datasets\source_erp\CUST_AZ12.csv'
		CSV HEADER;
	
		RAISE NOTICE 'Truncating bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		RAISE NOTICE 'Insert bronze.erp_loc_a101';
		COPY bronze.erp_loc_a101
		FROM 'C:\DATA\datasets\source_erp\LOC_A101.csv'
		CSV HEADER;
		 
		RAISE NOTICE 'Truncating bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		RAISE NOTICE 'Inserting bronze.erp_px_cat_g1v2';
		COPY bronze.erp_px_cat_g1v2
		FROM 'C:\DATA\datasets\source_erp\px_cat_g1v2.csv'
		CSV HEADER;

		RAISE NOTICE 'Bronze Layer loaded successfully';
		RAISE NOTICE 'Bronze Layer Duration: %',
			clock_timestamp()-v_start_time;
		
EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			v_message = MESSAGE_TEXT,
			v_sqlstate = RETURNED_SQLSTATE;

		RAISE NOTICE 'ERROR OCCURRED LOADING BRONZE LAYER';
		RAISE NOTICE 'ERROR MESSAGE: %',v_message;
		RAISE NOTICE 'SQLSTATE: %', v_sqlstate;
END;
$$;







