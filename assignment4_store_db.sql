-- Assignment 4. Subqueries, Grouping, Aggregate Functions and Functions
-- Database: Store_db (PostgreSQL)

-- Task 1.
SELECT
    first_name || ' ' || UPPER(last_name) AS full_name,
    title AS title,
    LOWER(LEFT(first_name, 1) || last_name) AS login,
    LENGTH(first_name) + LENGTH(last_name) AS name_length,
    EXTRACT(YEAR FROM hire_date)::int AS hire_year
FROM employees
ORDER BY hire_date;

-- Task 2.
SELECT
    order_id,
    TO_CHAR(order_date, 'DD.MM.YYYY') AS order_day,
    required_date,
    shipped_date,
    shipped_date - required_date AS days_late
FROM orders
WHERE shipped_date > required_date
ORDER BY days_late DESC, order_id;

-- Task 3.
SELECT
    c.category_name,
    COUNT(p.product_id) AS products_cnt,
    ROUND(AVG(p.unit_price)::numeric, 2) AS avg_price,
    MIN(p.unit_price) AS min_price,
    MAX(p.unit_price) AS max_price,
    SUM(p.units_in_stock) AS total_stock
FROM categories AS c
JOIN products AS p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
HAVING AVG(p.unit_price) > 25
ORDER BY avg_price DESC;

-- Task 4.
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customers_cnt,
    COUNT(o.order_id) AS orders_cnt,
    ROUND(SUM(o.freight)::numeric, 2) AS total_freight
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.country
HAVING COUNT(o.order_id) >= 30
ORDER BY orders_cnt DESC;

-- Task 5.
SELECT
    p.product_name,
    p.unit_price,
    ROUND((SELECT AVG(p2.unit_price)
           FROM products AS p2)::numeric, 2) AS avg_price
FROM products AS p
WHERE p.unit_price > (
    SELECT AVG(p2.unit_price)
    FROM products AS p2
)
ORDER BY p.unit_price DESC;

-- Task 6.
SELECT
    c.customer_id,
    c.company_name,
    c.country
FROM customers AS c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders AS o
    WHERE o.order_id IN (
        SELECT od.order_id
        FROM order_details AS od
        WHERE od.product_id = (
            SELECT p.product_id
            FROM products AS p
            WHERE p.product_name = 'Chai'
        )
    )
)
ORDER BY c.company_name;

-- Task 7.
SELECT
    c.customer_id,
    c.company_name,
    c.city,
    c.country
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
      AND EXTRACT(YEAR FROM o.order_date) = 1998
)
ORDER BY c.country, c.company_name;

-- Task 8.
SELECT
    p.product_name,
    c.category_name,
    p.unit_price,
    ROUND((SELECT AVG(p2.unit_price)
           FROM products AS p2
           WHERE p2.category_id = p.category_id)::numeric, 2) AS category_avg
FROM products AS p
JOIN categories AS c ON c.category_id = p.category_id
WHERE p.unit_price > (
    SELECT AVG(p2.unit_price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
)
ORDER BY c.category_name, p.unit_price DESC;

-- Task 9.
SELECT
    c.company_name,
    COUNT(o.order_id) AS orders_cnt,
    ROUND(AVG(ov.order_total)::numeric, 2) AS avg_order_value,
    ROUND(MAX(ov.order_total)::numeric, 2) AS max_order_value
FROM (
    SELECT
        od.order_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS order_total
    FROM order_details AS od
    GROUP BY od.order_id
) AS ov
JOIN orders AS o ON o.order_id = ov.order_id
JOIN customers AS c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name
HAVING COUNT(o.order_id) >= 15
ORDER BY avg_order_value DESC;

-- Task 10.
SELECT
    e.first_name || ' ' || e.last_name AS employee,
    COUNT(o.order_id) AS orders_1997
FROM employees AS e
JOIN orders AS o ON o.employee_id = e.employee_id
WHERE EXTRACT(YEAR FROM o.order_date) = 1997
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(employee_order_count)
    FROM (
        SELECT
            e2.employee_id,
            COUNT(o2.order_id) AS employee_order_count
        FROM employees AS e2
        LEFT JOIN orders AS o2
            ON o2.employee_id = e2.employee_id
           AND EXTRACT(YEAR FROM o2.order_date) = 1997
        GROUP BY e2.employee_id
    ) AS employee_counts
)
ORDER BY orders_1997 DESC;
