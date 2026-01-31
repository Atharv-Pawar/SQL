-- 🔹 SET 1 — JOIN Fundamentals (Must-Know)
-- Q1. INNER vs LEFT JOIN (Classic)
-- Tables:
-- employees(emp_id, dept_id)
-- departments(dept_id, dept_name)
-- 👉 Return all employees along with department name
-- 👉 If department does not exist, show NULL
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Q2. ⚠️ Interview Trap — WHERE vs ON
-- Same tables as Q1.
-- Return only employees belonging to ‘HR’ department,
-- but do NOT lose employees with NULL dept_id.
-- 👉 Write the query correctly and explain why condition placement matters.
SELECT e.emp_id, d.dept_name
FROM employees e
LEFT JOIN departments d
  ON e.dept_id = d.dept_id
 AND d.dept_name = 'HR';

-- Q3. Self Join (Very Common)
-- Table:
-- employees(emp_id, emp_name, manager_id)
-- 👉 Return:
-- employee_name | manager_name
SELECT e.emp_name AS employee_name, m.emp_name AS manager_name
FROM employees e 
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- 🔹 SET 2 — JOIN + Aggregation (Real Business Logic)
-- Q4.
-- Tables:
-- orders(order_id, customer_id, amount)
-- customers(customer_id, city)
-- 👉 Return city-wise total order amount
SELECT c.city, SUM(o.amount) AS total_amount
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city;

-- Q5. ⚠️ Interview Favorite
-- Same tables.
-- 👉 Return customers who never placed any order
-- ⚠️ Use JOIN, not EXISTS.
SELECT c.customer_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
--  o.customer_id IS NULL

-- Q6.
-- Tables:
-- employees(emp_id)
-- projects(project_id, emp_id)
-- 👉 Return employees working on more than one project
-- ⚠️ JOIN + GROUP BY required.
SELECT e.emp_id
FROM employees e
JOIN projects p ON e.emp_id = p.emp_id
GROUP BY e.emp_id
HAVING COUNT(p.project_id) > 1;
-- COUNT(*) counts rows even if project_id is NULL

-- 🔹 SET 3 — JOIN + WINDOW FUNCTIONS (High Yield)
-- Q7.
-- Table:
-- employees(emp_id, dept_id, salary)
-- 👉 Return:
-- emp_id | dept_id | salary | dept_avg_salary
SELECT emp_id, dept_id, salary, AVG(salary) OVER(PARTITION BY dept_id) AS dept_avg_salary
FROM employees;

-- Q8. ⚠️ Very Common Interview Question
-- Same table.
-- 👉 Return employees whose salary is above department average
-- ⚠️ Must use window function, no subquery filter.
SELECT emp_id, salary
FROM (
	SELECT emp_id, dept_id, salary, AVG(salary) OVER(PARTITION BY dept_id) AS dept_avg_salary
	FROM employees
) t 
WHERE salary > t.dept_avg_salary;

-- Q9.
-- Table:
-- sales(order_id, sale_date, amount)
-- 👉 Return:
-- order_id | sale_date | amount | running_total
-- 👉 Running total ordered by sale_date
SELECT order_id, sale_date, amount, SUM(amount) OVER(ORDER BY sale_date, order_id) AS running_total
FROM sales;

-- 🔹 SET 4 — Ranking & Comparison (Interview Gold)
-- Q10.
-- Table:
-- employees(emp_id, dept_id, salary)

-- 👉 Return top 2 highest paid employees per department
-- ⚠️ Use window function
-- ⚠️ Handle salary ties correctly
SELECT emp_id, salary
FROM (
	SELECT *, DENSE_RANK() OVER(PARTITION BY dept_id ORDER BY salary DESC) AS salary_rank
	FROM employees
) t 
WHERE t.salary_rank <= 2;

-- Q11.
-- Table:
-- scores(student_id, exam_date, marks)
-- 👉 Return:
-- student_id | exam_date | marks | previous_marks
SELECT student_id, exam_date, marks, LAG(marks) OVER(PARTITION BY student_id ORDER BY exam_date) AS previous_marks
FROM scores;

-- Q12. ⚠️ Logic Test
-- Same table.
-- 👉 Return students whose marks continuously increased in consecutive exams.
SELECT student_id
FROM (
  SELECT student_id,
         marks,
         LAG(marks) OVER(PARTITION BY student_id ORDER BY exam_date) AS prev_marks
  FROM scores
) t
GROUP BY student_id
HAVING SUM(CASE WHEN marks <= prev_marks THEN 1 ELSE 0 END) = 0;
-- 📌 This checks continuous increase

-- 🔹 SET 5 — JOIN + Date Logic (Interview Realism)
-- Q13.
-- Tables:
-- orders(order_id, order_date)
-- returns(order_id, return_date)

-- 👉 Return orders that were never returned
-- ⚠️ Use JOIN, not NOT IN.
SELECT o.order_id 
FROM orders o 
LEFT JOIN returns r ON o.order_id = r.order_id 
WHERE r.order_id IS NULL;

-- Q14.
-- Table:
-- logins(user_id, login_date)
-- 👉 Return users who logged in on consecutive days
SELECT user_id 
FROM (
	SELECT user_id, login_date, LAG(login_date) OVER(PARTITION BY user_id ORDER BY login_date) AS previous_login_date
	FROM logins
) l2
WHERE l2.login_date-l2.previous_login_date = 1;

-- OR --
-- ✅ Interview-Safe Version
SELECT DISTINCT user_id
FROM (
  SELECT user_id,
         login_date,
         LAG(login_date) OVER(PARTITION BY user_id ORDER BY login_date) AS prev_date
  FROM logins
) t
WHERE login_date = prev_date + INTERVAL '1 day';



-- 🔹 SET 6 — Debug & Fix (Interview Killer)
-- Q15. ❌ What’s wrong?
-- SELECT e.emp_id, d.dept_name
-- FROM employees e
-- LEFT JOIN departments d
-- WHERE d.dept_name = 'IT';
SELECT e.emp_id, d.dept_name
FROM employees e
LEFT JOIN departments d
  ON e.dept_id = d.dept_id
 AND d.dept_name = 'IT';


-- 👉 Explain + fix.
-- Q16. ❌ Fix the logic
-- SELECT emp_id,
--        salary,
--        AVG(salary) OVER() AS avg_salary
-- FROM employees
-- WHERE salary > avg_salary;

SELECT emp_id,
       salary
FROM (
	SELECT emp_id, dept_id, salary,
    AVG(salary) OVER(PARTITION BY dept_id) AS dept_avg_salary
	FROM employees
) t
WHERE salary > t.dept_avg_salary;


-- 🔹 SET 7 — FINAL INTERVIEW QUESTION 💀
-- Q17.
-- Tables:
-- orders(order_id, customer_id, order_date, amount)

-- 👉 For each customer, return:
-- customer_id
-- first_order_date
-- last_order_date
-- total_amount

-- ⚠️ Constraints:
-- Single SELECT
-- Use window functions
-- No GROUP BY in outer query
SELECT DISTINCT customer_id,
       FIRST_VALUE(order_date) OVER(
         PARTITION BY customer_id ORDER BY order_date
       ) AS first_order_date,
       FIRST_VALUE(order_date) OVER(
         PARTITION BY customer_id ORDER BY order_date DESC
       ) AS last_order_date,
       SUM(amount) OVER(PARTITION BY customer_id) AS total_amount
FROM orders;

-- 📌 Trick: Use FIRST_VALUE twice instead of LAST_VALUE
