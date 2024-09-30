CREATE OR REPLACE PROCEDURE P_GET_SAL2 (P_EMP_ID NUMBER,
                                         P_AMOUNT NUMBER)
AS
BEGIN
   UPDATE EMPLOYEES
      SET SALARY = SALARY + P_AMOUNT
    WHERE EMPLOYEE_ID = P_EMP_ID;
    COMMIT;
END;

--------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION P_GET_SAL1 (P_EMP_ID NUMBER,
                                        P_AMOUNT NUMBER)
   RETURN NUMBER
IS
   EMP_SAL   NUMBER;
BEGIN
   
   UPDATE EMPLOYEES
      SET SALARY = SALARY + P_AMOUNT
    WHERE EMPLOYEE_ID = P_EMP_ID;
    COMMIT;

   RETURN EMP_SAL;
END;