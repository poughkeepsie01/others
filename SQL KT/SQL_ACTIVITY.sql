--1.

SELECT *
  FROM employees
 WHERE employee_id >= 50;

--1.1

SELECT *
  FROM employees
 WHERE employee_id >= 50 AND manager_id <= 30;


--1.2
--there are no manager_id less than 30

SELECT *
  FROM employees
 WHERE employee_id >= 50 AND manager_id <= 30 OR job_id = 'IT_PROG';


--2
--employee_id (PK)

INSERT INTO employees (employee_id,
                       first_name,
                       last_name,
                       email,
                       phone_number,
                       hire_date,
                       job_id,
                       salary,
                       commission_pct,
                       manager_id,
                       department_id)
     VALUES (4,
             'Samira',
             'Chica',
             'samira1@chica',
             '09123456789',
             TO_DATE ('05-16-2022', 'mm-dd-yyyy'),
             'IT_PROG',
             10000,
             .2,
             4,
             10);


--3

SELECT *
  FROM jobs j, employees e
 WHERE     e.job_id = j.job_id
       AND j.job_title = (SELECT job_title
                            FROM jobs
                           WHERE job_id = 'SH_CLERK');



--3.1,2
--there are no employees Jasmine and Amber

SELECT *
  FROM jobs j, employees e
 WHERE     e.job_id = j.job_id
       AND j.job_title = 'Shipping Clerk'
       AND first_name NOT IN ('Jasmine', 'Amber');

--3.3

SELECT first_name || ' ' || last_name "Name"
  FROM employees e JOIN jobs j ON j.job_id = e.job_id
 WHERE     j.job_title = 'Shipping Clerk'
       AND first_name NOT IN ('Jasmine', 'Amber');


--4

SELECT *
  FROM employees
 WHERE employee_id IN (71, 72);

--5

SELECT DISTINCT job_title
  FROM jobs j, employees e
 WHERE e.job_id = j.job_id;



--6

  SELECT manager_id, COUNT (employee_id) EMP
    FROM employees
GROUP BY manager_id;

--6.1

  SELECT manager_id, COUNT (employee_id) EMP
    FROM employees
GROUP BY manager_id
ORDER BY EMP DESC;

--7

SELECT *
  FROM employees
 WHERE manager_id IS NULL;

--8


UPDATE employees
   SET job_id = 'UNEMP'
 WHERE employee_id BETWEEN 101 AND 104 OR phone_number LIKE '5%';

UPDATE employees
   SET hire_date = TO_DATE ('05-17-2022', 'mm-dd-yyyy')
 WHERE employee_id = 331;


SELECT *
  FROM employees
 WHERE employee_id BETWEEN 101 AND 104;

SELECT *
  FROM employees
 WHERE phone_number LIKE '5%';


INSERT INTO jobs
     VALUES ('UNEMP',
             'UNEMPLOYED',
             10000,
             20000);

SELECT *
  FROM employees e JOIN jobs j USING (job_id)
 WHERE e.employee_id BETWEEN 101 AND 104 OR e.phone_number LIKE '5%';

SELECT *
  FROM employees
 WHERE employee_id BETWEEN 101 AND 104 OR phone_number LIKE '5%';

--9

CREATE TABLE Customers
(
   ID              NUMBER (2),
   Customer_Name   VARCHAR2 (25),
   Address         VARCHAR2 (25)
);

--10

DROP TABLE customers;