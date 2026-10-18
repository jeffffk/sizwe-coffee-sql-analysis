# ☕Sizwe Coffee: SQL Analysis of Sales, Margins and Collections

## 📂Project Overview
Sizwe Coffee is a fictional company based in South Africa that buys green coffee beans, roasts them, and sells to about 1400 businesses, including grocery chains, hotels, cafés, offices, restaurants and retailers. It doesn't own any retail stores. There two channels for sale of roasted coffee beans: wholesale contracts (large volumes) or subscription (monthly delivery). There are five product lines: House Blend, Single Origin, Bulk Commercial, Decaf, and Capsules. There are 18 sales reps in total, each with their territory and monthly targets.

### 📚Assignment
This project is a SQL assignment from the Witle Academy data analytics bootcamp. Eight business tasks were provided by two fictional stakeholders, Nomsa (the Financial Director), and Bongani (the National Sales Manager). 

The tasks were performed using Databricks SQL. All queries, their outputs, and written answers are in [`queries.sql`](queries.sql).

### ❓The 8x Tasks:
1. **Channel performance:** revenue by channel for FY2024 and FY2025, with growth from FY2024 to FY2025
2. **Profit by product line:** for each product line - revenue, cost of goods, gross profit and gross margin
3. **Collections problem:** for each channel - invoices settled and open, days to settle and value outstanding
4. **Top ten accounts:** the ten largest customers in FY2025 by revenue, each with an assigned rep
5. **Commercial gap:** the fifteen highest revenue wholesale customers who never received a trade promotion
6. **Rep performance:** each rep's FY2025 monthly average against their target
7. **Shape of the year FY2024 & FY2025:** monthly revenue, month-on-month change in revenue, and the average of rolling three-month revenue
8. **Margin movement:** why has gross margin fallen from 34.7% (FY2024) to 33.0% (FY2025)?

#### ⚠️Financial years 
- FY2024 = 1 Jul 2023 to 30 Jun 2024
- FY2025 = 1 Jul 2024 to 30 Jun 2025
- The datasets range from 1 July 2023 to 27 June 2025

## 📦Dataset & Connections
The entire dataset is synthetic with no real data. However, the raw data is not uploaded on GitHub. 
| | Table | What it holds | PK | FK |
|---|---|---|---|---|
|1| `sizwe_customers` | One row per customer: trading name, channel, segment, province, credit limit, assigned sales rep | `customer_id` | `rep_id` |
|2| `sizwe_sales_orders` | One row per order: customer, order date, delivery date, sales rep, channel | `order_id` | `customer_id`, `rep_id` |
|3| `sizwe_sales_lines` | One row per order line: SKU, units, unit price, discount, line revenue, cost of goods | `order_id` + `line_no` combination | `order_id`, `sku` |
|4| `sizwe_products` | One row per SKU: product name, product line, pack size, list price, unit cost | `sku` | |
|5| `sizwe_reps` | One row per sales rep: territory, monthly target | `rep_id` | |
|6| `sizwe_trade_promotions` | One row per promotion: customer, sku, start date, end date | `promo_id` | `sku`, `customer_id` |
|7| `sizwe_ar_ledger` | One row per invoice: amount, invoice date, settlement date, payment terms | `invoice_no` | `customer_id` |

### ⚠️Data notes:
- There are 1,400 customers but only 1,337 distinct trading names. Therefore, it's imperative when it comes to the GROUP BY function, to use `customer_id` instead of `trading_name`. 
- Upon looking into the data, every `customer_id` has a valid `rep_id` which has a corresponding `rep_name`. In Task 4, `LEFT JOIN` was used between `sizwe_customers` and `sizwe_reps` for additional safety to ensure no customers without a rep are erased.

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
2. The seven datasets were provided by Witle Academy Data Analytics Bootcamp, and it's not been uploaded in this repo.
3. For those with access to the raw data files (csv): The query to answer each task is ordered. Each is marked with its task number, has corresponding SQL outputs, and has the written answers that sit in the comment directly below its query.

## ✅Key insights

### 💸For Nomsa (the financial director)
- **Growth is even across channels** Wholesale grew 8.85% (+/-R308.2m to R335.4m) and subscription 8.84% (+/-R132.8m to R144.6m). Total revenue rose from +/-R441.0m to +/-R480.0m, and wholesale is about +/-70% of it in both years.
- **Wholesale customers collections problem** 3,454 of wholesale's 28,944 invoices (+/-12%) are still open, against 44 of 19,200 (0.2%) for subscription. On average, wholesale takes 69 days to settle versus 4 for subscription, and holds about R87.8m (wholesale) outstanding against about R750,000 (subscription). It's imperative to note that this only looks at the channels and not time periods. Therefore, it can't show whether payment is getting slower over time. However, we'd need to further look into wholesale customers and their invoices to gain further insight.
- **Profit and margin** House Blend has the highest revenue (+/-R279.5m), but Single Origin has the highest margin (44.27%) for the FY2024 and FY2025 combined.
- **The overall gross margin decline** No product line's margin moved by more than 0.3 percentage points between FY2024 and FY2025. Low-margin Bulk commercial (about 20% margin) grew from 25.02% to 33.65% of revenue, while higher-margin lines lost share, for example Single Origin (19.45% to 17.57%) which has the highest gross margin of all product lines. Offering trade promotions for Single Origin in FY2026 may contribute well to higher overall revenue and profit margin.
- **Seasonal revenue pattern** The revenue falls month on month from August to December and recovers from January to June/July. The quietest month was December for FY2024 (R29.87m, down 13.09% on November) and for FY2025 (R32.6m, down 12.89% on November). For comparison, the rolling 3 months average was R33.34m (Dec 2023) and R36.35m (Dec 2024). 

### 📉For Bongani (the national sales manager)
- **Highest gross margin, relatively small revenue** The Single Origin product line has the highest gross margin (44.24% in FY 2024, 44.31% in FY2025) but contributed only modestly (3rd highest of the 5 product lines) to the total revenue (19.45% in FY2024). Furthermore, its contribution has also decreased to 17.57% in FY2025 from FY2024. It may help with the gross profit for FY2026 by training sales reps to promote this product line, and to offer discounts for large volume orders. 
- **Sales rep performances** It's impressive that many of the reps (16 out of 18) are hitting beyond their monthly targets. 8 out of 18 of them have hit 190% and above of their monthly targets. It's important to keep the high performers well incentivised for bringing in higher revenue. But it's also important to have a discussion with reps who are not hitting their monthly targets (R-011 and R-008) to find out reasons for their underperformance and how they may be further assisted.
- **Big accounts with no promotion** There are some customers who are making large purchases but never been offered trade promotions. The top 3 have contributed R6,224,772.37, R4,448,744.72, and R4,447,225.01 over FY2024 and FY2025 combined. It may be wise to consider offering them trade promotions as they could potentially hop over to another distributor who might offer a discount.
- **One customer dominates.** Halvane Retail Group is the largest account at R38.4m in FY2025, accounting for about 8% of revenue in FY2025 and more than 11 times the 2nd highest revenue customer (R3.38m). 
