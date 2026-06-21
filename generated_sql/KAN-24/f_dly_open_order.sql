-- Source: KAN-24
-- Target: f_dly_open_order
-- Branches: 3
-- Fields: 115
-- Unresolved: 92
-- Pipeline Run: pipeline-KAN-24
-- Validation: WARNINGS

WITH
daily_open_order_key_generation AS (
  SELECT 
    CAST(concat('msd_qad_', lower(sa.sa_domain), '|', date_format(current_date, 'yyyyMMdd'), '|', sa.sa_nbr, '|', sad.sad_ui_line, '|', sad.sad_serial) AS STRING) AS dly_open_ord_key,
    CAST(concat('msd_qad_', lower(sa.sa_domain)) AS STRING) AS src_sys_cd
  FROM 
    sa_mstr AS sa
  JOIN 
    sad_det AS sad
    ON sa.sa_domain = sad.sad_domain AND sa.sa_nbr = sad.sad_nbr
),
constants_and_defaults AS (
  SELECT 
    CAST(NULL AS DECIMAL(38,0)) AS as_of_dt_key,
    CAST(NULL AS STRING) AS dw_src_cd,
    CAST(NULL AS STRING) AS dw_dly_open_ord_key,
    CAST(NULL AS STRING) AS src_crt_by,
    CAST(NULL AS TIMESTAMP) AS rec_crt_ts,
    CAST(NULL AS TIMESTAMP) AS rec_updt_ts,
    CAST(NULL AS DOUBLE) AS bo_co_curncy_amt,
    CAST(NULL AS STRING) AS bo_flg,
    CAST(NULL AS DOUBLE) AS bo_lcur_amt,
    CAST(NULL AS DOUBLE) AS bo_qty,
    CAST(NULL AS STRING) AS ccg_lcd_chnl,
    CAST(NULL AS STRING) AS ccg_lcd_vndr_nbr,
    CAST(NULL AS STRING) AS contact_key,
    CAST(NULL AS STRING) AS co_usd_curncy_mth_rt_key,
    CAST(NULL AS STRING) AS co_curncy_cd,
    CAST(NULL AS STRING) AS cust_po_nbr,
    CAST(NULL AS STRING) AS derived_prod_key,
    CAST(NULL AS STRING) AS derived_sku,
    CAST(NULL AS STRING) AS derived_sku_nm,
    CAST(NULL AS DECIMAL(38,0)) AS expect_ship_dt_key,
    CAST(NULL AS DOUBLE) AS fin_bo_co_curncy_amt,
    CAST(NULL AS DOUBLE) AS fin_bo_lcur_amt,
    CAST(NULL AS DOUBLE) AS fin_bo_qty,
    CAST(NULL AS STRING) AS fin_ord_line_complt_flg,
    CAST(NULL AS STRING) AS hfm_entity_key,
    CAST(NULL AS STRING) AS hfm_entity_cd,
    CAST(NULL AS DECIMAL(38,0)) AS mtl_avbl_dt_key,
    CAST(NULL AS DOUBLE) AS ord_co_curncy_amt,
    CAST(NULL AS STRING) AS ord_hdr_usd_curncy_mth_rt_key,
    CAST(NULL AS DOUBLE) AS ord_lcur_amt,
    CAST(NULL AS STRING) AS strg_loc_cd,
    CAST(NULL AS STRING) AS req_strg_loc_cd,
    CAST(NULL AS DECIMAL(38,0)) AS ord_line_ship_nlt_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS orig_proms_dt_key,
    CAST(NULL AS STRING) AS plant_key,
    CAST(NULL AS STRING) AS plant_cd,
    CAST(NULL AS STRING) AS plant_nm,
    CAST(NULL AS STRING) AS prod_plant_key,
    CAST(NULL AS DECIMAL(38,0)) AS proms_delvr_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS req_delvr_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS ord_rls_dt_key,
    CAST(NULL AS DOUBLE) AS ship_qty,
    CAST(NULL AS STRING) AS ship_to_cust_nm,
    CAST(NULL AS STRING) AS ship_to_cntry_hier_key,
    CAST(NULL AS STRING) AS sls_ord_key,
    CAST(NULL AS DOUBLE) AS target_qty,
    CAST(NULL AS DOUBLE) AS unit_std_cost,
    CAST(NULL AS STRING) AS cur_ord_stat_cd,
    CAST(NULL AS STRING) AS cur_ord_stat_nm,
    CAST(NULL AS STRING) AS next_ord_stat_cd,
    CAST(NULL AS STRING) AS next_ord_stat_nm,
    CAST(NULL AS STRING) AS hdr_bill_block_cd,
    CAST(NULL AS STRING) AS hdr_bill_block_nm,
    CAST(NULL AS STRING) AS hdr_delvr_block_cd,
    CAST(NULL AS STRING) AS hdr_delvr_block_nm,
    CAST(NULL AS STRING) AS bill_block_cd,
    CAST(NULL AS STRING) AS bill_block_nm,
    CAST(NULL AS STRING) AS delvr_block_cd,
    CAST(NULL AS STRING) AS delvr_block_nm,
    CAST(NULL AS STRING) AS overall_stat_cd,
    CAST(NULL AS STRING) AS overall_stat_nm,
    CAST(NULL AS STRING) AS reject_rsn_cd,
    CAST(NULL AS STRING) AS reject_rsn_nm,
    CAST(NULL AS STRING) AS ord_type_cd,
    CAST(NULL AS STRING) AS ord_overall_stat_cd,
    CAST(NULL AS STRING) AS ord_overall_stat_nm,
    CAST(NULL AS STRING) AS hdr_ord_type_cd,
    CAST(NULL AS STRING) AS hdr_ord_type_nm,
    CAST(NULL AS STRING) AS bo_stat_nm,
    CAST(NULL AS DECIMAL(38,0)) AS commit_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS proms_ship_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS sched_ship_dt_key,
    CAST(NULL AS STRING) AS cust_key,
    CAST(NULL AS STRING) AS sls_rep_cust_key,
    CAST(NULL AS STRING) AS po_line_nbr,
    CAST(NULL AS STRING) AS sls_terr_cd,
    CAST(NULL AS STRING) AS cost_curncy_cd,
    CAST(NULL AS DOUBLE) AS disc_amt
),
sales_order_number_extraction AS (
  SELECT
    CAST(sa.sa_nbr AS STRING) AS sls_ord_nbr
  FROM
    sa_mstr AS sa
  JOIN
    sad_det AS sad
    ON lower(sa.sa_domain) = lower(sad.sad_domain)
    AND sa.sa_prefix = sad.sad_prefix
    AND sa.sa_nbr = sad.sad_nbr
    AND lower(sa.sa_site) = lower(si.si_site)
  JOIN
    si_mstr AS si
    ON lower(sa.sa_site) = lower(si.si_site)
),
sales_order_line_details AS (
  SELECT
      CAST(sad.sad_ui_line AS STRING) AS sls_ord_line_nbr,
      CAST(sad.sad_mod_userid AS STRING) AS src_updt_by,
      CAST(sad.sad_mod_date AS TIMESTAMP) AS src_updt_ts,
      CAST(sad.sad_serial AS STRING) AS cur_lot_nbr,
      CAST(sad.sad_qty_per AS DOUBLE) AS ord_qty,
      CAST(concat('msd_qad_', lower(sad.sad_domain), '|', sad.sad_for) AS STRING) AS prod_key,
      CAST(sad.sad_for AS STRING) AS sku,
      CAST(concat('msd_qad_', lower(sad.sad_domain), '|', sad.sad_eu_nbr) AS STRING) AS ship_to_cust_key,
      CAST(sad.sad_eu_nbr AS STRING) AS ship_to_cust_id,
      CAST(sad.sad_po AS STRING) AS po_nbr,
      CAST(sad.sad_price AS DOUBLE) AS prc_per_unit_amt,
      CAST(sad.sad_price AS DOUBLE) AS ord_prc_per_unit_amt,
      CAST(sad.sad_project AS STRING) AS proj_cd
  FROM sad_det AS sad
  WHERE sad.sad_line_type IN ('3', '5')
    AND sad.sad_prefix <> 'Q'
    AND (sad.sad_qty_per - sad.sad_qty_bld) <> 0
),
sales_order_master_details AS (
  SELECT
    CAST(sa.sa_ord_date AS TIMESTAMP) AS src_crt_ts,
    CAST(concat('msd_qad_', lower(sa.ad_domain), '|', sa.sa_cust) AS STRING) AS bill_to_cust_key,
    CAST(sa.sa_curr AS STRING) AS ord_curncy_cd,
    CAST(sa.sa_ord_date AS DECIMAL(38,0)) AS ord_dt_key,
    CAST(concat('msd_qad_', lower(sa.sa_domain), '|', sa.sa_cust) AS STRING) AS sold_to_cust_key
  FROM
    sa_mstr AS sa
),
customer_identification AS (
  SELECT
    CAST(d.debtorcode AS STRING) AS bill_to_cust_id,
    CAST(d.debtorcode AS STRING) AS sold_to_cust_id
  FROM
    sa_mstr AS sa
  LEFT JOIN
    debtor AS d
  ON
    d.debtorcode = sa.sa_cust
),
customer_name_mapping AS (
  SELECT
    CAST(bus.businessrelationsearchname AS STRING) AS bill_to_cust_nm
  FROM sa_mstr AS sa
  LEFT OUTER JOIN deb AS deb ON lower(sa.sa_domain) = lower(deb.domain_id)
  LEFT OUTER JOIN BusinessRelation AS bus ON deb.businessrelation_id = bus.businessrelation_id AND lower(sa.sa_domain) = lower(bus.domain_id)
),
company_information_extraction AS (
  SELECT
    CAST(concat('msd_qad_', lower(si.si_domain), '|', si.si_entity) AS STRING) AS co_key,
    CAST(si.si_desc AS STRING) AS co_nm
  FROM
    si_mstr AS si
),
company_code_extraction AS (
  SELECT
    CAST(si.si_entity AS STRING) AS co_cd
  FROM
    sa_mstr AS sa
  LEFT JOIN
    si_mstr AS si
  ON
    lower(si.si_domain) = lower(sa.sa_domain) AND lower(si.si_site) = lower(sa.sa_site)
),
invoice_quantity_calculation AS (
  SELECT
    CAST(idh.idh_qty_inv AS DOUBLE) AS invc_qty
  FROM
    idh_hist AS idh
  LEFT JOIN ih_hist AS ih
    ON lower(idh.idh_domain) = lower(ih.ih_domain)
    AND idh.idh_inv_nbr = ih.ih_inv_nbr
  LEFT JOIN sa_mstr AS sa
    ON idh.idh_sa_nbr = sa.sa_nbr
  LEFT JOIN sad_det AS sad
    ON idh.idh_sad_line = sad.sad_line
),
product_description_mapping AS (
  SELECT
    CAST(pt.pt_desc1 AS STRING) AS sku_nm
  FROM
    pt_mstr AS pt
  LEFT JOIN
    sad_det AS sad
  ON
    lower(sad.sad_domain) = lower(pt.pt_domain) AND sad.sad_for = pt.pt_part
),
revenue_division_classification AS (
  SELECT
    CASE
      WHEN isb.isb_warr_cd = 'WPEND' OR upper(isb.isb_warr_cd) LIKE 'I%' THEN 'Install'
      WHEN upper(isb.isb_warr_cd) LIKE 'W%' AND isb.isb_warr_exp >= current_date THEN 'Warranty'
      WHEN sad.sad_st_date <= current_date AND sad.sad_end_date > current_date THEN 'Contract'
      ELSE 'T&M'
    END AS revnu_div
  FROM
    SAD sad
  LEFT JOIN
    isb isb
  ON
    sad.sad_for = isb.isb_part AND sad.sad_serial = isb.isb_serial AND sad.sad_ref = isb.isb_ref
),
sold_to_customer_name_mapping AS (
  SELECT
    CAST(b.businessrelationsearchname AS STRING) AS sold_to_cust_nm
  FROM
    BusinessRelation b
  LEFT JOIN
    debtor d
  ON
    d.businessrelation_id = b.businessrelation_id
),
order_type_hardcoding AS (
  SELECT CAST('CONTRACT' AS STRING) AS ord_type_nm
),
business_unit_classification AS (
  SELECT
    CASE
      WHEN lower(costcentre.customcombo0) = 'unknownmd' THEN 'UNKNOWNMD'
      ELSE replace(replace(upper(costcentre.customlong0), '.', ''), '_', '')
    END AS bu_cd
  FROM
    tfsdl_aig_qad_delta.sad AS sad
  LEFT OUTER JOIN
    tfsdl_aig_qad_delta.costcentre AS costcentre
    ON sad.sad_cc = costcentre.costcentrecode
),
unit_of_measure_extraction AS (
  SELECT
    CAST(idh.idh_um AS STRING) AS uom_cd
  FROM
    idh_hist AS idh
),
order_transaction_amount_calculation AS (
  SELECT
    CAST(sad.sad_price * sad.sad_qty_item * sad.sad_qty_per AS DOUBLE) AS ord_txn_curncy_amt
  FROM
    sad AS sad
),
product_line_classification AS (
  SELECT
    CASE
      WHEN costcentre.customcombo1 = 'UnknownBL' THEN 'UNKNOWNBL'
      ELSE UPPER(costcentre.customcombo1)
    END AS prod_line_cd
  FROM sa_mstr AS sa
  LEFT OUTER JOIN tfsdl_aig_qad_delta.sad AS sad
    ON sa.sa_prefix = sad.sad_prefix AND sa.sa_nbr = sad.sad_nbr
  LEFT OUTER JOIN tfsdl_aig_qad_delta.costcentre AS costcentre
    ON sad.sad_cc = costcentre.costcentrecode
),
cost_center_extraction AS (
  SELECT
    CAST(c.costcentrecode AS STRING) AS cost_center_cd
  FROM
    costcentre AS c
),
constants_defaults_main AS (
  SELECT 
    CAST(NULL AS DECIMAL(38,0)) AS as_of_dt_key,
    CAST(NULL AS STRING) AS bill_block_cd,
    CAST(NULL AS STRING) AS bill_block_nm,
    CAST(NULL AS DOUBLE) AS bo_co_curncy_amt,
    CAST(NULL AS STRING) AS bo_flg,
    CAST(NULL AS DOUBLE) AS bo_lcur_amt,
    CAST(NULL AS DOUBLE) AS bo_qty,
    CAST(NULL AS STRING) AS bo_stat_nm,
    CAST(NULL AS STRING) AS ccg_lcd_chnl,
    CAST(NULL AS STRING) AS ccg_lcd_vndr_nbr,
    CAST(NULL AS STRING) AS co_curncy_cd,
    CAST(NULL AS STRING) AS co_usd_curncy_mth_rt_key,
    CAST(NULL AS DECIMAL(38,0)) AS commit_dt_key,
    CAST(NULL AS STRING) AS contact_key,
    CAST(NULL AS STRING) AS cost_curncy_cd,
    CAST(NULL AS STRING) AS cur_lot_nbr,
    CAST(NULL AS STRING) AS cur_ord_stat_cd,
    CAST(NULL AS STRING) AS cur_ord_stat_nm,
    CAST(NULL AS STRING) AS cust_key,
    CAST(NULL AS STRING) AS cust_po_nbr,
    CAST(NULL AS STRING) AS delvr_block_cd,
    CAST(NULL AS STRING) AS delvr_block_nm,
    CAST(NULL AS STRING) AS derived_prod_key,
    CAST(NULL AS STRING) AS derived_sku,
    CAST(NULL AS STRING) AS derived_sku_nm,
    CAST(NULL AS DOUBLE) AS disc_amt,
    CAST(NULL AS STRING) AS dw_dly_open_ord_key,
    CAST(NULL AS STRING) AS dw_src_cd,
    CAST(NULL AS DECIMAL(38,0)) AS expect_ship_dt_key,
    CAST(NULL AS DOUBLE) AS fin_bo_co_curncy_amt,
    CAST(NULL AS DOUBLE) AS fin_bo_lcur_amt,
    CAST(NULL AS DOUBLE) AS fin_bo_qty,
    CAST(NULL AS STRING) AS fin_ord_line_complt_flg,
    CAST(NULL AS STRING) AS hdr_bill_block_cd,
    CAST(NULL AS STRING) AS hdr_bill_block_nm,
    CAST(NULL AS STRING) AS hdr_delvr_block_cd,
    CAST(NULL AS STRING) AS hdr_delvr_block_nm,
    CAST(NULL AS STRING) AS hdr_ord_type_cd,
    CAST(NULL AS STRING) AS hdr_ord_type_nm,
    CAST(NULL AS STRING) AS hfm_entity_cd,
    CAST(NULL AS STRING) AS hfm_entity_key,
    CAST(NULL AS DOUBLE) AS invc_qty,
    CAST(NULL AS DECIMAL(38,0)) AS mtl_avbl_dt_key,
    CAST(NULL AS STRING) AS next_ord_stat_cd,
    CAST(NULL AS STRING) AS next_ord_stat_nm,
    CAST(NULL AS DOUBLE) AS ord_co_curncy_amt,
    CAST(NULL AS STRING) AS ord_hdr_usd_curncy_mth_rt_key,
    CAST(NULL AS DOUBLE) AS ord_lcur_amt,
    CAST(NULL AS DECIMAL(38,0)) AS ord_line_ship_nlt_dt_key,
    CAST(NULL AS STRING) AS ord_overall_stat_cd,
    CAST(NULL AS STRING) AS ord_overall_stat_nm,
    CAST(NULL AS DECIMAL(38,0)) AS ord_rls_dt_key,
    CAST(NULL AS STRING) AS ord_type_cd,
    CAST(NULL AS DECIMAL(38,0)) AS orig_proms_dt_key,
    CAST(NULL AS STRING) AS overall_stat_cd,
    CAST(NULL AS STRING) AS overall_stat_nm,
    CAST(NULL AS STRING) AS plant_cd,
    CAST(NULL AS STRING) AS plant_key,
    CAST(NULL AS STRING) AS plant_nm,
    CAST(NULL AS STRING) AS po_line_nbr,
    CAST(NULL AS STRING) AS po_nbr,
    CAST(NULL AS STRING) AS prod_plant_key,
    CAST(NULL AS STRING) AS proj_cd,
    CAST(NULL AS DECIMAL(38,0)) AS proms_delvr_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS proms_ship_dt_key,
    CAST(NULL AS TIMESTAMP) AS rec_crt_ts,
    CAST(NULL AS TIMESTAMP) AS rec_updt_ts,
    CAST(NULL AS STRING) AS reject_rsn_cd,
    CAST(NULL AS STRING) AS reject_rsn_nm,
    CAST(NULL AS DECIMAL(38,0)) AS req_delvr_dt_key,
    CAST(NULL AS STRING) AS req_strg_loc_cd,
    CAST(NULL AS STRING) AS revnu_div,
    CAST(NULL AS DECIMAL(38,0)) AS sched_ship_dt_key,
    CAST(NULL AS DOUBLE) AS ship_qty,
    CAST(NULL AS STRING) AS ship_to_cntry_hier_key,
    CAST(NULL AS STRING) AS ship_to_cust_key,
    CAST(NULL AS STRING) AS ship_to_cust_nm,
    CAST(NULL AS STRING) AS sls_ord_key,
    CAST(NULL AS STRING) AS sls_rep_cust_key,
    CAST(NULL AS STRING) AS sls_terr_cd
  FROM (SELECT 1) AS dummy
),
constants_defaults_secondary AS (
  SELECT
    CAST(NULL AS STRING) AS sold_to_cust_id,
    CAST(NULL AS STRING) AS sold_to_cust_key,
    CAST(NULL AS STRING) AS sold_to_cust_nm,
    CAST(NULL AS STRING) AS src_crt_by,
    CAST(NULL AS STRING) AS strg_loc_cd,
    CAST(NULL AS DOUBLE) AS target_qty,
    CAST(NULL AS DOUBLE) AS unit_std_cost,
    CAST(NULL AS STRING) AS uom_cd
),
customer_mapping_debtor AS (
  SELECT
    CAST(deb.debtorcode AS STRING) AS bill_to_cust_id
  FROM
    ca_mstr ca
  LEFT JOIN (
    SELECT
      debtorcode,
      debtortype_id,
      businessrelation_id,
      ROW_NUMBER() OVER (PARTITION BY debtorcode ORDER BY hub_debtor_key DESC) AS rn
    FROM
      debtor
  ) deb
  ON
    ca.ca_customer = deb.debtorcode AND deb.rn = 1
),
address_customer_mapping AS (
  SELECT 
    CAST(concat('msd_qad_', lower(ca.ca_domain), '|', ca.ca_customer) AS STRING) AS bill_to_cust_key
  FROM 
    ca_mstr AS ca
),
business_relation_customer_name AS (
  SELECT
    CAST(br.businessrelationsearchname AS STRING) AS bill_to_cust_nm
  FROM
    BusinessRelation br
  LEFT JOIN
    debtor d ON d.businessrelation_id = br.businessrelation_id
),
business_unit_mapping AS (
  SELECT
    CASE
      WHEN lower(cc.customcombo0) = 'unknownmd' THEN 'UNKNOWNMD'
      ELSE replace(replace(upper(cc.customlong0), '.', ''), '_', '')
    END AS bu_cd
  FROM
    costcentre AS cc
  LEFT JOIN
    wo AS wo
    ON wo.wo_cc = cc.costcentrecode
),
company_code_mapping AS (
  SELECT
    CAST(si.si_entity AS STRING) AS co_cd
  FROM
    ca_mstr AS ca
  LEFT JOIN
    si_mstr AS si
  ON
    lower(si.si_domain) = lower(ca.ca_domain) AND lower(si.si_site) = lower(ca.ca_site)
),
company_details AS (
  SELECT
    concat('msd_qad_', lower(si.si_domain)) AS co_key,
    CAST(si.si_desc AS STRING) AS co_nm
  FROM
    si_mstr AS si
),
daily_open_order_key AS (
  SELECT 
    CAST(concat('msd_qad_', ca.ca_domain, '|', date_format(current_date, 'yyyyMMdd'), '|', ca.ca_nbr, '|', it.itm_line, '|') AS STRING) AS dly_open_ord_key
  FROM 
    ca_mstr AS ca
  JOIN 
    itm_det AS it
    ON ca.ca_nbr = it.itm_nbr
),
customer_order_details AS (
  SELECT
    CAST(ca.ca_curr AS STRING) AS ord_curncy_cd,
    CAST(ca.ca_opn_date AS DECIMAL(38,0)) AS ord_dt_key,
    CAST(ca.ca_eu_nbr AS STRING) AS ship_to_cust_id,
    CAST(ca.ca_nbr AS STRING) AS sls_ord_nbr,
    CAST(ca.ca_opn_date AS TIMESTAMP) AS src_crt_ts,
    CAST(concat("msd_qad_", lower(ca.ca_domain)) AS STRING) AS src_sys_cd,
    CAST(ca.ca_mod_userid AS STRING) AS src_updt_by,
    CAST(ca.ca_mod_date AS TIMESTAMP) AS src_updt_ts
  FROM ca_mstr AS ca
),
order_pricing_equations AS (
  SELECT
    CAST((
      (wod.wod_qty_req * wod.wod_price) - wod.wod_covered_amt +
      (wr.wr_act_run * wr.wr_price) - wr.wr_covered_amt
    ) AS DOUBLE) AS ord_prc_per_unit_amt
  FROM
    wo_mstr wo
  LEFT JOIN wod_det wod
    ON lower(wo.wo_domain) = lower(wod.wod_domain) AND wo.wo_lot = wod.wod_lot
  LEFT JOIN wr_route wr
    ON lower(wo.wo_domain) = lower(wr.wr_domain) AND wo.wo_lot = wr.wr_lot
  WHERE
    ((wod.wod_qty_req * wod.wod_price) - wod.wod_covered_amt +
     (wr.wr_act_run * wr.wr_price) - wr.wr_covered_amt) <> 0
),
materials_quantity AS (
  SELECT CAST(1 AS DOUBLE) AS ord_qty
),
work_order_pricing AS (
  SELECT 
    CAST((COALESCE(wod.wod_qty_req * wod.wod_price, 0) - COALESCE(wod.wod_covered_amt, 0) + COALESCE(wr.wr_act_run * wr.wr_price, 0) - COALESCE(wr.wr_covered_amt, 0)) AS DOUBLE) AS ord_txn_curncy_amt
  FROM wod
  JOIN wr ON wr.wr_id = wod.wod_wr_id
  WHERE (COALESCE(wod.wod_qty_req * wod.wod_price, 0) - COALESCE(wod.wod_covered_amt, 0) + COALESCE(wr.wr_act_run * wr.wr_price, 0) - COALESCE(wr.wr_covered_amt, 0)) <> 0
),
order_type_mapping AS (
  SELECT CAST('CALL' AS STRING) AS ord_type_nm
),
amounts_pricing_equations AS (
  SELECT
    CAST(NULL AS DOUBLE) AS prc_per_unit_amt
  FROM
    ca_mstr
),
item_details AS (
  SELECT 
    CAST(concat('msd_qad_', itm_det.itm_domain, '|', itm_det.itm_part) AS STRING) AS prod_key,
    CAST(itm_det.itm_part AS STRING) AS sku
  FROM itm_det AS itm_det
),
product_line_mapping AS (
  SELECT
    CASE
      WHEN costcentre.customcombo1 = 'UnknownBL' THEN 'UNKNOWNBL'
      ELSE UPPER(costcentre.customcombo1)
    END AS prod_line_cd
  FROM idh_hist AS idh
  LEFT OUTER JOIN tfsdl_aig_qad_delta.costcentre AS costcentre
    ON idh.idh_cc = costcentre.costcentrecode
),
item_description_mapping AS (
  SELECT
    CAST(pt.pt_desc1 AS STRING) AS sku_nm
  FROM
    pt_mstr AS pt
  LEFT JOIN
    itm_det AS itm
    ON lower(pt.pt_domain) = lower(itm.itm_domain) AND pt.pt_part = itm.itm_part
),
sales_order_line_mapping AS (
  SELECT
    CAST(itm.itm_line AS STRING) AS sls_ord_line_nbr
  FROM
    ca_mstr AS ca
  LEFT JOIN itm_det AS itm
    ON lower(ca.ca_domain) = lower(itm.itm_domain)
    AND ca.ca_nbr = itm.itm_nbr
  LEFT JOIN si_mstr AS si
    ON lower(itm.itm_site) = lower(si.si_site)
  WHERE
    itm.itm_prefix = 'CA'
    AND itm.itm_itm_line = 0
),
cost_centre_mapping AS (
  SELECT
    CAST(cc.costcentrecode AS STRING) AS cost_center_cd
  FROM
    costcentre AS cc
),
daily_open_order_key_generation_2 AS (
  SELECT
    concat(
      'msd_qad_',
      lower(so.so_domain),
      '|',
      date_format(current_date, 'yyyyMMdd'),
      '|',
      so.so_nbr,
      '|',
      sod.sod_line,
      '|',
      coalesce(idh.idh_part, sod.sod_part)
    ) AS dly_open_ord_key
  FROM
    so_mstr AS so
  JOIN
    sod_det AS sod
    ON lower(so.so_domain) = lower(sod.sod_domain) AND so.so_nbr = sod.sod_nbr
  LEFT JOIN
    idh_hist AS idh
    ON lower(so.so_domain) = lower(idh.idh_domain) AND so.so_nbr = idh.idh_nbr AND sod.sod_line = idh.idh_line
),
sales_order_master_data AS (
  SELECT 
    CAST(concat('msd_qad_', lower(so.so_domain)) AS STRING) AS src_sys_cd,
    CAST(so.so_nbr AS STRING) AS sls_ord_nbr,
    CAST(so.so_ord_date AS TIMESTAMP) AS src_crt_ts,
    CAST(concat('msd_qad_', lower(so.so_domain)) AS STRING) AS bill_to_cust_key,
    CAST(so.so_bill AS STRING) AS bill_to_cust_id,
    CAST(so.so_curr AS STRING) AS ord_curncy_cd,
    CAST(so.so_ord_date AS DECIMAL(38,0)) AS ord_dt_key,
    CAST(so.so_ship AS STRING) AS ship_to_cust_id
  FROM so_mstr AS so
),
constants_and_defaults_large AS (
  SELECT 
    CAST(NULL AS DECIMAL(38,0)) AS as_of_dt_key,
    CAST(NULL AS STRING) AS dw_src_cd,
    CAST(NULL AS STRING) AS dw_dly_open_ord_key,
    CAST(NULL AS STRING) AS src_crt_by,
    CAST(NULL AS STRING) AS src_updt_by,
    CAST(NULL AS TIMESTAMP) AS src_updt_ts,
    CAST(NULL AS TIMESTAMP) AS rec_crt_ts,
    CAST(NULL AS TIMESTAMP) AS rec_updt_ts,
    CAST(NULL AS DOUBLE) AS bo_co_curncy_amt,
    CAST(NULL AS STRING) AS bo_flg,
    CAST(NULL AS DOUBLE) AS bo_lcur_amt,
    CAST(NULL AS DOUBLE) AS bo_qty,
    CAST(NULL AS STRING) AS ccg_lcd_chnl,
    CAST(NULL AS STRING) AS ccg_lcd_vndr_nbr,
    CAST(NULL AS STRING) AS contact_key,
    CAST(NULL AS STRING) AS co_usd_curncy_mth_rt_key,
    CAST(NULL AS STRING) AS co_curncy_cd,
    CAST(NULL AS STRING) AS cur_lot_nbr,
    CAST(NULL AS STRING) AS cust_po_nbr,
    CAST(NULL AS STRING) AS derived_prod_key,
    CAST(NULL AS STRING) AS derived_sku,
    CAST(NULL AS STRING) AS derived_sku_nm,
    CAST(NULL AS DECIMAL(38,0)) AS expect_ship_dt_key,
    CAST(NULL AS DOUBLE) AS fin_bo_co_curncy_amt,
    CAST(NULL AS DOUBLE) AS fin_bo_lcur_amt,
    CAST(NULL AS DOUBLE) AS fin_bo_qty,
    CAST(NULL AS STRING) AS fin_ord_line_complt_flg,
    CAST(NULL AS STRING) AS hfm_entity_key,
    CAST(NULL AS STRING) AS hfm_entity_cd,
    CAST(NULL AS DOUBLE) AS invc_qty,
    CAST(NULL AS DECIMAL(38,0)) AS mtl_avbl_dt_key,
    CAST(NULL AS DOUBLE) AS ord_co_curncy_amt,
    CAST(NULL AS STRING) AS ord_hdr_usd_curncy_mth_rt_key,
    CAST(NULL AS DOUBLE) AS ord_lcur_amt,
    CAST(NULL AS STRING) AS strg_loc_cd,
    CAST(NULL AS STRING) AS req_strg_loc_cd,
    CAST(NULL AS DECIMAL(38,0)) AS ord_line_ship_nlt_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS orig_proms_dt_key,
    CAST(NULL AS STRING) AS plant_key,
    CAST(NULL AS STRING) AS plant_cd,
    CAST(NULL AS STRING) AS plant_nm,
    CAST(NULL AS STRING) AS prod_plant_key,
    CAST(NULL AS DECIMAL(38,0)) AS proms_delvr_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS req_delvr_dt_key,
    CAST(NULL AS STRING) AS revnu_div,
    CAST(NULL AS DECIMAL(38,0)) AS ord_rls_dt_key,
    CAST(NULL AS DOUBLE) AS ship_qty,
    CAST(NULL AS STRING) AS ship_to_cust_key,
    CAST(NULL AS STRING) AS ship_to_cust_nm,
    CAST(NULL AS STRING) AS ship_to_cntry_hier_key,
    CAST(NULL AS STRING) AS sls_ord_key,
    CAST(NULL AS STRING) AS sold_to_cust_key,
    CAST(NULL AS STRING) AS sold_to_cust_id,
    CAST(NULL AS STRING) AS sold_to_cust_nm,
    CAST(NULL AS DOUBLE) AS target_qty,
    CAST(NULL AS DOUBLE) AS unit_std_cost,
    CAST(NULL AS STRING) AS cur_ord_stat_cd,
    CAST(NULL AS STRING) AS cur_ord_stat_nm,
    CAST(NULL AS STRING) AS next_ord_stat_cd,
    CAST(NULL AS STRING) AS next_ord_stat_nm,
    CAST(NULL AS STRING) AS hdr_bill_block_cd,
    CAST(NULL AS STRING) AS hdr_bill_block_nm,
    CAST(NULL AS STRING) AS hdr_delvr_block_cd,
    CAST(NULL AS STRING) AS hdr_delvr_block_nm,
    CAST(NULL AS STRING) AS bill_block_cd,
    CAST(NULL AS STRING) AS bill_block_nm,
    CAST(NULL AS STRING) AS delvr_block_cd,
    CAST(NULL AS STRING) AS delvr_block_nm,
    CAST(NULL AS STRING) AS overall_stat_cd,
    CAST(NULL AS STRING) AS overall_stat_nm,
    CAST(NULL AS STRING) AS reject_rsn_cd,
    CAST(NULL AS STRING) AS reject_rsn_nm,
    CAST(NULL AS STRING) AS ord_type_cd,
    CAST(NULL AS STRING) AS ord_overall_stat_cd,
    CAST(NULL AS STRING) AS ord_overall_stat_nm,
    CAST(NULL AS STRING) AS hdr_ord_type_cd,
    CAST(NULL AS STRING) AS hdr_ord_type_nm,
    CAST(NULL AS STRING) AS bo_stat_nm,
    CAST(NULL AS DECIMAL(38,0)) AS commit_dt_key,
    CAST(NULL AS DECIMAL(38,0)) AS proms_ship_dt_key
),
constants_and_defaults_small AS (
  SELECT
    CAST(NULL AS DECIMAL(38,0)) AS sched_ship_dt_key,
    CAST(NULL AS STRING) AS cust_key,
    CAST(NULL AS STRING) AS sls_rep_cust_key,
    CAST(NULL AS STRING) AS po_nbr,
    CAST(NULL AS STRING) AS po_line_nbr,
    CAST(NULL AS STRING) AS sls_terr_cd,
    CAST(NULL AS STRING) AS cost_curncy_cd,
    CAST(NULL AS DOUBLE) AS disc_amt,
    CAST(NULL AS STRING) AS proj_cd
),
sales_order_line_data AS (
  SELECT
    CAST(sod.sod_line AS STRING) AS sls_ord_line_nbr
  FROM
    so_mstr AS so
  JOIN
    sod_det AS sod
    ON lower(so.so_domain) = lower(sod.sod_domain)
       AND so.so_nbr = sod.sod_nbr
       AND sod.sod_qty_ord <> sod.sod_qty_inv
       AND sod.sod_price <> 0
),
customer_business_relation AS (
  SELECT
    CAST(br.businessrelationsearchname AS STRING) AS bill_to_cust_nm
  FROM
    BusinessRelation br
  LEFT JOIN debtor d ON d.businessrelation_id = br.businessrelation_id
),
site_master_data AS (
  SELECT
    concat('msd_qad_', lower(si.si_domain)) AS co_key,
    CAST(si.si_desc AS STRING) AS co_nm
  FROM
    si_mstr AS si
),
site_and_sales_order_data AS (
  SELECT
      CAST(si.si_entity AS STRING) AS co_cd
  FROM
      so_mstr AS so
  LEFT JOIN
      si_mstr AS si
  ON
      lower(si.si_domain) = lower(so.so_domain) AND lower(si.si_site) = lower(so.so_site)
),
order_quantity_calculation AS (
  SELECT
    CASE
      WHEN idh.idh_qty_ord IS NULL THEN CAST(sod.sod_qty_ord - sod.sod_qty_inv AS DOUBLE)
      ELSE CAST(idh.idh_qty_ord AS DOUBLE)
    END AS ord_qty
  FROM
    sod_det sod
  LEFT JOIN
    idh idh
  ON
    sod.sod_domain = idh.idh_domain AND sod.sod_nbr = idh.idh_nbr
),
sales_order_detail_data AS (
  SELECT
    concat('msd_qad_', lower(s.sod_domain), '|', s.sod_part) AS prod_key,
    CAST(s.sod_price AS DOUBLE) AS prc_per_unit_amt,
    CAST(s.sod_price AS DOUBLE) AS ord_prc_per_unit_amt
  FROM
    sod_det AS s
),
sku_data_combination AS (
  SELECT
    CAST(coalesce(idh.idh_part, sod.sod_part) AS STRING) AS sku
  FROM
    idh_hist AS idh
  LEFT JOIN
    sod_det AS sod
  ON /* ERROR: missing join condition */ 1=0
),
product_description_data AS (
  SELECT
    CAST(pt.pt_desc1 AS STRING) AS sku_nm
  FROM
    pt_mstr AS pt
  LEFT JOIN sod_det AS sod
    ON lower(pt.pt_domain) = lower(sod.sod_domain) AND pt.pt_part = sod.sod_part
),
order_type_classification AS (
  SELECT 
    CASE 
      WHEN so.so_fsm_type = 'RMA' THEN 'RMA' 
      ELSE 'SO' 
    END AS ord_type_nm
  FROM so_mstr AS so
),
business_unit_mapping_2 AS (
  SELECT
    CASE
      WHEN lower(cc.customcombo0) = 'unknownmd' THEN 'UNKNOWNMD'
      ELSE replace(replace(upper(cc.customlong0), '.', ''), '_', '')
    END AS bu_cd
  FROM
    tfsdl_aig_qad_delta.so_mstr AS so
  LEFT JOIN
    tfsdl_aig_qad_delta.sod_det AS sod
    ON lower(so.so_domain) = lower(sod.sod_domain) AND so.so_nbr = sod.sod_nbr
  LEFT JOIN
    tfsdl_aig_qad_delta.idh_hist AS idh
    ON lower(idh.idh_domain) = lower(sod.sod_domain) AND trim(idh.idh_nbr) = trim(so.so_nbr) AND idh.idh_line = sod.sod_line
  LEFT JOIN
    (SELECT DISTINCT costcentrecode, costcentreisactive, customcombo0, customlong0 FROM costcentre) AS cc
    ON sod.sod_cc = cc.costcentrecode AND cc.costcentreisactive = true
),
unit_of_measure_data AS (
  SELECT
    CAST(idh.idh_um AS STRING) AS uom_cd
  FROM
    idh_hist AS idh
),
order_transaction_currency_amount AS (
  SELECT
    CASE
      WHEN rhd.rhd_price IS NULL THEN (sod.sod_price * (sod.sod_qty_ord - sod.sod_qty_inv))
      ELSE rhd.rhd_price
    END AS ord_txn_curncy_amt
  FROM
    sod_det sod
  LEFT JOIN
    rhd rhd
    ON rhd.some_key = sod.some_key
),
product_line_mapping_2 AS (
  SELECT
    CASE 
      WHEN COALESCE(idh.idh_prodline, '') <> '' THEN idh.idh_prodline
      WHEN COALESCE(rhd.rhd_prodline, '') <> '' THEN rhd.rhd_prodline
      ELSE '' 
    END AS prod_line_cd
  FROM idh
  LEFT JOIN (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY rhd_domain, rhd_nbr, rhd_line ORDER BY oid_rhd_hist ASC) AS rn
    FROM rhd
  ) rhd
    ON LOWER(rhd.rhd_domain) = LOWER(idh.idh_domain)
       AND rhd.rhd_nbr = idh.idh_nbr
       AND rhd.rhd_line = idh.idh_line
       AND rhd.rn = 1
),
cost_center_data AS (
  SELECT
    CAST(cc.costcentrecode AS STRING) AS cost_center_cd
  FROM
    costcentre AS cc
),
fact_daily_open_order_uisc AS (
  SELECT
  daily_open_order_key_generation.dly_open_ord_key AS dly_open_ord_key,
  daily_open_order_key_generation.src_sys_cd AS src_sys_cd,
  constants_and_defaults.as_of_dt_key AS as_of_dt_key,
  sales_order_number_extraction.sls_ord_nbr AS sls_ord_nbr,
  sales_order_line_details.sls_ord_line_nbr AS sls_ord_line_nbr,
  constants_and_defaults.dw_src_cd AS dw_src_cd,
  constants_and_defaults.dw_dly_open_ord_key AS dw_dly_open_ord_key,
  constants_and_defaults.src_crt_by AS src_crt_by,
  sales_order_master_details.src_crt_ts AS src_crt_ts,
  sales_order_line_details.src_updt_by AS src_updt_by,
  sales_order_line_details.src_updt_ts AS src_updt_ts,
  constants_and_defaults.rec_crt_ts AS rec_crt_ts,
  constants_and_defaults.rec_updt_ts AS rec_updt_ts,
  sales_order_master_details.bill_to_cust_key AS bill_to_cust_key,
  customer_identification.bill_to_cust_id AS bill_to_cust_id,
  customer_name_mapping.bill_to_cust_nm AS bill_to_cust_nm,
  constants_and_defaults.bo_co_curncy_amt AS bo_co_curncy_amt,
  constants_and_defaults.bo_flg AS bo_flg,
  constants_and_defaults.bo_lcur_amt AS bo_lcur_amt,
  constants_and_defaults.bo_qty AS bo_qty,
  constants_and_defaults.ccg_lcd_chnl AS ccg_lcd_chnl,
  constants_and_defaults.ccg_lcd_vndr_nbr AS ccg_lcd_vndr_nbr,
  constants_and_defaults.contact_key AS contact_key,
  constants_and_defaults.co_usd_curncy_mth_rt_key AS co_usd_curncy_mth_rt_key,
  company_information_extraction.co_key AS co_key,
  company_code_extraction.co_cd AS co_cd,
  company_information_extraction.co_nm AS co_nm,
  constants_and_defaults.co_curncy_cd AS co_curncy_cd,
  sales_order_line_details.cur_lot_nbr AS cur_lot_nbr,
  constants_and_defaults.cust_po_nbr AS cust_po_nbr,
  constants_and_defaults.derived_prod_key AS derived_prod_key,
  constants_and_defaults.derived_sku AS derived_sku,
  constants_and_defaults.derived_sku_nm AS derived_sku_nm,
  constants_and_defaults.expect_ship_dt_key AS expect_ship_dt_key,
  constants_and_defaults.fin_bo_co_curncy_amt AS fin_bo_co_curncy_amt,
  constants_and_defaults.fin_bo_lcur_amt AS fin_bo_lcur_amt,
  constants_and_defaults.fin_bo_qty AS fin_bo_qty,
  constants_and_defaults.fin_ord_line_complt_flg AS fin_ord_line_complt_flg,
  constants_and_defaults.hfm_entity_key AS hfm_entity_key,
  constants_and_defaults.hfm_entity_cd AS hfm_entity_cd,
  invoice_quantity_calculation.invc_qty AS invc_qty,
  constants_and_defaults.mtl_avbl_dt_key AS mtl_avbl_dt_key,
  constants_and_defaults.ord_co_curncy_amt AS ord_co_curncy_amt,
  sales_order_master_details.ord_curncy_cd AS ord_curncy_cd,
  sales_order_master_details.ord_dt_key AS ord_dt_key,
  constants_and_defaults.ord_hdr_usd_curncy_mth_rt_key AS ord_hdr_usd_curncy_mth_rt_key,
  constants_and_defaults.ord_lcur_amt AS ord_lcur_amt,
  constants_and_defaults.strg_loc_cd AS strg_loc_cd,
  constants_and_defaults.req_strg_loc_cd AS req_strg_loc_cd,
  constants_and_defaults.ord_line_ship_nlt_dt_key AS ord_line_ship_nlt_dt_key,
  sales_order_line_details.ord_qty AS ord_qty,
  constants_and_defaults.orig_proms_dt_key AS orig_proms_dt_key,
  constants_and_defaults.plant_key AS plant_key,
  constants_and_defaults.plant_cd AS plant_cd,
  constants_and_defaults.plant_nm AS plant_nm,
  sales_order_line_details.prod_key AS prod_key,
  sales_order_line_details.sku AS sku,
  product_description_mapping.sku_nm AS sku_nm,
  constants_and_defaults.prod_plant_key AS prod_plant_key,
  constants_and_defaults.proms_delvr_dt_key AS proms_delvr_dt_key,
  constants_and_defaults.req_delvr_dt_key AS req_delvr_dt_key,
  revenue_division_classification.revnu_div AS revnu_div,
  constants_and_defaults.ord_rls_dt_key AS ord_rls_dt_key,
  constants_and_defaults.ship_qty AS ship_qty,
  sales_order_line_details.ship_to_cust_key AS ship_to_cust_key,
  sales_order_line_details.ship_to_cust_id AS ship_to_cust_id,
  constants_and_defaults.ship_to_cust_nm AS ship_to_cust_nm,
  constants_and_defaults.ship_to_cntry_hier_key AS ship_to_cntry_hier_key,
  constants_and_defaults.sls_ord_key AS sls_ord_key,
  sales_order_master_details.sold_to_cust_key AS sold_to_cust_key,
  customer_identification.sold_to_cust_id AS sold_to_cust_id,
  sold_to_customer_name_mapping.sold_to_cust_nm AS sold_to_cust_nm,
  constants_and_defaults.target_qty AS target_qty,
  constants_and_defaults.unit_std_cost AS unit_std_cost,
  constants_and_defaults.cur_ord_stat_cd AS cur_ord_stat_cd,
  constants_and_defaults.cur_ord_stat_nm AS cur_ord_stat_nm,
  constants_and_defaults.next_ord_stat_cd AS next_ord_stat_cd,
  constants_and_defaults.next_ord_stat_nm AS next_ord_stat_nm,
  constants_and_defaults.hdr_bill_block_cd AS hdr_bill_block_cd,
  constants_and_defaults.hdr_bill_block_nm AS hdr_bill_block_nm,
  constants_and_defaults.hdr_delvr_block_cd AS hdr_delvr_block_cd,
  constants_and_defaults.hdr_delvr_block_nm AS hdr_delvr_block_nm,
  constants_and_defaults.bill_block_cd AS bill_block_cd,
  constants_and_defaults.bill_block_nm AS bill_block_nm,
  constants_and_defaults.delvr_block_cd AS delvr_block_cd,
  constants_and_defaults.delvr_block_nm AS delvr_block_nm,
  constants_and_defaults.overall_stat_cd AS overall_stat_cd,
  constants_and_defaults.overall_stat_nm AS overall_stat_nm,
  constants_and_defaults.reject_rsn_cd AS reject_rsn_cd,
  constants_and_defaults.reject_rsn_nm AS reject_rsn_nm,
  constants_and_defaults.ord_type_cd AS ord_type_cd,
  order_type_hardcoding.ord_type_nm AS ord_type_nm,
  constants_and_defaults.ord_overall_stat_cd AS ord_overall_stat_cd,
  constants_and_defaults.ord_overall_stat_nm AS ord_overall_stat_nm,
  constants_and_defaults.hdr_ord_type_cd AS hdr_ord_type_cd,
  constants_and_defaults.hdr_ord_type_nm AS hdr_ord_type_nm,
  constants_and_defaults.bo_stat_nm AS bo_stat_nm,
  constants_and_defaults.commit_dt_key AS commit_dt_key,
  constants_and_defaults.proms_ship_dt_key AS proms_ship_dt_key,
  constants_and_defaults.sched_ship_dt_key AS sched_ship_dt_key,
  constants_and_defaults.cust_key AS cust_key,
  constants_and_defaults.sls_rep_cust_key AS sls_rep_cust_key,
  sales_order_line_details.po_nbr AS po_nbr,
  constants_and_defaults.po_line_nbr AS po_line_nbr,
  business_unit_classification.bu_cd AS bu_cd,
  constants_and_defaults.sls_terr_cd AS sls_terr_cd,
  constants_and_defaults.cost_curncy_cd AS cost_curncy_cd,
  unit_of_measure_extraction.uom_cd AS uom_cd,
  sales_order_line_details.prc_per_unit_amt AS prc_per_unit_amt,
  sales_order_line_details.ord_prc_per_unit_amt AS ord_prc_per_unit_amt,
  constants_and_defaults.disc_amt AS disc_amt,
  order_transaction_amount_calculation.ord_txn_curncy_amt AS ord_txn_curncy_amt,
  product_line_classification.prod_line_cd AS prod_line_cd,
  sales_order_line_details.proj_cd AS proj_cd,
  cost_center_extraction.cost_center_cd AS cost_center_cd
  FROM business_unit_classification CROSS JOIN company_code_extraction CROSS JOIN company_information_extraction CROSS JOIN constants_and_defaults CROSS JOIN cost_center_extraction CROSS JOIN customer_identification CROSS JOIN customer_name_mapping CROSS JOIN daily_open_order_key_generation CROSS JOIN invoice_quantity_calculation CROSS JOIN order_transaction_amount_calculation CROSS JOIN order_type_hardcoding CROSS JOIN product_description_mapping CROSS JOIN product_line_classification CROSS JOIN revenue_division_classification CROSS JOIN sales_order_line_details CROSS JOIN sales_order_master_details CROSS JOIN sales_order_number_extraction CROSS JOIN sold_to_customer_name_mapping CROSS JOIN unit_of_measure_extraction
),
fact_daily_open_order_uiscall AS (
  SELECT
  daily_open_order_key.dly_open_ord_key AS dly_open_ord_key,
  customer_order_details.src_sys_cd AS src_sys_cd,
  constants_defaults_main.as_of_dt_key AS as_of_dt_key,
  customer_order_details.sls_ord_nbr AS sls_ord_nbr,
  sales_order_line_mapping.sls_ord_line_nbr AS sls_ord_line_nbr,
  constants_defaults_main.dw_src_cd AS dw_src_cd,
  constants_defaults_main.dw_dly_open_ord_key AS dw_dly_open_ord_key,
  constants_defaults_secondary.src_crt_by AS src_crt_by,
  customer_order_details.src_crt_ts AS src_crt_ts,
  customer_order_details.src_updt_by AS src_updt_by,
  customer_order_details.src_updt_ts AS src_updt_ts,
  constants_defaults_main.rec_crt_ts AS rec_crt_ts,
  constants_defaults_main.rec_updt_ts AS rec_updt_ts,
  address_customer_mapping.bill_to_cust_key AS bill_to_cust_key,
  customer_mapping_debtor.bill_to_cust_id AS bill_to_cust_id,
  business_relation_customer_name.bill_to_cust_nm AS bill_to_cust_nm,
  constants_defaults_main.bo_co_curncy_amt AS bo_co_curncy_amt,
  constants_defaults_main.bo_flg AS bo_flg,
  constants_defaults_main.bo_lcur_amt AS bo_lcur_amt,
  constants_defaults_main.bo_qty AS bo_qty,
  constants_defaults_main.ccg_lcd_chnl AS ccg_lcd_chnl,
  constants_defaults_main.ccg_lcd_vndr_nbr AS ccg_lcd_vndr_nbr,
  constants_defaults_main.contact_key AS contact_key,
  constants_defaults_main.co_usd_curncy_mth_rt_key AS co_usd_curncy_mth_rt_key,
  company_details.co_key AS co_key,
  company_code_mapping.co_cd AS co_cd,
  company_details.co_nm AS co_nm,
  constants_defaults_main.co_curncy_cd AS co_curncy_cd,
  constants_defaults_main.cur_lot_nbr AS cur_lot_nbr,
  constants_defaults_main.cust_po_nbr AS cust_po_nbr,
  constants_defaults_main.derived_prod_key AS derived_prod_key,
  constants_defaults_main.derived_sku AS derived_sku,
  constants_defaults_main.derived_sku_nm AS derived_sku_nm,
  constants_defaults_main.expect_ship_dt_key AS expect_ship_dt_key,
  constants_defaults_main.fin_bo_co_curncy_amt AS fin_bo_co_curncy_amt,
  constants_defaults_main.fin_bo_lcur_amt AS fin_bo_lcur_amt,
  constants_defaults_main.fin_bo_qty AS fin_bo_qty,
  constants_defaults_main.fin_ord_line_complt_flg AS fin_ord_line_complt_flg,
  constants_defaults_main.hfm_entity_key AS hfm_entity_key,
  constants_defaults_main.hfm_entity_cd AS hfm_entity_cd,
  constants_defaults_main.invc_qty AS invc_qty,
  constants_defaults_main.mtl_avbl_dt_key AS mtl_avbl_dt_key,
  constants_defaults_main.ord_co_curncy_amt AS ord_co_curncy_amt,
  customer_order_details.ord_curncy_cd AS ord_curncy_cd,
  customer_order_details.ord_dt_key AS ord_dt_key,
  constants_defaults_main.ord_hdr_usd_curncy_mth_rt_key AS ord_hdr_usd_curncy_mth_rt_key,
  constants_defaults_main.ord_lcur_amt AS ord_lcur_amt,
  constants_defaults_secondary.strg_loc_cd AS strg_loc_cd,
  constants_defaults_main.req_strg_loc_cd AS req_strg_loc_cd,
  constants_defaults_main.ord_line_ship_nlt_dt_key AS ord_line_ship_nlt_dt_key,
  materials_quantity.ord_qty AS ord_qty,
  constants_defaults_main.orig_proms_dt_key AS orig_proms_dt_key,
  constants_defaults_main.plant_key AS plant_key,
  constants_defaults_main.plant_cd AS plant_cd,
  constants_defaults_main.plant_nm AS plant_nm,
  item_details.prod_key AS prod_key,
  item_details.sku AS sku,
  item_description_mapping.sku_nm AS sku_nm,
  constants_defaults_main.prod_plant_key AS prod_plant_key,
  constants_defaults_main.proms_delvr_dt_key AS proms_delvr_dt_key,
  constants_defaults_main.req_delvr_dt_key AS req_delvr_dt_key,
  constants_defaults_main.revnu_div AS revnu_div,
  constants_defaults_main.ord_rls_dt_key AS ord_rls_dt_key,
  constants_defaults_main.ship_qty AS ship_qty,
  constants_defaults_main.ship_to_cust_key AS ship_to_cust_key,
  customer_order_details.ship_to_cust_id AS ship_to_cust_id,
  constants_defaults_main.ship_to_cust_nm AS ship_to_cust_nm,
  constants_defaults_main.ship_to_cntry_hier_key AS ship_to_cntry_hier_key,
  constants_defaults_main.sls_ord_key AS sls_ord_key,
  constants_defaults_secondary.sold_to_cust_key AS sold_to_cust_key,
  constants_defaults_secondary.sold_to_cust_id AS sold_to_cust_id,
  constants_defaults_secondary.sold_to_cust_nm AS sold_to_cust_nm,
  constants_defaults_secondary.target_qty AS target_qty,
  constants_defaults_secondary.unit_std_cost AS unit_std_cost,
  constants_defaults_main.cur_ord_stat_cd AS cur_ord_stat_cd,
  constants_defaults_main.cur_ord_stat_nm AS cur_ord_stat_nm,
  constants_defaults_main.next_ord_stat_cd AS next_ord_stat_cd,
  constants_defaults_main.next_ord_stat_nm AS next_ord_stat_nm,
  constants_defaults_main.hdr_bill_block_cd AS hdr_bill_block_cd,
  constants_defaults_main.hdr_bill_block_nm AS hdr_bill_block_nm,
  constants_defaults_main.hdr_delvr_block_cd AS hdr_delvr_block_cd,
  constants_defaults_main.hdr_delvr_block_nm AS hdr_delvr_block_nm,
  constants_defaults_main.bill_block_cd AS bill_block_cd,
  constants_defaults_main.bill_block_nm AS bill_block_nm,
  constants_defaults_main.delvr_block_cd AS delvr_block_cd,
  constants_defaults_main.delvr_block_nm AS delvr_block_nm,
  constants_defaults_main.overall_stat_cd AS overall_stat_cd,
  constants_defaults_main.overall_stat_nm AS overall_stat_nm,
  constants_defaults_main.reject_rsn_cd AS reject_rsn_cd,
  constants_defaults_main.reject_rsn_nm AS reject_rsn_nm,
  constants_defaults_main.ord_type_cd AS ord_type_cd,
  order_type_mapping.ord_type_nm AS ord_type_nm,
  constants_defaults_main.ord_overall_stat_cd AS ord_overall_stat_cd,
  constants_defaults_main.ord_overall_stat_nm AS ord_overall_stat_nm,
  constants_defaults_main.hdr_ord_type_cd AS hdr_ord_type_cd,
  constants_defaults_main.hdr_ord_type_nm AS hdr_ord_type_nm,
  constants_defaults_main.bo_stat_nm AS bo_stat_nm,
  constants_defaults_main.commit_dt_key AS commit_dt_key,
  constants_defaults_main.proms_ship_dt_key AS proms_ship_dt_key,
  constants_defaults_main.sched_ship_dt_key AS sched_ship_dt_key,
  constants_defaults_main.cust_key AS cust_key,
  constants_defaults_main.sls_rep_cust_key AS sls_rep_cust_key,
  constants_defaults_main.po_nbr AS po_nbr,
  constants_defaults_main.po_line_nbr AS po_line_nbr,
  business_unit_mapping.bu_cd AS bu_cd,
  constants_defaults_main.sls_terr_cd AS sls_terr_cd,
  constants_defaults_main.cost_curncy_cd AS cost_curncy_cd,
  constants_defaults_secondary.uom_cd AS uom_cd,
  amounts_pricing_equations.prc_per_unit_amt AS prc_per_unit_amt,
  order_pricing_equations.ord_prc_per_unit_amt AS ord_prc_per_unit_amt,
  constants_defaults_main.disc_amt AS disc_amt,
  work_order_pricing.ord_txn_curncy_amt AS ord_txn_curncy_amt,
  product_line_mapping.prod_line_cd AS prod_line_cd,
  constants_defaults_main.proj_cd AS proj_cd,
  cost_centre_mapping.cost_center_cd AS cost_center_cd
  FROM address_customer_mapping CROSS JOIN amounts_pricing_equations CROSS JOIN business_relation_customer_name CROSS JOIN business_unit_mapping CROSS JOIN company_code_mapping CROSS JOIN company_details CROSS JOIN constants_defaults_main CROSS JOIN constants_defaults_secondary CROSS JOIN cost_centre_mapping CROSS JOIN customer_mapping_debtor CROSS JOIN customer_order_details CROSS JOIN daily_open_order_key CROSS JOIN item_description_mapping CROSS JOIN item_details CROSS JOIN materials_quantity CROSS JOIN order_pricing_equations CROSS JOIN order_type_mapping CROSS JOIN product_line_mapping CROSS JOIN sales_order_line_mapping CROSS JOIN work_order_pricing
),
fact_daily_open_order_oo_rma AS (
  SELECT
  daily_open_order_key_generation_2.dly_open_ord_key AS dly_open_ord_key,
  sales_order_master_data.src_sys_cd AS src_sys_cd,
  constants_and_defaults_large.as_of_dt_key AS as_of_dt_key,
  sales_order_master_data.sls_ord_nbr AS sls_ord_nbr,
  sales_order_line_data.sls_ord_line_nbr AS sls_ord_line_nbr,
  constants_and_defaults_large.dw_src_cd AS dw_src_cd,
  constants_and_defaults_large.dw_dly_open_ord_key AS dw_dly_open_ord_key,
  constants_and_defaults_large.src_crt_by AS src_crt_by,
  sales_order_master_data.src_crt_ts AS src_crt_ts,
  constants_and_defaults_large.src_updt_by AS src_updt_by,
  constants_and_defaults_large.src_updt_ts AS src_updt_ts,
  constants_and_defaults_large.rec_crt_ts AS rec_crt_ts,
  constants_and_defaults_large.rec_updt_ts AS rec_updt_ts,
  sales_order_master_data.bill_to_cust_key AS bill_to_cust_key,
  sales_order_master_data.bill_to_cust_id AS bill_to_cust_id,
  customer_business_relation.bill_to_cust_nm AS bill_to_cust_nm,
  constants_and_defaults_large.bo_co_curncy_amt AS bo_co_curncy_amt,
  constants_and_defaults_large.bo_flg AS bo_flg,
  constants_and_defaults_large.bo_lcur_amt AS bo_lcur_amt,
  constants_and_defaults_large.bo_qty AS bo_qty,
  constants_and_defaults_large.ccg_lcd_chnl AS ccg_lcd_chnl,
  constants_and_defaults_large.ccg_lcd_vndr_nbr AS ccg_lcd_vndr_nbr,
  constants_and_defaults_large.contact_key AS contact_key,
  constants_and_defaults_large.co_usd_curncy_mth_rt_key AS co_usd_curncy_mth_rt_key,
  site_master_data.co_key AS co_key,
  site_and_sales_order_data.co_cd AS co_cd,
  site_master_data.co_nm AS co_nm,
  constants_and_defaults_large.co_curncy_cd AS co_curncy_cd,
  constants_and_defaults_large.cur_lot_nbr AS cur_lot_nbr,
  constants_and_defaults_large.cust_po_nbr AS cust_po_nbr,
  constants_and_defaults_large.derived_prod_key AS derived_prod_key,
  constants_and_defaults_large.derived_sku AS derived_sku,
  constants_and_defaults_large.derived_sku_nm AS derived_sku_nm,
  constants_and_defaults_large.expect_ship_dt_key AS expect_ship_dt_key,
  constants_and_defaults_large.fin_bo_co_curncy_amt AS fin_bo_co_curncy_amt,
  constants_and_defaults_large.fin_bo_lcur_amt AS fin_bo_lcur_amt,
  constants_and_defaults_large.fin_bo_qty AS fin_bo_qty,
  constants_and_defaults_large.fin_ord_line_complt_flg AS fin_ord_line_complt_flg,
  constants_and_defaults_large.hfm_entity_key AS hfm_entity_key,
  constants_and_defaults_large.hfm_entity_cd AS hfm_entity_cd,
  constants_and_defaults_large.invc_qty AS invc_qty,
  constants_and_defaults_large.mtl_avbl_dt_key AS mtl_avbl_dt_key,
  constants_and_defaults_large.ord_co_curncy_amt AS ord_co_curncy_amt,
  sales_order_master_data.ord_curncy_cd AS ord_curncy_cd,
  sales_order_master_data.ord_dt_key AS ord_dt_key,
  constants_and_defaults_large.ord_hdr_usd_curncy_mth_rt_key AS ord_hdr_usd_curncy_mth_rt_key,
  constants_and_defaults_large.ord_lcur_amt AS ord_lcur_amt,
  constants_and_defaults_large.strg_loc_cd AS strg_loc_cd,
  constants_and_defaults_large.req_strg_loc_cd AS req_strg_loc_cd,
  constants_and_defaults_large.ord_line_ship_nlt_dt_key AS ord_line_ship_nlt_dt_key,
  order_quantity_calculation.ord_qty AS ord_qty,
  constants_and_defaults_large.orig_proms_dt_key AS orig_proms_dt_key,
  constants_and_defaults_large.plant_key AS plant_key,
  constants_and_defaults_large.plant_cd AS plant_cd,
  constants_and_defaults_large.plant_nm AS plant_nm,
  sales_order_detail_data.prod_key AS prod_key,
  sku_data_combination.sku AS sku,
  product_description_data.sku_nm AS sku_nm,
  constants_and_defaults_large.prod_plant_key AS prod_plant_key,
  constants_and_defaults_large.proms_delvr_dt_key AS proms_delvr_dt_key,
  constants_and_defaults_large.req_delvr_dt_key AS req_delvr_dt_key,
  constants_and_defaults_large.revnu_div AS revnu_div,
  constants_and_defaults_large.ord_rls_dt_key AS ord_rls_dt_key,
  constants_and_defaults_large.ship_qty AS ship_qty,
  constants_and_defaults_large.ship_to_cust_key AS ship_to_cust_key,
  sales_order_master_data.ship_to_cust_id AS ship_to_cust_id,
  constants_and_defaults_large.ship_to_cust_nm AS ship_to_cust_nm,
  constants_and_defaults_large.ship_to_cntry_hier_key AS ship_to_cntry_hier_key,
  constants_and_defaults_large.sls_ord_key AS sls_ord_key,
  constants_and_defaults_large.sold_to_cust_key AS sold_to_cust_key,
  constants_and_defaults_large.sold_to_cust_id AS sold_to_cust_id,
  constants_and_defaults_large.sold_to_cust_nm AS sold_to_cust_nm,
  constants_and_defaults_large.target_qty AS target_qty,
  constants_and_defaults_large.unit_std_cost AS unit_std_cost,
  constants_and_defaults_large.cur_ord_stat_cd AS cur_ord_stat_cd,
  constants_and_defaults_large.cur_ord_stat_nm AS cur_ord_stat_nm,
  constants_and_defaults_large.next_ord_stat_cd AS next_ord_stat_cd,
  constants_and_defaults_large.next_ord_stat_nm AS next_ord_stat_nm,
  constants_and_defaults_large.hdr_bill_block_cd AS hdr_bill_block_cd,
  constants_and_defaults_large.hdr_bill_block_nm AS hdr_bill_block_nm,
  constants_and_defaults_large.hdr_delvr_block_cd AS hdr_delvr_block_cd,
  constants_and_defaults_large.hdr_delvr_block_nm AS hdr_delvr_block_nm,
  constants_and_defaults_large.bill_block_cd AS bill_block_cd,
  constants_and_defaults_large.bill_block_nm AS bill_block_nm,
  constants_and_defaults_large.delvr_block_cd AS delvr_block_cd,
  constants_and_defaults_large.delvr_block_nm AS delvr_block_nm,
  constants_and_defaults_large.overall_stat_cd AS overall_stat_cd,
  constants_and_defaults_large.overall_stat_nm AS overall_stat_nm,
  constants_and_defaults_large.reject_rsn_cd AS reject_rsn_cd,
  constants_and_defaults_large.reject_rsn_nm AS reject_rsn_nm,
  constants_and_defaults_large.ord_type_cd AS ord_type_cd,
  order_type_classification.ord_type_nm AS ord_type_nm,
  constants_and_defaults_large.ord_overall_stat_cd AS ord_overall_stat_cd,
  constants_and_defaults_large.ord_overall_stat_nm AS ord_overall_stat_nm,
  constants_and_defaults_large.hdr_ord_type_cd AS hdr_ord_type_cd,
  constants_and_defaults_large.hdr_ord_type_nm AS hdr_ord_type_nm,
  constants_and_defaults_large.bo_stat_nm AS bo_stat_nm,
  constants_and_defaults_large.commit_dt_key AS commit_dt_key,
  constants_and_defaults_large.proms_ship_dt_key AS proms_ship_dt_key,
  constants_and_defaults_small.sched_ship_dt_key AS sched_ship_dt_key,
  constants_and_defaults_small.cust_key AS cust_key,
  constants_and_defaults_small.sls_rep_cust_key AS sls_rep_cust_key,
  constants_and_defaults_small.po_nbr AS po_nbr,
  constants_and_defaults_small.po_line_nbr AS po_line_nbr,
  business_unit_mapping_2.bu_cd AS bu_cd,
  constants_and_defaults_small.sls_terr_cd AS sls_terr_cd,
  constants_and_defaults_small.cost_curncy_cd AS cost_curncy_cd,
  unit_of_measure_data.uom_cd AS uom_cd,
  sales_order_detail_data.prc_per_unit_amt AS prc_per_unit_amt,
  sales_order_detail_data.ord_prc_per_unit_amt AS ord_prc_per_unit_amt,
  constants_and_defaults_small.disc_amt AS disc_amt,
  order_transaction_currency_amount.ord_txn_curncy_amt AS ord_txn_curncy_amt,
  product_line_mapping_2.prod_line_cd AS prod_line_cd,
  constants_and_defaults_small.proj_cd AS proj_cd,
  cost_center_data.cost_center_cd AS cost_center_cd
  FROM business_unit_mapping_2 CROSS JOIN constants_and_defaults_large CROSS JOIN constants_and_defaults_small CROSS JOIN cost_center_data CROSS JOIN customer_business_relation CROSS JOIN daily_open_order_key_generation_2 CROSS JOIN order_quantity_calculation CROSS JOIN order_transaction_currency_amount CROSS JOIN order_type_classification CROSS JOIN product_description_data CROSS JOIN product_line_mapping_2 CROSS JOIN sales_order_detail_data CROSS JOIN sales_order_line_data CROSS JOIN sales_order_master_data CROSS JOIN site_and_sales_order_data CROSS JOIN site_master_data CROSS JOIN sku_data_combination CROSS JOIN unit_of_measure_data
),
f_dly_open_order_all AS (
  SELECT * FROM fact_daily_open_order_uisc
  UNION ALL
  SELECT * FROM fact_daily_open_order_uiscall
  UNION ALL
  SELECT * FROM fact_daily_open_order_oo_rma
)
SELECT
  dly_open_ord_key,
  src_sys_cd,
  as_of_dt_key,
  sls_ord_nbr,
  sls_ord_line_nbr,
  dw_src_cd,
  dw_dly_open_ord_key,
  src_crt_by,
  src_crt_ts,
  src_updt_by,
  src_updt_ts,
  rec_crt_ts,
  rec_updt_ts,
  bill_to_cust_key,
  bill_to_cust_id,
  bill_to_cust_nm,
  bo_co_curncy_amt,
  bo_flg,
  bo_lcur_amt,
  bo_qty,
  ccg_lcd_chnl,
  ccg_lcd_vndr_nbr,
  contact_key,
  co_usd_curncy_mth_rt_key,
  co_key,
  co_cd,
  co_nm,
  co_curncy_cd,
  cur_lot_nbr,
  cust_po_nbr,
  derived_prod_key,
  derived_sku,
  derived_sku_nm,
  expect_ship_dt_key,
  fin_bo_co_curncy_amt,
  fin_bo_lcur_amt,
  fin_bo_qty,
  fin_ord_line_complt_flg,
  hfm_entity_key,
  hfm_entity_cd,
  invc_qty,
  mtl_avbl_dt_key,
  ord_co_curncy_amt,
  ord_curncy_cd,
  ord_dt_key,
  ord_hdr_usd_curncy_mth_rt_key,
  ord_lcur_amt,
  strg_loc_cd,
  req_strg_loc_cd,
  ord_line_ship_nlt_dt_key,
  ord_qty,
  orig_proms_dt_key,
  plant_key,
  plant_cd,
  plant_nm,
  prod_key,
  sku,
  sku_nm,
  prod_plant_key,
  proms_delvr_dt_key,
  req_delvr_dt_key,
  revnu_div,
  ord_rls_dt_key,
  ship_qty,
  ship_to_cust_key,
  ship_to_cust_id,
  ship_to_cust_nm,
  ship_to_cntry_hier_key,
  sls_ord_key,
  sold_to_cust_key,
  sold_to_cust_id,
  sold_to_cust_nm,
  target_qty,
  unit_std_cost,
  cur_ord_stat_cd,
  cur_ord_stat_nm,
  next_ord_stat_cd,
  next_ord_stat_nm,
  hdr_bill_block_cd,
  hdr_bill_block_nm,
  hdr_delvr_block_cd,
  hdr_delvr_block_nm,
  bill_block_cd,
  bill_block_nm,
  delvr_block_cd,
  delvr_block_nm,
  overall_stat_cd,
  overall_stat_nm,
  reject_rsn_cd,
  reject_rsn_nm,
  ord_type_cd,
  ord_type_nm,
  ord_overall_stat_cd,
  ord_overall_stat_nm,
  hdr_ord_type_cd,
  hdr_ord_type_nm,
  bo_stat_nm,
  commit_dt_key,
  proms_ship_dt_key,
  sched_ship_dt_key,
  cust_key,
  sls_rep_cust_key,
  po_nbr,
  po_line_nbr,
  bu_cd,
  sls_terr_cd,
  cost_curncy_cd,
  uom_cd,
  prc_per_unit_amt,
  ord_prc_per_unit_amt,
  disc_amt,
  ord_txn_curncy_amt,
  prod_line_cd,
  proj_cd,
  cost_center_cd
FROM f_dly_open_order_all;