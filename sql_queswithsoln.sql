-- SET 1 — JOIN Logic (Interview Traps)
-- Q1. ⚠️ LEFT JOIN Trap
-- Tables:
-- employees(emp_id, dept_id)
-- departments(dept_id, dept_name)

-- Return all employees and show dept_name = 'Unknown' if department is missing.
SELECT e.emp_id, CASE
	WHEN e.dept_id IS NULL THEN 'Unknown'
	ELSE d.dept_name
END AS dept_name
FROM employees e 
LEFT JOIN departments d ON e.dept_id = d.dept_id;


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

-- Q3. ⚠️ Anti-Join Logic
-- Tables:
-- products(product_id)
-- sales(product_id, sale_date)

-- Return products that were never sold.
SELECT p.product_id
FROM products p 
LEFT JOIN sales s ON p.product_id = s.product_id
  AND s.product_id IS NULL;


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
SELECT t.customer_id 
FROM (
	SELECT customer_id, AVG(amount) OVER(PARTITION BY customer_id) AS customer_average_order_amount
	FROM customers 
) t 
JOIN (
	SELECT customer_id, AVG(amount) AS company_wide_order_amount 
	FROM customers 
	GROUP BY customer_id
) t2 ON t.customer_id = t2.customer_id
  AND t.customer_average_order_amount > t2.company_wide_order_amount;


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
SELECT order_id, order_date, amount, moving_avg
FROM (
	SELECT order_id, order_date, amount, 
	  AVG(amount) OVER(PARTITION BY order_date ORDER BY order_date) AS moving_avg
	FROM sales 
) t 
WHERE order_date = CURRENT_DATE + INTERVAL '2 days';

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
	SELECT emp_id, salary, NTILE(salary, 10) AS top_10_salary
	FROM employees
) t
WHERE salary >= top_10_salary;

-- 🔹 SET 5 — Date + Window Logic
-- Q11.
-- Table:
-- logins(user_id, login_date)
-- Return users who logged in on at least 3 consecutive days.
SELECT user_id
FROM (
	SELECT user_id, login_date, LAG(login_date) OVER(PARTITION BY user_id ORDER BY login_date) AS prev_login_date
	FROM logins 
) t 
WHERE login_date >= prev_login_date + INTERVAL '3 days';

-- Q12. ⚠️ Interview Trap
-- Table:
-- orders(order_id, order_date)
-- Return orders placed on the last working day (Mon–Fri) of each month.
SELECT order_id 
FROM (
	SELECT order_id, order_date, 
	  LAG(order_date) OVER(PARTITION BY EXTRACT(MONTH FROM order_date) ORDER BY order_date) AS prev_order_date
	FROM orders 
) t 
WHERE prev_order_date < order_date
  AND DAYNAME(t.prev_order_date) IN ('Monday', 'Tuesday', 'Wednesday', 'Thrusday', 'Friday');


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
HAVING COUNT(order_date) = (
	SELECT DISTINCT COUNT(order_date)
	FROM orders 
);

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
	SELECT user_id, txn_date, LAG(txn_date) OVER(PARTITION BY user_id ORDER BY txn_date) AS prev_txn_date
	FROM transactions
) t 
WHERE txn_date = prev_txn_date + INTERVAL '3 days';
