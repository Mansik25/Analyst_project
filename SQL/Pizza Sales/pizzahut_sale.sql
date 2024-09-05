-- 1) Retriving the total numbers of orders placed.
select count(order_id) as Total_orders from orders;

-- 2) Calculate the total revenue generated from pizza sales.
SELECT 
    round(SUM(order_details.quantity * pizzas.price),2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3) Identify the highest price pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4) Identify the most common size pizza ordered.
SELECT 
  pizzas.size, count(order_details.order_detail_id) as Total_order
FROM
    pizzas
        JOIN
  order_details ON pizzas.pizza_id = order_details.pizza_id
group BY pizzas.size
order by Total_order desc limit 1;

-- 5) List the top 5 most orderd pizza types along with their quantities.

SELECT 
    pizza_types.name,
    sum(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC limit 5;

-- 6) Join the necessary table to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Total_Quantity_Ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- 7)Determine the distribution of ordered by hours of the day.
SELECT 
    HOUR(order_time) as hours, COUNT(order_id) as Total_Ordered
FROM
    orders
GROUP BY HOUR(order_time);

-- 8) Find the category_wise distribution of pizza.
SELECT 
    category, COUNT(name) AS Total_pizza_type
FROM
    pizza_types
GROUP BY category;

-- 10) Groupby the orders by date and calculate the 
-- average number of pizzas ordered per day. 
select avg(quantity) from
(select  orders.order_date, sum(order_details.quantity) as quantity from order_details join orders on orders.order_id = order_details.order_id
group by orders.order_date) as ordered_quantity;

-- 11) Determine the top 3 most ordered pizz types based on revenue.
SELECT 
    pizza_types.name,
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- 12) calculate the percentage calculation of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(pizzas.price * order_details.quantity) / (SELECT 
                    SUM(pizzas.price * order_details.quantity)
                FROM
                    pizzas
                        JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS Revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- 13)Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as Cumulative_revenue from
(select orders.order_date, sum(pizzas.price * order_details.quantity) as revenue from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.order_date) as total_revenue;

-- 14) Determine top 3 most ordered pizza pizza type based on revenue for each pizza category.
select category, name , revenue, rn
from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name, sum(pizzas.price * order_details.quantity) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a)as b
where rn<=3;
