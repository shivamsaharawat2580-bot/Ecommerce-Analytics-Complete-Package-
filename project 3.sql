CREATE TABLE customerp3 (
customer_id INT PRIMARY KEY,
customer_name varchar(100),
gender varchar(50),
city varchar(50),
state varchar(100),
signup_date date
);

CREATE TABLE productp3 (
product_id INT PRIMARY KEY,
product_name varchar(100),
category varchar(100),
brand varchar(100),
price INT
);

CREATE TABLE employeep3 (
employee_id INT PRIMARY KEY,
employee_name varchar(100),
department varchar(100),
manager varchar(50),
joining_date date
);

CREATE TABLE orderp3 (
order_id INT PRIMARY KEY,
customer_id INT,
employee_id INT,
order_date DATE
);

CREATE TABLE orderdetailsp3 (
order_detail_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
discount INT
);

CREATE TABLE returnp3 (
return_id INT PRIMARY KEY,
order_id INT,
return_reason VARCHAR(100),
return_date DATE
);


SELECT * FROM customerp3;
SELECT * FROM productp3;
SELECT * FROM employeep3;
SELECT * FROM orderp3;
SELECT * FROM orderdetailsp3;	
SELECT * FROM returnp3;

-- Q1. Data Quality: Count rows in each table and check for duplicate primary keys.

-- Count rows in Customers
SELECT COUNT(*) AS total_customers
FROM Customerp3;

-- Count rows in Products
SELECT COUNT(*) AS total_products
FROM Productp3;

-- Count rows in Employees
SELECT COUNT(*) AS total_employees
FROM Employeep3;

-- Count rows in Orders
SELECT COUNT(*) AS total_orders
FROM Orderp3;

-- Count rows in Order_Details
SELECT COUNT(*) AS total_order_details
FROM OrderDetailsp3;

-- Count rows in Returns
SELECT COUNT(*) AS total_returns
FROM Returnp3;

-- Check duplicate customer IDs
SELECT customer_id, COUNT(*)
FROM Customerp3
GROUP BY customer_id
HAVING COUNT(*) > 1;

--same we can calculate duplicate

-- Q2. Data Quality: Identify columns containing NULL or blank values that need investigation.
SELECT COUNT(customer_id), COUNT(customer_name),COUNT(gender),COUNT(city),COUNT(state),COUNT(signup_date)
FROM customerp3
WHERE customer_id IS NULL;
WHERE customer_name IS NULL
WHERE gender IS NULL
WHERE city IS NULL
WHERE state IS NULL
WHERE signup_date IS NULL;


-- Q3. Sales Overview: Calculate total revenue after discounts.
SELECT SUM(p.price*od.quantity*(1-od.discount/100.00)) AS toal_revenue
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id; 

-- Q4. Sales Overview: Count the number of distinct orders placed.
SELECT COUNT(DISTINCT order_id) AS total_order
FROM orderdetailsp3;


-- Q5. Sales Overview: Calculate the total quantity of products sold.
SELECT SUM(quantity) AS total_orders
FROM orderdetailsp3;


-- Q6. Time Trend: Analyze the monthly revenue trend.
SELECT SUM(p.price*od.quantity) AS total_revenue,EXTRACT(MONTH FROM o.order_date) AS month,
 EXTRACT(YEAR FROM o.order_date) AS year
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
JOIN orderp3 o ON o.order_id=od.order_id
GROUP BY 2,3; 

-- Q7. Product Analysis: Find the product categories that generate the most revenue.
SELECT p.category,SUM(p.price*od.quantity) AS total_revenue
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
GROUP BY 1
ORDER BY total_revenue desc limit 1; 


-- Q8. Product Analysis: Find the Top 10 products by revenue.
SELECT p.product_name,SUM(p.price*od.quantity) AS total_revenue
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
GROUP BY 1
ORDER BY total_revenue desc limit 10; 

-- Q9. Product Analysis: Identify products with high quantities sold but relatively low revenue.
SELECT p.product_name,SUM(p.price*od.quantity) AS total_revenue,SUM(od.quantity) AS total_quantity
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
GROUP BY 1
ORDER BY total_quantity DESC, total_revenue ASC LIMIT 10; 

-- Q10. Customer Analysis: Find the Top 10 customers by revenue.
SELECT SUM(p.price*od.quantity) AS total_revenue,c.customer_name
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
JOIN orderp3 o ON o.order_id=od.order_id
JOIN customerp3 c ON c.customer_id=o.customer_id
GROUP BY 2
ORDER BY total_revenue DESC LIMIT 10; 

-- Q11. Customer Analysis: Calculate the percentage of total revenue contributed by the Top 10 customers.
WITH customer_revenue AS (
SELECT c.customer_name,c.customer_id,SUM(p.price*od.quantity) AS total_revenue 
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
JOIN orderp3 o ON o.order_id=od.order_id
JOIN customerp3 c ON c.customer_id=o.customer_id
GROUP BY 1,2
ORDER BY total_revenue DESC LIMIT 10
)
SELECT SUM(total_revenue)*100.0/(SELECT SUM(p.price*od.quantity) 
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id) AS total_revenue_percentage_10_cx
FROM customer_revenue; 


-- Q12. Customer Analysis: Count customers who placed more than one order.
SELECT SUM(c.customer_id) AS total_customer,COUNT(DISTINCT o.order_id) AS total_order
FROM customerp3 c 
JOIN orderp3 o ON o.customer_id=c.customer_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_order DESC; 

-- Q13. Customer Analysis: Calculate the average revenue per active customer.
SELECT SUM(p.price*od.quantity)/COUNT(DISTINCT o.customer_id)
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
JOIN orderp3 o ON o.order_id=od.order_id; 

-- Q14. Geography: Identify the state or city that generates the highest revenue.
SELECT c.city,SUM(p.price*od.quantity) AS total_revenue 
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
JOIN orderp3 o ON o.order_id=od.order_id
JOIN customerp3 c ON c.customer_id=o.customer_id
GROUP BY 1
ORDER BY total_revenue DESC LIMIT 1;

-- Q15. Employee Analysis: Identify employees associated with the highest revenue.
SELECT e.employee_name,SUM(p.price*od.quantity) AS total_revenue 
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
JOIN orderp3 o ON o.order_id=od.order_id
JOIN employeep3 e ON e.employee_id=o.employee_id
GROUP BY 1
ORDER BY total_revenue DESC;  

-- Q16. Discount Analysis: Calculate the revenue associated with each discount level.
 
-- Q17. Returns: Count the total return records and calculate the order return rate.
SELECT COUNT(order_id) AS total_return
FROM returnp3; 

SELECT COUNT(DISTINCT r.order_id)*100.0/COUNT(DISTINCT o.order_id) AS return_rate
FROM orderp3 o
LEFT JOIN returnp3 r ON r.order_id=o.order_id;

-- Q18. Returns: Identify the most common return reasons.
SELECT COUNT(return_reason) AS total_return,return_reason
FROM returnp3 
GROUP BY 2
ORDER BY total_return DESC LIMIT 1; 

-- Q19. Returns: Identify the products or categories with the highest return rate.
SELECT p.product_name,p.category,p.product_id,COUNT(DISTINCT r.order_id)*100.0/COUNT(DISTINCT o.order_id) AS return_rate
FROM orderp3 o
LEFT JOIN returnp3 r ON r.order_id=o.order_id
JOIN orderdetailsp3 od ON od.order_id=o.order_id
JOIN productp3 p ON p.product_id=od.product_id
GROUP BY 1,2,3
ORDER BY return_rate DESC LIMIT 10; 

-- Q20. Advanced Analysis: Rank product categories by revenue and calculate each category's 
--share of total revenue.
SELECT p.category,SUM(p.price*od.quantity) AS total_revenue
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
GROUP BY 1
ORDER BY total_revenue DESC ;

SELECT p.category,SUM(p.price*od.quantity) AS total_revenue
FROM productp3 p
JOIN orderdetailsp3 od ON od.product_id=p.product_id
GROUP BY 1; 

