CREATE OR REPLACE PROCEDURE ACTIVITY_2
AS
   V_FNAME      EMPLOYEES.FIRST_NAME%TYPE;
   V_LNAME      EMPLOYEES.LAST_NAME%TYPE;
   V_HIREDATE   EMPLOYEES.HIRE_DATE%TYPE;
   V_SALARY     EMPLOYEES.SALARY%TYPE;
   V_DEPTID     DEPARTMENTS.DEPARTMENT_ID%TYPE;
   V_DEPTNAME   DEPARTMENTS.DEPARTMENT_NAME%TYPE;

   CURSOR SAMPLE_1
   IS
      SELECT FIRST_NAME,
             LAST_NAME,
             HIRE_DATE,
             SALARY
        FROM EMPLOYEES
       WHERE DEPARTMENT_ID = V_DEPTID;

   CURSOR SAMPLE_2
   IS
      SELECT DEPARTMENT_ID, DEPARTMENT_NAME
        FROM DEPARTMENTS
       WHERE DEPARTMENT_ID < 100;

BEGIN
   OPEN SAMPLE_2;

   LOOP
      FETCH SAMPLE_2
         INTO V_DEPTID, V_DEPTNAME;

      EXIT WHEN SAMPLE_2%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE (
         'DEPARTMENT ID: ' || V_DEPTID || '  DEPARTMENT NAME: ' || V_DEPTNAME);

      OPEN SAMPLE_1;

      LOOP
         FETCH SAMPLE_1
            INTO V_FNAME, V_LNAME, V_HIREDATE, V_SALARY;

         EXIT WHEN SAMPLE_1%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE (
               V_FNAME
            || ' '
            || V_LNAME
            || ' -'
            || TO_CHAR(V_HIREDATE, 'MON DD, YYYY')
            || ' -'
            || V_SALARY);
      END LOOP;

      CLOSE SAMPLE_1;

      DBMS_OUTPUT.PUT_LINE (' ');
   END LOOP;

   CLOSE SAMPLE_2;
END;


-----------------------------------------------------------------------------
/*USING FOR LOOP*/

CREATE OR REPLACE PROCEDURE ACTIVITY_2
AS
   DI   NUMBER;

   CURSOR SAMPLE_1
   IS
      SELECT FIRST_NAME,
             LAST_NAME,
             HIRE_DATE,
             SALARY
        FROM EMPLOYEES
       WHERE DEPARTMENT_ID = DI;

   CURSOR SAMPLE_2
   IS
      SELECT DEPARTMENT_ID, DEPARTMENT_NAME
        FROM DEPARTMENTS
       WHERE DEPARTMENT_ID < 100;

BEGIN
   FOR SAMPLE_CUR1 IN SAMPLE_2
   LOOP
      DBMS_OUTPUT.PUT_LINE (
            'DEPARTMENT ID:  '
         || SAMPLE_CUR1.DEPARTMENT_ID
         || ' DEPARTMENT NAME:  '
         || SAMPLE_CUR1.DEPARTMENT_NAME);

      DI := SAMPLE_CUR1.DEPARTMENT_ID;

      FOR SAMPLE_CUR2 IN SAMPLE_1
      LOOP
         DBMS_OUTPUT.PUT_LINE (
               SAMPLE_CUR2.FIRST_NAME
            || ' '
            || SAMPLE_CUR2.LAST_NAME
            || ' - '
            || TO_CHAR(SAMPLE_CUR2.HIRE_DATE, 'MON DD, YYYY')
            || ' - '
            || SAMPLE_CUR2.SALARY);
      END LOOP;

      DBMS_OUTPUT.PUT_LINE (' ');
   END LOOP;
END;