# ☕Sizwe Coffee: SQL Analysis of Sales, Margins and Collections

## 📂Project Overview
Sizwe Coffee is a fictional company based in South Africa that buys green coffee beans, roasts them, and sells to about 1400 businesses, including grocery chains, hotels, cafés, offices, restaurants and retailers. It doesn't own any retail stores. Roasted coffee beans are sold to the businesses either via wholesale contracts (large volumes) or subscription (monthly delivery). There are five product lines: House Blend, Single Origin, Bulk Commercial, Decaf, and Capsules. 

### 📚Assignment
This project is a SQL assignment from the Witle Academy data analytics bootcamp. Eight business questions were raised by two stakeholders, Nomsa, the Financial Director, and Bongani, the National Sales Manager. 

The questions were answered using Databricks SQL. All queries and written answers are in [`queries.sql`](queries.sql).

### ❓The eight questions:
1. **Channel performance:** revenue by channel for FY2024 and FY2025, with growth from FY2024 to FY2025.
2. **Profit by product line:** by product line - revenue, cost of goods, gross profit and gross margin.
3. **Collections problem:** by channel - invoices settled and open, days to settle and value outstanding.
4. **Top ten accounts:** the ten largest customers by FY2025 revenue, with owning rep.
5. **Commercial gap:** the fifteen highest-revenue wholesale customers who never received a trade promotion.
6. **Rep performance:** each rep's FY2025 monthly average against their target.
7. **Shape of the year FY2024 & FY2025:** monthly revenue, month-on-month change in revenue, and the average of rolling three-month revenue.
8. **Margin movement:** why has gross margin fell from 34.7% (FY2024) to 33.0% (FY2025)?

#### ⚠️Financial years 
Financial years run 1 July to 30 June: FY2024 is 1 Jul 2023 to 30 Jun 2024 and FY2025 is 1 Jul 2024 to 30 Jun 2025. The data runs from 1 July 2023 to 27 June 2025.

## 📦Dataset & Connections
The entire dataset is synthetic with no real data. The raw data is not uploaded on GitHub. 
| Table | What it holds | PK | FK |
|---|---|---|---|
| `sizwe_customers` | One row per customer: trading name, channel, segment, province, credit limit, assigned sales rep | `customer_id` | `rep_id` |
| `sizwe_sales_orders` | One row per order: customer, order date, delivery date, sales rep, channel | `order_id` | `customer_id`, `rep_id` |
| `sizwe_sales_lines` | One row per order line: SKU, units, unit price, discount, line revenue, cost of goods | `order_id` + `line_no` combination | `order_id`, `sku` |
| `sizwe_products` | One row per SKU: product name, product line, pack size, list price, unit cost | `sku` | |
| `sizwe_reps` | One row per sales rep: territory, monthly target | `rep_id` | |
| `sizwe_trade_promotions` | One row per promotion: customer, sku, start date, end date | `promo_id` | `sku`, `customer_id` |
| `sizwe_ar_ledger` | One row per invoice: amount, invoice date, settlement date, payment terms | `invoice_no` | `customer_id` |

### ⚠️Data notes:
- There are 1,400 customers but only 1,337 distinct trading names. Therefore, it's imperative to GROUP BY `customer_id` instead of `trading_name`.
- Every customer has a valid `rep_id` with a `rep_name`. However, in Task 4, `LEFT JOIN` was used between `sizwe_customers` and `sizwe_reps` for additional safety to ensure no customers without a rep are erased.

## 🛠️Skills demonstrated
| Technique | Task(s) |
|---|---|
| Single CTE | 1,8 |
| Chain CTE | 7 |
| Aggregation | 2,3,4,5 |
| Conditional aggregation | 1,3,6,8 | 
| Inner Join | 1,2,3,4,5,7,8 |
| Left Join | 4,5,6 |
| Filtering | 4,5,7 |
| Numeric functions | 1,2,3,4,5,6,7,8 |
| Date functions | 3,7 |
| Sorting | 2,4,5,6,7 |
| Calculations | 1,6,7,8 | 
| Window functions | 7 |

### 🖥️SQL queries
All queries, their outputs, and written answers are in [`queries.sql`](queries.sql).

## 🖥️How to run
1. Tool: Databricks SQL
2. The seven tables were provided by Witle Academy Data Analytics Bootcamp, and it's not been uploaded in this repo.
3. For those with access to the raw data files (csv): open `queries.sql`. The queries to answer the questions in each task is available, in order. Each is marked with its task number, and the written answer sits in the comment directly below it.

## ✅Key insights

### 💸For Nomsa (the financial director)
- **Growth is even across channels** Wholesale grew 8.85% (+/-R308.2m to R335.4m) and subscription 8.84% (+/-R132.8m to R144.6m). Total revenue rose from +/-R441.0m to +/-R480.0m, and wholesale is about +/-70% of it in both years.
- **Collections are a wholesale problem** 3,454 of wholesale's 28,944 invoices (+/-12%) are still open, against 44 of 19,200 (0.2%) for subscription. Wholesale takes 69 days to settle versus 4 on average, and holds about R87.8m outstanding against about R750,000. It's imperative to note that this only looks at the channels and not time periods. Therefore, it can't show whether payment is getting slower over time. However, we'd need to further look into wholesale customers and their invoices.
- **Profit and margin** House Blend earns the most gross profit (R107.1m), but Single Origin has the highest margin (44.27%).
- **The margin decline is a mix effect** No product line's margin moved by more than 0.3 percentage points. Low-margin Bulk commercial (about 20% margin) grew from 25.02% to 33.65% of revenue, while higher-margin lines lost share, for example Single Origin (19.45% to 17.57%). Offering trade promotions for Single Origin in FY2026 may contribute well to higher overall revenue and profit margin.
- **Revenue is seasonal** It falls month on month from July to December and recovers from January to June. The quietest month was December for FY2024 (R29.87m, down 13.09% on November) and for FY2025 (RR32.6m, down 12.89% on November). 

### 📉For Bongani (the national sales manager)
- **Highest gross margin, relatively small revenue** The Single Origin product line has the highest gross margin (44.24% in FY 2024, 44.31% in FY2025) but contributed modestly (3rd highest of the 5 product lines) to the total revenue (19.45% in FY2024). Its contribution has also decreased in FY2025 from FY2024 (17.57% in FY2025). It may help for FY2026 to train sales reps to promote this product line, and to offer discounts for large volume orders. 
- **Sales rep performances** It's impressive that many of the reps (16 out of 18) are hitting beyond their monthly targets. 8 out of 18 of them have hit 190% and above of their monthly targets. It's important to keep the high performers well incentivised for bringing in higher revenue. But it's also important to have a discussion with reps who are not hitting their monthly targets (R-011 and R-008) to find out reasons for their underperformance and how they may be further assisted.
- **Big accounts with no promotion** There are some customers who are making large purchases but never been offered trade promotions. The top 3 have contributed R6.22m, R4.45m, and R4.44m over FY2024 and FY2025 together. It may be wise to consider offering them trade promotions as they might hop over to another distributor who could offer a discount.
- **One customer dominates.** Halvane Retail Group is the largest account at R38.4m in FY2025, about 8% of revenue in FY2025 and more than 11 times the 2nd highest revenue customer (R3.38m). 
