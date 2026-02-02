-- 🔹 SET 1 — JOINS (Interview Traps & Logic)

-- Q1. LEFT JOIN + Filter Trap
-- Tables:
-- employees(emp_id, dept_id)
-- departments(dept_id, dept_name)
-- 👉 Return all employees, but show only those departments whose name is ‘Finance’.
-- Employees without any department must still appear.
SELECT e.emp_id, d.dept_name 
FROM employees e 
LEFT JOIN departments d 
ON e.dept_id = d.dept_id 
  AND d.dept_name = 'Finance';

-- Q2. Anti-Join (Very Common)
-- Tables:
-- customers(customer_id)
-- orders(order_id, customer_id)
-- 👉 Return customers who never placed an order
-- ⚠️ Use JOIN
-- ⚠️ No NOT IN
SELECT c.customer_id 
FROM customers c 
LEFT JOIN orders o 
ON c.customer_id = o.customer_id 
WHERE o.order_id IS NULL;

-- Q3. Self Join (Hierarchy)
-- Table:
-- employees(emp_id, emp_name, manager_id)
-- 👉 Return:
-- employee_name | manager_name
-- 👉 CEO’s manager should appear as NULL
SELECT e.emp_name AS employee_name, m.emp_name AS manager_name
FROM employees e 
LEFT JOIN employees m 
ON e.manager_id = m.emp_id;

-- Q4. JOIN + Aggregation Logic
-- Tables:
-- employees(emp_id, dept_id, salary)
-- departments(dept_id, dept_name)
-- 👉 Return departments whose average salary is higher than company-wide average salary
SELECT d.dept_id, d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d 
JOIN employees e ON d.dept_id = e.dept_id 
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > (
	SELECT AVG(salary) 
	FROM employees
);

-- 🔹 SET 2 — WINDOW FUNCTIONS (Must-Know)

-- Q5. Department Comparison
-- Table:
-- employees(emp_id, dept_id, salary)
-- 👉 Return employees who earn less than the department maximum
-- ⚠️ No subqueries in WHERE
-- ⚠️ Window function only
SELECT emp_id
FROM (
	SELECT emp_id, dept_id, salary,
	  MAX(salary) OVER(PARTITION BY dept_id) AS max_dept_salary
	FROM employees 
) t 
WHERE dept_id = t.dept_id
  AND salary < t.max_dept_salary;

-- Q6. Ranking Logic
-- Table:
-- employees(emp_id, dept_id, salary)
-- 👉 Return third highest salary per department
-- ⚠️ Handle ties correctly
-- ⚠️ Use window functions
SELECT dept_id, MAX(CASE WHEN dnsrnk = 3 THEN salary END) AS third_highest_salary
FROM (
	SELECT emp_id, dept_id, salary,
	  DENSE_RANK() OVER(PARTITION BY dept_id ORDER BY salary DESC) AS dnsrnk 
	FROM employees 
) t 
GROUP BY dept_id;

-- Q7. Change Detection
-- Table:
-- employees(emp_id, salary_month, salary)
-- 👉 Return employees whose salary decreased at least once
SELECT emp_id 
FROM (
	SELECT emp_id, salary_month, salary, 
	  LAG(salary) OVER(PARTITION BY emp_id ORDER BY salary_month) AS prev_month_salary
	FROM employees
) t 
GROUP BY emp_id	
HAVING SUM(CASE WHEN salary < prev_month_salary THEN 1 ELSE 0 END) != 0;
	
-- Q8. Consecutive Rows Logic (Interview Favorite)
-- Table:
-- logins(user_id, login_date)
-- 👉 Return users who logged in on at least 3 consecutive days
SELECT user_id 
FROM (
	SELECT user_id, login_date, 
	  (login_date - ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date)) AS gaps
	FROM logins 
) t 
GROUP BY user_id, gaps
HAVING COUNT(*) >= 3;

-- 🔹 SET 3 — JOIN + WINDOW FUNCTIONS (Real World)

-- Q9. JOIN + Running Total
-- Tables:
-- orders(order_id, customer_id, order_date, amount)
-- customers(customer_id, city)
-- 👉 Return:
-- city | order_date | daily_amount | running_city_total
SELECT
    city,
    order_date,
    daily_amount,
    SUM(daily_amount) OVER (
        PARTITION BY city
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_city_total
FROM (
    SELECT
        c.city,
        o.order_date,
        SUM(o.amount) AS daily_amount
    FROM customers c
    JOIN orders o
      ON c.customer_id = o.customer_id
    GROUP BY c.city, o.order_date
) t;



-- Q10. JOIN + Ranking
-- Tables:
-- students(student_id, class_id, marks)
-- classes(class_id, class_name)
-- 👉 Return top 2 students per class
-- ⚠️ Handle ties
-- ⚠️ Show class_name
SELECT
    c.class_name,
    s.student_id,
    s.marks
FROM (
    SELECT
        student_id,
        class_id,
        marks,
        DENSE_RANK() OVER (
            PARTITION BY class_id
            ORDER BY marks DESC
        ) AS rnk
    FROM students
) s
JOIN classes c
  ON s.class_id = c.class_id
WHERE rnk <= 2;


-- 🔹 SET 4 — DATE + WINDOW (Logic Heavy)

-- Q11. Last Activity Logic
-- Table:
-- user_activity(user_id, activity_date)
-- 👉 Return users who were active yesterday but NOT today
SELECT DISTINCT user_id
FROM user_activity
WHERE activity_date = CURRENT_DATE - INTERVAL '1 day'
  AND user_id NOT IN (
      SELECT user_id
      FROM user_activity
      WHERE activity_date = CURRENT_DATE
  );


-- Q12. Monthly Logic
-- Table:
-- orders(order_id, order_date, amount)
-- 👉 Return orders placed on the first order date of each month
SELECT order_id, order_date, amount 
FROM (
	SELECT order_id, order_date, amount,
	  RANK() OVER(PARTITION BY 
		EXTRACT(YEAR FROM order_date),
		EXTRACT(MONTH FROM order_date) 
	  ORDER BY order_date) AS rnk
) t 
WHERE rnk = 1;

-- 🔹 SET 5 — 🔥 RECURSIVE CTE (Interview Core)

-- Q13. Number Generation
-- Generate numbers from 1 to 100 using WITH RECURSIVE


-- Q14. Employee Hierarchy
-- Table:
-- employees(emp_id, manager_id, emp_name)
-- 👉 Return full employee hierarchy starting from CEO
-- 👉 Show: emp_id | emp_name | level


-- Q15. Salary Rollup (Hard)
-- Table:
-- org(emp_id, manager_id, salary)
-- 👉 Return total salary under each manager
-- (including all indirect reports)
-- ⚠️ Must use recursive CTE


-- 🔹 SET 6 — FINAL INTERVIEW QUESTION 💀

-- Q16. Extreme Logic Test
-- Table:
-- transactions(user_id, txn_date)
-- 👉 Return users who made transactions on exactly 2 consecutive days only
-- (not more, not less)
-- ⚠️ Window functions required
-- ⚠️ No GROUP BY in outer query
