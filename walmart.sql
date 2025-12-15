
--Business Problems

--Q.1 Find different payment method and number of transactions, number of qty sold
SELECT
    payment_method,
    COUNT(*) AS transactions,
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;


--2. Identify the highest-rated category in each branch, displaying the branch, category,AVG RATING

SELECT branch,category,avg_rating FROM
(SELECT
  branch,
  category,
  AVG(rating) AS avg_rating,
  RANK() OVER (
    PARTITION BY branch
    ORDER BY AVG(rating) DESC
  ) AS rating_rank
FROM walmart
GROUP BY branch, category)
WHERE rating_rank=1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT branch,
       day_name,
       transaction_count
FROM (
    SELECT
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
        COUNT(*) AS transaction_count,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS t_rank
    FROM walmart
    GROUP BY branch, day_name
) 
WHERE t_rank = 1;

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT payment_method,SUM(quantity) as Total_quantity
FROM  walmart
GROUP BY payment_method;


-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
SELECT 
category,city,
AVG(rating) as average_rating,
MIN(rating) as minimum_rating,
MAX(rating) as maximum_rating
FROM walmart
GROUP BY  category,city;


-- Q.6
-- List category and total_profit, ordered from highest to lowest profit.
SELECT 
category,ROUND(SUM(unit_price * quantity * profit_margin)::numeric, 2) as total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte 
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT branch, payment_method as Top_payment_method, total_transactions
FROM cte
WHERE rank = 1;


-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT branch,COUNT(*) invoices,
CASE
  WHEN time>'6:00:00' AND time < '12:00:00' THEN 'Morning'
  WHEN time>='12:00:00' AND time <'18:00:00' THEN 'Afternoon'
  ELSE 'Evening'
END as shift
FROM walmart
GROUP BY branch,shift;


-- #9 Identify 5 branch with highest decrese ratio in revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100

WITH revenue_ly AS (
    SELECT
        branch,
        SUM(unit_price * quantity) AS revenue_ly
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
),
revenue_curr AS (
    SELECT
        branch,
        SUM(unit_price * quantity) AS revenue_curr
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
)
SELECT
    branch,
    ROUND(
        ((revenue_ly - revenue_curr) / revenue_ly)::numeric * 100,
        2
    ) AS revenue_decrease_rate,
    RANK() OVER (
        ORDER BY ((revenue_ly - revenue_curr) / revenue_ly) 
    ) AS rnk
FROM revenue_ly
JOIN revenue_curr USING (branch)
WHERE revenue_ly > 0
ORDER BY revenue_decrease_rate
LIMIT 5;




