/*
Table: employees
emp_id | dept_id | salary | emp_name
1024 101 65000	Aarav
1241 101 55000	Smita
1279 102 78000	Amey
2400 104 96000	Renuka
4800 104 97000	Atharv
2309 103 45000 	Rahul
2100 102 78000 	Pritam
2252 102 75000	Sumit
3275 103 67000 	Catherine
3211 103 67000  Asfaq
1025 101 72000	Stephenie

*/

-- return 3rd highest salary 
SELECT DISTINCT salary FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 2;

-- return department wise 3rd highest salary and if the dept has 2 employees return dept_id with NULL AS 3rd highest salary
SELECT dept_id, 
	MAX(CASE WHEN _rnk_ = 3 THEN salary END) AS third_highest_salary 
FROM (
	SELECT dept_id, salary, 
		DENSE_RANK() OVER(PARTITION BY dept_id ORDER BY salary DESC) AS _rnk_
	FROM employees
) t 
GROUP BY dept_id;
