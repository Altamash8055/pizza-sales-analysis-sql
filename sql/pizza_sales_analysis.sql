create database pizzhut;
use pizzhut;

-- 1.Retrive the total numbers of orders placed.

select count(order_id) as total_orders
from orders;

-- 2.Calculated the total revenue generated from pizza sales

select round(sum(od.quantity * p.price),2) as total_revenue
from orders_details as od
join pizzas as p
on od.pizza_id = p.pizza_id  ;

-- 3.identify the highest-priced pizza

-- using basic join + ORDER BY and limit 
select pt.name , p.price
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id =p.pizza_type_id
order by p.price desc
limit 1;

-- using subquery + join
SELECT pt.name,p.price
FROM pizza_types AS pt
JOIN pizzas AS p
    ON pt.pizza_type_id = p.pizza_type_id
WHERE p.price = (
    SELECT MAX(price)
    FROM pizzas
);

-- 4.Identify the most common pizza size ordered

select p.size ,count(od.order_details_id) as order_count
from pizzas as p
join orders_details as od
on p.pizza_id =od.pizza_id
group by p.size order by order_count desc ;

-- 5.list the top 3 most ordered pizza types along with their quantities

select pt.name,sum(od.quantity) as quantity
from orders_details as od
join pizzas as p
on od.pizza_id =p.pizza_id
join pizza_types as pt
on p.pizza_type_id =pt.pizza_type_id
group by pt.name
order by quantity desc
limit 3;

-- 6.join the necessary tables to find the total quantity of each pizza category ordered

select pt.category,sum(od.quantity) as quantity
from orders_details as od
join pizzas as p
on od.pizza_id =p.pizza_id
join pizza_types as pt
on p.pizza_type_id =pt.pizza_type_id
group by pt.category
order by quantity desc
limit 3;

-- 7.determine the distribution of orders by hour of the day

SELECT 
    HOUR(order_time) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY HOUR(order_time)
ORDER BY order_hour ;

-- 8.join relevant tables to find the category wise distribution of pizzas

select category,count(name) as categories_count
from pizza_types
group by category;


-- 9.determine the top 3 most ordered pizza types based on revenue

select pt.name,sum(od.quantity * p.price) as revenue
from orders_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.name 
order by revenue desc
limit 3;

-- 10.Calculate the percentage contribution of each pizza type to total revenue

select pizza_types.category,
round(sum(orders_details.quantity*pizzas.price) /
(select round(sum(orders_details.quantity*pizzas.price),2) as total_sales
from orders_details 
join pizzas 
on pizzas.pizza_id=orders_details.pizza_id)*100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue desc;

-- 11 analyze the cumulative revenue generated over time

SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM
(
    SELECT orders.order_date,
           SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM orders_details
    JOIN pizzas
        ON orders_details.pizza_id = pizzas.pizza_id
    JOIN orders
        ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) AS sales;
