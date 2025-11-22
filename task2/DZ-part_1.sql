/**
 * Задача 1
Вывести все уникальные бренды, у которых есть хотя бы один продукт со 
стандартной стоимостью выше 
1500 долларов, и суммарными продажами не менее 1000 единиц.
**/

/** Думал что речь идет про бренды, написал запрос, оставил его*/
SELECT 
    pd.brand,    
    SUM(oi.quantity) as sum_quantity
FROM task2.product_cor pd
JOIN task2.order_items oi 
    ON pd.product_id = oi.product_id
GROUP BY pd.brand
HAVING 
    -- условие по суммарным продажам бренда
    SUM(oi.quantity) >= 1000
    -- у бренда есть хотя бы один продукт дороже 1500
    AND MAX(CASE 
                WHEN pd.standard_cost > 1500 THEN 1 
                ELSE 0 
            END) = 1
ORDER BY pd.brand;


/** но правила русского языка говроят что это продукты, здесь работаем только с 
 * доргогими продуктами, а не со всеми как в прошлом */
WITH product_list AS (
SELECT 
    pd.product_id,
    SUM(oi.quantity) AS sum_quantity
FROM task2.product_cor pd
LEFT JOIN task2.order_items oi ON pd.product_id = oi.product_id
WHERE pd.standard_cost > 1500
GROUP BY pd.product_id
HAVING SUM(oi.quantity) >= 1000
)
SELECT DISTINCT pd.brand
FROM product_list pl
JOIN task2.product_cor pd
    ON pd.product_id = pl.product_id
ORDER BY pd.brand;



/**
 * Задача 2
Для каждого дня в диапазоне с 2017-04-01 по 2017-04-09 включительно вывести количество подтвержденных 
онлайн-заказов и количество уникальных клиентов, совершивших эти заказы.
  **/

SELECT
    od.order_date::date as order_day,
    COUNT(*) as order_cnt,
    COUNT(DISTINCT od.customer_id) as unc_customer
FROM task2.orders od
WHERE od.order_date::date BETWEEN '2017-04-01' AND '2017-04-09'
  AND od.order_status = 'Approved'
  AND od.online_order = true          -- фильтр по онлайн-заказам
GROUP BY od.order_date::date
ORDER BY order_day

/* Проверка* за какой-то день/
select count(*) from task2.orders od where od.order_date::date = '2017-04-05' and od.order_status = 'Approved' and od.online_order = true
select count(distinct (od.customer_id)) from task2.orders od where od.order_date::date = '2017-04-05' and od.order_status = 'Approved' and od.online_order = true
**/


/**
 * Задача 3
 * Вывести профессии клиентов:
из сферы IT, чья профессия начинается с Senior;
из сферы Financial Services, чья профессия начинается с Lead.
Для обеих групп учитывать только клиентов старше 35 лет. Объединить выборки с помощью UNION ALL.
 **/

SELECT 
    customer_id,
    job_title,
    job_industry_category,
    dob
FROM task2.customer
WHERE job_industry_category = 'IT'
  AND job_title LIKE 'Senior%'
  AND dob <> ''                          
  AND dob::date < CURRENT_DATE - INTERVAL '35 years'  -- старше 35 лет

UNION ALL

SELECT 
    customer_id,
    job_title,
    job_industry_category,
    dob
FROM task2.customer
WHERE job_industry_category = 'Financial Services'
--select * FROM task2.customer WHERE job_title LIKE 'Lead%' -- у меня никого нет с таким префиксом 
  AND job_title LIKE 'Lead%'
  AND dob <> ''                          
  AND dob::date < CURRENT_DATE - INTERVAL '35 years';


/**
 * Задача 4
 * Вывести бренды, которые были куплены клиентами из сферы Financial Services, но не были куплены клиентами из сферы IT.
 */

WITH fi_services_brands AS (
    SELECT DISTINCT p.brand
    FROM task2.product_cor p
    JOIN task2.order_items oi ON p.product_id = oi.product_id
    JOIN task2.orders o ON oi.order_id = o.order_id
    JOIN task2.customer c ON o.customer_id = c.customer_id
    WHERE c.job_industry_category = 'Financial Services'
),
it_brands AS (
    SELECT DISTINCT p.brand
    FROM task2.product_cor p
    JOIN task2.order_items oi ON p.product_id = oi.product_id
    JOIN task2.orders o ON oi.order_id = o.order_id
    JOIN task2.customer c ON o.customer_id = c.customer_id
    WHERE c.job_industry_category = 'IT'
)
SELECT brand FROM fi_services_brands WHERE brand NOT IN (SELECT brand FROM it_brands);




