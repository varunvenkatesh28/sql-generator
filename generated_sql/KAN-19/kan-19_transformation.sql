-- Query: KAN-19_transformation
-- Purpose: Generated SQL for KAN-19 via 7-stage pipeline
-- Query Type: SELECT

WITH uom_conversion_view AS (
    select
        vbep.vbeln as vbeln,
        vbep.posnr as posnr,
        vbep.etenr as etenr,
        vbep.edatu as edatu,
        vbep.bmeng as bmeng,
        vbap.wavwr as wavwr,
        vbap.netwr as netwr,
        vbap.netpr as netpr,
        vbap.kpein as kpein,
        if(vbap.meins = vbap.kmein,'yes','no') as uom_check,
        (marm.umrez / marm.umren) as conversion_factor,
        case
            when vbep.vrkme = vbap.meins 
            then vbep.bmeng
            else (marm.umrez / marm.umren)* vbep.bmeng
        end as order_qty,
        mbew.vprsv,
        mbew.verpr,
        mbew.stprs,
        case
            when (mbew.peinh is null or mbew.peinh = 0)
            then 1
            else mbew.peinh
        end as currency_factor,
        case when trim(mbew.vprsv) = 'V'
            then round(if(t001.waers in('KRW', 'JPY'),mbew.verpr*100,mbew.verpr)/currency_factor,2)
            when trim(mbew.vprsv) = 'S' 
            then round(if(t001.waers in('KRW', 'JPY'),mbew.stprs*100,mbew.stprs)/currency_factor,2)
        end as company_currency_derive,
        vbap.kwmeng
    from vbep
    left outer join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
    left outer join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
    left outer join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey and mbew.mandt = '100' and trim(mbew.bwtar)=''
    left outer join vbak on vbep.vbeln = vbak.vbeln
    left outer join t001 on t001.bukrs = vbak.bukrs_vf
),
uom_conversion AS (
    select 
        vbeln,
        posnr,
        etenr,
        edatu,
        bmeng,
        order_qty,
        wavwr,
        company_currency_derive,
        vbap.kwmeng,
        coalesce(case 
                    when uom_check = 'yes' 
                    then if(netpr=0,netwr/kwmeng,(netpr/kpein))
                    else if(netpr=0,netwr/kwmeng,(netpr/kpein)/conversion_factor)
                end,0) as price_uom
    from uom_conversion_view
),
sales_order_detail_cte AS (
    select
        concat('gbl', g_order_company_cd) as co_key,
        case 
            when mska.sobkz is not null then 
                cast(
                    coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)
                    as string
                )
            else g_shipped_qty_primary_uom
        end as g_allocated_qty_primary_uom,
        cast(null as date) as g_availability_dt_yyyymmdd,
        case 
            when vbap.kunnr is not null then vbap.kunnr
            else null
        end as g_bill_to_customer_nbr,
        case 
            when vbap.aedat = 0 then vbap.erdat
            else vbap.aedat
        end as g_cancel_dt_yyyymmdd,
        cast(null as string) as g_cancel_qty_primary_uom,
        case 
            when t001.waers = 'RMB' then 'CNY'
            else t001.waers
        end as g_company_currency_cd,
        vbap.kdmat as g_customer_item_nbr,
        'NULL' as g_customer_po_line_nbr,
        case 
            when vbkd.bstkd is not null then vbkd.bstkd
            else null
        end as g_customer_po_nbr,
        case 
            when vbkd.bsark is not null then vbkd.bsark
            else null
        end as g_customer_po_type,
        case 
            when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
            when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') then trim(vbep.request_dt)
            else vbep.edatu
        end as g_customer_request_dt_yyyymmdd,
        vbep.etenr as g_delivery_schedule_line_nbr,
        case 
            when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
            else 'no'
        end as g_flag_consignment_order,
        case 
            when vbap.uepos is not null and vbap.uepos != 0 then 'yes'
            else 'no'
        end as g_flag_has_parent,
        case 
            when mska.sobkz = 'E' and (coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)) > 0 then 'yes'
            else 'no'
        end as g_flag_inventory_fully_allocated,
        case 
            when vbap.posnr = vbap.uepos then 'yes'
            else 'no'
        end as g_flag_is_parent,
        case 
            when vbak.kunnr in (select kna1.kunnr from kna1 where kna1.ktokd in ('ZSUB', 'IC3P')) then 'yes'
            when knvv.kdgrp in ('05', '06', '07') then 'yes'
            else 'no'
        end as g_flag_is_transfer_order,
        case 
            when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
            when trim(vbup.lfsta) in ('A', 'B', 'C') and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') then 'no'
            when trim(vbup.lfsta) = '' or vbup.lfsta is null then 'no'
            else 'yes'
        end as g_flag_material_transacted,
        case 
            when vbep.lifsp != '' then 'yes'
            when vbak.lifsk != '' then 'yes'
            when vbuk.cmgst in ('B', 'C') then 'yes'
            else 'no'
        end as g_flag_on_hold,
        case 
            when vbak.autlf = 'X' then 'no'
            when cancel_qty_primary_uom = order_qty_primary_uom then 'no'
            when open_qty_primary_uom <= 0 then 'no'
            else 'yes'
        end as g_flag_open_to_ship,
        case 
            when vbak.vbtyp in ('H', 'T') then 'yes'
            else 'no'
        end as g_flag_return,
        case 
            when order_qty_primary_uom = 0 then 'no'
            when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
            when trim(tvap.prsfd) = 'X' then 'yes'
            else 'no'
        end as g_flag_revenue_recognition,
        vbkd.inco1 as g_inco_terms,
        vbfa.erdat as g_invoice_dt_yyyymmdd,
        vbap.matnr as g_item_nbr,
        cast(null as date) as g_last_actual_ship_dt_yyyymmdd,
        case 
            when upper(trim(vbup.gbsta)) = 'A' then 'NOT YET PROCESSED'
            when upper(trim(vbup.gbsta)) = 'B' then 'PARTIALLY PROCESSED'
            when upper(trim(vbup.gbsta)) = 'C' then 'COMPLETELY PROCESSED'
            else 'NOT RELEVANT'
        end as g_line_status_cd,
        case 
            when order_type = 'DEMO' and ship_lines.sttrg = '7' then 0
            when tvap.fkrel in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') then round(coalesce(order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0), 4)
            when trim(tvap.fkrel) = '' then 0
            else round(coalesce(order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0), 0)
        end as g_open_qty_primary_uom,
        vbap.erdat as g_order_dt_yyyymmdd,
        vbep.bmeng as g_order_qty_order_uom,
        vbep.bmeng as g_order_qty_primary_uom,
        vbap.vrkme as g_order_uom_cd,
        vbap.meins as g_primary_uom_cd,
        vbep.edatu as g_promised_ship_dt_yyyymmdd,
        vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
        vbpa.kunnr as g_ship_to_customer_nbr,
        case 
            when g_order_qty_primary_uom = 0 then 0
            else datediff(vbep.mbdat, vbep.edatu)
        end as g_ship_to_delivery_days,
        tvsbt.vtext as g_shipment_mode,
        v1.qty as g_shipped_qty_primary_uom,
        'GBL' as g_source_system_cd,
        case 
            when trim(mbew.vprsv) = 'V' then round(if(t001.waers in ('KRW', 'JPY'), mbew.verpr * 100, mbew.verpr) / currency_factor, 2)
            when trim(mbew.vprsv) = 'S' then round(if(t001.waers in ('KRW', 'JPY'), mbew.stprs * 100, mbew.stprs) / currency_factor, 2)
        end as g_unit_cost_company_currency_primary_uom,
        case 
            when trim(vbap.waerk) = trim(t001.waers) then if(trim(vbap.waerk) = 'JPY', puom.price_uom * 100 * coalesce(vbkd.kursk, vbkd_derived.kursk), puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact)
            else puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk) * (tcurf.tfact / tcurf.ffact)
        end as g_unit_price_company_currency_primary_uom,
        case 
            when vbep.vrkme = vbap.meins then vbep.bmeng
            else (marm.umrez / marm.umren) * vbep.bmeng
        end as g_unit_price_order_currency_primary_uom,
        concat('gbl', g_plant_cd) as plant_key,
        concat('gbl', g_item_nbr) as prod_key,
        concat('gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
        concat('gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
        concat('gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key
    from vbep
    left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
    left join vbak on vbep.vbeln = vbak.vbeln
    left join vbuk on vbep.vbeln = vbuk.vbeln
    left join t001 on t001.bukrs = vbak.bukrs_vf
    left join tcurf on trim(vbap.waerk) = trim(tcurf.fcurr) and trim(t001.waers) = trim(tcurf.tcurr)
    left join mska on vbep.vbeln = mska.vbeln and vbep.posnr = mska.posnr
    left join vbup on vbep.vbeln = vbup.vbeln and vbep.posnr = vbup.posnr
    left join vbkd on vbep.vbeln = vbkd.vbeln and vbep.posnr = vbkd.posnr
    left join tvap on vbap.pstyv = tvap.pstyv
    left join t001w on vbap.werks = t001w.werks
    left join t001k on t001k.bwkey = t001w.bwkey
    left join uom_conversion puom on vbep.vbeln = puom.vbeln and vbep.posnr = puom.posnr and vbep.etenr = puom.etenr
    left join kna1 on vbak.kunnr = kna1.kunnr
    left join knvv on vbak.kunnr = knvv.kunnr and vbak.vkorg = knvv.vkorg and vbak.vtweg = knvv.vtweg and vbak.spart = knvv.spart
    left join f_sls_ord_sched sls on sls.order_nbr = vbep.vbeln and sls.order_line_nbr = vbep.posnr and sls.delivery_schedule_line_nbr = vbep.etenr and sls.src_sys_cd = 'gbl'
)
SELECT * FROM sales_order_detail_cte;