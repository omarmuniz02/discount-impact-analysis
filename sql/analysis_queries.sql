
-- ============================================
-- KPI CALCULATIONS
-- ============================================

-- Average Order Value (AOV)
SELECT ROUND(SUM(total_amount) / COUNT(DISTINCT order_id), 2) AS AOV
FROM orders;

-- Total Revenue
SELECT SUM(net_sales * quantity) AS revenue
FROM order_items;

-- Revenue, Orders, AOV
SELECT 
    SUM(total_amount) AS revenue,
    COUNT(DISTINCT order_id) AS orders,
    SUM(total_amount) / COUNT(DISTINCT order_id) AS AOV
FROM orders;

-- ============================================
-- CHANNEL PERFORMANCE
-- ============================================

-- AOV by Sales Channel
SELECT 
    sales_channel,
    SUM(total_amount) AS revenue,
    COUNT(DISTINCT order_id) AS orders,
    SUM(total_amount) / COUNT(DISTINCT order_id) AS AOV
FROM orders
GROUP BY sales_channel
ORDER BY AOV DESC;

-- ============================================
-- BASKET ANALYSIS
-- ============================================

-- Average Items Per Order
WITH order_level AS 
(
SELECT 
    o.order_id,
    o.sales_channel,
    CASE 
        WHEN o.discount_total > 0 THEN 'discounted'
        ELSE 'not discounted'
    END AS discounted,
    SUM(oi.quantity) AS items_per_order
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY 
    o.sales_channel,
    o.order_id,
    discounted
)
SELECT 
    sales_channel,
    discounted,
    COUNT(*) AS orders,
    ROUND(AVG(items_per_order), 2) AS avg_items_per_order
FROM order_level
GROUP BY sales_channel, discounted
ORDER BY avg_items_per_order DESC;

-- Product Diversity Per Order
WITH order_level AS 
(
SELECT 
    o.order_id,
    o.sales_channel,
    CASE 
        WHEN o.discount_total > 0 THEN 'discounted'
        ELSE 'not discounted'
    END AS discounted,
    SUM(oi.quantity) AS items_per_order,
    COUNT(DISTINCT oi.product_id) AS unique_products_per_order
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY 
    o.sales_channel,
    o.order_id,
    discounted
)
SELECT 
    sales_channel,
    discounted,
    COUNT(*) AS orders,
    ROUND(AVG(items_per_order), 2) AS avg_items_per_order,
    ROUND(AVG(unique_products_per_order), 2) AS avg_unique_products_per_order
FROM order_level
GROUP BY sales_channel, discounted
ORDER BY avg_items_per_order DESC;
