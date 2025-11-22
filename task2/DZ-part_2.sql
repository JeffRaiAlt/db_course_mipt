/**
 * Задача 5
 * Вывести 10 клиентов (ID, имя, фамилия), которые совершили наибольшее количество онлайн-заказов (в штуках) брендов 
 * Giant Bicycles, Norco Bicycles, Trek Bicycles, при условии, что они активны и имеют оценку имущества (property_valuation) 
 * выше среднего среди клиентов из того же штата.
 */
WITH active_rich_customers AS (
    SELECT *
    FROM task2.customer c
    WHERE c.deceased_indicator = 'N'  -- активные (живые) клиенты
      AND c.property_valuation >
          (
              SELECT AVG(c2.property_valuation)
              FROM task2.customer c2
              WHERE c2.state = c.state   -- среднее по тому же штату
          )
), 
customer_brand_qty AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM active_rich_customers c
    JOIN task2.orders o
        ON o.customer_id = c.customer_id
       AND o.online_order = true           -- только онлайн-заказы
    JOIN task2.order_items oi
        ON oi.order_id = o.order_id
    JOIN task2.product_cor p
        ON p.product_id = oi.product_id
    WHERE p.brand IN (
        'Giant Bicycles',
        'Norco Bicycles',
        'Trek Bicycles'
    )
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    first_name,
    last_name,
    total_orders
FROM customer_brand_qty
ORDER BY total_orders desc
LIMIT 10;


/**
 * Задача 6
 *Вывести всех клиентов (ID, имя, фамилия), у которых нет подтвержденных онлайн-заказов за последний год, 
 *но при этом они владеют автомобилем и их сегмент благосостояния не Mass Customer
 */

WITH rich_customers AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name
    FROM task2.customer c
    WHERE c.owns_car::boolean = true
      AND c.wealth_segment <> 'Mass Customer'
),
last_year AS (
    SELECT date_trunc('year', MAX(order_date::date)) AS y
    FROM task2.orders
)
SELECT
    rc.customer_id,
    rc.first_name,
    rc.last_name
FROM rich_customers rc
LEFT JOIN task2.orders od
    ON od.customer_id = rc.customer_id
   AND od.online_order = true
   AND od.order_status = 'Approved'
   AND date_trunc('year', od.order_date::date) = (SELECT y FROM last_year)
WHERE od.order_id IS NULL;


/**
 * Задача 7
 * Вывести всех клиентов из сферы 'IT' (ID, имя, фамилия), которые купили 2 из 5 продуктов с 
 * самой высокой list_price в продуктовой линейке Road.
 */

WITH top_products AS (
    SELECT p.product_id, p.list_price
    FROM task2.product_cor p
    WHERE p.product_line = 'Road'
    ORDER BY p.list_price DESC
    LIMIT 5
),
it_customers AS (
    SELECT c.customer_id, c.first_name, c.last_name  
    FROM task2.customer c
    WHERE c.job_industry_category  = 'IT'
),
customer_top_products AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT (oi.product_id)) AS cnt_products
    FROM it_customers c
    JOIN task2.orders o
        ON o.customer_id = c.customer_id
    JOIN task2.order_items oi
        ON oi.order_id = o.order_id
    JOIN top_products t
        ON t.product_id = oi.product_id
    GROUP BY c.customer_id, c.first_name, c.last_name  
)
SELECT
    customer_id,
    first_name,
    last_name,
    cnt_products
FROM customer_top_products
WHERE cnt_products = 2;


/**
 * Задача 8
 * Вывести клиентов (ID, имя, фамилия, сфера деятельности) из сфер IT или Health, которые совершили не менее 
 * 3 подтвержденных заказов в период 2017-01-01 по 2017-03-01, и при этом их общий доход от этих заказов превышает 10 000 долларов.
Разделить вывод на две группы (IT и Health) с помощью UNION.
 * 
 */

WITH order_revenue AS (
    SELECT
        od.order_id,
        od.customer_id,
        SUM(oi.item_list_price_at_sale * oi.quantity) AS order_sum
    FROM task2.orders od
    JOIN task2.order_items oi ON oi.order_id = od.order_id
    WHERE od.order_status = 'Approved'
      AND od.order_date::date >= DATE '2017-01-01'
      AND od.order_date::date <= DATE '2017-03-01'
    GROUP BY od.order_id, od.customer_id
), customer_stats AS (
    SELECT
        orv.customer_id,
        COUNT(*) AS approved_orders_cnt,
        SUM(orv.order_sum) AS total_revenue
    FROM order_revenue orv
    GROUP BY orv.customer_id
    HAVING COUNT(*) >= 3
       AND SUM(orv.order_sum) > 10000
) 
-- тут разделяем на две группы: IT и Health
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_industry_category 
FROM customer_stats cs
JOIN task2.customer c ON c.customer_id = cs.customer_id
WHERE c.job_industry_category  = 'IT'

UNION

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_industry_category 
FROM customer_stats cs
JOIN task2.customer c ON c.customer_id = cs.customer_id
WHERE c.job_industry_category  = 'Health'


---ORDER BY last_name, first_name;



