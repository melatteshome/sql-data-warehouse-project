INSERT INTO Silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
select 
	prd_id,
    replace(substring(prd_key, 1 ,5), '-', '_') as cat_id, 
    replace(substring(prd_key, 7 ,length(prd_key)), '-', '_') as prd_key,
	prd_nm,
	ifnull(prd_cost , 0) as prd_cost,
    case when upper(trim(prd_line)) = 'M' then 'mountain'
		 when upper(trim(prd_line)) = 'R' then 'road'
         when upper(trim(prd_line)) = 'S' then 'other sales'
         when upper(trim(prd_line)) = 'T' then  'touring'
         else 'n/a'
	end as prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
DATE_SUB(
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ),
    INTERVAL 1 DAY
) AS prd_end_dt 
from 
	Bronze.crm_prd_info ;
