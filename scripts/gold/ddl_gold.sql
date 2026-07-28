create view Gold.dim_customers as
select 
  row_number() over (order by cst_id) as customer_key,
  ci.cst_id as cusomer_id,
  ci.cst_key as cusomer_number,
  ci.cst_firstname as first_name,
  ci.cst_lastname as last_name,
  ci.cst_marital_status as martial_status ,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr
	  else coalesce(ca.gen, 'n/a')
    end as gender,
  ci.cst_create_date as created_date,
  ci.dwh_create_date ,
  ca.bdate as birth_date,
  la.cntry as country
 from 
    Silver.crm_cust_info ci
 left join
    Silver.erp_cust_az12 ca
 on ci.cst_key = ca.cid
 left join 
    Silver.erp_loc_a101 la
 on ci.cst_key = la.cid;



create view Gold.dim_products as 
select 
	row_number() over (order by pn.prd_start_dt , pn.prd_key) as Product_key,
	pn.prd_id as product_id,
    pn.cat_id as category_id,
    pn.prd_key as product_number,
    pn.prd_nm as product_name,
    pn.prd_cost as product_cost,
    pn.prd_line as product_line,
    pn.prd_start_dt as start_date,
    pc.cat as category,
    pc.subcat as sub_category,
    pc.maintenance
 from Silver.crm_prd_info pn
 left join Silver.erp_px_cat_g1v2 pc
 on pn.cat_id = pc.id
 where prd_end_dt is null
