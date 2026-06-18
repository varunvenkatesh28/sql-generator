-- Query: KAN-22_transformation
-- Purpose: Generated SQL for KAN-22 via 7-stage pipeline
-- Query Type: SELECT

-- ═══════════════════════════════════════════════
-- Target: d_branch
-- ═══════════════════════════════════════════════
SELECT
  cast('' AS string) AS st_prov_cd,
  cast('' AS string) AS st_prov_nm

-- ═══════════════════════════════════════════════
-- Target: d_buyer
-- ═══════════════════════════════════════════════
WITH d_buyer_null_placeholders AS (
  SELECT
    cast('' AS string) AS src_sys_cd,
    cast(f4102.ibbuyr AS string) AS buyer_cd,
    cast(f0101.abalph AS string) AS buyer_nm
  FROM
    f4102
  LEFT JOIN
    f0101
    ON f0101.aban8 = f4102.ibbuyr
)
SELECT
  src_sys_cd,
  buyer_cd,
  buyer_nm
FROM
  d_buyer_null_placeholders