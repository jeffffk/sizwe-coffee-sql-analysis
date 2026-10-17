# Sizwe Coffee: SQL Analysis of Sales, Margins and Collections

## Project Overview
Sizwe Coffee is a fictional company based in South Africa that buys green coffee beans, roasts them, and sells to about 1400 businesses, including grocery chains, hotels, cafés, offices, restaurants and retailers. It doesn't own any retail stores. Roasted coffee beans are sold to the businesses either via wholesale contracts (large volumes) or subscription (monthly delivery). There are five product lines: House Blend, Single Origin, Bulk Commercial, Decaf, and Capsules. 

This project is a SQL assignment from the Witle Academy data analytics bootcamp. I answered eight business questions for two stakeholders, Nomsa, the Financial Director, and Bongani, the National Sales Manager, using Databricks SQL. All queries and written answers are in [`queries.sql`](queries.sql).

### The eight questions:
1. **Channel performance:** revenue by channel for FY2024 and FY2025, with growth from FY2024 to FY2025.
2. **Profit by product line:** by product line - revenue, cost of goods, gross profit and gross margin.
3. **Collections problem:** by channel - invoices settled and open, days to settle and value outstanding.
4. **Top ten accounts:** the ten largest customers by FY2025 revenue, with owning rep.
5. **Commercial gap:** the fifteen highest-revenue wholesale customers who never received a trade promotion.
6. **Rep performance:** each rep's FY2025 monthly average against their target.
7. **Shape of the year FY2024 & FY2025:** monthly revenue, month-on-month change in revenue, and the average of rolling three-month revenue.
8. **Margin movement:** why has gross margin fell from 34.7% (FY2024) to 33.0% (FY2025)?

Financial years run 1 July to 30 June: FY2024 is 1 Jul 2023 to 30 Jun 2024 and FY2025 is 1 Jul 2024 to 30 Jun 2025. The data runs from 1 July 2023 to 27 June 2025.

## Dataset & Connections
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

### Data notes:
- There are 1,400 customers but only 1,337 distinct trading names. Therefore, it's imperative to GROUP BY `customer_id` instead of `trading_name`.
- Every customer has a valid `rep_id` with a `rep_name`. However, in Task 4, `LEFT JOIN` was used between `sizwe_customers` and `sizwe_reps` for additional safety to ensure no customers without a rep are erased.

## Skills demonstrated
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

## How to run
1. Tool: Databricks SQL
2. The seven tables were provided by Witle Academy Data Analytics Bootcamp, and it's not been uploaded in this repo.
3. For those with access to the raw data files (csv): open `queries.sql`. The queries to answer the questions in each task is available, in order. Each is marked with its task number, and the written answer sits in the comment directly below it.

## Key insights

### For Nomsa
- **Growth is even across channels.** Wholesale grew 8.85% (R308.2m to R335.4m) and subscription 8.84% (R132.8m to R144.6m). Total revenue rose from R441.0m to R480.0m, and wholesale is about 70% of it in both years.
- **Collections are a wholesale problem.** 3,454 of wholesale's 28,944 invoices (12%) are still open, against 44 of 19,200 (0.2%) for subscription. Wholesale takes 69 days to settle versus 4, and holds about R87.8m outstanding against about R750,000. This compares channels, not time periods, so it can't show whether payment is getting slower.
- **Profit and margin are different leaders.** House Blend earns the most gross profit (R107.1m), but Single Origin has the highest margin (44.27%).
- **The margin decline is a mix effect.** No product line's margin moved by more than 0.3 percentage points. Low-margin Bulk commercial (about 20% margin) grew from 25.02% to 33.65% of revenue, while higher-margin lines lost share, for example Single Origin (19.45% to 17.57%).
- **Revenue is seasonal.** It falls month on month from July to December and recovers from January to June. The quietest month is December 2023 (R29.87m, down 13.09% on November).

### For Bongani
- **One customer dominates.** Halvane Retail Group is the largest account at R38.4m in FY2025, about 8% of revenue and more than 11 times the next account. The top ten together bring in about R61.4m (12.8% of revenue).
- **Big accounts with no promotion.** Five of the ten largest FY2025 accounts have never had a trade promotion. The biggest three by total revenue are Umhlanga Fresh 108 (Gauteng, R6.22m), Ridgeway Foods 308 (KwaZulu-Natal, R4.45m) and Kalahari Kitchen 42 (Gauteng, R4.45m). I recommend the territory reps contact them directly.
- **Reps are beating their targets.** 16 of 18 reps exceeded their monthly target in FY2025, and eight are above 190%. The best is Karabo van Wyk (250.32%) and the lowest Johan Naidoo (77.63%), with Sipho Steyn just under (97.99%). Such large overshoots suggest the targets may be set too low.

## Limitations
- Task 3 compares channels, not time periods.
- Task 5 ranks customers on all-time revenue (both years), while Task 4 uses FY2025 only, so a customer's figure differs between them.
- The rolling average in Task 7 uses the three months before each month and excludes the current one. June 2025 is a partial month (data ends 27 June).
