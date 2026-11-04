-- Marketplace Operations & Profitability | SQL analysis (SQLite compatible)
-- Import CSVs as marketplace_orders and seller_directory.

-- 1. Executive KPI dashboard
SELECT COUNT(*) AS total_orders,
       SUM(CASE WHEN is_cancelled=0 THEN 1 ELSE 0 END) AS completed_orders,
       ROUND(SUM(net_sales),2) AS net_sales,
       ROUND(SUM(profit_proxy),2) AS profit_proxy,
       ROUND(100.0*SUM(is_late_delivery)/COUNT(*),2) AS late_delivery_pct,
       ROUND(100.0*SUM(is_refunded)/COUNT(*),2) AS refund_order_pct,
       ROUND(100.0*SUM(is_cancelled)/COUNT(*),2) AS cancellation_pct,
       ROUND(AVG(customer_rating),2) AS avg_rating
FROM marketplace_orders;

-- 2. Profitability by category
SELECT product_category, COUNT(*) orders,
       ROUND(SUM(net_sales),2) net_sales,
       ROUND(SUM(profit_proxy),2) profit_proxy,
       ROUND(100.0*SUM(profit_proxy)/NULLIF(SUM(net_sales),0),2) profit_margin_pct,
       ROUND(AVG(customer_rating),2) avg_rating
FROM marketplace_orders GROUP BY product_category
ORDER BY profit_proxy DESC;

-- 3. Sales channel performance
SELECT sales_channel, COUNT(*) orders,
       ROUND(SUM(net_sales),2) net_sales,
       ROUND(SUM(profit_proxy),2) profit_proxy,
       ROUND(AVG(profit_proxy),2) avg_profit_per_order,
       ROUND(100.0*SUM(is_late_delivery)/COUNT(*),2) late_delivery_pct,
       ROUND(100.0*SUM(is_refunded)/COUNT(*),2) refund_order_pct
FROM marketplace_orders GROUP BY sales_channel
ORDER BY profit_proxy DESC;

-- 4. Monthly sales and profit trend with MoM change
WITH monthly AS (
 SELECT substr(order_date,1,7) month,
        SUM(net_sales) net_sales, SUM(profit_proxy) profit_proxy,
        COUNT(*) orders
 FROM marketplace_orders GROUP BY substr(order_date,1,7)
)
SELECT month, ROUND(net_sales,2) net_sales, ROUND(profit_proxy,2) profit_proxy, orders,
       ROUND(net_sales-LAG(net_sales) OVER (ORDER BY month),2) net_sales_mom_change,
       ROUND(100.0*(net_sales-LAG(net_sales) OVER (ORDER BY month))/
         NULLIF(LAG(net_sales) OVER (ORDER BY month),0),2) net_sales_mom_pct
FROM monthly ORDER BY month;

-- 5. Late delivery by shipping mode and region
SELECT shipping_mode, region, COUNT(*) orders,
       ROUND(100.0*SUM(is_late_delivery)/COUNT(*),2) late_delivery_pct,
       ROUND(AVG(delivery_days),2) avg_delivery_days,
       ROUND(AVG(customer_rating),2) avg_rating
FROM marketplace_orders
GROUP BY shipping_mode, region
ORDER BY late_delivery_pct DESC;

-- 6. Seller scorecard: minimum sample size guard
SELECT s.seller_id, s.seller_tier, COUNT(o.order_id) orders,
       ROUND(SUM(o.net_sales),2) net_sales,
       ROUND(SUM(o.profit_proxy),2) profit_proxy,
       ROUND(100.0*SUM(o.is_late_delivery)/COUNT(o.order_id),2) late_delivery_pct,
       ROUND(100.0*SUM(o.is_refunded)/COUNT(o.order_id),2) refund_order_pct,
       ROUND(AVG(o.customer_rating),2) avg_rating
FROM seller_directory s JOIN marketplace_orders o USING(seller_id)
GROUP BY s.seller_id,s.seller_tier
HAVING COUNT(o.order_id) >= 20
ORDER BY late_delivery_pct DESC;

-- 7. Refund and profit leakage by category
SELECT product_category,
       ROUND(SUM(refund_amount),2) refund_value,
       ROUND(SUM(shipping_cost+fulfillment_cost+payment_fee),2) operating_costs,
       ROUND(SUM(profit_proxy),2) profit_proxy
FROM marketplace_orders
GROUP BY product_category ORDER BY refund_value DESC;

-- 8. High-value orders with service failure (human investigation queue)
SELECT order_id, order_date, region, product_category, sales_channel, seller_id,
       net_sales, profit_proxy, shipping_mode, delivery_days, is_late_delivery,
       is_refunded, customer_rating
FROM marketplace_orders
WHERE is_cancelled=0 AND (is_late_delivery=1 OR is_refunded=1 OR customer_rating<=2)
ORDER BY net_sales DESC LIMIT 300;

-- 9. Data quality checks
SELECT 'duplicate_order_ids' AS check_name, COUNT(*)-COUNT(DISTINCT order_id) issue_count
FROM marketplace_orders
UNION ALL SELECT 'negative_net_sales', COUNT(*) FROM marketplace_orders WHERE net_sales < 0
UNION ALL SELECT 'invalid_rating', COUNT(*) FROM marketplace_orders WHERE customer_rating NOT BETWEEN 1 AND 5;

-- 10. Revenue scenario: illustrative margin improvement, not a forecast
SELECT ROUND(SUM(net_sales),2) current_net_sales,
       ROUND(SUM(profit_proxy),2) current_profit_proxy,
       ROUND(SUM(profit_proxy)*0.05,2) illustrative_profit_uplift_if_5pct_improvement
FROM marketplace_orders;
