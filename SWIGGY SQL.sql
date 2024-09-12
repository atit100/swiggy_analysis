-- finding customers who have never ordered
select name from users where user_id not in (select user_id from orders);

-- average food per dish price
select f_name,avg(price) as avg_price
from menu
join food using(f_id)
group by f_name;



-- restraunts with monthly sales > 500 for the month of june
select r_name,monthname(date) as month_name,sum(amount) as total_sales
from restaurants 
join orders using(r_id)
where monthname(date) like 'june'
group by 1,2
having sum(amount) > 500 ;



-- order history of ankit beteen 2022-06-10 to 2022-07-10
select order_id,r_name,f_name  from  orders 
join restaurants using(r_id)
join order_details using(order_id)
join food using(f_id)
join users using(user_id)
where name='ankit' and( date > '2022-06-10' and date < '2022-07-10');

-- find restraunts with max repeated customer
select r_id,r_name,name,count(*)as frequency from 
(
select r_id,r_name,user_id,name,count(*) visits from orders 
join users using(user_id)
join restaurants using(r_id)
group by 1,2,3,4
having visits >1
order by r_id) t
group by 1,2,3
order by frequency desc limit 2;

select r_id,user_id ,count(*)as visits from orders
group by 1,2
having visits >1
order by r_id;

with cte as
(select monthname(date) as month,sum(amount)as total_rev from orders
group by 1)
select month,total_rev,sum(total_rev) over(order by total_rev) as running_sales
from cte;



-- find most loyal customer for all restraunts
select r_name,name,count(*) as visits from  orders
join restaurants using(r_id)
join users using(user_id)
group by 1,2
having visits >1
order by r_name;

-- running monthly sales of swiggy
with cte as
(select monthname(date) month,sum(amount) as revenue
from orders
group by 1)
select month ,sum(revenue) over(order by month) as running_rev
from cte;

-- month on month revenue growth
select month,revenue,pre_rev,revenue-pre_rev,((revenue-pre_rev)/pre_rev)*100 as mom_growth from
(
with cte1 as(
select monthname(date) as month,
sum(amount)as revenue from orders group by 1)
select month,revenue, 
lag (revenue,1)
over (order by revenue)as pre_rev from cte1)t;

-- month on month revenue growth of dominos restraunts only
select month,r_name,revenue,pre_sales,(((revenue-pre_sales)/pre_sales)*100) as mom_growth from
(
with cte1 as(
select monthname(date) month,r_name,sum(amount) as revenue from orders 
    join restaurants using(r_id) 
    where r_name='dominos'
    group by 1,2)
    select month,r_name,revenue,lag(revenue,1) over(order by month) as pre_sales
    from cte1)t;
    
-- favourite food of each customer

with temp as(
select name,f_name,count(*) frequency from orders
join order_details using(order_id)
join food using(f_id)
join users using(user_id) 
group by 1,2
having frequency >1)
select * from temp t1 
where frequency=(select max(frequency) from temp t2 where t2.name=t1.name);

-- running total of swiggy sales
with cte as(
select monthname(date) as month ,sum(amount) as total_sales from orders group by 1)
select month,total_sales,sum(total_sales) over(order by month)  as running_sales from cte;



-- find the running monthly sales of kfc restaurants
with cte1 as(
select monthname(date) as month,r_name,sum(amount) as total_sales from orders
join restaurants using(r_id) 
where r_name like 'kfc'
group by 1,2
order by sum(amount) desc) 
select *,sum(total_sales) over(order by month) as running_sales from cte1;

-- month on month revenue growth of kfc restaurants
select month,total_rev,presales,round((((total_rev-presales)/presales)*100),2) as mom_prct_chg from

(with cte as
(select monthname(date) as month,r_name,sum(amount) as total_rev from orders
join restaurants using(r_id)
where r_name like'kfc'
group by 1,2)

select month,total_rev, lag (total_rev,1) over(order by month) as presales from cte) t


    
    