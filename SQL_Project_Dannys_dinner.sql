/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	s.customer_id,
    SUM(m.price) AS spent
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id ASC;

-- 2. How many days has each customer visited the restaurant?

SELECT 
	customer_id,
    COUNT(DISTINCT order_date) AS visits
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id ASC;

-- 3. What was the first item from the menu purchased by each customer?

-- first create CTE with the ranking by order date
with cte_ranking as (
SELECT 
	s.customer_id,
    s.order_date,
    m.product_name,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m
	ON s.product_id = m.product_id)

-- then use this CTE to perform the query
SELECT 
	customer_id,
    product_name
FROM cte_ranking
WHERE ranking = '1'
GROUP BY customer_id, product_name
ORDER BY customer_id ASC;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	m.product_name,
    COUNT(s.product_id) AS Total_orders
FROM dannys_diner.menu m
LEFT JOIN dannys_diner.sales s
	ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY Total_orders;

-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:
SELECT
  	product_id,
    product_name,
    price
FROM dannys_diner.menu
ORDER BY price DESC
LIMIT 5;
