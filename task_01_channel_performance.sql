--Task 1: Channel performance
-- ======================================
-- Nomsa needs the revenue split by channel for FY2024 and FY2025 side by side, with the growth rate between them. One row per channel, three figures on each. FY2024 is orders placed on or before 30 June 2024. FY2025 is everything after that. 
-- ======================================
-- FY2024 is 1 Jul 2023 to 30 Jun 2024
-- FY2025 is 1 Jul 2024 to 30 Jun 2025

WITH draft_revenue AS 
(
    SELECT 
        channel,
        ROUND(SUM(
                CASE
                    WHEN order_date BETWEEN '2023-07-01' AND '2024-06-30'
                    THEN line_revenue
                    ELSE 0
                END
                  ),2) AS fy2024_revenue,
        ROUND(SUM(
                CASE
                    WHEN order_date BETWEEN '2024-07-01' AND '2025-06-30'
                    THEN line_revenue
                    ELSE 0
                END
                 ),2) AS fy2025_revenue
    FROM sizwe_sales_orders so
    JOIN sizwe_sales_lines sl
        ON so.order_id = sl.order_id
    GROUP BY channel
)
SELECT 
    channel,
    fy2024_revenue,
    fy2025_revenue,
    ROUND(((fy2025_revenue - fy2024_revenue) / fy2024_revenue * 100), 2) AS percent_growth
FROM draft_revenue
















