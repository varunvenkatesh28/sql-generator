/**********************************************************************
artefact name :- d_customer
description   :- d_customer sql generated from mapping
----------------------------------------------------------------------
change log
version :   date :        description :                       changed by
----------------------------------------------------------------------
0.0         2026-08-31    auto-generated from mapping         ai_agent
**********************************************************************/

with ad_cte as (
    select *
    from ad_mstr ad
    where lower(ad.ad_domain) = lower(cm.cm_domain) and ad.ad_addr = cm.cm_addr
)

select
    concat('msd_qad_', lower(ad_mstr.ad_domain)) || '|' || ad_mstr.ad_addr as cust_key,
    concat('msd_qad_', lower(ad_mstr.ad_domain)) || '|' || ad_mstr.ad_addr as src_sys_cd,
    cm_mstr.cm_addr as cust_id,
    ad_mstr.ad_name as cust_nm,
    ad_mstr.ad_name as cust_nm_en,
    ad_mstr.ad_type as cust_type_cd,
    ad_mstr.ad_type as cust_type_nm,
    cast(null as string) as active_flg,  -- TODO: no source in mapping
    cast(null as string) as parent_cust_id,  -- TODO: no source in mapping
    cast(null as string) as parent_cust_nm,  -- TODO: no source in mapping
    cast(null as string) as naics_cd,  -- TODO: no source in mapping
    cast(null as string) as naics_nm,  -- TODO: no source in mapping
    cast(null as string) as sic_cd,  -- TODO: no source in mapping
    cast(null as string) as sic_nm,  -- TODO: no source in mapping
    cast(null as string) as gbl_govt_id,  -- TODO: no source in mapping
    cast(null as string) as gbl_loc_nbr,
    cast(null as string) as dnb_duns_nm,
    cast(null as string) as alt_payer_cust_id,
    cast(null as string) as annl_sls_amt,
    cast(null as string) as central_bill_block_cd,
    cast(null as string) as central_bill_block_nm,
    cast(null as string) as central_delvr_block_cd,
    cast(null as string) as central_delvr_block_nm,
    cast(null as string) as central_ord_block_cd,
    cast(null as string) as central_ord_block_nm,
    cast(null as string) as cust_acct_grp_cd,
    cast(null as string) as cust_acct_grp_nm,
    cast(null as string) as cust_class_cd,
    cast(null as string) as cust_class_nm,
    cm.cm_curr as curncy_cd,
    currency.currencydescription as curncy_nm,
    cast(null as string) as indy_cd,  -- TODO: no source in mapping
    cast(null as string) as indy_nm,  -- TODO: no source in mapping
    cast(null as string) as intl_loc_nbr_check_digit,  -- TODO: no source in mapping
    ad_mstr.ad_lang as lang_cd,
    cast(null as string) as lang_iso_cd,  -- TODO: no source in mapping
    cast(null as string) as lang_nm,  -- TODO: no source in mapping
    cast(null as string) as lgl_stat_cd,  -- TODO: no source in mapping
    cast(null as string) as lgl_stat_nm,  -- TODO: no source in mapping
    cast(null as string) as rgn_mkt,  -- TODO: no source in mapping
    cast(null as string) as sls_since_yr,  -- TODO: no source in mapping
    ad_mstr.ad_sort as sort_field,
    ad_mstr.ad_tax_usage as tax_juris_cd,
    cast(null as string) as tax_juris_nm,  -- TODO: no source in mapping
    cast(null as string) as teletex_nbr,  -- TODO: no source in mapping
    cast(null as string) as telex_nbr,
    cast(null as string) as title,
    cast(null as string) as transp_zone_cd,
    cast(null as string) as transp_zone_nm,
    cast(null as string) as trading_prtnr_co_cd,
    cast(null as string) as url,
    cast(null as string) as unload_point_flg,
    ad.ad_vat_reg as vat_regstr_nbr,
    cast(null as string) as central_del_block_flg,
    cast(null as string) as central_del_flg,
    cast(null as string) as central_post_block_flg,
    cast(null as string) as central_sls_block_flg,
    cast(null as string) as cmptr_flg,
    cast(null as string) as natural_pers_flg,
    cast(null as string) as one_time_cust_flg,
    cast(null as string) as sls_prtnr_flg,
    cast(null as string) as sls_prospect_flg,
    ad_mstr.ad_address_id as addr_key,
    ad_mstr.ad_line2 as street_line,
    ad_mstr.ad_zip as pstl_cd,
    ad_mstr.ad_city as city,
    cast(null as string) as city_coord,
    cast(null as string) as po_box,
    cast(null as string) as po_box_pstl_cd,
    cast(null as string) as district,
    ad_mstr.ad_state as st_prov_cd,
    cast(null as string) as st_prov_nm,
    ad_mstr.ad_ctry as cntry_cd,
    ad_mstr.ad_country as cntry_nm,
    ad_mstr.ad_fax as fax_nbr,
    cast(null as string) as trading_prtnr_co_nm,
    cast(null as string) as prim_contact_key,
    cast(null as string) as dnb_duns_nbr,
    ad_mstr.ad_line1 as addr_nm_line2,
    ad_mstr.ad_line2 as addr_nm_line3,
    ad_mstr.ad_line3 as addr_nm_line4,
    cast(null as string) as cust_cond_grp_cd1,
    cast(null as string) as cust_cond_grp_cd2,
    cast(null as string) as cust_cond_grp_nm1,
    cast(null as string) as cust_cond_grp_nm2,
    ad_mstr.ad_email as cust_email_addr_txt,
    cast(null as string) as cust_rept_hier_base,
    cast(null as string) as dw_src_key,
    cast(null as string) as indy_cd1,
    cast(null as string) as indy_cd2,
    cast(null as string) as indy_nm1,
    cast(null as string) as indy_nm2,
    cast(null as string) as intl_loc_nbr1,
    cast(null as string) as intl_loc_nbr2,
    ad_mstr.ad_phone as phn_nbr1,
    ad_mstr.ad_phone2 as phn_nbr2,
    cast(null as string) as search_mcode1,
    cast(null as string) as search_mcode2,
    cast(null as string) as search_mcode3,
    cast(null as string) as sply_center_cd,
    cast(null as string) as sply_center_flg,
    cast(null as string) as sply_center_nm,
    ad_mstr.ad_pst_id as tax_nbr1,
    cast(null as string) as tax_nbr2,
    cast(null as string) as tax_nbr3,
    cast(null as string) as src_crt_by,
    ad_mstr.ad_date as src_crt_ts,
    ad_mstr.ad_userid as src_updt_by,
    cm_mstr.cm_mod_date as src_updt_ts,
    current_timestamp as rec_crt_ts,
    current_timestamp as rec_updt_ts,
    cast(null as string) as stock_ticker_cd,
    cast(null as string) as cdw_cust_key,
    cast(null as string) as dw_cust_key,
    cast(null as string) as addr_phn_nbr,
    ad_mstr.ad_fax2 as addr_fax_nbr,
    cast(null as string) as sls_chnl_cd,
    cast(null as string) as sls_terr_cd,
    cast(null as string) as sls_rep_cust_key,
    cast(null as string) as addr_type_cd,
    cast(null as string) as hfm_entity_key,
    cast(null as string) as hfm_entity_cd,
    d_cntry_hier.cntry_hier_key as deflt_delvr_cntry_key,
    ad_mstr.ad_ctry as deflt_delvr_cntry_cd,
    cast(null as string) as trade_chnl_cd,
    case when ad_mstr.ad_addr like 'Z%' or ad_mstr.ad_addr like 'TM%' then 'IC' else '3rd' end as inter_co_cd,
    cast(null as string) as county,
    cast(null as string) as temporary_flag,
    cast(null as string) as bank_acct_1,
    cast(null as string) as ad_bk_acct2,
    cast(null as string) as ad_format,
    cast(null as string) as coc_number,
    cast(null as string) as tax_id_federal,
    cast(null as string) as tax_type,
    cast(null as string) as tax_class_code,
    cast(null as string) as taxable_flag,
    cast(null as string) as tax_in_flag,
    cast(null as string) as netting_logic,
    cast(null as string) as trading_prtnr_interface_id,
    cast(null as string) as edi_control,
    cast(null as string) as time_zone,
    cast(null as string) as trading_prtnr_edi_id,
    cast(null as string) as barcode_label_print_program,
    cast(null as string) as barcode_validation_program,
    cast(null as string) as calendar,
    cast(null as string) as edi_standard,
    cast(null as string) as edi_standard_level,
    cast(null as string) as ad_qad01,
    cast(null as string) as ad_qad02,
    cast(null as string) as ad_qad03,
    cast(null as string) as ad_qad04,
    cast(null as string) as ad_qad05,
    cast(null as string) as ad_chr01,
    cast(null as string) as ad_chr02,
    cast(null as string) as ad_chr03,
    cast(null as string) as ad_chr04,
    cast(null as string) as ad_chr05,
    cast(null as string) as trd_partner_location_code,
    cast(null as string) as tax_zone,
    cast(null as string) as tax_id_misc_1,
    cast(null as string) as tax_id_misc_2,
    cast(null as string) as tax_id_misc_3,
    cast(null as string) as week_offset,
    cast(null as string) as invoices_via,
    cast(null as string) as schedules_via,
    cast(null as string) as purchase_orders_via,
    cast(null as string) as asn_default_data,
    cast(null as string) as intrastat_division,
    cast(null as string) as tax_report_flag,
    cast(null as string) as name_control,
    cast(null as string) as last_filing_flag,
    cast(null as string) as ad_email2,
    cast(null as string) as priority,
    cast(null as string) as route,
    cast(null as string) as load_sequence,
    cast(null as string) as pick_by_date,
    cast(null as string) as profile,
    cast(null as string) as tac_in_city_flag,
    cast(null as string) as non_sales_price_list,
    cast(null as string) as business_relation,
    cast(null as string) as alternate_um,
    cast(null as string) as city_code,
    'NA' as crt_proc_id,
    'NA' as crt_proc_ts,
    'NA' as updt_proc_id,
    'NA' as updt_proc_ts
from cm_mstr cm
inner join ad_cte ad on lower(ad.ad_domain) = lower(cm.cm_domain) and ad.ad_addr = cm.cm_addr
left join currency currency on cm.cm_curr = currency.curr_code
left join d_cntry_hier d_cntry_hier on cm.cm_cntry = d_cntry_hier.cntry_code;