DECLARE
   V_SALARY1   NUMBER;
   V_SALARY2   NUMBER;
   V_FNAME1    VARCHAR2 (25);
   V_FNAME2    VARCHAR2 (25);
   V_LNAME1    VARCHAR2 (25);
   V_LNAME2    VARCHAR2 (25);

BEGIN
   SELECT SALARY, FIRST_NAME, LAST_NAME
     INTO V_SALARY1, V_FNAME1, V_LNAME1
     FROM EMPLOYEES
    WHERE EMPLOYEE_ID = '&V_EMPID1';

   SELECT SALARY, FIRST_NAME, LAST_NAME
     INTO V_SALARY2, V_FNAME2, V_LNAME2
     FROM EMPLOYEES
    WHERE EMPLOYEE_ID = '&V_EMPID2';

   IF V_SALARY1 > V_SALARY2
   THEN
      DBMS_OUTPUT.PUT_LINE (
            V_FNAME1
         || ' '
         || V_LNAME1
         || ' has a greater salary than '
         || V_FNAME2
         || ' '
         || V_LNAME2);
   ELSIF V_SALARY1 < V_SALARY2
   THEN
      DBMS_OUTPUT.PUT_LINE (
            V_FNAME1
         || ' '
         || V_LNAME1
         || ' has a lesser salary than '
         || V_FNAME2
         || ' '
         || V_LNAME2);
   ELSE
      DBMS_OUTPUT.PUT_LINE (
            V_FNAME1
         || ' '
         || V_LNAME1
         || ' and '
         || V_FNAME2
         || ' '
         || V_LNAME2
         || ' have the same salary.');
   END IF;
END;

----------------------------------------------------------------------------

DECLARE
   V_SALARY     NUMBER;
   V_HIREDATE   DATE;
BEGIN
   SELECT SALARY, HIRE_DATE
     INTO V_SALARY, V_HIREDATE
     FROM EMPLOYEES
    WHERE EMPLOYEE_ID = 100;

   DBMS_OUTPUT.PUT_LINE ('SALARY: ' || V_SALARY * 2);
   DBMS_OUTPUT.PUT_LINE ('HIRE DATE: ' || (TO_CHAR (V_HIREDATE, 'MON DD,YYYY')));
END;

---------------------------------------------------------------------

SELECT ROWNUM, EMPLOYEE_ID, FIRST_NAME , LAST_NAME
FROM EMPLOYEES
WHERE ROWNUM< 10;

---------------------------------------------------------------------
DECLARE

CURSOR SAMPLE_CUR IS
     SELECT  ROWNUM, EMPLOYEE_ID, FIRST_NAME
       FROM EMPLOYEES
       WHERE ROWNUM <10;
        V_EMP SAMPLE_CUR%ROWTYPE;
BEGIN
OPEN SAMPLE_CUR;
LOOP
    FETCH SAMPLE_CUR
    INTO V_EMP;
    EXIT WHEN SAMPLE_CUR%NOTFOUND;
   DBMS_OUTPUT.PUT_LINE (V_EMP. EMPLOYEE_ID||' '||V_EMP.FIRST_NAME);
   END LOOP;
END;


--------------------------------------------------------- **exact fetch returns more than requested number of rows**
---------------------------------------------------------(W/OUT CURSOR)
DECLARE
   V_ID   NUMBER;
   V_FN   VARCHAR2 (30);
BEGIN
   SELECT EMPLOYEE_ID, FIRST_NAME
     INTO V_ID, V_FN
     FROM EMPLOYEES;
--WHERE EMPLOYEE_ID= 331;
   DBMS_OUTPUT.PUT_LINE (V_ID ||' '|| V_FN);
END;
---------------------------------------------------------------(WITH CURSOR) explicit cursor: user-defined
DECLARE
   V_ID   NUMBER;
   V_FN   VARCHAR2 (30);

   CURSOR SAMPLE_CUR
   IS
      SELECT EMPLOYEE_ID, FIRST_NAME FROM EMPLOYEES;

BEGIN
   OPEN SAMPLE_CUR;

   LOOP
      FETCH SAMPLE_CUR
         INTO V_ID, V_FN;

      EXIT WHEN SAMPLE_CUR%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE (V_ID ||' '||V_FN);
   END LOOP;
END;

-------------------------------------------------------------------------------

DECLARE
   EMP_REC    EMPLOYEES%ROWTYPE;
   MY_EMPNO   EMPLOYEES.EMPLOYEE_ID%TYPE := 100;

   CURSOR C1
   IS
      SELECT DEPARTMENT_ID, DEPARTMENT_NAME, LOCATION_ID FROM DEPARTMENTS;

   DEPT_REC   C1%ROWTYPE;
BEGIN
   SELECT *
     INTO EMP_REC
     FROM EMPLOYEES
    WHERE EMPLOYEE_ID = MY_EMPNO;

   IF (EMP_REC.DEPARTMENT_ID = 20) AND (EMP_REC.SALARY > 2000)
   THEN
      IF SQL%FOUND
      THEN
         DBMS_OUTPUT.PUT_LINE (' FOUND!');
      END IF;
   ELSE
      DBMS_OUTPUT.PUT_LINE (' NOT FOUND!');
   END IF;
END;

-------------------------------------------------------------------------table-based record
                                                                        /*exact fetch returns more than requested number of rows*/

DECLARE
   VEMPLOYEENAME   EMPLOYEES%ROWTYPE;
BEGIN
     SELECT *
       INTO VEMPLOYEENAME
       FROM EMPLOYEES
      WHERE ROWNUM < 10
   ORDER BY 2;

   DBMS_OUTPUT.PUT_LINE (VEMPLOYEENAME. EMPLOYEE_ID||' '||VEMPLOYEENAME.FIRST_NAME);
END;

--------------------------------------------------------------------------cursor-based record

CREATE OR REPLACE PROCEDURE SAMPLEPROCEDURE1
IS
   CURSOR SAMPLE_CUR
   IS
        SELECT FIRST_NAME, HIRE_DATE
          FROM EMPLOYEES
         WHERE HIRE_DATE BETWEEN TO_DATE ('01/01/2020', 'MM/DD/YYYY')
                             AND TO_DATE ('05/30/2022', 'MM/DD/YYYY')
      ORDER BY HIRE_DATE DESC;

   SAMPLE_VAR   SAMPLE_CUR%ROWTYPE;
BEGIN
   OPEN SAMPLE_CUR;

   LOOP
      FETCH SAMPLE_CUR INTO SAMPLE_VAR;

      EXIT WHEN SAMPLE_CUR%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE (
         SAMPLE_VAR.FIRST_NAME || ' WAS HIRED ON  ' || SAMPLE_VAR.HIRE_DATE);
   END LOOP;

   CLOSE SAMPLE_CUR;
END;

--------------------------------------------------------------------------EXPLICIT CURSOR

CREATE OR REPLACE PROCEDURE SAMPLEPROCEDURE2 (
   V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE)
IS
   V_FNAME   EMPLOYEES.FIRST_NAME%TYPE;
   V_LNAME   EMPLOYEES.LAST_NAME%TYPE;
   V_HIRE    EMPLOYEES.HIRE_DATE%TYPE;
   V_JOB     EMPLOYEES.JOB_ID%TYPE;
   V_SAL     EMPLOYEES.SALARY%TYPE;

   CURSOR SAMPLE_CUR
   IS
      SELECT FIRST_NAME,
             LAST_NAME,
             HIRE_DATE,
             JOB_ID,
             SALARY
        FROM EMPLOYEES
       WHERE EMPLOYEE_ID = V_EMP_ID;

BEGIN
   OPEN SAMPLE_CUR;

   LOOP
      FETCH SAMPLE_CUR
         INTO V_FNAME, V_LNAME, V_HIRE, V_JOB, V_SAL;

      EXIT WHEN SAMPLE_CUR%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE ('EMPLOYEE ID: ' || V_EMP_ID);
      DBMS_OUTPUT.PUT_LINE ('NAME: ' || V_FNAME || ' ' || V_LNAME);
      DBMS_OUTPUT.PUT_LINE ('HIRE DATE: ' || V_HIRE);
      DBMS_OUTPUT.PUT_LINE ('JOB: ' || V_JOB);
      DBMS_OUTPUT.PUT_LINE ('SALARY: ' || V_SAL);
   END LOOP;

   CLOSE SAMPLE_CUR;
END;

------------------------------------------------------------------------IMPLICIT CURSOR

DECLARE
   TOTAL_SAL   NUMBER;
BEGIN
   UPDATE CUSTOMERS
      SET SALARY = SALARY + 1
    WHERE ADDRESS = 'MINDANAO';

   IF SQL%FOUND
   THEN
      TOTAL_SAL := SQL%ROWCOUNT;
      DBMS_OUTPUT.PUT_LINE ('EMPLOYEES WITH UPDATED SALARY: ' || TOTAL_SAL);
   ELSE
      DBMS_OUTPUT.PUT_LINE ('NO SALARY TO UPDATE!!');
   END IF;
END;

----------------------------------------------------------------------------

DECLARE
   CURSOR SAMPLE_CUR
   IS
      SELECT FIRST_NAME,
             LAST_NAME,
             TO_CHAR (HIRE_DATE, 'MON DD, YYYY') H_DATE
        FROM EMPLOYEES
       WHERE EMPLOYEE_ID = &E_ID;

BEGIN
   FOR SAMPLE_LOOP IN SAMPLE_CUR
   LOOP
      DBMS_OUTPUT.PUT_LINE (
         'NAME: ' || SAMPLE_LOOP.FIRST_NAME || ' ' || SAMPLE_LOOP.LAST_NAME);
      DBMS_OUTPUT.PUT_LINE ('HIRE DATE: ' || SAMPLE_LOOP.H_DATE);
   END LOOP;
END;

---------------------------------------------------------------------------table-based record
                                                                            /*    MUST (*)   */
DECLARE
   L_EMPLOYEE   EMPLOYEES%ROWTYPE;
BEGIN
   SELECT *
     INTO L_EMPLOYEE
     FROM EMPLOYEES
    WHERE EMPLOYEE_ID = 331;

   DBMS_OUTPUT.PUT_LINE (L_EMPLOYEE.LAST_NAME);
END;

--------------------------------------------------------------------/*ROWTYPE*/
DECLARE

EMP1    EMPLOYEES%ROWTYPE;
EMP2    EMPLOYEES%ROWTYPE;

BEGIN
   SELECT *
     INTO EMP1
     FROM EMPLOYEES
    WHERE EMPLOYEE_ID = '&V_EMPID1';

   SELECT *
     INTO EMP2
     FROM EMPLOYEES
    WHERE EMPLOYEE_ID = '&V_EMPID2';

   IF EMP1.SALARY > EMP2.SALARY
   THEN
      DBMS_OUTPUT.PUT_LINE (
            EMP1.FIRST_NAME
         || ' '
         || EMP1.LAST_NAME
         || ' has a greater salary than '
         || EMP2.FIRST_NAME
         || ' '
         || EMP2.LAST_NAME);
   ELSIF EMP1.SALARY < EMP2.SALARY
   THEN
      DBMS_OUTPUT.PUT_LINE (
            EMP1.FIRST_NAME
         || ' '
         || EMP1.LAST_NAME
         || ' has a lesser salary than '
         || EMP2.FIRST_NAME
         || ' '
         || EMP2.LAST_NAME);
   ELSE
      DBMS_OUTPUT.PUT_LINE (
            EMP1.FIRST_NAME
         || ' '
         || EMP1.LAST_NAME
         || ' and '
         || EMP2.FIRST_NAME
         || ' '
         || EMP2.LAST_NAME
         || ' have the same salary.');
   END IF;
END;

