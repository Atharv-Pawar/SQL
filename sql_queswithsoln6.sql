-- 🔹 SET 1 — JOINS (Interview Traps & Logic)

-- Q1. LEFT JOIN + Filter Trap
-- Tables:
-- employees(emp_id, dept_id)
-- departments(dept_id, dept_name)
-- 👉 Return all employees, but show only those departments whose name is ‘Finance’.
-- Employees without any department must still appear.

-- Q2. Anti-Join (Very Common)
-- Tables:
-- customers(customer_id)
-- orders(order_id, customer_id)
-- 👉 Return customers who never placed an order
-- ⚠️ Use JOIN
-- ⚠️ No NOT IN

-- Q3. Self Join (Hierarchy)
-- Table:
-- employees(emp_id, emp_name, manager_id)
-- 👉 Return:
-- employee_name | manager_name
-- 👉 CEO’s manager should appear as NULL

-- Q4. JOIN + Aggregation Logic
-- Tables:
-- employees(emp_id, dept_id, salary)
-- departments(dept_id, dept_name)
-- 👉 Return departments whose average salary is higher than company-wide average salary

-- 🔹 SET 2 — WINDOW FUNCTIONS (Must-Know)

-- Q5. Department Comparison
-- Table:
-- employees(emp_id, dept_id, salary)
-- 👉 Return employees who earn less than the department maximum
-- ⚠️ No subqueries in WHERE
-- ⚠️ Window function only

-- Q6. Ranking Logic
-- Table:
-- employees(emp_id, dept_id, salary)
-- 👉 Return third highest salary per department
-- ⚠️ Handle ties correctly
-- ⚠️ Use window functions

-- Q7. Change Detection
-- Table:
-- employees(emp_id, salary_month, salary)
-- 👉 Return employees whose salary decreased at least once

-- Q8. Consecutive Rows Logic (Interview Favorite)
-- Table:
-- logins(user_id, login_date)
-- 👉 Return users who logged in on at least 3 consecutive days

-- 🔹 SET 3 — JOIN + WINDOW FUNCTIONS (Real World)

-- Q9. JOIN + Running Total
-- Tables:
-- orders(order_id, order_date, amount)
-- customers(customer_id, city)
-- 👉 Return:
-- city | order_date | daily_amount | running_city_total

-- Q10. JOIN + Ranking
-- Tables:
-- students(student_id, class_id, marks)
-- classes(class_id, class_name)
-- 👉 Return top 2 students per class
-- ⚠️ Handle ties
-- ⚠️ Show class_name

-- 🔹 SET 4 — DATE + WINDOW (Logic Heavy)

-- Q11. Last Activity Logic
-- Table:
-- user_activity(user_id, activity_date)
-- 👉 Return users who were active yesterday but NOT today

-- Q12. Monthly Logic
-- Table:
-- orders(order_id, order_date, amount)
-- 👉 Return orders placed on the first order date of each month

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
