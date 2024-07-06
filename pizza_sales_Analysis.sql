create database pizzahut;
-- now import csv file pizzas
-- right click on table and import wizard then browse file from folder

select* from pizzas;

-- import pizza_types--  
select* from pizza_types;

-- for importing orders.csv we need time datatype , which is not availible so we need to creat this table
create table orders(
	order_id   int  not null,
    order_date  date not null,
    order_time  time not null,
    primary key(order_id)
);

select* from orders;


-- 4th column
create table order_details(
	order_details_id int not null,
	order_id   int  not null,
	pizza_id  text  not null,
    quantity  int not null ,
    primary key(order_details_id)
);
select* from order_details;





-- -------------------------------------------------------------Questions-- ----------------------------------------------------------- 



    
-- 1 -- Select the total number of orders place
select count(order_id) as total_numbers from orders ;
-- 21350


-- 2- select the total revenue

SELECT
    round(SUM(order_details.quantity * pizzas.price), 2) as total_sales -- Assuming you want to calculate total price
FROM
    order_details
JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
 
 -- 817860.04999999993 alter round -- 817860.05

-- 3-- highest prise pizza

select pizza_types.name , pizzas.price
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;
-- the Greek pizza  35.95--

-- 4-- identify the most common pizza size orders

select  pizzas.size,  count(order_details.order_details_id) as total_orders  -- count ya koi b agg function  hy tou sath group by use krna hta
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id
group by  pizzas.size order by total_orders desc;


-- 5-- top 5 most ordered pizzas types along with their quantities/ 
-- no common column in both tables , so need to use third column'
-- pizza_types has pizza_type_id which is common in pizzas, pizzas has pizza_id which is common in order_details

select pizza_types.name , sum(order_details.quantity) as total 
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by total desc ; -- hm yha aik table bnany ka keh rhy jo k name aur total ka ho


-- ------ ----------------------------------------------------------------------------------------------------------------------------------

-- 1--Join the necessary tables to find the quantity of each pizza Category ordered

select  pizza_types.category, sum(order_details.quantity) as total_orders
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category order by  total_orders desc;

-- 2-- determine the distribution of the orders by the hour of the day

select hour(order_time), count(order_id) from orders
group by hour(order_time) order by order_id; -- order by na b kry tou output aye gi


-- 3-- join relevant table to find category wise distribution of pizzas
select pizza_types.category , count(name) from pizza_types
group by  pizza_types.category;


-- 4-- Group the orders by date and calculate the average number of pizzas ordered per day----------------------------
select orders.order_date, count(order_details.quantity) as detail
from orders join order_details on order_details.order_id = orders.order_id
group by orders.order_date;

-- ab hmy check krna k aik din me kitny huye 
select round(avg( detail), 0) as average_pizza_ordered
 from (select orders.order_date, count(order_details.quantity) as detail
from orders join order_details on order_details.order_id = orders.order_id
group by orders.order_date) as order_quantity;


-- 5-- top 3 most ordered pizza types based on revenue
-- revenue is quantity * price

select pizza_types.name , sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by  pizza_types.name order by revenue desc limit 3 ;

-- ---------------------------------------------------------------------------------------------------------------------------------------------

-- 1-- contribution of each pizza type in total revenue
select pizza_types.category , sum(order_details.quantity * pizzas.price) as revenue 
from  pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue;

-- for percentage
SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
		SUM(order_details.quantity * pizzas.price)
        FROM
            pizza_types
                JOIN
            pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
                JOIN
            order_details ON order_details.pizza_id = pizzas.pizza_id) * 100 , 2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue;

-- 2-- Analyze the  cumulative  revenue generated over time
-- income of on day | cumulative income
-- 200 						200
-- 300						200+300
-- 400						200+300+400

SELECT
    sales.order_date,  -- order_date b just likh skty
    SUM(sales.revenue) OVER (ORDER BY sales.order_date) AS cumulative
FROM
    (SELECT
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
     FROM
        order_details
     JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
     JOIN orders ON order_details.order_id = orders.order_id
     GROUP BY orders.order_date
    ) AS sales;

-- 3-- determine top 3 most ordered pizza types based on revenue for each pizza category
-- revenue for each pizza category and inside category each type

select category, name, revenue ,
rank()  over(partition by category order by revenue desc) as b
from
(select pizza_types.category, pizza_types.name , sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) a ;

-- ye hmy sb ki category me utha k de rha 1,2,3,... 
-- but hmy top 3 chihy
-- hmy isy pr condition lgani hy b<=3 ki 

select name , revenue from
(select category, name, revenue ,
rank()  over(partition by category order by revenue desc) as b
from
(select pizza_types.category, pizza_types.name , sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) a) as c
where b<=3  ;

 



















