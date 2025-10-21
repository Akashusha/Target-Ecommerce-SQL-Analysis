#1
# Data type of all columns in the "customers" table.

select * from `Target_SQL.customers` limit 10;

# Get the time range between which the orders were placed.

select min(order_purchase_timestamp) as start_time,
max(order_purchase_timestamp) as end_time
from `Target_SQL.orders` ;

# Display the Cities & States of customers who ordered during the given period.

select
c.customer_city,c.customer_state
from `Target_SQL.customers` as c
join `Target_SQL.orders` as o 
on c.customer_id =o.customer_id
where extract(YEAR from o.order_purchase_timestamp) = 2018
and  extract(MONTH from o.order_purchase_timestamp) between 1 and 3;

#2
#Is there a growing trend in the no. of orders placed over the past years?

SELECT
EXTRACT(MONTH from order_purchase_timestamp) as month,
COUNT(customer_id)as order_num
FROM `Target_SQL.orders`
GROUP BY EXTRACT(MONTH from order_purchase_timestamp)
ORDER BY order_num desc; 

# During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
SELECT
EXTRACT(HOUR from order_purchase_timestamp) as hour,
COUNT(customer_id)as order_num
FROM `Target_SQL.orders`
GROUP BY EXTRACT(HOUR from order_purchase_timestamp)
ORDER BY order_num desc; 

#3
# Get the month on month no. of orders 
SELECT
EXTRACT(MONTH from order_purchase_timestamp) as month,
EXTRACT(YEAR from order_purchase_timestamp) as year,
COUNT(*) as num_orders,
FROM `Target_SQL.orders`
GROUP BY year, month
ORDER BY year, month;

#How are the customers distributed across all the states and cites?
SELECT
customer_city,
customer_state,
COUNT(customer_id) as customer_count
FROM `Target_SQL.customers`
GROUP BY customer_city,customer_state
ORDER BY customer_count desc;

#4
#Get the % increase in the cost of orders from year 2017 to 2018
#(include months between Jan to Aug only).
#You can use the "payment_value" column in the payments table to get the cost of orders.

#Step1: Calculate total payments per year
with yearly_totals as(
SELECT
EXTRACT(YEAR from o.order_purchase_timestamp) as year,
SUM(p.payment_value) as total_payment
FROM `Target_SQL.payments` as p 
JOIN `Target_SQL.orders` as o 
ON p.order_id=o.order_id
WHERE EXTRACT(YEAR from o.order_purchase_timestamp) IN (2017,2018)
AND EXTRACT(MONTH from o.order_purchase_timestamp) between 1 and 8
GROUP BY EXTRACT(YEAR from o.order_purchase_timestamp)
),

#Step2: Use LEAD window function to compare each years payment with previous year
yearly_comparisons as(
SELECT 
year,
total_payment,
LEAD(total_payment) over(order by year desc) as prev_year_payment
FROM yearly_totals
)

#Step3: Calculate % increase

SELECT
year,
ROUND(((total_payment-prev_year_payment)/prev_year_payment)*100,2) as percentage_increase
FROM yearly_comparisons;

#Mean and Sum of price and fright value by customer state
SELECT
c.customer_state,
SUM(oi.price) as total_price,
AVG(oi.price) as avg_price,
SUM(oi.freight_value) as total_freight_value,
AVG(oi.freight_value) as avg_freight_value
FROM `Target_SQL.orders` as o 
JOIN `Target_SQL.order_items`as oi 
ON o.order_id=oi.order_id
JOIN `Target_SQL.customers`as c 
ON o.customer_id = c.customer_id
GROUP BY c.customer_state;

#5. Calculate the days between purchase and delivery and estimated delivery

SELECT
order_id,
DATE_DIFF(Date(order_delivered_customer_date),Date(order_purchase_timestamp),Day) as time_to_deliver,
DATE_DIFF(Date(order_delivered_customer_date),Date(order_estimated_delivery_date),Day) as diff_estimated_delivery
FROM `Target_SQL.orders`;


#top 5 states with the highest & lowest average freight value.
SELECT
c.customer_state,
AVG(oi.freight_value) as avg_freight_value
FROM `Target_SQL.orders` as o 
JOIN `Target_SQL.order_items`as oi 
ON o.order_id=oi.order_id
JOIN `Target_SQL.customers`as c 
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_freight_value DESC
LIMIT 5;

#Find out the top 5 states with the highest & lowest average delivery time.
SELECT
c.customer_state,
AVG(EXTRACT(Date from o.order_delivered_customer_date)-EXTRACT(Date from  o.order_purchase_timestamp)) as avg_delivery_time
FROM `Target_SQL.orders` as o 
JOIN `Target_SQL.order_items`as oi 
ON o.order_id=oi.order_id
JOIN `Target_SQL.customers`as c 
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_delivery_time DESC
LIMIT 5;

#Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.
WITH state_delivery AS (
  SELECT
    c.customer_state,
    AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time,
    AVG(DATE_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date, DAY)) AS avg_early_delivery
  FROM `Target_SQL.orders` AS o
  JOIN `Target_SQL.customers` AS c 
    ON o.customer_id = c.customer_id
  WHERE o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
  GROUP BY c.customer_state
)
SELECT
  customer_state,
  avg_delivery_time,
  avg_early_delivery
FROM state_delivery
ORDER BY avg_early_delivery DESC
LIMIT 5;

#6
#Find the month on month no. of orders placed using different payment types
SELECT
payment_type,
EXTRACT(YEAR from order_purchase_timestamp) as year,
EXTRACT(MONTH from order_purchase_timestamp) as month,
COUNT(Distinct o.order_id) as orders_count
FROM `Target_SQL.orders` as o 
JOIN `Target_SQL.payments`as p
ON o.order_id = p.order_id
GROUP BY payment_type,year,month
ORDER BY year,month DESC;

#Find the no. of orders placed on the basis of the payment installmentsthat have been paid. 

SELECT
payment_installments,
COUNT(order_id) as num_orders
FROM `Target_SQL.payments`
GROUP BY payment_installments;

