/*
Project: Pizza Sales Performance Analysis
Dataset: 1 Year of Sales Data (4 Tables)
Author: [Aryan Saklani]
Tools: MySQL Workbench
*/

-- SECTION 1: BASIC QUERIES --
-- qus 1
-- Retrieve the total number of orders placed.

select count(order_id)as total_orders from orders;

-- qus 2
-- Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(o.quantity * p.price) AS total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id;

-- qus 3
-- Identify the highest-priced pizza.
 SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- qus 4
-- Identify the most common pizza size ordered.
 SELECT 
    size, COUNT(order_details_id) AS total_orders
FROM
    order_details AS o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id
GROUP BY (size)
ORDER BY total_orders DESC
LIMIT 1;

-- qus 5
-- List the top 5 most ordered pizza types along with their quantities.
 SELECT 
    pt.name, SUM(quantity) AS total_quantity
FROM
    order_details AS o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY (pt.name)
ORDER BY total_quantity DESC
LIMIT 5;
 
-- SECTION 2: Intermediate QUERIES --

-- qus 6
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(o.quantity) AS total_quantity
FROM
    order_details AS o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY (pt.category)
ORDER BY total_quantity DESC;

-- qus 7
-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS time_of_order,
    COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY (time_of_order)
ORDER BY time_of_order ;

-- qus 8
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    round(AVG(total_orders),0) as average_pizzas_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(quantity) AS total_orders
    FROM
        order_details AS od
    JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY o.order_date) AS abc;


-- qus 9
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- SECTION 3: Advanced QUERIES --

-- qus 10
-- Calculate the percentage contribution of each pizza type to total revenue.
-- total revenue
SELECT 
    SUM(od.quantity * p.price) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id;
-- percentage contribution of each pizza type
SELECT 
    pt.category,
    (SUM(od.quantity * p.price) * 100 / (SELECT 
            SUM(od.quantity * p.price) AS total_revenue
        FROM
            order_details AS od
                JOIN
            pizzas AS p ON od.pizza_id = p.pizza_id)) AS percentage_contribution
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category;


-- qus 11
-- Analyze the cumulative revenue generated over time.
with my_cte as
(select o.order_date,sum(od.quantity*p.price) as per_date_revenue from order_details as od
join orders as o 
on od.order_id=o.order_id
join pizzas as p
on od.pizza_id=p.pizza_id
group by o.order_date)
select order_date,per_date_revenue,
sum(per_date_revenue)over(order by (order_date)) as cumulative_revenue
from my_cte;


-- qus 12
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from
(with my_cte as (
select pt.category,pt.name,sum(od.quantity*p.price) as net_category_revenue from order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
join pizza_types as pt
on pt.pizza_type_id=p.pizza_type_id
group by pt.category,pt.name)
select category,name,net_category_revenue,
rank()over(partition by(category)order by(net_category_revenue)desc )as rank_number
from my_cte)
as rank_pizza
where rank_number <=3;






