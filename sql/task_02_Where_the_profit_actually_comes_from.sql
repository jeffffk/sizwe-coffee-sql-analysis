-- Task 2 - Where the profit actually comes from
-- =============================================
-- For each product line, return revenue, cost of goods, gross profit and gross margin percentage. 
-- Sort by gross profit. 
-- In one or two sentences under your query: 
--       which line earns the most profit, 
--       and is it the same line that earns the highest margin?
-- =============================================

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
ORDER BY 4 DESC

-- Answer:
-- The most profitable product line is House Blend.
-- However, it's Single Origin that has the highest gross margin percentage.
