select * from sales_data;

-- Q1: find top 10 highest reveue generating products 
select
     product_id,
	 round(sum(sale))as total_sales
from sales_data
group by product_id
order by total_sales desc
limit 10;


-- Q2: find top 5 highest selling products in each region

with cte as 
(select
    region,
    product_id,
	sum(sale) as total_sales,
	row_number() over(partition by product_id order by sum(sale) desc) as rn
from sales_data
group by product_id,region)

select
    region,
	product_id
from cte
where rn<=5;
    
 -- Q3: for each category which month had highest sales 
 
 with cte as (
	 select
         category,
	     month_name,
	     sum(sale) as total_sales,
	     row_number() over(partition by category order by sum(sale) desc) rn
      from sales_data
      group by category,month_name)

select
    category,
	month_name,
	total_sales
from cte
where rn=1;


-- Q4: which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
	select
		sub_category,
		extract(year from order_date) as order_year,
	    sum(sale) as sale_price
		from sales_data
		group by sub_category,order_year
),

cte1 as (
     select
	    sub_category,
	     sum(case when order_year=2023 then sale_price else 0 end ) as year_2023,
	     sum(case when order_year=2022 then sale_price else 0 end) as year_2022
	 from cte
	 group by sub_category
)

select
    sub_category,
	year_2023,
	year_2022,
	(year_2023-year_2022) as diff
from cte1
order by diff desc
limit 1;



-- Q5: find month over month growth comparison for 2022 and 2023 sales


with cte as (
	select
		month_name,
	    extract( year from order_date) as order_year,
	    sum(sale) as sale_price
		from sales_data
		group by month_name,order_year
),

cte1 as (
     select
	    month_name,
	     sum(case when order_year=2023 then sale_price else 0 end ) as year_2023,
	     sum(case when order_year=2022 then sale_price else 0 end) as year_2022
	 from cte
	 group by month_name
)

select
    month_name,
	year_2023,
	year_2022,
	((year_2023-year_2022)/year_2022)*100 as growth
from cte1
order by growth desc;

 
-- Identify the top 3 best-selling products in terms of quantity sold for each quarter of the year.

with cte as (
	select
    extract(year from order_date) as years,
	quarter,
    product_id,
	sum(quantity) as total_sold,
	row_number() over(partition by extract(year from order_date),quarter,product_id order by sum(quantity) desc) as rn
from sales_data
group by years,quarter,product_id
)

select
   years,
   quarter,
   product_id,
   total_sold
 from cte 
 where rn<=3;
 
 
-- Q6: Calculate the average profit margin (profit / sale) for each product category.
 
 with cte as (
	 select
		 category,
		 sum(profit)/sum(sale) as profit_margin
		 from sales_data
     group by category
)

select
    category,
	avg(profit_margin)*100 as avg_profit_margin
from cte 
group by category
order by avg_profit_margin desc;
 
 
 
 
 
 
 