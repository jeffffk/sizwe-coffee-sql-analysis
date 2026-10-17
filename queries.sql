--Task 1: Channel performance

-- Nomsa needs the revenue split by channel for FY2024 and FY2025 side by side, with the growth rate between them. One row per channel, three figures on each. FY2024 is orders placed on or before 30 June 2024. FY2025 is everything after that. 

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
FROM draft_revenue;
    
-- ====================================================================
    
-- Task 2 - Where the profit actually comes from

-- For each product line, return revenue, cost of goods, gross profit and gross margin percentage. Sort by gross profit. In one or two sentences under your query: which line earns the most profit, and is it the same line that earns the highest margin?

SELECT 
    product_line,
    ROUND(SUM(line_revenue),2) AS p_line_revenue,
    ROUND(SUM(cogs),2) AS p_line_cogs,
    ROUND((SUM(line_revenue) - SUM(cogs)),2) AS gross_profit,
    ROUND(((SUM(line_revenue) - SUM(cogs)) / SUM(line_revenue) * 100),2) AS gross_margin_percent
FROM sizwe_products p 
JOIN sizwe_sales_lines sl
    ON p.sku = sl.sku
GROUP BY product_line
ORDER BY 4 DESC;

-- Answer:
-- The House Blend product line yielded the highest gross profit of R107,148,746.60. However, it's Single Origin that has the highest gross margin percentage of 44.27%.

-- ====================================================================

-- Task 3 - The collections problem

-- Nomsa suspects the business is being paid more slowly than it used to be, and wants to know where the problem sits. For each channel, return the number of invoices, how many have been settled, how many are still open, the average number of days taken to settle, and the total value still outstanding. In two or three sentences: what does this tell you, and which channel would you investigate first?

SELECT 
    c.channel,
    COUNT(invoice_no) AS num_invoices,
    SUM(CASE
            WHEN settlement_date IS NOT NULL THEN 1
            ELSE 0
        END) AS num_invoices_settled,
    SUM(CASE
            WHEN settlement_date IS NULL THEN 1
            ELSE 0
        END) AS num_invoices_unsettled,
    CEILING(AVG(DATEDIFF(DAY, invoice_date, settlement_date))) AS avg_days_settle,
    ROUND(SUM(invoice_amount - amount_settled),2) AS total_unsettled
FROM sizwe_customers c
JOIN sizwe_ar_ledger al
    ON c.customer_id = al.customer_id
GROUP BY c.channel;

-- Answer: Wholesale is where the collections problem sits: 3,454 of its 28,944 invoices (12%) are still open, against 44 of 19,200 (0.2%) for subscription, and wholesale takes 69 days to settle on average versus 4. Wholesale also holds about R87.8m of the outstanding value against about R750,000 for subscription, so I would investigate wholesale first, though this compares channels rather than time periods, so it doesn't show whether payment is getting slower.

-- ====================================================================

-- Task 4 - The ten accounts that matter most

-- Bongani wants a one-page list of the ten largest customers by FY2025 revenue, showing the trading name, segment, province, the sales representative who owns the account, and the revenue. Not every customer has a sales representative. Make sure your query does not silently drop anyone. 

SELECT 
    c.customer_id,
    c.trading_name,
    c.segment,
    c.province,
    r.rep_id,
    r.rep_name,
    ROUND(SUM(sl.line_revenue),2) AS fy2025_revenue
FROM sizwe_customers c
JOIN sizwe_sales_orders so 
    ON c.customer_id = so.customer_id
JOIN sizwe_sales_lines sl
    ON so.order_id = sl.order_id
LEFT JOIN sizwe_reps r -- LEFT JOIN to prevent dropping customers without a rep
    ON c.rep_id = r.rep_id  
WHERE order_date BETWEEN '2024-07-01' AND '2025-06-30'
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY 7 DESC
LIMIT 10;

-- ====================================================================

-- Task 5 - A commercial gap

-- Trade promotions are how Sizwe supports its wholesale accounts. Bongani thinks some sizeable customers have been getting nothing. Return the fifteen highest-revenue Wholesale customers who have never received a trade promotion, with their segment and province. One sentence: what would you recommend doing about the top three?

SELECT
    c.customer_id,
    c.trading_name,
    c.segment,
    c.province,
    ROUND(SUM(sl.line_revenue),2) AS customer_total_revenue
FROM sizwe_customers c
JOIN sizwe_sales_orders so
    ON c.customer_id = so.customer_id
JOIN sizwe_sales_lines sl
    ON so.order_id = sl.order_id
LEFT JOIN sizwe_trade_promotions tp ---Not inner join, because we want to see which customers have not been offered a promotion
    ON c.customer_id = tp.customer_id
WHERE c.channel = 'Wholesale'
    AND tp.customer_id IS NULL
GROUP BY c.customer_id, c.trading_name, c.segment, c.province
ORDER BY 5 DESC
LIMIT 15;

-- Answer: I would get the territorial sales reps to telephonically reach these customers (Umhlanga Fresh 108 in Gauteng, Ridgeway Foods 308 in KZN, Kalahari Kitchen 42 in Gauteng) and offer them a trade promotion, as their total revenue is quite sizeable and we don't want to lose them to a competitor who might offer them a discount.

-- ====================================================================

-- Task 6 - Are the sales representatives hitting target?

-- Each sales representative carries a monthly revenue target. Return every sales representative with their territory, their monthly target, their actual FY2025 monthly average, and that average as a percentage of target. Sort by percentage of target, best first. Every sales representative must appear, including any who generated no revenue. 

SELECT 
    r.rep_id,
    r.rep_name,
    r.territory,
    r.target_monthly,
    ROUND((SUM(CASE
            WHEN so.order_date >= '2024-07-01' AND so.order_date <= '2025-06-30' 
                THEN sl.line_revenue
            ELSE 0
        END
        ) / 12),2) AS fy2025_avg_monthly_revenue,
    ROUND(((SUM(CASE
            WHEN so.order_date >= '2024-07-01' AND so.order_date <= '2025-06-30' 
                THEN sl.line_revenue
            ELSE 0
        END
        ) / 12) / r.target_monthly * 100),2) AS fy2025_avg_monthly_revenue_percent
FROM sizwe_reps r
LEFT JOIN sizwe_sales_orders so 
    ON r.rep_id = so.rep_id
LEFT JOIN sizwe_sales_lines sl 
    ON so.order_id = sl.order_id 
GROUP BY 1, 2, 3, 4
ORDER BY 6 DESC;

-- ====================================================================

-- Task 7 - The shape of the year

-- Return monthly revenue across the full two years, with the percentage change on the previous month and a rolling three-month average alongside it. In two sentences: is there a seasonal pattern, and when is Sizwe's quietest month?

WITH monthly_revenue AS 
    (
    SELECT 
        DATE_FORMAT(so.order_date, 'yyyy-MM') AS year_month,
        ROUND(SUM(sl.line_revenue),2) AS month_revenue
    FROM sizwe_sales_orders so
    JOIN sizwe_sales_lines sl
        ON so.order_id = sl.order_id
    WHERE so.order_date BETWEEN '2023-07-01' AND '2025-06-30'
    GROUP BY 1
    ORDER BY 1 ASC
    ),

monthly_revenue_lags AS
    (
    SELECT
        year_month,
        month_revenue,
        LAG(month_revenue) OVER(ORDER BY year_month) AS month_lag_1,
        LAG(LAG(month_revenue) OVER(ORDER BY year_month)) OVER(ORDER BY year_month) AS month_lag_2,
        LAG(LAG(LAG(month_revenue) OVER(ORDER BY year_month)) OVER(ORDER BY year_month)) OVER(ORDER BY year_month) AS month_lag_3
    FROM monthly_revenue
    )

-- rolling_3_month_avg = average of the 3 months before each month (current month excluded)

SELECT 
    year_month,
    month_revenue,
    ROUND(((month_revenue - month_lag_1) / month_lag_1 * 100), 2) AS percent_change,
    ROUND(((month_lag_1 + month_lag_2 + month_lag_3) / 3),2) AS rolling_3_month_avg
FROM monthly_revenue_lags
ORDER BY 1;

-- Answer: Yes, there is a seasonal pattern. It is clear that the monthly revenue drops month-over-month from Jul to Dec and it grows from Jan to Jun. The quietest month was Dec 2023 (R29,872,699.78) which was -13.09% from Nov 2023 and lower than the 3 lagging months' average of R35,654,249.12 (Sep, Oct, Nov 2023).

-- ====================================================================

-- Task 8 - Why has the margin moved?

-- Gross margin fell from 34.7% in FY2024 to 33.0% in FY2025, while revenue grew nearly 9%. Nobody can explain it. For each product line, return revenue and gross margin for each financial year, plus that line's share of total revenue in that year. Then answer, in a short paragraph: what caused the margin decline? Your answer must point at specific numbers in your result. 

WITH revenue_cogs AS 
    (
        SELECT 
            p.product_line,
            ROUND(SUM(CASE
                    WHEN so.order_date BETWEEN '2023-07-01' AND '2024-06-30'
                        THEN sl.line_revenue
                    ELSE 0
                END),2) AS fy2024_rev,
            ROUND(SUM(CASE
                    WHEN so.order_date BETWEEN '2024-07-01' AND '2025-06-30'
                        THEN sl.line_revenue
                    ELSE 0
                END),2) AS fy2025_rev,
            ROUND(SUM(CASE
                    WHEN so.order_date BETWEEN '2023-07-01' AND '2024-06-30'
                        THEN sl.cogs
                    ELSE 0
                END),2) AS fy2024_cogs,
            ROUND(SUM(CASE
                    WHEN so.order_date BETWEEN '2024-07-01' AND '2025-06-30'
                        THEN sl.cogs
                    ELSE 0
                END),2) AS fy2025_cogs
        FROM sizwe_sales_lines sl
        JOIN sizwe_sales_orders so 
            ON sl.order_id = so.order_id
        JOIN sizwe_products p
            ON p.sku = sl.sku
        GROUP BY p.product_line
    )

SELECT 
    product_line,
    fy2024_rev,
    ROUND((100 * (fy2024_rev - fy2024_cogs) / fy2024_rev),2) AS fy2024_gm,
    ROUND((100 * fy2024_rev / SUM(fy2024_rev) OVER()),2) AS fy2024_share_percent,
    fy2025_rev,
    ROUND((100 * (fy2025_rev - fy2025_cogs) / fy2025_rev),2) AS fy2025_gm,
    ROUND((100 * fy2025_rev / SUM(fy2025_rev) OVER()),2) AS fy2025_share_percent
FROM revenue_cogs;

-- Answer: The gross margin for each product line hasn't changed significantly from 2024 to 2025 (all within 0.3 percentage points). However, there have been more significant changes in each of their share of the total revenue in each year. Most notably, Bulk commercial product line's share of the total revenue has increased from 25.02% to 33.65% from FY2024 to FY2025. Bulk commercial has the smallest gross margin compared to other product lines for both years (19.89% and 19.91%) against higher margins elsewhere. This contributed to the reduced overall gross margin in 2025. At the same time, the decline in gross margin is further accounted for by the decreased share of the total revenue for the product lines with higher gross margins. For example, Single Origin product line which has the highest gross margin has contributed relatively less to the total revenue in 2025 (17.57%) compared to in 2024 (19.45%). The same reason applies to all the remaining product lines with higher gross margins.
