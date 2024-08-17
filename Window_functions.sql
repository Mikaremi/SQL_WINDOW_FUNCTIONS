CREATE DATABASE Test;

USE Test;

CREATE TABLE [dbo].[Orders]
(
	order_id INT,
	order_date DATE,
	customer_name VARCHAR(250),
	city VARCHAR(100),	
	order_amount MONEY
)
 
INSERT INTO [dbo].[Orders]
SELECT '1001','04/01/2017','David Smith','GuildFord',10000
UNION ALL	  
SELECT '1002','04/02/2017','David Jones','Arlington',20000
UNION ALL	  
SELECT '1003','04/03/2017','John Smith','Shalford',5000
UNION ALL	  
SELECT '1004','04/04/2017','Michael Smith','GuildFord',15000
UNION ALL	  
SELECT '1005','04/05/2017','David Williams','Shalford',7000
UNION ALL	  
SELECT '1006','04/06/2017','Paum Smith','GuildFord',25000
UNION ALL	 
SELECT '1007','04/10/2017','Andrew Smith','Arlington',15000
UNION ALL	  
SELECT '1008','04/11/2017','David Brown','Arlington',2000
UNION ALL	  
SELECT '1009','04/20/2017','Robert Smith','Shalford',1000
UNION ALL	  
SELECT '1010','04/25/2017','Peter Smith','GuildFord',500


SELECT * FROM Orders

-- AGREGATE WINDOW FUNCTIONS 


-- SUM() (without window function)
-- summing the order amount for each city
SELECT city,
SUM(order_amount) AS total_order_amount
FROM Orders
GROUP BY city;

-- with window function
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
SUM(order_amount) OVER ( PARTITION BY [city] ) AS grand_total
FROM Orders;

-- AVG()
-- usually works the same way as an window function
-- I want to find an average order amount for each city and for each month
-- This can be done by specifying multiple fields in the partion list
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
AVG(order_amount) OVER( PARTITION BY city, MONTH(order_date)) AS avg_amount_order
FROM Orders;

-- Min()
-- This will find the minimum value for a specified group or the eintire table if the group is not specified
-- in this case i want to find the smallest order(minimum order) for each city
SELECT order_id, 
order_date,
customer_name,
city,
order_amount,
MIN(order_amount) OVER( PARTITION BY city) AS minimum_order_amount
FROM Orders;

-- Max()
-- Maximum amount of order for ach city
SELECT order_id,
order_date,
city,
order_amount,
MAX(order_amount) OVER( PARTITION BY city) AS maximum_order_amount
FROM Orders;

--COUNT()
-- This normally counts the the records / rows
-- DISTINCT IS NOT SUPPORTED WITH WINDOW FUNCTION COUNT()
--example
-- How many customers placed an order in April 2017,
SELECT city, COUNT(DISTINCT customer_name) as number_of_customers
FROM Orders
GROUP BY city;

-- Using window function
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
COUNT(order_id) OVER( PARTITION BY [city]) AS Total_orders
FROM Orders;





-- RANKING WINDOW FUNCTIONS
-- ranks the values of a specified field and categorise them according to their rank
-- RANK(), DENSE_RANK(), ROW_NUMBER(), NTILE()


-- RANK()
-- Used to give a specific rank to each record based on a specified value, for example salary, ordder amount etc
-- ranking each order by their order amount
SELECT order_id,
order_date,
customer_name,
city,
RANK() OVER( ORDER BY order_amount DESC) AS rank_
FROM Orders; 

-- DENSE_RANK()
-- Identicle to RANK() but it does not skip any rank.
-- if there are two identicle records, DENSE_RANK() will assign the same rank toboth records but not skip the rank
SELECT order_id,
order_date,
customer_name,
city,
DENSE_RANK() OVER( ORDER BY [order_amount] DESC) AS Rank_
FROM Orders;


-- Row_Number()
-- assigns a unique row number to each record
--the rows number will be reset for each partition if PARTITION BY is specified.
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
ROW_NUMBER() OVER( ORDER BY [order_id]) AS row_number
FROM Orders;


-- INCLUDING partition by
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
ROW_NUMBER() OVER( PARTITION BY city ORDER BY order_amount DESC) AS ROW_number
FROM Orders;


--NTILE()
-- Helps you to identify what percentile(or quartile, or any other subdivison) a given row falls into
--Example (creating quartile based on the order amount)
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
NTILE(4) OVER (ORDER BY order_amount) AS row_number
FROM Orders;





-- VALUE WINDOW FUNCTIONS
-- used to find the first, last,previous and next values.
-- LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE()

-- LAG() and LEAD()
-- LAG() allows to access data form the prevous row in the same result set withous the use of any SQL joins
-- Example(script to find previous order date)
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
-- in below line, 1 indicates check for prevous row of the current row
LAG(order_date,1) OVER(ORDER BY order_date) as prev_order_date
FROM Orders;


--LEAD() function allows to access the data from the next row in the same result set without any use of SQL joins.
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
-- in below line, 1 indicate check for next row of the current row
LEAD(order_date,1) OVER(ORDER BY order_date) AS next_order_date
FROM Orders



--FIRST_VALUE() and LAST_VALUE()
--They help you to identify first and alst record within a partition or entire table if PARTITION BY is not specified
-- THE ORDER_BY clause is mandatory for FIRST_VALUE() and LAST_VALUE() functions
-- find the last order of each city 
SELECT order_id,
order_date,
customer_name,
city,
order_amount,
FIRST_VALUE(order_date) OVER( PARTITION BY city ORDER BY city ) AS first_oder_date,
LAST_VALUE(order_date) OVER( PARTition BY city ORDER BY city ) AS last_order_date
FROM Orders