-- SET 1 — JOIN Logic (Interview Traps)
-- Q1. ⚠️ LEFT JOIN Trap
-- Tables:
-- employees(emp_id, dept_id)
-- departments(dept_id, dept_name)

-- Return all employees and show dept_name = 'Unknown' if department is missing.
SELECT e.emp_id,
       COALESCE(d.dept_name, 'Unknown') AS dept_name
FROM employees e
LEFT JOIN departments d
  ON e.dept_id = d.dept_id;


-- Q2.
-- Tables:
-- customers(customer_id)
-- orders(order_id, customer_id)

-- Return customers who placed {(at least one order but never placed more than one order) means (exactly one order)}.
-- 👉 Use JOIN
-- 👉 No subquery in SELECT
SELECT c.customer_id 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING COUNT(o.order_id) = 1;
-- what will be the result of HAVING COUNT(*) = 1
/*
Answer:
With an INNER JOIN, COUNT(*) = COUNT(o.order_id) because joined rows exist only for orders.
So both work here, but:

👉 Best practice: use COUNT(o.order_id) — more explicit.
*/

-- Q3. ⚠️ Anti-Join Logic
-- Tables:
-- products(product_id)
-- sales(product_id, sale_date)

-- Return products that were never sold.
SELECT p.product_id
FROM products p
LEFT JOIN sales s
  ON p.product_id = s.product_id
WHERE s.product_id IS NULL;
-- LEFT JOIN + WHERE right_table.col IS NULL


-- 🔹 SET 2 — JOIN + Aggregation (Business Logic)
-- Q4.
-- Tables:
-- employees(emp_id, dept_id, salary)
-- departments(dept_id, dept_name)

-- Return department name and average salary, but only for departments having more than 3 employees.
SELECT d.dept_name, AVG(e.salary) AS average_salary 
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id 
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 3;

-- Q5. ⚠️ Interview Favorite
-- Tables:
-- orders(order_id, customer_id, amount)

-- Return customers whose average order amount is greater than the company-wide average order amount.
-- 👉 No GROUP BY in outer query
-- 👉 Window function required
SELECT DISTINCT customer_id
FROM (
  SELECT customer_id,
         AVG(amount) OVER (PARTITION BY customer_id) AS cust_avg,
         AVG(amount) OVER () AS company_avg
  FROM orders
) t
WHERE cust_avg > company_avg;



-- 🔹 SET 3 — Window Functions (Core)
-- Q6.
-- Table:
-- employees(emp_id, dept_id, salary)

-- Return each employee with:
-- salary
-- department max salary
-- difference from department max salary
-- 👉 No subqueries
-- 👉 Must use window functions
SELECT emp_id, salary, dept_max_salary, diff_from_max_salary
FROM (
	SELECT emp_id, dept_id, salary, 
	  MAX(salary) OVER(PARTITION BY dept_id) AS dept_max_salary, 
	  (MAX(salary)OVER(PARTITION BY dept_id) - salary) AS diff_from_max_salary
	FROM employees
) t;

-- Q7. ⚠️ Logic Depth
-- Table:
-- scores(student_id, exam_date, marks)
-- Return students whose (marks never decreased across exams.) means (continous increase)
SELECT student_id 
FROM (
	SELECT student_id, exam_date, marks, LAG(marks) OVER(pARTITION BY student_id ORDER BY exam_date) AS prev_marks
	FROM scores 
) t 
GROUP BY student_id
HAVING SUM(CASE WHEN marks <= prev_marks THEN 1 ELSE 0 END) = 0;

-- Q8.
-- Table:
-- sales(order_id, order_date, amount)
-- Return:
-- order_id
-- order_date
-- amount
-- 3-day moving average of sales (current day + previous 2 days)
SELECT order_id, order_date, amount,
       AVG(amount) OVER (
         ORDER BY order_date
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS moving_avg
FROM sales;
-- Missing frame definition | Filtering by CURRENT_DATE + 2 is wrong

-- 🔹 SET 4 — Ranking & Comparison
-- Q9.
-- Table:
-- employees(emp_id, dept_id, salary)
-- Return second highest salary per department
-- 👉 Handle ties correctly
-- 👉 Use window functions only
SELECT dept_id, MAX(CASE WHEN rk = 2 THEN salary ELSE NULL END) AS second_highest_salary
FROM (
	SELECT emp_id, dept_id, salary, 
		DENSE_RANK() OVER(PARTITION BY dept_id ORDER BY salary DESC) AS rk 
	FROM employees
) t
GROUP BY dept_id;

-- Q10. ⚠️ Very Common
-- Table:
-- employees(emp_id, salary)
-- Return employees whose salary is in the top 10% of all salaries.
SELECT emp_id
FROM (
  SELECT emp_id,
         NTILE(10) OVER(ORDER BY salary DESC) AS tile
  FROM employees
) t
WHERE tile = 1;
-- 👉 Meaning: top 10% ≈ highest tile

-- 🔹 SET 5 — Date + Window Logic
-- Q11.
-- Table:
-- logins(user_id, login_date)
-- Return users who logged in on at least 3 consecutive days.
SELECT DISTINCT user_id
FROM (
  SELECT user_id,
         login_date,
         login_date - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) AS grp
  FROM logins
) t
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;
-- 👉 Interview trick: date - row_number()

-- Q12. ⚠️ Interview Trap
-- Table:
-- orders(order_id, order_date)
-- Return orders placed on the last working day (Mon–Fri) of each month.
SELECT order_id
FROM orders
WHERE order_date = (
  SELECT MAX(order_date)
  FROM orders o2
  WHERE EXTRACT(YEAR FROM o2.order_date) = EXTRACT(YEAR FROM orders.order_date)
    AND EXTRACT(MONTH FROM o2.order_date) = EXTRACT(MONTH FROM orders.order_date)
    AND DAYNAME(o2.order_date) NOT IN ('Saturday','Sunday')
);



-- 🔹 SET 6 — Debug & Explain (Must Explain in Interview)
-- Q13. ❌ What’s wrong?
-- SELECT emp_id, salary,
--        MAX(salary) OVER(PARTITION BY dept_id) AS max_sal
-- FROM employees
-- WHERE salary < max_sal;

-- 👉 Explain why it fails
-- 👉 Fix it

-- Answer: the use of alias in WHERE(for filtering). The corrected query as:
SELECT emp_id, salary, max_sal 
FROM (
	SELECT emp_id, salary, 
	  MAX(salary) OVER(PARTITION BY dept_id) AS max_sal 
	FROM employees 
) t 
WHERE salary < max_sal;


-- Q14. ❌ Identify the bug
-- SELECT customer_id
-- FROM orders
-- GROUP BY customer_id
-- HAVING COUNT(order_date) = COUNT(DISTINCT order_date);

-- 👉 What business logic does this incorrectly assume?
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(order_date) = COUNT(DISTINCT order_date);
-- “Customers never place multiple orders on the same day”

/*
🔹 SET 7 — 💀 FINAL INTERVIEW QUESTION
Q15.
Table:
transactions(user_id, txn_date, amount)

Return users who:
made transactions on exactly 3 consecutive days
and no other days

👉 Window functions required
👉 No GROUP BY in outer query
*/
SELECT user_id
FROM (
  SELECT user_id,
         txn_date,
         txn_date - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY txn_date) AS grp
  FROM transactions
) t
GROUP BY user_id, grp
HAVING COUNT(*) = 3;
