-- Query: KAN-18_transformation
-- Purpose: Generated SQL for KAN-18 via 7-stage pipeline
-- Query Type: SELECT

WITH sales_order_detail_cte AS (
    SELECT
        -- Field 1
        CONCAT('gbl', g_order_company_cd) AS co_key,
        -- Field 2
        vbap.kdmat AS g_customer_item_nbr,
        -- Field 3
        CAST(NULL AS STRING) AS g_customer_po_line_nbr,
        -- Field 4
        vbkd.bsark AS g_customer_po_type,
        -- Field 5
        CASE WHEN VBAK.VBTYP IN ('H', 'T') THEN 'Yes' ELSE 'No' END AS g_flag_return,
        -- Field 6
        VBAP.UEPOS AS g_parent_order_line_nbr,
        -- Field 7
        CONCAT('gbl', g_plant_cd) AS plant_key,
        -- Field 8
        CONCAT('gbl', g_item_nbr) AS prod_key,
        -- Field 9
        CONCAT('gbl', g_item_nbr, g_plant_cd) AS prod_plant_key,
        -- Field 10
        CONCAT('gbl', g_order_company_cd, g_order_type, g_order_nbr) AS sls_ord_key,
        -- Field 11
        CONCAT('gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) AS sls_ord_sched_key,
        -- Field 12
        CAST(NULL AS STRING) AS g_customer_po_line,
        -- Field 13
        CAST(NULL AS STRING) AS g_customer_po_type,
        -- Field 14
        CAST(NULL AS STRING) AS g_customer_item_nbr,
        -- Field 15
        CAST(NULL AS STRING) AS g_flag_return,
        -- Field 16
        CAST(NULL AS STRING) AS g_parent_order_line_nbr,
        -- Field 17
        CAST(NULL AS STRING) AS sls_ord_sched_key,
        -- Field 18
        CAST(NULL AS STRING) AS sls_ord_key,
        -- Field 19
        CAST(NULL AS STRING) AS prod_plant_key,
        -- Field 20
        CAST(NULL AS STRING) AS plant_key,
        -- Field 21
        CAST(NULL AS STRING) AS prod_key,
        -- Field 22
        CAST(NULL AS STRING) AS co_key
    FROM vbap
    LEFT JOIN vbkd ON vbap.vbeln = vbkd.vbeln
    LEFT JOIN VBAK ON vbap.vbeln = VBAK.vbeln
    WHERE vbap.vbeln IS NOT NULL
),
Sales_Order_Detail AS (
    SELECT
        -- Field 1
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM MSKA 
                WHERE MSKA.VBELN = VBEP.VBELN AND MSKA.POSNR = VBEP.POSNR
            ) THEN COALESCE(MSKA.KALAB, 0) + COALESCE(MSKA.KAINS, 0) + COALESCE(MSKA.KASPE, 0) + COALESCE(MSKA.KAVLA, 0) + COALESCE(MSKA.KAVIN, 0) + COALESCE(MSKA.KAVSP, 0)
            ELSE g_shipped_qty_primary_uom
        END AS g_allocated_qty_primary_uom,

        -- Field 2
        CAST(NULL AS STRING) AS g_availability_dt_yyyymmdd,

        -- Field 3
        CASE 
            WHEN VBAP.KUNNR IS NOT NULL THEN VBAP.KUNNR
            ELSE NULL
        END AS g_bill_to_customer_nbr,

        -- Field 4
        CASE 
            WHEN VBAP.AEDAT = 0 THEN VBAP.ERDAT
            ELSE VBAP.AEDAT
        END AS g_cancel_dt_yyyymmdd,

        -- Field 5
        CAST(NULL AS STRING) AS g_cancel_qty_primary_uom,

        -- Field 6
        CASE 
            WHEN T001.WAERS = 'RMB' THEN 'CNY'
            ELSE T001.WAERS
        END AS g_company_currency_cd,

        -- Field 7
        CASE 
            WHEN VBKD.BSTKD IS NOT NULL THEN VBKD.BSTKD
            ELSE NULL
        END AS g_customer_po_nbr,

        -- Field 8
        CASE 
            WHEN COALESCE(request_date.LAND1, request_date_posnr0.LAND1) NOT IN ('US', 'CA') THEN COALESCE(request_date.vdatu, request_date_posnr0.vbdatu)
            WHEN COALESCE(request_date.LAND1, request_date_posnr0.LAND1) IN ('US', 'CA') THEN TRIM(VBEP.request_dt)
            ELSE VBEP.edatu
        END AS g_customer_request_dt_yyyymmdd,

        -- Field 9
        VBEP.ETENR AS g_delivery_schedule_line_nbr,

        -- Field 10
        CASE 
            WHEN VBAP.PSTYV IN ('KBN', 'KEN', 'KAN', 'KRN') THEN 'yes'
            ELSE 'no'
        END AS g_flag_consignment_order,

        -- Field 11
        CASE 
            WHEN VBAP.UEPOS IS NOT NULL AND VBAP.UEPOS <> 0 THEN 'yes'
            ELSE 'no'
        END AS g_flag_has_parent,

        -- Field 12
        CASE 
            WHEN MSKA.SOBKZ = 'E' AND (COALESCE(MSKA.KALAB, 0) + COALESCE(MSKA.KAINS, 0) + COALESCE(MSKA.KASPE, 0) + COALESCE(MSKA.KAVLA, 0) + COALESCE(MSKA.KAVIN, 0) + COALESCE(MSKA.KAVSP, 0)) > 0 THEN 'yes'
            ELSE 'no'
        END AS g_flag_inventory_fully_allocated,

        -- Field 13
        CASE 
            WHEN VBAP.POSNR = VBAP.UEPOS THEN 'yes'
            ELSE 'no'
        END AS g_flag_is_parent,

        -- Field 14
        CASE 
            WHEN KNA1.KTOKD IN ('ZSUB', 'IC3P') THEN 'yes'
            WHEN KNVV.KDGRP IN ('05', '06', '07') THEN 'yes'
            ELSE 'no'
        END AS g_flag_is_transfer_order,

        -- Field 15
        CASE 
            WHEN TRIM(VBAK.VBTYP) IN ('A', 'B', 'D') THEN 'no'
            WHEN TRIM(VBUP.LFSTA) IN ('A', 'B', 'C') AND MARA.MTART IN ('DIEN', 'NSTK', 'SERV', 'ZSRV') THEN 'no'
            WHEN TRIM(VBUP.LFSTA) = '' OR VBUP.LFSTA IS NULL THEN 'no'
            ELSE 'yes'
        END AS g_flag_material_transacted,

        -- Field 16
        CASE 
            WHEN VBEP.LIFSP <> '' THEN 'yes'
            WHEN VBAK.LIFSK <> '' THEN 'yes'
            WHEN VBUK.CMGST IN ('B', 'C') THEN 'yes'
            ELSE 'no'
        END AS g_flag_on_hold,

        -- Field 17
        CASE 
            WHEN VBAK.AUTLF = 'X' THEN 'no'
            WHEN cancel_qty_primary_uom = order_qty_primary_uom THEN 'no'
            WHEN open_qty_primary_uom <= 0 THEN 'no'
            ELSE 'yes'
        END AS g_flag_open_to_ship,

        -- Field 18
        CASE 
            WHEN order_qty_primary_uom = 0 THEN 'no'
            WHEN TRIM(VBAK.VBTYP) IN ('A', 'B', 'D') THEN 'no'
            WHEN TRIM(TVAP.PRSFD) = 'X' THEN 'yes'
            ELSE 'no'
        END AS g_flag_revenue_recognition,

        -- Field 19
        VBKD.INCO1 AS g_inco_terms,

        -- Field 20
        CASE 
            WHEN VBFA.VBTYP = 'M' THEN VBFA.ERDAT
            ELSE NULL
        END AS g_invoice_dt_yyyymmdd,

        -- Field 21
        VBAP.MATNR AS g_item_nbr,

        -- Field 22
        CAST(NULL AS STRING) AS g_last_actual_ship_dt_yyyymmdd,

        -- Field 23
        CASE 
            WHEN UPPER(TRIM(VBUP.GBSTA)) = 'A' THEN 'NOT YET PROCESSED'
            WHEN UPPER(TRIM(VBUP.GBSTA)) = 'B' THEN 'PARTIALLY PROCESSED'
            WHEN UPPER(TRIM(VBUP.GBSTA)) = 'C' THEN 'COMPLETELY PROCESSED'
            ELSE 'NOT RELEVANT'
        END AS g_line_status_cd,

        -- Field 24
        CASE 
            WHEN order_type = 'DEMO' AND ship_lines.sttrg = '7' THEN 0
            WHEN TVAP.FKREL IN ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') THEN ROUND((COALESCE(order_qty_primary_uom, 0) - COALESCE(lst.shipped_qty, 0)), 4)
            WHEN TRIM(TVAP.FKREL) = '' THEN 0
            ELSE ROUND((COALESCE(order_qty_primary_uom, 0) - (CASE 
                WHEN lst.shipped_qty <> 0 THEN lst.shipped_qty
                WHEN lst.shipped_qty = 0 AND inv.invoice_qty <> 0 THEN inv.invoice_qty
                ELSE 0
            END)), 0)
        END - COALESCE(cancel_qty_primary_uom, 0) AS g_open_qty_primary_uom,

        -- Field 25
        VBAP.PSTYV AS g_order_category,

        -- Field 26
        T001K.BUKRS AS g_order_company_cd,

        -- Field 27
        CASE 
            WHEN TRIM(VBAK.WAERK) = 'RMB' THEN 'CNY'
            ELSE TRIM(VBAK.WAERK)
        END AS g_order_currency_cd,

        -- Field 28
        VBAP.ERDAT AS g_order_dt_yyyymmdd,

        -- Field 29
        VBEP.POSNR AS g_order_line_nbr,

        -- Field 30
        VBEP.VBELN AS g_order_nbr,

        -- Field 31
        CASE 
            WHEN VBEP_BMENG.calculated_bmeng IS NOT NULL AND VBEP_BMENG.calculated_bmeng > 0 THEN VBEP.BMENG
            ELSE VBEP.WMENG
        END AS g_order_qty_order_uom,

        -- Field 32
        CASE 
            WHEN VBEP_BMENG.calculated_bmeng IS NOT NULL AND VBEP_BMENG.calculated_bmeng > 0 THEN VBEP.BMENG
            ELSE VBEP.WMENG
        END AS g_order_qty_primary_uom,

        -- Field 33
        CASE 
            WHEN VBAK.AUART = 'TA' THEN 'OR'
            ELSE VBAK.AUART
        END AS g_order_type,

        -- Field 34
        TRIM(VBAP.VRKME) AS g_order_uom_cd,

        -- Field 35
        CASE 
            WHEN COALESCE(request_date.LAND1, request_date_posnr0.LAND1) NOT IN ('US', 'CA') THEN COALESCE(request_date.vdatu, request_date_posnr0.vbdatu)
            WHEN COALESCE(request_date.LAND1, request_date_posnr0.LAND1) IN ('US', 'CA') THEN TRIM(VBEP.request_dt)
            ELSE VBEP.edatu
        END AS g_original_customer_request_dt_yyyymmdd,

        -- Field 36
        CASE 
            WHEN TRIM(VBAP.WERKS) = '0070' THEN VBAK.ZZ_Ship_By
            ELSE COALESCE(CASE 
                WHEN zosdates.lddat IS NOT NULL THEN zosdates.lddat
                ELSE COALESCE(CASE 
                    WHEN sls.original_promised_ship_dt_yyyymmdd IS NULL THEN VBEP.edatu
                    ELSE sls.original_promised_ship_dt_yyyymmdd
                END, NULL)
            END)
        END AS g_original_promised_ship_dt_yyyymmdd,

        -- Field 37
        VBKD.ZTERM AS g_payment_terms,

        -- Field 38
        VBAP.WERKS AS g_plant_cd,

        -- Field 39
        TRIM(VBAP.MEINS) AS g_primary_uom_cd,

        -- Field 40
        CASE 
            WHEN TRIM(VBAP.WERKS) = '0070' THEN VBAK.ZZ_Ship_By
            ELSE TRIM(VBEP.edatu)
        END AS g_promised_ship_dt_yyyymmdd,

        -- Field 41
        VBEP.MBDAT AS g_scheduled_ship_dt_yyyymmdd,

        -- Field 42
        CASE 
            WHEN VBPA.KUNNR IS NOT NULL THEN VBPA.KUNNR
            ELSE NULL
        END AS g_ship_to_customer_nbr,

        -- Field 43
        CASE 
            WHEN g_order_qty_primary_uom = 0 THEN 0
            ELSE VBEP.MBDAT - VBEP.EDATU
        END AS g_ship_to_delivery_days,

        -- Field 44
        TVSBT.VTEXT AS g_shipment_mode,

        -- Field 45
        CAST(NULL AS STRING) AS g_shipped_qty_primary_uom,

        -- Field 46
        'GBL' AS g_source_system_cd,

        -- Field 47
        CASE 
            WHEN TRIM(MBEW.VPRSV) = 'V' THEN ROUND(IF(T001.WAERS IN ('KRW', 'JPY'), MBEW.VERPR * 100, MBEW.VERPR) / currency_factor, 2)
            WHEN TRIM(MBEW.VPRSV) = 'S' THEN ROUND(IF(T001.WAERS IN ('KRW', 'JPY'), MBEW.STPRS * 100, MBEW.STPRS) / currency_factor, 2)
        END AS g_unit_cost_company_currency_primary_uom,

        -- Field 48
        CASE 
            WHEN TRIM(VBAP.WAERK) = TRIM(T001.WAERS) THEN IF(TRIM(VBAP.WAERK) = 'JPY', puom.price_uom * 100 * COALESCE(VBKD.KURSK, VBKD_DERIVED.KURSK), puom.price_uom * COALESCE(VBKD.KURSK, VBKD_DERIVED.KURSK)) * (TCURF.TFACT / TCURF.FFACT)
            ELSE (puom.price_uom * COALESCE(VBKD.KURSK, VBKD_DERIVED.KURSK)) * (TCURF.TFACT / TCURF.FFACT)
        END AS g_unit_price_company_currency_primary_uom,

        -- Field 49
        CASE 
            WHEN VBEP.VRKME = VBAP.MEINS THEN VBEP.BMENG
            ELSE (MARM.UMREZ / MARM.UMREN) * VBEP.BMENG
        END AS g_unit_price_order_currency_primary_uom,

        -- Field 50
        CAST(NULL AS STRING) AS flag_is_blanket

    FROM VBEP
    LEFT JOIN VBAP ON VBEP.VBELN = VBAP.VBELN AND VBEP.POSNR = VBAP.POSNR
    LEFT JOIN VBAK ON VBEP.VBELN = VBAK.VBELN
    LEFT JOIN VBKD ON VBEP.VBELN = VBKD.VBELN
    LEFT JOIN VBUP ON VBEP.VBELN = VBUP.VBELN AND VBEP.POSNR = VBUP.POSNR
    LEFT JOIN MSKA ON VBEP.VBELN = MSKA.VBELN AND VBEP.POSNR = MSKA.POSNR
    LEFT JOIN T001 ON VBAK.BUKRS = T001.BUKRS
    LEFT JOIN T001K ON T001.BUKRS = T001K.BUKRS
    LEFT JOIN TVSBT ON VBAK.VSBED = TVSBT.VSBED
    LEFT JOIN MARM ON VBAP.MATNR = MARM.MATNR
    LEFT JOIN MBEW ON VBAP.MATNR = MBEW.MATNR
    LEFT JOIN TCURF ON VBAP.WAERK = TCURF.FFACT AND T001.WAERS = TCURF.TFACT
    LEFT JOIN VBPA ON VBEP.VBELN = VBPA.VBELN AND VBEP.POSNR = VBPA.POSNR
    LEFT JOIN TVAP ON VBAP.PSTYV = TVAP.PSTYV
    LEFT JOIN MARA ON VBAP.MATNR = MARA.MATNR
    LEFT JOIN VBFA ON VBEP.VBELN = VBFA.VBELN AND VBEP.POSNR = VBFA.POSNR
    LEFT JOIN request_date ON VBEP.VBELN = request_date.VBELN AND VBEP.POSNR = request_date.POSNR
    LEFT JOIN request_date_posnr0 ON VBEP.VBELN = request_date_posnr0.VBELN
    LEFT JOIN zosdates ON VBEP.VBELN = zosdates.VBELN AND VBEP.POSNR = zosdates.POSNR
    LEFT JOIN sls ON VBEP.VBELN = sls.VBELN AND VBEP.POSNR = sls.POSNR
    LEFT JOIN puom ON VBEP.VBELN = puom.VBELN AND VBEP.POSNR = puom.POSNR
    LEFT JOIN lst ON VBEP.VBELN = lst.VBELN AND VBEP.POSNR = lst.POSNR
    LEFT JOIN inv ON VBEP.VBELN = inv.VBELN AND VBEP.POSNR = inv.POSNR
    LEFT JOIN VBKD_DERIVED ON VBEP.VBELN = VBKD_DERIVED.VBELN
    WHERE VBEP.VBELN IS NOT NULL
)
SELECT * FROM Sales_Order_Detail