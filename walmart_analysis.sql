show databases;
use walmart_db;
select count(*)from walmart;


select 
payment_method ,
count(*)
from walmart
group by payment_method;

select count(distinct branch)
from walmart;

select min(quantity) from walmart;

-- businness problems --
-- q1. find different payment method and number of transaction and number of qty sold--

select 
payment_method ,
count(*) as no_payments,
sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- q2 .display the highest-rated category in each branch ,displaying the bracnh,cateogry and avg rating

SELECT *
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank`
    FROM walmart
    GROUP BY branch, category
) AS ranked_categories
WHERE `rank` = 1;

-- identify the busiest day for each branch based on the number of transactions ;



select *
from
(
SELECT
    branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
    count(*) as no_transactions,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
FROM walmart
group by branch ,day_name
)as ranked_transactions
where `rank` =1 ;

-- determine the avg ,min ,amx ,rating of products for each city and list the city ,avg_rating ,min_rating of categy,and max_rating--

select 
city,
category,
MIN(rating) as min_rating,
MAX(rating) as max_rating,
AVG(rating) as avg_rating
from walmart
group by city,category;

-- calculate highest and lowest profit from each ctgy --

select 
category,
sum(total) as total_revenue, 
SUM(total * profit_margin)
from walmart
group by category;
 
 -- dispaly the most common payment method foe each branch and preferred_payment_methd--
 
 
 with cte
 AS
 (select 
 branch,
 payment_method,
 count(*) as total_trans,
     RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
 from walmart
 group by branch,payment_method
 )select * from cte
 where `rank` = 1;
 
 -- categorsie sales into morn,after , eve and find out each shift and no of invoices;
 

SELECT
    branch,
    CASE
        WHEN HOUR(time) < 12 THEN 'MORNING'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS day_time,
    COUNT(*) AS transaction_count
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, transaction_count;

-- identify the 5 branch with highest decrease ratio in revenue compare to last yeat 22 and 23;
-- 2022 sales--

WITH 
revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue_2022
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue_2023
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)

SELECT
    ls.branch,
    ls.revenue_2022,
    cs.revenue_2023,
    (ls.revenue_2022 - cs.revenue_2023) / ls.revenue_2022  * 100 AS revenue_decrease_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
    ON ls.branch = cs.branch
WHERE ls.revenue_2022 > cs.revenue_2023 
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

 
 







