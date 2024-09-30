/*CREATE TABL TABLE_NAMEE*/

CREATE TABLE DEPT_SAM
(
   DEPTNO        NUMBER (2),
   DNAME         VARCHAR2 (14),
   LOC           VARCHAR2 (13),
   CREATE_DATE   DATE DEFAULT SYSDATE
);

----------------------------------------------------------------------

/*ALTER TABLE TABLE_NAME
 (MODIFY, ADD, DROP)*/

ALTER TABLE DEPT_SAM
MODIFY (DEPTNO VARCHAR(20));

ALTER TABLE DEPT_SAM
ADD (LOCATIONS VARCHAR(20));

ALTER TABLE DEPT_SAM
DROP COLUMN LOCATIONS;

ALTER TABLE DEPT_SAM                             --modify(deptno primary key);
                    DROP PRIMARY KEY;

---------------------------------------------------------------------

/*INSERT INTO TABLE_NAME*/

INSERT INTO DEPT_SAM (DEPTNO, DNAME, LOC)
     VALUES (100, 'SAM', 'LAGUNA');

---------------------------------------------------------------------

/*UPDATE TABLE_NAME*/

UPDATE DEPT_SAM
   SET DEPTNO = 200
 WHERE DNAME = 'SAM' AND LOC = 'LAGUNA';

---------------------------------------------------------------------------

/*ALIAS,BETWEEN, IN, LIKE(%,_), NULL, OR, AND, NOT(<>), CONCATENATE, ORDER BY */

SELECT LAST_NAME, SALARY, 12 * SALARY + 300 AS "New_Salary" FROM EMPLOYEES;

SELECT FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME,
       SALARY,
       COMMISSION_PCT,
       (SALARY * COMMISSION_PCT) + SALARY AS TOTAL_SALARY
  FROM EMPLOYEES;

  SELECT *
    FROM EMPLOYEES
   WHERE SALARY BETWEEN 5000 AND 10000
ORDER BY SALARY;

SELECT *
  FROM EMPLOYEES
 WHERE FIRST_NAME IN ('Kevin', 'Charles');

SELECT *
  FROM EMPLOYEES
 WHERE FIRST_NAME LIKE '%h%_l';

SELECT *
  FROM EMPLOYEES
 WHERE COMMISSION_PCT IS NULL;

SELECT EMPLOYEE_ID,
       LAST_NAME,
       JOB_ID,
       SALARY
  FROM EMPLOYEES
 WHERE SALARY >= 12000 OR JOB_ID LIKE '%MAN%';

SELECT FIRST_NAME || ' is in ' || JOB_ID AS "Emp Job_id"
  FROM EMPLOYEES
 WHERE EMPLOYEE_ID <> 105;

  SELECT *
    FROM EMPLOYEES
   WHERE SALARY BETWEEN 5000 AND 10000
ORDER BY SALARY;

-----------------------------------------------------------------------

/*USER INPUT*/

SELECT EMPLOYEE_ID,
       LAST_NAME,
       SALARY,
       DEPARTMENT_ID
  FROM EMPLOYEES
 WHERE SALARY = &EMPLOYEE_SALARY;

--------------------------------------------------------------------

/*USE OF ROWNUM*/

SELECT JOB_ID
  FROM (  SELECT JOB_ID
            FROM EMPLOYEES
        GROUP BY JOB_ID
        ORDER BY COUNT (*) DESC)
 WHERE ROWNUM <= 1;

--------------------------------------------------------------------------

                        /* all even empID
                          !=0 --odd     */

SELECT EMPLOYEE_ID
  FROM EMPLOYEES
 WHERE MOD (EMPLOYEE_ID, 2) = 0;

-----------------------------------------------------------------------

/*CASE WHEN*/

SELECT FIRST_NAME,
       JOB_ID,
       CASE JOB_ID WHEN 'IT_PROG' THEN 'programmer' ELSE 'not programmer' END
          WHATAREYOU
  FROM EMPLOYEES;

SELECT FIRST_NAME,
       SALARY,
       CASE
          WHEN SALARY < 5000 THEN 'c'
          WHEN SALARY BETWEEN 5000 AND 15000 THEN 'b'
          WHEN SALARY BETWEEN 15000 AND 20000 THEN 'a'
          ELSE 's'
       END
          SALARY_RATE
  FROM EMPLOYEES;

----------------------------------------------------------------------

 /*JOIN*/

  SELECT EMPLOYEE_ID, FIRST_NAME, DEPARTMENT_NAME
    FROM EMPLOYEES
         INNER JOIN DEPARTMENTS
            ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.DEPARTMENT_ID
ORDER BY EMPLOYEE_ID;

  SELECT *
    FROM EMPLOYEES NATURAL JOIN DEPARTMENTS
ORDER BY EMPLOYEE_ID;

  SELECT EMPLOYEE_ID, FIRST_NAME, DEPARTMENT_NAME
    FROM EMPLOYEES
         LEFT JOIN DEPARTMENTS
            ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.DEPARTMENT_ID
ORDER BY EMPLOYEE_ID;

  SELECT EMPLOYEE_ID,
         FIRST_NAME,
         LAST_NAME,
         DEPARTMENT_NAME
    FROM EMPLOYEES
         RIGHT JOIN DEPARTMENTS
            ON EMPLOYEES.MANAGER_ID = DEPARTMENTS.MANAGER_ID
ORDER BY EMPLOYEE_ID;

  SELECT EMPLOYEE_ID, FIRST_NAME, DEPARTMENT_NAME
    FROM EMPLOYEES CROSS JOIN DEPARTMENTS
   --all of the employees in a department_name
   WHERE EMAIL IN ('fff@zzz.com', 'SKING', 'JCHEN')
ORDER BY EMPLOYEE_ID;

  SELECT E.FIRST_NAME, D.DEPARTMENT_NAME, D.DEPARTMENT_ID
    FROM EMPLOYEES E
         FULL OUTER JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
ORDER BY EMPLOYEE_ID;

SELECT EMPLOYEE_ID,
       FIRST_NAME,
       DEPARTMENT_NAME,
       SALARY
  FROM EMPLOYEES JOIN DEPARTMENTS USING (DEPARTMENT_ID)
 WHERE SALARY < 5000;

SELECT EMPLOYEE_ID, CITY, DEPARTMENT_NAME
  FROM EMPLOYEES E
       JOIN DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
       JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID;

SELECT E.EMPLOYEE_ID,
       E.LAST_NAME,
       E.DEPARTMENT_ID,
       E.MANAGER_ID,
       D.DEPARTMENT_ID,
       D.LOCATION_ID
  FROM EMPLOYEES E
       JOIN DEPARTMENTS D
          ON (E.DEPARTMENT_ID = D.DEPARTMENT_ID) AND E.MANAGER_ID = 149;

SELECT E.EMPLOYEE_ID,
       E.LAST_NAME,
       E.DEPARTMENT_ID,
       E.MANAGER_ID,
       D.DEPARTMENT_ID,
       D.LOCATION_ID
  FROM EMPLOYEES E JOIN DEPARTMENTS D ON (E.DEPARTMENT_ID = D.DEPARTMENT_ID)
 WHERE E.MANAGER_ID = 149;

----------------------------------------------------------------------------

/*TO_CHAR & TO_DATE*/

SELECT LAST_NAME, TO_CHAR (HIRE_DATE, 'DD-Mon-YYYY') EMP_HIRE_DATE
  FROM EMPLOYEES
 WHERE HIRE_DATE > TO_DATE ('01 Jan, 20', 'DD Mon,RR');

----------------------------------------------------------------------

/*UNION/ UNION ALL*/

SELECT DEPARTMENT_ID FROM EMPLOYEES
UNION                                                 --eliminate duplications
--or UNION ALL(with duplications)
SELECT DEPARTMENT_ID FROM DEPARTMENTS;

SELECT MANAGER_ID, DEPARTMENT_ID FROM EMPLOYEES
INTERSECT
SELECT MANAGER_ID, DEPARTMENT_ID FROM DEPARTMENTS;

----------------------------------------------------------------------

SELECT E.FIRST_NAME || ' ' || E.LAST_NAME FULL_NAME,
       J.JOB_TITLE,
       J.JOB_ID,
       D.DEPARTMENT_NAME,
       E.SALARY,
       L.STREET_ADDRESS
  FROM EMPLOYEES E
       JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
       JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
       JOIN JOBS J ON E.JOB_ID = J.JOB_ID;

SELECT E.FIRST_NAME, E.LAST_NAME, L.CITY
  FROM EMPLOYEES E, LOCATIONS L, DEPARTMENTS D
 WHERE E.DEPARTMENT_ID = D.DEPARTMENT_ID AND D.LOCATION_ID = L.LOCATION_ID;

--------------------------------------------------------------------

 /*SUBQUERIES*/

SELECT *
  FROM EMPLOYEES
 WHERE DEPARTMENT_ID = (SELECT DEPARTMENT_ID
                          FROM DEPARTMENTS
                         WHERE DEPARTMENT_ID = 20);

SELECT *
  FROM EMPLOYEES
 WHERE DEPARTMENT_ID = (SELECT DEPARTMENT_ID
                          FROM DEPARTMENTS
                         WHERE DEPARTMENT_NAME = 'Marketing');

SELECT EJ.FIRST_NAME, EJ.DEPARTMENT_NAME, J.JOB_TITLE
  FROM JOBS J
       INNER JOIN
       (SELECT E.FIRST_NAME,
               E.EMAIL,
               E.SALARY,
               E.JOB_ID,
               D.DEPARTMENT_NAME
          FROM EMPLOYEES E
               INNER JOIN DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
         WHERE D.DEPARTMENT_NAME = 'Purchasing') EJ
          ON J.JOB_ID = EJ.JOB_ID;

SELECT E.FIRST_NAME,
       D.DEPARTMENT_NAME,
       J.JOB_TITLE,
       L.CITY
  FROM EMPLOYEES E
       JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
       JOIN JOBS J ON E.JOB_ID = J.JOB_ID
       JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID;

------------------------------------------------------------------------

/*CREATE TABLE 
        WITH CONSTRAINTS*/

CREATE TABLE DEPT_SAMIRA
(
   EMPLOYEE_ID     NUMBER (9),
   DEPARTMENT_ID   NUMBER (6),
   FULL_NAME       VARCHAR2 (25) NOT NULL,
   AGE             NUMBER (2) NOT NULL,
   JOB_NAME        VARCHAR2 (25),
   EMAIL           VARCHAR2 (25),
   CONSTRAINT A_FK FOREIGN KEY
      (DEPARTMENT_ID)
       REFERENCES DEPARTMENTS (DEPARTMENT_ID),
   CONSTRAINT B_UK UNIQUE (EMAIL)
);
--------------------------------------------------------------------------
/*USE OF MAX & COUNT*/

SELECT MAX(EMPLOYEE_ID) EMP, JOB_ID, HIRE_DATE  FROM EMPLOYEES
WHERE HIRE_DATE BETWEEN TO_DATE ('01012020','MMDDYYYY') AND TO_DATE('12012020','MMDDYYYY')
GROUP BY JOB_ID,
         HIRE_DATE
ORDER BY EMP DESC;

SELECT COUNT(*) EMPLOYEES , TITLE FROM  PER_ALL_PEOPLE_F
WHERE EFFECTIVE_START_DATE BETWEEN TO_DATE('01012020','MMDDYYYY') AND TO_DATE('12302020','MMDDYYYY')
GROUP BY TITLE;
-------------------------------------------------------------------------
/*DECODE*/

SELECT FIRST_NAME,
DECODE (DEPARTMENT_ID ,'90','EXECUTIVE',
                        '60','IT',
                        'NO DEPARTMENT') DEPARTMENT_NAME FROM EMPLOYEES;
----------------------------------------------------------------------
/*SELF JOIN*/


 SELECT E2.LAST_NAME "MANAGER", E1.LAST_NAME "EMPLOYEE"
    FROM EMPLOYEES E1, EMPLOYEES E2
   WHERE E1.MANAGER_ID = E2.EMPLOYEE_ID
ORDER BY E1.MANAGER_ID;

  SELECT E1.HIRE_DATE,
         (E1.FIRST_NAME || ' ' || E1.LAST_NAME) EMPLOYEE1,
         (E2.FIRST_NAME || ' ' || E2.LAST_NAME) EMPLOYEE2
    FROM EMPLOYEES E1
         INNER JOIN EMPLOYEES E2
            ON E1.HIRE_DATE = E2.HIRE_DATE AND E1.EMPLOYEE_ID > E2.EMPLOYEE_ID
ORDER BY E1.HIRE_DATE DESC, EMPLOYEE1, EMPLOYEE2;
-----------------------------------------------------------------------

/*CREATING SAME TABLE*/

CREATE TABLE CUSTOMER1
AS
   (SELECT * FROM CUSTOMERS);

-------------------------------------------------------------------------

/*USE OF ROWID*/


--DELETE FROM BANK_CUSTOMERS
--      WHERE ROWID IN (SELECT MAX (ROWID) FROM BANK_CUSTOMERS);

-------------------------------------------------------------------------

/*USE OF SEQUENCE*/

ALTER SEQUENCE TRANSAC_NUM RESTART START WITH 100;

-------------------------------------------------------------------------

SELECT MAX(LENGTH(NAME)) FROM HR_ALL_ORGANIZATION_UNITS

-------------------------------------------------------------------------

UPDATE PER_ALL_PEOPLE_F
SET DATE_OF_BIRTH =TO_DATE('09/01/1997','MM/DD/YYYY') -- OR  ='01-SEP-1997'
WHERE FULL_NAME LIKE 'CHICA%'
AND EMPLOYEE_NUMBER = '122E0005'

--------------------------------------------------------------------------

SELECT
  TO_CHAR( 
    TRUNC(TO_DATE( '04-Aug-2017 15:35:32 ', 'DD-Mon-YYYY HH24:MI:SS' )),'DD-Mon-YYYY HH24:MI:SS') result
FROM
  dual;
