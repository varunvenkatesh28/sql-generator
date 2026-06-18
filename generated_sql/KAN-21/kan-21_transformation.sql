-- Query: KAN-21_transformation
-- Purpose: Generated SQL for KAN-21 via 7-stage pipeline
-- Query Type: SELECT

WITH d_buyer_cte AS (
  SELECT
    cast('' AS string) AS src_sys_cd,
    f4102.ibbuyr AS buyer_cd,
    f0101.abalph AS buyer_nm
  FROM
    f4102
  LEFT JOIN f0101
    ON f0101.aban8 = f4102.ibbuyr
),
d_branch_cte AS (
  SELECT
    cast('' AS string) AS cntry_cd,
    cast('' AS string) AS cntry_nm,
    cast('' AS string) AS curncy_cd,
    cast('' AS string) AS curncy_nm,
    t2.c2 AS org_unit_cd,
    t3.c3 AS org_unit_nm,
    t4.c4 AS org_unit_type,
    t5.c5 AS parent_org_unit_cd,
    t6.c6 AS parent_org_unit_nm,
    cast('e1' AS string) AS src_sys_cd,
    cast('' AS string) AS st_prov_cd,
    cast('' AS string) AS st_prov_nm,
    t1.c1 AS src_sys_cd,
    t2.c2 AS org_unit_cd,
    t3.c3 AS org_unit_nm,
    t4.c4 AS org_unit_type,
    t5.c5 AS parent_org_unit_cd,
    t6.c6 AS parent_org_unit_nm,
    t7.c7 AS curncy_cd,
    t8.c8 AS curncy_nm,
    t9.c9 AS st_prov_cd,
    t10.c10 AS st_prov_nm,
    t11.c11 AS cntry_cd,
    t12.c12 AS cntry_nm,
    t13.c13 AS rec_crt_ts,
    t14.c14 AS rec_updt_ts
  FROM
    t1
    LEFT JOIN t2 ON 1=1
    LEFT JOIN t3 ON 1=1
    LEFT JOIN t4 ON 1=1
    LEFT JOIN t5 ON 1=1
    LEFT JOIN t6 ON 1=1
    LEFT JOIN t7 ON 1=1
    LEFT JOIN t8 ON 1=1
    LEFT JOIN t9 ON 1=1
    LEFT JOIN t10 ON 1=1
    LEFT JOIN t11 ON 1=1
    LEFT JOIN t12 ON 1=1
    LEFT JOIN t13 ON 1=1
    LEFT JOIN t14 ON 1=1
)
SELECT * FROM d_branch_cte;