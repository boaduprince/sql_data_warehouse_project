


CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
	  v_message TEXT;
	  v_sqlstate TEXT;
	  v_start_time TIMESTAMP;
	  
BEGIN 
	v_start_time:= clock_timestamp();
	RAISE NOTICE 'LOADING SILVER LAYER';
	RAISE NOTICE 'LOADING CRM TABLES';
	

		/*CLEANING THE BRONZE.CRM_CUST_INFO INSERTING INTO THE SILVER.CRM_CUST_INFO LAYER*/
		RAISE NOTICE 'TRUNCATING SILVER.CRM_CUST_INFO';
		TRUNCATE TABLE silver.crm_cust_info;
		RAISE NOTICE 'INSERTING SILVER.CRM_CUST_INFO';
		INSERT INTO silver.crm_cust_info(
					cst_id,
					cst_key,
					cst_firstname,
					cst_lastname,
					cst_marital_status,
					cst_gender,
					cst_create_date)
		select 
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname)as cst_lastname,
		
		CASE 
			WHEN UPPER(TRIM(cst_marital_status) )='S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status))  = 'M' THEN 'Married'
			ELSE 'n/a'
		END cst_marital_status,
		
		CASE
			WHEN cst_gender = 'M' THEN 'Male'
			WHEN cst_gender = 'F' THEN 'Female'
			ELSE 'n/a'
		END cst_gender,
		cst_create_date
		from
			(select *,
			  ROW_NUMBER() OVER(partition by cst_id order by cst_create_date) as row_num
			  from bronze.crm_cust_info
			  where cst_id IS NOT NULL
			  )t
		where row_num=1;
		
		
		/*CLEANING THE BRONZE.CRM_PRD_INFO AND INSERTING INTO SILVER.CRM_PRD_INFO TABLE*/
		RAISE NOTICE 'TRUNCATING SILVER.CRM_PRD_INFO';
		TRUNCATE TABLE silver.crm_prd_info;
		RAISE NOTICE 'INSERTING SILVER.CRM_PRD_INFO';
		INSERT INTO silver.crm_prd_info(
					prd_id,
					cat_id,
					prd_key, 
					prd_nm,
					prd_cost,
					prd_line,
					prd_start_dt,
					prd_end_dt
		)
		SELECT prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,
		prd_nm,
		COALESCE(prd_cost,0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'	
			WHEN 'T' THEN 'Touring'
		    ELSE 'n/a'
		END AS prd_line,
		prd_start_dt,
		LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
		from bronze.crm_prd_info;
		
		
		/*CLEANING THE BRONCE.CRM_SALES_DETAILS AND INSERTING INTO SILVER.CRM_SALES_DETAILS*/
		RAISE NOTICE 'TRUNCATING SILVER.CRM_SALES_DETAILS';
		TRUNCATE TABLE silver.crm_sales_details;
		RAISE NOTICE 'INSERTING INTO SILVER.CRM_SALES_DETAILS';
		INSERT INTO silver.crm_sales_details(
			sls_ord_number ,
			sls_prod_key ,
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select 
		    sls_ord_number,
		    sls_prod_key,
		    sls_cust_id,
			  case
				when sls_order_dt <=0 or length(sls_order_dt::text)!=8 then null
				else cast(cast(sls_order_dt as varchar) as date)
			  end as sls_order_dt ,
				case 
				  when sls_ship_dt <=0 or length(sls_ship_dt::text)!=8 then null
				  else cast(cast(sls_ship_dt as varchar) as date)
				end as sls_ship_dt,
				case
				  when sls_due_dt <=0 or length(sls_due_dt::text) !=8 then null
				  else cast(cast(sls_due_dt as varchar) as date)
				end as sls_due_date,
			case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity *abs(sls_price)
				then sls_quantity * abs(sls_price)
			    else sls_sales
			end as sls_sales,
			sls_quantity,
			case when sls_price is null or sls_price <=0
				 then sls_sales/ nullif(sls_quantity,0)
				 else sls_price
			end as sls_price
		from bronze.crm_sales_details;
		 
		
		
		/*CLEANING THE BRONZE.ERP_CUST_AZ12 TABLE AND INSERTING INTO SILVER.ERP_CUST_AZ12*/
        RAISE NOTICE 'TRUNCATING SILVER.ERP_CUST_AZ12';
		TRUNCATE TABLE silver.erp_cust_az12;
		RAISE NOTICE 'INSERTING INTO SILVER.ERP_CUST_AZ12';
		INSERT INTO silver.erp_cust_az12(
			 cid,
			 bdate,
			 gender)
				SELECT 
					CASE
						WHEN cid LIKE 'NAS%' 
						THEN SUBSTRING(cid,4, LENGTH(cid))
						ELSE cid
					END AS cid,
					CASE 
					 	WHEN bdate > CURRENT_DATE
						THEN NULL
						ELSE bdate
					END AS bdate,
					CASE
						WHEN UPPER(TRIM(gender)) IN ('F','FEMALE') THEN 'Female'
						WHEN UPPER(TRIM(gender)) IN ('M','MALE') THEN 'Male'
						ELSE 'n/a'
					END AS gender
				FROM bronze.erp_cust_az12;
		
		
		/*CLEANING THE BRONZE.ERP_LOC_A101 TABLE AND INSERTING INTO SILVER.ERP_LOC_A101*/
		RAISE NOTICE 'TRUNCATING SILVER.ERP_LOC_A101';
		TRUNCATE TABLE silver.erp_loc_a101;
		RAISE NOTICE 'INSERTING INTO SILVER.ERP_LOC_A101';
		INSERT INTO silver.erp_loc_a101(
		cid,cntry
		)
		SELECT 
		REPLACE(cid,'-','') AS cid,
	    CASE
			WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'USA'
			WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END AS cntry
		FROM bronze.erp_loc_a101;
		
		
		/*CLEANING THE BRONZE.ERP_LOC_A101 TABLE AND INSERTING INTO SILVER.ERP_PX_CAT_G1V2*/
		RAISE NOTICE 'TRUNCATING SILVER.ERP_PX_CAT_G1V2';
		TRUNCATE silver.erp_px_cat_g1v2;
		RAISE NOTICE 'INSERTING INTO SILVER.ERP_PX_CAT_G1V2';
		INSERT INTO silver.erp_px_cat_g1v2
		(id,cat,subcat,maintenance)
			SELECT
				id,
				cat,
				subcat,
				maintenance
			from bronze.erp_px_cat_g1v2;

			RAISE NOTICE 'SILVER LAYER LOADED SUCCESSFULLY';
			RAISE NOTICE 'SILVER LAYER DURATION :%',
				clock_timestamp() - v_start_time;
  EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				v_message = MESSAGE_TEXT,
				v_sqlstate = RETURNED_SQLSTATE;

			RAISE NOTICE 'ERROR OCCURRED WHILE LOADING SILVER LAYER';
			RAISE NOTICE 'ERROR MESSAGE:%', v_message;
			RAISE NOTICE 'SQLSTATE:%' , v_sqlstate;
END;
$$;
			
				
