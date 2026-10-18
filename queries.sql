--Task 1: Channel performance

-- Nomsa needs the revenue split by channel for FY2024 and FY2025 side by side, with the growth rate between them. One row per channel, three figures on each. FY2024 includes orders placed on or before 30 June 2024. FY2025 includes all orders after that. 

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

-- Output:
-- channel	    fy2024_revenue	fy2025_revenue	percent_growth
-- Wholesale	308166012.32	335426325.02	8.85
-- Subscription	132833985.15	144573698.33	8.84

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

-- Output:
-- product_line	    p_line_revenue	    p_line_cogs	    gross_profit	gross_margin_percent
-- House Blend	    279530948.9	        172382202.3	    107148746.6	    38.33
-- Single Origin	170112619.61	    94799818.74	    75312800.87	    44.27
-- Bulk Commercial	271838831.01	    217735951.53	54102879.48	    19.9
-- Capsules	        108875076.22	    66516571.55	    42358504.67	    38.91
-- Decaf	        90642545.08	        58167547.01	    32474998.07	    35.83

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

-- Output:
-- channel	    num_invoices	num_invoices_settled	num_invoices_unsettled	avg_days_settle	    total_unsettled
-- Wholesale	28944	        25490	                3454	                69	                87848227.2
-- Subscription	19200	        19156	                44	                    4	                751178.89

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

-- Output:
-- customer_id	trading_name	        segment	            province	    rep_id	rep_name	    fy2025_revenue
-- C-00001	    Halvane Retail Group	Grocery Chain	    Western Cape	R-001	Kagiso Mkhize	38399999.89
-- C-00336	    Highveld Deli 85	    Restaurant Group	Free State	    R-009	Karabo Mokoena	3380200.33
-- C-00593	    Table Bay Foods 280	    Independent Cafe	KwaZulu-Natal	R-016	Karabo van Wyk	3333678
-- C-00439	    Umhlanga Fresh 108	    Restaurant Group	Gauteng	        R-011	Sipho Steyn	    3246754.35
-- C-00555	    Kalahari Kitchen 42    	Independent Cafe	Gauteng	        R-013	Chantal Ismail	2320923.25
-- C-00116	    Ridgeway Foods 308	    Independent Cafe	KwaZulu-Natal	R-004	Chantal Adams	2320555.37
-- C-00425	    Boland Bakery 91	    Independent Cafe	Free State	    R-003	Karabo Zwane	2280097.99
-- C-00249	    The Daily Grind 219	    Hotel Group	        Western Cape	R-002	Nomsa Botha	    2134607.32
-- C-00238	    Midrand Market 293	    Independent Cafe	KwaZulu-Natal	R-013	Chantal Ismail	2024456.98
-- C-00216	    Bloom Coffee House 275	Hotel Group	        Gauteng	        R-003	Karabo Zwane	1934391.39

-- ====================================================================

-- Task 5 - A commercial gap

-- Trade promotions are how Sizwe supports its wholesale accounts. Bongani thinks some sizeable customers have been getting nothing. Return the fifteen highest-revenue Wholesale customers who have never received a trade promotion, with their segment and province. One sentence: what would you recommend doing about the top three?

SELECT
    c.customer_id,
    c.trading_name,
    c.segment,
    c.province,
    ROUND(SUM(sl.line_revenue),2) AS customer_total_revenue -- Revenue covers all orders in the data (FY2024 and FY2025 combined)
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
ORDER BY customer_total_revenue DESC
LIMIT 15;

-- Answer: I would get the territorial sales reps to telephonically reach these customers (Umhlanga Fresh 108 in Gauteng, Ridgeway Foods 308 in KZN, Kalahari Kitchen 42 in Gauteng) and offer them a trade promotion, as their total revenue is quite sizeable and we don't want to lose them to a competitor who might offer them a discount.

-- Output:
-- customer_id	trading_name	        segment	            province	    customer_total_revenue
-- C-00439	    Umhlanga Fresh 108	    Restaurant Group	Gauteng	        6224772.37
-- C-00116	    Ridgeway Foods 308	    Independent Cafe	KwaZulu-Natal	4448744.72
-- C-00555	    Kalahari Kitchen 42	    Independent Cafe	Gauteng	        4447225.01
-- C-00238	    Midrand Market 293	    Independent Cafe	KwaZulu-Natal	3887087.18
-- C-00216	    Bloom Coffee House 275	Hotel Group	        Gauteng	        3719361.46
-- C-00420	    Corner Perk 34	        Independent Cafe	Limpopo	        3431735.39
-- C-00465	    Highveld Deli 28	    Independent Cafe	Gauteng	        3421285.02
-- C-00197	    Bloom Coffee House 306	Restaurant Group	Gauteng	        3397003.31
-- C-00597	    Kalahari Kitchen 348	Independent Cafe	KwaZulu-Natal	3270408.02
-- C-00489	    Zebra Cafe 201	        Grocery Chain	    Free State	    3169175.74
-- C-00123	    Highveld Deli 305	    Independent Cafe	Free State	    2712773.51
-- C-00046	    Zebra Cafe 337	        Grocery Chain	    Gauteng	        2587275.23
-- C-00538	    Table Bay Foods 291	    Independent Cafe	Gauteng	        2413619.42
-- C-00230	    Ridgeway Foods 125	    Restaurant Group	Gauteng	        2340560.47
-- C-00476	    Corner Perk 248	        Hotel Group	        KwaZulu-Natal	2311270.14

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

-- Output:
-- rep_id	rep_name	        territory	    target_monthly	fy2025_avg_monthly_revenue	fy2025_avg_monthly_revenue_percent
-- R-016	Karabo van Wyk	    Gauteng South	900000	        2252880.96	                250.32
-- R-001	Kagiso Mkhize	    Gauteng North	2000000	        4996325.67	                249.82
-- R-018	Johan Maluleke	    KwaZulu-Natal	900000	        2184885.21                	242.77
-- R-010	Anele Naidoo	    Western Cape	900000	        2011837.24	                223.54
-- R-007	Anele Zwane	        Northern Region	900000	        1846514.09                	205.17
-- R-009	Karabo Mokoena	    Gauteng South	1200000	        2365324.98                	197.11
-- R-012	Anele Ismail	    Eastern Cape	1200000	        2299147.69	                191.6
-- R-013	Chantal Ismail	    Central Region	1200000	        2285301.19	                190.44
-- R-006	Pieter Pillay	    Central Region	1200000	        2068510.95	                172.38
-- R-002	Nomsa Botha	        Gauteng South	1500000	        2377843.54	                158.52
-- R-017	Kagiso Dlamini	    Western Cape	1500000	        2018850.46	                134.59
-- R-004	Chantal Adams	    KwaZulu-Natal	1500000	        1940122.04	                129.34
-- R-003	Karabo Zwane	    Western Cape	2000000	        2512055.06	                125.6
-- R-015	Sibusiso Nkosi	    Gauteng North	1500000	        1778548                    	118.57
-- R-005	Bongani Mahlangu	Eastern Cape	2000000	        2321162.58	                116.06
-- R-014	Anele Botha	        Northern Region	1500000	        1616477.8	                107.77
-- R-011	Sipho Steyn	        KwaZulu-Natal	2000000	        1959822.17	                97.99
-- R-008	Johan Naidoo	    Gauteng North	1500000	        1164392.3	                77.63

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
        LAG(LAG(month_revenue) OVER(ORDER BY year_month)) OVER(ORDER BY year_month) AS month_lag_2
    FROM monthly_revenue
    )

-- rolling_3_month_avg = average of the current month and the 2 months before it

SELECT 
    year_month,
    month_revenue,
    ROUND(((month_revenue - month_lag_1) / month_lag_1 * 100), 2) AS percent_change,
    ROUND(((month_revenue + month_lag_1 + month_lag_2) / 3),2) AS rolling_3_month_avg
FROM monthly_revenue_lags
ORDER BY 1;

-- Answer: Yes, there is a seasonal pattern: revenue peaks around June to July, falls month on month from August to December, and recovers from January to June. The quietest month was December 2023 (R29,872,699.78), down 13.09% on November and the lowest of all 24 months.

-- Output:
-- year_month	month_revenue	percent_change	rolling_3_month_avg
-- 2023-07	    41051471.75	    null	        null
-- 2023-08    	39607744.34	    -3.52	        null
-- 2023-09    	36807779.06	    -7.07	        39155665.05
-- 2023-10	    35784805.69	    -2.78	        37400109.7
-- 2023-11	    34370162.62	    -3.95	        35654249.12
-- 2023-12    	29872699.78	    -13.09        	33342556.03
-- 2024-01	    31255621.08	    4.63	        31832827.83
-- 2024-02	    35156025.63    	12.48        	32094782.16
-- 2024-03    	37287497.58	    6.06	        34566381.43
-- 2024-04	    37950728.75	    1.78	        36798083.99
-- 2024-05    	40372504.38	    6.38	        38536910.24
-- 2024-06	    41482956.81    	2.75	        39935396.65
-- 2024-07	    44577702.77	    7.46        	42144387.99
-- 2024-08    	43053627.21    	-3.42        	43038095.6
-- 2024-09	    40013872.74	    -7.06	        42548400.91
-- 2024-10	    39014595.93	    -2.5	        40694031.96
-- 2024-11	    37435415.91	    -4.05	        38821294.86
-- 2024-12    	32609167.66	    -12.89        	36353059.83
-- 2025-01	    34184711.27	    4.83	        34743098.28
-- 2025-02	    38246732.89	    11.88	        35013537.27
-- 2025-03	    40504297.3	    5.9	            37645247.15
-- 2025-04	    41326872.55	    2.03	        40025967.58
-- 2025-05	    43905063.28	    6.24	        41912077.71
-- 2025-06	    45127963.84	    2.79	        43453299.89
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

-- Answer: The gross margin for each product line hasn't changed significantly from 2024 to 2025 (all within 0.3 percentage points). However, there have been more significant changes in each of their share of the total revenue in each year. Most notably, Bulk Commercial product line's share of the total revenue has increased from 25.02% to 33.65% from FY2024 to FY2025. Bulk Commercial has the smallest gross margin compared to other product lines for both years (19.89% and 19.91%) against higher margins elsewhere. This contributed to the reduced overall gross margin in 2025. At the same time, the decline in gross margin is further accounted for by the decreased share of the total revenue for the product lines with higher gross margins. For example, Single Origin product line which has the highest gross margin has contributed relatively less to the total revenue in 2025 (17.57%) compared to in 2024 (19.45%). The same reason applies to all the remaining product lines with higher gross margins.

-- Output:
-- product_line	    fy2024_rev	    fy2024_gm	fy2024_share_percent	fy2025_rev	    fy2025_gm	fy2025_share_percent
-- House Blend	    141746471.48	38.32	    32.14	                137784477.42	38.34	    28.71
-- Decaf	        46300477.47	    35.85	    10.5	                44342067.61	    35.81	    9.24
-- Capsules	        56822349.5	    39.01	    12.88	                52052726.72	    38.79	    10.84
-- Bulk Commercial	110338581.35	19.89	    25.02	                161500249.66	19.91	    33.65
-- Single Origin	85792117.67	    44.24	    19.45	                84320501.94	    44.31	    17.57
