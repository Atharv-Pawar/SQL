-- SET 1 — JOIN Logic (Interview Traps)
-- Q1. ⚠️ LEFT JOIN Trap

-- Tables:

-- employees(emp_id, dept_id)

-- departments(dept_id, dept_name)

-- Return all employees and show dept_name = 'Unknown' if department is missing.

-- Q2.

-- Tables:

-- customers(customer_id)

-- orders(order_id, customer_id)

-- Return customers who placed at least one order but never placed more than one order.
-- 👉 Use JOIN
-- 👉 No subquery in SELECT

-- Q3. ⚠️ Anti-Join Logic

-- Tables:

-- products(product_id)

-- sales(product_id, sale_date)

-- Return products that were never sold.

-- 🔹 SET 2 — JOIN + Aggregation (Business Logic)
-- Q4.

-- Tables:

-- employees(emp_id, dept_id, salary)

-- departments(dept_id, dept_name)

-- Return department name and average salary, but only for departments having more than 3 employees.

-- Q5. ⚠️ Interview Favorite

-- Tables:

-- orders(order_id, customer_id, amount)

-- Return customers whose average order amount is greater than the company-wide average order amount.
-- 👉 No GROUP BY in outer query
-- 👉 Window function required

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

-- Q7. ⚠️ Logic Depth

-- Table:

-- scores(student_id, exam_date, marks)

-- Return students whose marks never decreased across exams.

-- Q8.

-- Table:

-- sales(order_id, order_date, amount)

-- Return:

-- order_id

-- order_date

-- amount

-- 3-day moving average of sales (current day + previous 2 days)

-- 🔹 SET 4 — Ranking & Comparison
-- Q9.

-- Table:

-- employees(emp_id, dept_id, salary)

-- Return second highest salary per department
-- 👉 Handle ties correctly
-- 👉 Use window functions only

-- Q10. ⚠️ Very Common

-- Table:

-- employees(emp_id, salary)

-- Return employees whose salary is in the top 10% of all salaries.

-- 🔹 SET 5 — Date + Window Logic
-- Q11.

-- Table:

-- logins(user_id, login_date)

-- Return users who logged in on at least 3 consecutive days.

-- Q12. ⚠️ Interview Trap

-- Table:

-- orders(order_id, order_date)

-- Return orders placed on the last working day (Mon–Fri) of each month.

-- 🔹 SET 6 — Debug & Explain (Must Explain in Interview)
-- Q13. ❌ What’s wrong?
-- SELECT emp_id, salary,
--        MAX(salary) OVER(PARTITION BY dept_id) AS max_sal
-- FROM employees
-- WHERE salary < max_sal;


-- 👉 Explain why it fails
-- 👉 Fix it

-- Q14. ❌ Identify the bug
-- SELECT customer_id
-- FROM orders
-- GROUP BY customer_id
-- HAVING COUNT(order_date) = COUNT(DISTINCT order_date);

-- 👉 What business logic does this incorrectly assume?

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
