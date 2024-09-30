-------------------------------------------------------------------------------Simple CASE STATEMENT
DECLARE
   C_GRADE   CHAR (1);
   C_RANK    VARCHAR2 (20);
BEGIN
   C_GRADE := '&GRADE';

   CASE C_GRADE
      WHEN 'A'
      THEN
         C_RANK := 'EXCELLENT';
      WHEN 'B'
      THEN
         C_RANK := 'VERY GOOD';
      WHEN 'C'
      THEN
         C_RANK := 'GOOD';
      WHEN 'D'
      THEN
         C_RANK := 'FAIR';
      WHEN 'F'
      THEN
         C_RANK := 'POOR';
      ELSE
         C_RANK := 'NO SUCH GRADE';
   END CASE;

   DBMS_OUTPUT.PUT_LINE (C_RANK);
END;

-------------------------------------------------------------------------------Searched CASE STATEMENT
DECLARE
   N_SALES        NUMBER;
   N_COMMISSION   NUMBER;
BEGIN
   N_SALES := 150000;

   CASE
      WHEN N_SALES > 200000
      THEN
         N_COMMISSION := 0.2;
      WHEN N_SALES >= 100000 AND N_SALES < 200000
      THEN
         N_COMMISSION := 0.15;
      WHEN N_SALES >= 50000 AND N_SALES < 100000
      THEN
         N_COMMISSION := 0.1;
      WHEN N_SALES > 30000
      THEN
         N_COMMISSION := 0.05;
      ELSE
         N_COMMISSION := 0;
   END CASE;

   DBMS_OUTPUT.PUT_LINE ('Commission is ' || N_COMMISSION * 100 || '%');
END;