CREATE DATABASE e_commerce_company;
USE e_commerce_company;


DESC customers;
DESC orderdetails;
DESC orders;
DESC products;

SELECT * FROM customers;
SELECT * FROM orderdetails;
SELECT * FROM orders;
SELECT * FROM products;




## Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.
-- Delhi: 16, Chennai: 15, Jaipur: 11
SELECT
    location,
    COUNT(customer_id) AS number_of_customers
FROM customers
GROUP BY location
ORDER BY number_of_customers DESC
LIMIT 3;


## Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.

WITH numberoforders AS
    (SELECT
        customer_id,
        COUNT(order_id) AS NumberOfOrders
    FROM orders
    GROUP BY customer_id)
    
    SELECT
        NumberOfOrders,
        COUNT(customer_id) AS CustomerCount
    FROM numberoforders
    GROUP BY NumberOfOrders
    ORDER BY NumberOfOrders ASC;
    

## Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
-- Product ID 1 & 8
SELECT
    product_id AS Product_Id,
    AVG(quantity) AS AvgQuantity,
    SUM(price_per_unit*quantity) AS totalrevenue
FROM orderdetails
GROUP BY Product_Id
HAVING
    AvgQuantity =2 AND
    MAX(price_per_unit)
ORDER BY totalrevenue DESC;


## For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.
-- Electronics: 79, Wearable Tech: 61, Photography: 45
SELECT
    p.category,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM products AS p
JOIN orderdetails AS od
    ON p.product_id = od.product_id
JOIN orders AS o
    ON od.order_id = o.order_id
GROUP BY p.category
ORDER BY unique_customers DESC;


## Analyze the month-on-month percentage change in total sales to identify growth trends.
WITH total_sales AS (
SELECT
    CONCAT((YEAR(order_date)),'-',LPAD((MONTH(order_date)),2,0)) AS Month,
    SUM(total_amount) AS TotalSales
FROM orders
GROUP BY Month)

SELECT
    Month,
    TotalSales,
    ROUND(((TotalSales - LAG(TotalSales) OVER(ORDER BY Month))/LAG(TotalSales) OVER(ORDER BY Month)*100),2) AS PercentChange
FROM total_sales;


## Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
WITH avg_order AS
(SELECT
    CONCAT((YEAR(order_date)),'-',LPAD((MONTH(order_date)),2,0)) AS Month,
    ROUND(AVG(total_amount),2) AS AvgOrderValue
FROM orders
GROUP BY Month)

SELECT
    Month,
    AvgOrderValue,
    ROUND((AvgOrderValue - LAG(AvgOrderValue) OVER(ORDER BY Month)),2) AS ChangeInValue
FROM avg_order
ORDER BY ChangeInValue DESC;


## Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
SELECT * FROM orderdetails;

SELECT
    p.product_id,
    p.name AS product_name,
    COUNT(od.order_id) AS sales_frequency
FROM orderdetails od
JOIN products p
    ON od.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY sales_frequency DESC
LIMIT 5;


## Top Revenue Generating Products -- Laptop 15*Pro - 7560000
SELECT
    p.name AS product_name,
    SUM(od.price_per_unit * od.quantity) AS total_revenue
FROM orderdetails od
JOIN products p
ON od.product_id = p.product_id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 5;


## List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
SELECT * FROM orderdetails;
SELECT * FROM orders;
SELECT * FROM products;

SELECT
    p.product_id AS Product_id,
    p.name AS Name,
    COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
FROM orders AS o
JOIN orderdetails AS od
    ON o.order_id = od.order_id
JOIN products AS p
    ON od.product_id = p.product_id
GROUP BY
	Product_id,
    Name
HAVING UniqueCustomerCount < (SELECT 0.4*COUNT(DISTINCT customer_id) FROM customers);


## Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
SELECT * FROM orders;
WITH purchase_month AS
(SELECT
    customer_id,
    CONCAT(YEAR(order_date),'-',LPAD(MONTH(order_date),2,0)) AS purchase_month
FROM orders
GROUP BY customer_id, purchase_month)

SELECT
    MIN(purchase_month) AS FirstPurchaseMonth,
    COUNT(customer_id) AS TotalNewCustomers
FROM purchase_month;



## Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
SELECT
    CONCAT(YEAR(order_date),'-',LPAD(MONTH(order_date),2,0)) AS Month,
    SUM(total_amount) AS TotalSales
FROM orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;