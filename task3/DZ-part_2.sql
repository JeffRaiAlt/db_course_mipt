/**
 * Задача 5
 * Найти имена и фамилии клиентов с топ-3 минимальной и топ-3 максимальной суммой 
 * транзакций за весь период (учесть клиентов, у которых нет заказов, приняв их сумму транзакций за 0).
 */


WITH customer_sums AS ( 
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(oi.quantity * oi.item_list_price_at_sale), 0) AS total_sum
    FROM task2.customer c
    LEFT JOIN task2.orders od
        ON od.customer_id = c.customer_id
    LEFT JOIN task2.order_items oi
        ON oi.order_id = od.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
ranked AS (
    SELECT
        customer_id,
        first_name,
        last_name,        
        total_sum,
        ROW_NUMBER() OVER (ORDER BY total_sum ASC)  AS r_min,
        ROW_NUMBER() OVER (ORDER BY total_sum DESC) AS r_max
    FROM customer_sums
)
SELECT 
    customer_id,
    first_name,
    last_name,
    total_sum,
    CASE WHEN r_min <= 3 THEN 'MIN_TOP3'
         WHEN r_max <= 3 THEN 'MAX_TOP3'
    END AS category
FROM ranked
WHERE r_min <= 3 OR r_max <= 3
ORDER BY category, total_sum;


/**
 * Задача 6
 * Вывести только вторые транзакции клиентов (если они есть) с помощью оконных функций. Если у клиента меньше двух транзакций, 
 * он не должен попасть в результат.
 */ 

WITH ordered_orders AS (
    SELECT
        od.customer_id,
        od.order_id,
        ROW_NUMBER() OVER (
            PARTITION BY od.customer_id
            ORDER BY od.order_date, od.order_id
        ) AS r_num
    FROM task2.orders od
)
SELECT
    customer_id,
    order_id
FROM ordered_orders
WHERE r_num = 2
ORDER BY customer_id, order_id;


/**
 * Задача 7
 * Вывести имена, фамилии и профессии клиентов, а также длительность 
 * максимального интервала (в днях) между двумя последовательными заказами. 
 * Исключить клиентов, у которых только один или меньше заказов. 
 */

WITH customer_orders AS (
    SELECT
        od.customer_id,
        od.order_id,
        od.order_date::date AS order_date,
        LAG(od.order_date::date) OVER (
            PARTITION BY od.customer_id
            ORDER BY od.order_date::date
        ) AS prev_order_date
    FROM task2.orders od
), gaps AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        prev_order_date,
        (order_date - prev_order_date) AS gap_days
    FROM customer_orders
    WHERE prev_order_date IS NOT NULL    -- отбрасываем первый заказ клиента
), 
max_gap_per_customer AS (
    SELECT
        customer_id,
        MAX(gap_days) AS max_gap_days
    FROM gaps
    GROUP BY customer_id
) SELECT
    c.first_name,
    c.last_name,
    c.job_title,
    mg.max_gap_days
FROM max_gap_per_customer mg
JOIN task2.customer c
  ON c.customer_id = mg.customer_id
ORDER BY mg.max_gap_days DESC, c.last_name, c.first_name;


/** Задача 8
 * Найти топ-5 клиентов (по общему доходу) в каждом сегменте благосостояния (wealth_segment). 
 * Вывести имя, фамилию, сегмент и общий доход. Если в сегменте менее 5 клиентов, вывести всех.
 */ 
 
-- хм, упрощение 7 задачи...

 WITH customer_sum AS (
    SELECT
        od.customer_id,
        SUM(oi.quantity * oi.item_list_price_at_sale) AS total_revenue
    FROM task2.orders od
    JOIN task2.order_items oi
        ON oi.order_id = od.order_id
    GROUP BY od.customer_id
), grouped AS (
    SELECT 
        c.first_name AS first_name,
        c.last_name  AS last_name, 
        c.wealth_segment AS wealth_segment, 
        cs.total_revenue AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY c.wealth_segment 
            ORDER BY cs.total_revenue DESC
        ) AS wealth_segment_gr
    FROM task2.customer c 
    JOIN customer_sum cs 
        ON cs.customer_id = c.customer_id
)
SELECT first_name, last_name, wealth_segment, total_revenue
FROM grouped
WHERE wealth_segment_gr <= 5;




