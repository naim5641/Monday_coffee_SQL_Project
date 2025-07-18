select * from city
select * from customers
select * from sales
select * from products

-- Q1.Coffee Consumers Count
-- How many people in each city are estimated to consume coffee,given that 25% of the population does?


select
	city_name,
	round((population * 0.25)/1000000,
	2) as coffe_in_millions,
	city_rank
from city
order by 2 desc


-- Q.2 Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?


select
	ct.city_name,
	sum(s.total) as total_sales	
from sales as s
inner join customers as c
on s.customer_id = c.customer_id
inner join city as ct
on ct.city_id = c.city_id
where extract(year from s.sale_date)= '2023'
and
extract(quarter from s.sale_date)= '4'
group by 1
order by 2 desc



-- Q3. Sales Count for Each Product
-- Q3. How many units of each coffee product have been sold?

 

select 
	p.product_id,
	p.product_name,
	count(s.sale_id) as product_sale
from products as p
inner join sales as s
on p.product_id = s.product_id
group by p.product_id
order by 3 desc

select * from products



-- Q4. Average Sales Amount per City
-- What is the average sales amount per customer in each city?

select
	
	ct.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_cx,
	round(
			sum(s.total)::numeric/
				count(distinct s.customer_id)::numeric
				,2) as avg_sale_pr_cx
from sales as s
inner join customers as c
on s.customer_id = c.customer_id
inner join city as ct
on ct.city_id = c.city_id
group by 1
order by 2 desc


-- Q5. City Population and Coffee Consumers
-- Q5. Provide a list of cities along with their populations and estimated coffee consumers.

with city_table as
(
	select
		city_name,
		round((population * 0.25)/1000000, 2) as coffee_consumers
	from city
),
customers_table
as
(
	select
		ci.city_name,
		count(distinct c.customer_id) as unique_cx
	from sales as s
	join customers as c
	on c.customer_id = s.customer_id
	join city as ci
	on ci.city_id = c.city_id
	group by 1
)
select
	city_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cx
from city_table
join
customers_table
on city_table.city_name = customers_table.city_name


-- Q6.Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

-- product,
-- sales,
-- city,

with cte_tabel as
(select
	ct.city_name as city_name,
	p.product_name as product_name,
	count(s.sale_id) as total_sale,
	dense_rank() over(partition by ct.city_name order by count(s.sale_id) desc) as rnk
from products as p
inner join sales as s
on s.product_id = p.product_id
inner join customers as c
on c.customer_id = s.customer_id
inner join city as ct
on ct.city_id = c.city_id
group by 1,2
)
select
	city_name,
	product_name,
	total_sale,
	rnk
from cte_tabel
where rnk <= 3


-- Q7. Customer Segmentation by City
-- Q7. How many unique customers are there in each city who have purchased coffee products?



select 
	ct.city_name,
	count(distinct c.customer_id) as unique_cx
from products as p
inner join sales as s
on s.product_id = p.product_id
inner join customers as c
on c.customer_id = s.customer_id
inner join city as ct
on ct.city_id = c.city_id
where p.product_name ilike '%coffee%'
group by 1


-- Q8. Average Sale vs Rent
-- Q8. Find each city and their average sale per customer and avg rent per customer



select 
	ct.city_name as city_name,
	ct.estimated_rent as estimated_rent,
	count(distinct c.customer_id) as unique_cx,
	round(sum(s.total)::numeric/count(distinct c.customer_id)::numeric,2) as avg_sale_per_cx,
	round(ct.estimated_rent::numeric/count(distinct c.customer_id)::numeric,2) as avg_rent_per_cx
	
from products as p
inner join sales as s
on s.product_id = p.product_id
inner join customers as c
on c.customer_id = s.customer_id
inner join city as ct
on ct.city_id = c.city_id
group by 1,2



-- Q9. Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).


with monthly_sale as
(select 
	ct.city_name,
	extract(month from s.sale_date) as month,
	extract(year from s.sale_date) as year,
	sum(s.total) as cr_month_sale
from city as ct
join customers as c
on c.city_id = ct.city_id
join sales as s
on s.customer_id = c.customer_id
group by 1,2,3
order by 1,3,2),

grouth_ratio as 
(select 
	 city_name,
	 month,
	 year,
	 cr_month_sale,
	 lag(cr_month_sale, 1) over(partition by city_name order by year, month) as last_month_sale
from monthly_sale)

select	
	 city_name,
	 month,
	 year,
	 cr_month_sale,
	 last_month_sale,
	 ROUND(
	 
	 	(cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
	 	, 2
	 ) as growth_ratio

from grouth_ratio
where 
	last_month_sale is not null




-- Q.10
-- Market Potential Analysis.
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer.




select 
	ct.city_name,
	sum(s.total) as total_sale,
	ct.estimated_rent,
	count(distinct c.customer_id) as total_customer,
	round(
		(ct.population * 0.25)::numeric/1000000::numeric * 100
		, 2 
	) as coffe_consumer
from city as ct
join customers as c
on c.city_id = ct.city_id
join sales as s
on s.customer_id = c.customer_id
group by 1,3,5
order by 2 desc


