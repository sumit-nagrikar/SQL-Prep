create database practice;
use practice;
show tables;
-- Create the table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    salary DECIMAL(10, 2)
);

--  Q.1 To retrieve employees earning above the average salary, you can use SQL. Here's how you can do it:
-- insert data
INSERT INTO employees (employee_id, name, salary) VALUES
(1, 'John Doe', 50000),
(2, 'Jane Smith', 70000),
(3, 'Alex Brown', 40000),
(4, 'Chris White', 90000);

SELECT * FROM employees;

-- we have to find employees earning salary higher than average

SELECT employee_id, name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

SELECT * FROM employees WHERE employee_id IS NULL OR name IS NULL OR salary IS NULL;

ALTER TABLE employees
MODIFY employee_id INT NOT NULL,
MODIFY name VARCHAR(50) NOT NULL,
MODIFY salary DECIMAL(10,2) NOT NULL;


-- Q.2 To retrieve the nth highest salary from an employee table, you can use SQL queries. Here's a standard approach:

 -- Query Using LIMIT and OFFSET (For MySQL/PostgreSQL)
 
 SELECT DISTINCT name, salary
 FROM employees
 ORDER BY salary DESC
 LIMIT 1 OFFSET 2;
 
 -- Query Using DENSE_RANK() (For SQL Server/Oracle)
 SELECT salary 
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) as `rank` 
    FROM employees
) ranked_salaries
WHERE `rank` = 1;

-- Query Using ROW_NUMBER() (Similar to DENSE_RANK())

SELECT salary 
FROM (
    SELECT salary, ROW_NUMBER() OVER (ORDER BY salary DESC) as `rank` 
    FROM employees
) ranked_salaries
WHERE `rank` = 2;

SELECT VERSION();


-- Q.3 To identify duplicate email records in an employees table, you can use SQL queries with aggregation and filtering.

-- first add email column and add emails for everyone
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees
SET email = CASE
    WHEN employee_id = 1 THEN 'john.doe@example.com'
    WHEN employee_id = 2 THEN 'jane.smith@example.com'
    WHEN employee_id = 3 THEN 'alex.brown@example.com'
    WHEN employee_id = 4 THEN 'chris.white@example.com'
END;
INSERT INTO employees (employee_id, name, salary, email) VALUES
(5, 'Emily Clark', 60000, 'john.doe@example.com'), -- Duplicate email
(6, 'Liam Wilson', 45000, 'jane.smith@example.com'), -- Duplicate email
(7, 'Sophia Taylor', 55000, 'alex.brown@example.com'), -- Duplicate email
(8, 'Daniel Harris', 48000, 'chris.white@example.com'); -- Duplicate email


SET SQL_SAFE_UPDATES = 0;

-- Query to Find Duplicate Emails:
SELECT email, COUNT(email) AS count
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;

-- what if I also want to show names alongside them

SELECT e1.name, e1.email
FROM employees e1
JOIN (
		SELECT email
        FROM employees
        GROUP BY email
        HAVING COUNT(*) > 1
	) duplicates
ON e1.email = duplicates.email;

-- Query to Get Full Details of Employees with Duplicate Emails: 
-- first add column join_ date

ALTER TABLE employees
ADD COLUMN join_date DATE;

-- find employees who joined within the last 30 days
-- insert join_date for each of them

UPDATE employees
SET join_date = CASE
	WHEN  employee_id = 1 THEN '2024-01-01'
    WHEN employee_id = 2 THEN '2023-02-01'
    WHEN employee_id = 3 THEN '2023-03-01'
    WHEN employee_id = 4 THEN '2023-04-01'
    WHEN employee_id = 5 THEN '2023-05-01'
    WHEN employee_id = 6 THEN '2023-06-01'
    WHEN employee_id = 7 THEN '2023-07-01'
    WHEN employee_id = 8 THEN '2023-08-01'
END;

UPDATE employees
SET join_date = CASE
    WHEN employee_id = 1 THEN DATE_SUB(CURDATE(), INTERVAL 15 DAY) -- Joined 15 days ago
    WHEN employee_id = 2 THEN DATE_SUB(CURDATE(), INTERVAL 45 DAY) -- Joined 45 days ago
    WHEN employee_id = 3 THEN DATE_SUB(CURDATE(), INTERVAL 10 DAY) -- Joined 10 days ago
    WHEN employee_id = 4 THEN DATE_SUB(CURDATE(), INTERVAL 5 DAY)  -- Joined 5 days ago
    WHEN employee_id = 5 THEN DATE_SUB(CURDATE(), INTERVAL 60 DAY) -- Joined 60 days ago
    WHEN employee_id = 6 THEN DATE_SUB(CURDATE(), INTERVAL 90 DAY) -- Joined 90 days ago
    WHEN employee_id = 7 THEN DATE_SUB(CURDATE(), INTERVAL 20 DAY) -- Joined 20 days ago
    WHEN employee_id = 8 THEN DATE_SUB(CURDATE(), INTERVAL 120 DAY) -- Joined 120 days ago
    WHEN employee_id = 9 THEN DATE_SUB(CURDATE(), INTERVAL 3 DAY)   -- Joined 3 days ago
    WHEN employee_id = 10 THEN DATE_SUB(CURDATE(), INTERVAL 75 DAY) -- Joined 75 days ago
END;


SELECT * FROM employees;
-- find employees who joined within the last 30 days

SELECT *
FROM employees
WHERE join_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);

-- For Databases Without DATE_SUB
-- If your database doesn't support DATE_SUB, use a direct calculation:

SELECT name, join_date
FROM employees
WHERE join_date >= CURRENT_DATE - INTERVAL 30 DAY;

-- FOR SQL SERVER NT GONNA WORK IN MYSQL

-- SELECT *
-- FROM employees
-- WHERE join_date >= DATEADD(DAY, -30, GETDATE());

-- determine the department with the highest number of employee
-- add column department
 ALTER TABLE employees
 ADD COLUMN department VARCHAR(20);
 
 UPDATE employees
SET department = CASE
	WHEN  employee_id = 1 THEN 'IT'
    WHEN employee_id = 2 THEN 'SALES'
    WHEN employee_id = 3 THEN 'IT'
    WHEN employee_id = 4 THEN 'IT'
    WHEN employee_id = 5 THEN 'IT'
    WHEN employee_id = 6 THEN 'TESTING'
    WHEN employee_id = 7 THEN 'SALES'
    WHEN employee_id = 8 THEN 'TESTING'
END;

SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC
LIMIT 1;

-- Handling Ties (Multiple Departments with Same Count)
SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department
HAVING employee_count = (
	SELECT MAX(employee_count)
    FROM (
        SELECT department, COUNT(*) as employee_count
        FROM employees
        GROUP BY department
    ) subquery
);

-- Rank employees based on their salaries -- 
-- To rank employees based on their salaries, you can use window functions like RANK(), DENSE_RANK(), or ROW_NUMBER() depending on your requirements.
-- Using RANK():

SELECT employee_id, name, salary,
	Rank() OVER (ORDER BY salary DESC) AS `rank`
FROM employees;

-- Key Differences:
-- RANK(): Skips ranks if there are ties (e.g., ranks 2 and 2 → next rank is 4).
-- DENSE_RANK(): Does not skip ranks if there are ties (e.g., ranks 2 and 2 → next rank is 3).
-- ROW_NUMBER(): No ties; each row gets a unique rank.


-- list consecutive seat numbers that are currently availabel
-- Create the table
create table seats (
	seat_number INT PRIMARY KEY,
    status VARCHAR(20)
);

-- Insert data into the table

INSERT INTO seats 
(seat_number, status)
VALUES
(1, 'available'),
(2, 'available'),
(3, 'occupied'),
(4, 'available'),
(5, 'available'),
(6, 'available'),
(7, 'occupied');

SELECT * FROM seats;

-- Query to Find Consecutive Available Seats
-- 1. Using Window Functions
-- If your database supports window functions, you can use the LAG() and LEAD() functions to check if a seat is part of a consecutive sequence of available seats.

SELECT seat_number
FROM (
SELECT seat_number,
		status,
        LAG(status) OVER (ORDER BY seat_number) as `prev_status`,
        LEAD(status) OVER (ORDER BY seat_number) as `next_status`
	FROM seats
) subquery
WHERE status = 'available'
AND (prev_status = 'available' OR next_status = 'available');

-- Q.7 identify days with temperruter higher than the previous day

CREATE TABLE weather (date DATE,
	temprature INT);
    
INSERT INTO weather(date,temprature) VALUES
('2024-11-15', 20),
('2024-11-16', 22),
('2024-11-17', 21),
('2024-11-18', 23),
('2024-11-19', 24);

SELECT date, temprature
FROM (
	SELECT date, temprature,
    LAG(temprature) OVER (ORDER BY date) AS `previous_temp`
    FROM weather
    ) subquery
WHERE temprature > previous_temp;

show tables;
use practice;
-- 2. Using a Self-Join (Second Query)

SELECT w1.date , w1.temprature
FROM weather w1 
JOIN weather w2
	ON w1.date = DATE_ADD(w2.date, INTERVAL 1 DAY)
WHERE w1.temprature > w2. temprature;

-- 8. find the last person who can fit into the elevator
-- create table persons

CREATE TABLE persons (
id INT PRIMARY KEY,
name VARCHAR(20),
weight INT
);

INSERT INTO persons(id, name, weight)
VALUES
	(1, 'Alice', 60),
    (2, 'Bob', 80),
    (3, 'Carol', 55),
    (4, 'Dave', 70),
    (5, 'Eve', 65);

-- Maximum weight capacity of elevator: For example, 200 kg.

-- first we take cumulative_weights as subquery

WITH cumulative_weights AS (
	SELECT 
		id,
        name,
        weight,
		SUM(weight) OVER (ORDER BY id) AS total_weight
    FROM persons
    )
SELECT id, name, total_weight
FROM cumulative_weights
WHERE total_weight <= 200
ORDER BY total_weight DESC
LIMIT 1;

-- 8. retirev themost rrecent three order for each customers
CREATE TABLE orders (
	order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL
    );
    
-- insert values to orders table

INSERT INTO orders ( order_id, customer_id, order_date, total_amount)
VALUES
	(1, 101, '2024-11-15', 500),
	(2, 102, '2024-11-16', 300),
	(3, 101, '2024-11-16', 700),
	(4, 101, '2024-11-17', 200),
	(5, 102, '2024-11-17', 150),
	(6, 101, '2024-11-18', 400);
    
