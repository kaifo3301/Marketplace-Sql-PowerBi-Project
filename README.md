# Marketplace Operations & Profitability Analytics (SQL + Power BI)

## Project goal
Build a business-focused analytics solution for an online marketplace to understand profitability, late deliveries, refunds, cancellations, and seller performance—and turn findings into operational actions.

**Data note:** All records are synthetic and generated for portfolio practice. Do not present findings as real company results or measured business impact.

## Business questions
- Which product categories and sales channels generate the most net sales and profit proxy?
- Where are refunds, cancellations, and late deliveries concentrated?
- Which sellers may need operational review?
- What should the business prioritize to improve customer experience and profitability?
- How should changes be measured?

## Files
- `data/marketplace_orders.csv` — 12,000 synthetic order records with sales, cost, service and rating fields.
- `data/seller_directory.csv` — seller tier and service target lookup.
- `sql/marketplace_analysis.sql` — 10 SQLite queries for KPIs, profitability, delivery, sellers, leakage and QA.
- `powerbi/Power_BI_Model_and_DAX.md` — star-schema guidance, relationships, DAX measures, dashboard pages and design notes.
- `reports/marketplace_business_report.pdf` — executive report, decisions, findings and action plan.
- `docs/presentation_guide.md` — interview talk track and likely questions.
- `resume_bullets.md` — resume bullets based on project scope.

## Recommended Power BI model
For an intermediate project, use `marketplace_orders` as the fact table and `seller_directory` as a dimension table, linked on `seller_id`. For a stronger model, create a dedicated Date table and relate it to `order_date`. Use single-direction, one-to-many relationships where possible.

## Run end to end
1. Load the CSV files into SQLite and execute the SQL file.
2. Open Power BI Desktop and import the CSVs, or connect to your cleaned SQL outputs.
3. Create the relationships and measures described in `powerbi/Power_BI_Model_and_DAX.md`.
4. Build the three dashboard pages: Executive Overview, Operations & Customer Experience, Seller & Category Performance.
5. Validate totals against SQL before publishing.
6. Add screenshots of the finished dashboard to this repository; the included project contains the model and build instructions, not a native `.pbix` file.

## Metric definitions
- Net sales: generated sales after discounts, refunds, and cancellations as encoded in the dataset.
- Profit proxy: net sales minus simulated cost of goods, shipping, fulfillment, and payment fees. It is not audited accounting profit.
- Late-delivery rate: share of all orders marked late; specify denominator consistently.
- Refund-order rate: share of all orders flagged refunded; refund amount can be partial.
- Scenario uplift: arithmetic sensitivity assumption, not a forecast or measured impact.

## Recommended actions
- Review seller/region/shipping combinations with high late-delivery rates and adequate sample sizes.
- Investigate categories with high refund value or weak profit proxy.
- Compare channels on profit per order, service quality, and order mix rather than sales alone.
- Pilot service improvements and measure impact using a controlled test or pre/post analysis with clear caveats.

## Limitations
Synthetic data, simplified costs, no marketing spend/CAC, no inventory/stockout events, no SLA timestamp detail, and no real intervention outcomes. Treat seller scorecards as investigation queues, not automatic penalties.
