insert into mart.f_customer_retention 
(
 new_customers_count,
 returning_customers_count,
 refunded_customer_count,
 period_id,
 new_customers_revenue,
 returning_customers_revenue,
 customers_refunded 
)
with cte as
(
select
date_part('week',date_time) as period_id,
count (*) as returning_customers_count,
sum(payment_amount) as returning_customers_revenue
from staging.user_order_log 
where quantity != '1' and status != 'refunded'
group by date_part('week',date_time)
),

cte1 as 
(
select 
date_part('week',date_time) as period_id,
count (*) as new_customers_count,
sum(payment_amount) as new_customers_revenue
from staging.user_order_log 
where quantity = '1' and status != 'refunded'
group by date_part('week',date_time)),

cte2 as 
(
select 
date_part('week',date_time) as period_id,
count (*) as refunded_customers_count,
sum(payment_amount) as customers_refunded
from staging.user_order_log
where status = 'refunded'
group by date_part('week',date_time))


select cte1.new_customers_count,
       cte.returning_customers_count,
       cte2.refunded_customers_count,
       cte.period_id,
       cte1.new_customers_revenue, 
       cte.returning_customers_revenue,
       cte2.customers_refunded
from cte
join cte1 on cte.period_id=cte1.period_id
join cte2 on cte.period_id=cte2.period_id