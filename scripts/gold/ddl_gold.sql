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
