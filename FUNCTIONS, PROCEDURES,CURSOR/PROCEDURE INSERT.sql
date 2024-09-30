CREATE OR REPLACE PROCEDURE PROC_INSERT (V_ID                  NUMBER,
                                         V_NAME                VARCHAR2,
                                         V_AGE                 NUMBER,
                                         V_ADDRESS             VARCHAR2,
                                         V_SALARY              NUMBER,
                                         V_LAST_UPDATE_DATE    DATE)
IS
BEGIN
   INSERT INTO CUSTOMERS
        VALUES (V_ID,
                V_NAME,
                V_AGE,
                V_ADDRESS,
                V_SALARY,
                V_LAST_UPDATE_DATE);
END;