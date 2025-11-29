
/**
 * Задача 1
 * Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат 
 * по убыванию количества.
*/

SELECT count(customer_id) AS qty, job_industry_category AS industry_category 
FROM task2.customer 
GROUP BY job_industry_category 
ORDER BY qty DESC 



/**
 * Задача 2
 * Найти общую сумму дохода (list_price*quantity) по всем подтвержденным 
 * заказам за каждый месяц по сферам деятельности клиентов. Отсортировать результат 
 * по году, месяцу и сфере деятельности.
 */

SELECT
    TO_CHAR(od.order_date::date, 'YYYY')::int AS year,
    TO_CHAR(od.order_date::date, 'MM')::int AS month,
    c.job_industry_category,
    SUM(p.list_price * oi.quantity) AS total_revenue
FROM task2.orders od
JOIN task2.order_items oi 
    ON od.order_id = oi.order_id
JOIN task2.product p 
    ON oi.product_id = p.product_id
JOIN task2.customer c
    ON od.customer_id = c.customer_id
WHERE od.order_status = 'Approved'
GROUP BY
    TO_CHAR(od.order_date::date, 'YYYY')::int,
    TO_CHAR(od.order_date::date, 'MM')::int,
    c.job_industry_category
ORDER BY
    year,
    month,
    c.job_industry_category;


/**
 * Задача 3
 * Вывести количество уникальных онлайн-заказов для всех брендов в рамках подтвержденных 
 * заказов клиентов из сферы IT. 
 * Включить бренды, у которых нет онлайн-заказов от 
 * IT-клиентов, — для них должно быть указано количество 0. 
 */

WITH brand_orders AS (
    SELECT
        p.brand,
        COUNT(DISTINCT o.order_id) AS online_orders_cnt
    FROM task2.product_cor p
    JOIN task2.order_items oi
        ON oi.product_id = p.product_id
    JOIN task2.orders o
        ON o.order_id = oi.order_id
    JOIN task2.customer c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Approved'
      AND o.online_order = TRUE
      AND c.job_industry_category = 'IT'
    GROUP BY p.brand
) SELECT
    p.brand,
    COALESCE(bo.online_orders_cnt, 0) AS online_orders_cnt
FROM task2.product_cor p
LEFT JOIN brand_orders bo
    ON bo.brand = p.brand
GROUP BY p.brand, bo.online_orders_cnt
ORDER BY p.brand;


/**
 * Задача 4
 * Найти по всем клиентам: сумму всех заказов (общего дохода), максимум, минимум и количество заказов, 
 * а также среднюю сумму заказа по каждому клиенту. Отсортировать результат по убыванию суммы всех заказов и 
 * количества заказов. Выполнить двумя способами: используя только GROUP BY и используя только оконные функции. Сравнить результат.
 */

WITH order_sums AS (
    SELECT
        od.customer_id,
        od.order_id,
        SUM(oi.quantity * oi.item_list_price_at_sale) AS order_sum
    FROM task2.orders od
    JOIN task2.order_items oi
        ON oi.order_id = od.order_id
    GROUP BY od.customer_id, od.order_id
) SELECT
    customer_id,
    SUM(order_sum) AS total_revenue,      -- сумма всех заказов клиента
    MAX(order_sum) AS max_order_sum,      -- максимальная сумма одного заказа
    MIN(order_sum) AS min_order_sum,      -- минимальная сумма одного заказа
    COUNT(*)      AS order_count,         -- количество заказов
    AVG(order_sum) AS avg_order_sum       -- средняя сумма заказа
FROM order_sums
GROUP BY customer_id
ORDER BY
    total_revenue DESC,
    order_count desc
    
    
    
WITH order_sums AS (
    SELECT
        od.customer_id,
        od.order_id,
        SUM(oi.quantity * oi.item_list_price_at_sale) AS order_sum
    FROM task2.orders od
    JOIN task2.order_items oi
        ON oi.order_id = od.order_id
    GROUP BY od.customer_id, od.order_id
)
SELECT
    customer_id,
    order_id,
    order_sum,                                          -- сумма именно заказа

    SUM(order_sum) OVER (PARTITION BY customer_id) AS total_revenue,   -- общая сумма всех заказов клиента
    MAX(order_sum) OVER (PARTITION BY customer_id) AS max_order_sum,   -- максимальный чек
    MIN(order_sum) OVER (PARTITION BY customer_id) AS min_order_sum,   -- минимальный чек
    COUNT(*)      OVER (PARTITION BY customer_id) AS order_count,      -- количество заказов
    AVG(order_sum) OVER (PARTITION BY customer_id) AS avg_order_sum    -- средний чек
FROM order_sums
ORDER BY
    total_revenue DESC,
    order_count   DESC
    --customer_id,
    --order_id;
    
 /**
  * Вижу ровно то, что и ожидается от оконных функций, промежуточные результаты
  * одновременно - видишь все заказы и насколько платежеспособный клиент в целом.
  */
