-- Query: KAN-12_transformation
-- Purpose: Generated SQL for KAN-12 via 7-stage pipeline
-- Query Type: SELECT

WITH
constants_cluster_defaults AS (
    SELECT
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_availability_dt_yyyymmdd, -- TODO: Date corresponding to the Thermo Fisher best approximation of a future ship date
        CAST(NULL AS STRING) AS Sales_Order_Detail.flag_is_blanket, -- TODO
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_delivery_schedule_line_nbr, -- TODO: g_delivery_schedule_line_nbr
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_item_nbr, -- TODO: g_item_nbr
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_company_cd, -- TODO: g_order_company_cd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_line_nbr, -- TODO: g_order_line_nbr
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_nbr, -- TODO: g_order_nbr
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_type, -- TODO: g_order_type
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_plant_cd, -- TODO: g_plant_cd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_source_system_cd, -- TODO: g_source_system_cd
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_last_actual_ship_dt_yyyymmdd, -- TODO: g_last_actual_ship_dt_yyyymmdd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_allocated_qty_primary_uom, -- TODO: g_allocated_qty_primary_uom
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_bill_to_customer_nbr, -- TODO: g_bill_to_customer_nbr
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_cancel_dt_yyyymmdd, -- TODO: g_cancel_dt_yyyymmdd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_cancel_qty_primary_uom, -- TODO: g_cancel_qty_primary_uom
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_company_currency_cd, -- TODO: g_company_currency_cd
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_customer_request_dt_yyyymmdd, -- TODO: g_customer_request_dt_yyyymmdd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_is_transfer_order, -- TODO: g_flag_is_transfer_order
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_has_parent, -- TODO: g_flag_has_parent
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_inventory_fully_allocated, -- TODO: g_flag_inventory_fully_allocated
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_is_parent, -- TODO: g_flag_is_parent
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_on_hold, -- TODO: g_flag_on_hold
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_open_to_ship, -- TODO: g_flag_open_to_ship
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_line_status_cd, -- TODO: g_line_status_cd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_open_qty_primary_uom, -- TODO: g_open_qty_primary_uom
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_order_dt_yyyymmdd, -- TODO: g_order_dt_yyyymmdd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_qty_order_uom, -- TODO: g_order_qty_order_uom
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_qty_primary_uom, -- TODO: g_order_qty_primary_uom
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_uom_cd, -- TODO: g_order_uom_cd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_primary_uom_cd, -- TODO: g_primary_uom_cd
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_promised_ship_dt_yyyymmdd, -- TODO: g_promised_ship_dt_yyyymmdd
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_scheduled_ship_dt_yyyymmdd, -- TODO: g_scheduled_ship_dt_yyyymmdd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_ship_to_customer_nbr, -- TODO: g_ship_to_customer_nbr
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_shipped_qty_primary_uom, -- TODO: g_shipped_qty_primary_uom
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_unit_cost_company_currency_primary_uom, -- TODO: g_unit_cost_company_currency_primary_uom
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_unit_price_company_currency_primary_uom, -- TODO: g_unit_price_company_currency_primary_uom
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_original_promised_ship_dt_yyyymmdd, -- TODO: g_original_promised_ship_dt_yyyymmdd
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_original_customer_request_dt_yyyymmdd, -- TODO: g_original_customer_request_dt_yyyymmdd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_availability_dt_yyyymmdd, -- TODO: Column Removed from Alation
        CAST(NULL AS DATE) AS Sales_Order_Detail.g_invoice_dt_yyyymmdd, -- TODO: g_invoice_dt_yyyymmdd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_material_transacted, -- TODO: g_flag_material_transacted
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_ship_to_delivery_days, -- TODO: g_ship_to_delivery_days
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_shipment_mode, -- TODO: g_shipment_mode
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_revenue_recognition, -- TODO: g_flag_revenue_recognition
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_flag_consignment_order, -- TODO: g_flag_consignment_order
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_category, -- TODO: g_order_category
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_inco_terms, -- TODO: g_inco_terms
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_payment_terms, -- TODO: g_payment_terms
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_order_currency_cd, -- TODO: g_order_currency_cd
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_unit_price_order_currency_primary_uom, -- TODO: g_unit_price_order_currency_primary_uom
        CAST(NULL AS STRING) AS Sales_Order_Detail.g_customer_po_nbr, -- TODO: g_customer_po_nbr
        CAST(NULL AS STRING) AS sales_order_detail.g_customer_po_line, -- TODO: g_customer_po_line
        CAST(NULL AS STRING) AS sales_order_detail.g_customer_po_type, -- TODO: g_customer_po_type
        CAST(NULL AS STRING) AS sales_order_detail.g_customer_item_nbr, -- TODO: g_customer_item_nbr
        CAST(NULL AS STRING) AS sales_order_detail.g_flag_return, -- TODO: g_flag_return
        CAST(NULL AS STRING) AS sales_order_detail.g_parent_order_line_nbr, -- TODO: g_parent_order_line_nbr
        CAST(NULL AS STRING) AS sales_order_detail.sls_ord_sched_key, -- TODO: New Column Added in Alation
        CAST(NULL AS STRING) AS sales_order_detail.sls_ord_key, -- TODO: New Column Added in Alation
        CAST(NULL AS STRING) AS sales_order_detail.prod_plant_key, -- TODO: New Column Added in Alation
        CAST(NULL AS STRING) AS sales_order_detail.plant_key, -- TODO: New Column Added in Alation
        CAST(NULL AS STRING) AS sales_order_detail.prod_key, -- TODO: New Column Added in Alation
        CAST(NULL AS STRING) AS sales_order_detail.co_key -- TODO: New Column Added in Alation
)
SELECT * FROM constants_cluster_defaults;