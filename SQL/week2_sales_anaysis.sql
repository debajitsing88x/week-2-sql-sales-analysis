/*
PROJECT: Week 2 SQL Sales Analysis
AUTHOR: Debajit Sing
TOOLS: MySQL and MySQL Workbench
DATASET: SQL Sales Dataset - 200 Rows

OBJECTIVE:
Analyse sales performance and identify top customers,
average order value, category performance, regional
performance, monthly trends and order-value segments.
*/

create database if not exists week2_sales_analysis;
use week2_sales_analysis;

create table sales(
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date DATE,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(12,2),
    region VARCHAR(20)
);

show tables;

describe sales;

select count(*) as total_rows
from sales;

select * from sales limit 10;

-- DATA VALIDATION

select order_id, count(*) as duplicate_count from sales group by order_id having count(*)>1;

SELECT
    SUM(customer_name IS NULL) AS missing_customers,
    SUM(order_date IS NULL) AS missing_dates,
    SUM(category IS NULL) AS missing_categories,
    SUM(product_name IS NULL) AS missing_products,
    SUM(quantity IS NULL) AS missing_quantities,
    SUM(unit_price IS NULL) AS missing_unit_prices,
    SUM(total_price IS NULL) AS missing_total_prices,
    SUM(region IS NULL) AS missing_regions
FROM sales;

SELECT * FROM sales WHERE total_price <> quantity * unit_price;

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM sales;

-- BASIC SQL QUERIES

select order_id, customer_name, order_date, product_name, total_price from sales limit 10;

select order_id, customer_name, order_date, product_name, total_price from sales where total_price>20000;

select order_id, customer_name, category, product_name, total_price, region from sales where region = 'South' and category = 'Electronics';

select order_id, customer_name,product_name,total_price from sales order by total_price desc;

select order_id, customer_name,product_name,total_price from sales order by total_price desc limit 10;

-- BUSINESS KPI ANALYSIS

select count(distinct order_id) as total_orders from sales;

select sum(quantity) as total_units_sold from sales;

select sum(total_price) as total_revenue from sales;

select round(avg(total_price),2) as average_order_value from sales;

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(AVG(total_price), 2) AS average_order_value,
    ROUND(MIN(total_price), 2) AS smallest_order,
    ROUND(MAX(total_price), 2) AS largest_order
FROM sales;

-- TOP CUSTOMER ANALYSIS

select customer_name, count(distinct order_id) as number_of_orders,
sum(quantity) as total_units, sum(total_price) as total_spent
from sales group by customer_name order by total_spent desc limit 10;

-- CATEGORY PERFORMANCE

SELECT
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(AVG(total_price), 2) AS average_order_value,
    ROUND(
        SUM(total_price) * 100 /
        (SELECT SUM(total_price) FROM sales),
        2) AS revenue_percentage
   
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;



-- REGIONAL PERFORMANCE

SELECT
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(AVG(total_price), 2) AS average_order_value,
    ROUND(
        SUM(total_price) * 100 /
        (SELECT SUM(total_price) FROM sales),
        2) AS revenue_percentage
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;

-- MONTHLY SALES TREND

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(AVG(total_price), 2) AS average_order_value
FROM sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
order by total_revenue desc, order_month ;

-- ORDER VALUE SEGMENTATION

SELECT
    CASE
        WHEN total_price >= 20000 THEN 'High Value'
        WHEN total_price >= 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_segment,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(
        SUM(total_price) * 100 /
        (SELECT SUM(total_price) FROM sales),
        2) AS revenue_percentage
FROM sales
GROUP BY order_segment
ORDER BY total_revenue DESC;

-- Insight: Low-value orders have the highest order count,
-- while high-value orders contribute the most revenue.

-- ABOVE-AVERAGE ORDER ANALYSIS

SELECT
    order_id,
    customer_name,
    product_name,
    category,
    total_price
FROM sales
WHERE total_price > (
    SELECT AVG(total_price)
    FROM sales
)
ORDER BY total_price DESC;

SELECT COUNT(*) AS above_average_orders
FROM sales
WHERE total_price > (
    SELECT AVG(total_price)
    FROM sales
);

SELECT
    COUNT(*) AS above_average_orders,
    ROUND(SUM(total_price), 2) AS above_average_revenue,
    ROUND(
        SUM(total_price) * 100 /
        (SELECT SUM(total_price) FROM sales),
        2) AS revenue_percentage
FROM sales
WHERE total_price > (
    SELECT AVG(total_price)
    FROM sales
);

-- Insight: 81 of 200 orders (40.5%) are above the overall
-- average order value of 12100.54.

-- JOIN DEMONSTRATION

SELECT
    revenue_summary.category,
    revenue_summary.total_revenue,
    quantity_summary.total_units
FROM
    (
        SELECT
            category,
            ROUND(SUM(total_price), 2) AS total_revenue
        FROM sales
        GROUP BY category
    ) AS revenue_summary
INNER JOIN
    (
        SELECT
            category,
            SUM(quantity) AS total_units
        FROM sales
        GROUP BY category
    ) AS quantity_summary
ON revenue_summary.category = quantity_summary.category
ORDER BY revenue_summary.total_revenue DESC;

-- The source dataset contains one physical table.
-- This query demonstrates INNER JOIN by combining two
-- independently calculated category summaries.

-- TOP CATEGORY IN EACH REGION

WITH category_region_sales AS (
    SELECT
        region,
        category,
        ROUND(SUM(total_price), 2) AS total_revenue
    FROM sales
    GROUP BY region, category
),
ranked_categories AS (
    SELECT
        region,
        category,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM category_region_sales
)
SELECT
    region,
    category,
    total_revenue
FROM ranked_categories
WHERE revenue_rank = 1
ORDER BY total_revenue DESC;

-- PRODUCT PERFORMANCE

SELECT
    category,
    sub_category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(AVG(total_price), 2) AS average_order_value
FROM sales
GROUP BY category, sub_category
ORDER BY total_revenue DESC;

-- Insight: Bread was the highest-revenue subcategory,
-- generating 244529 from 14 orders and 81 units.







































