DECLARE
BEGIN
   FOR A IN 1 .. &NUM
   LOOP
      IF MOD (A, 2) = 0
      THEN
         DBMS_OUTPUT.PUT_LINE (A||' = EVEN');
         ELSE
         DBMS_OUTPUT.PUT_LINE (A||' = ODD');
      END IF;
   END LOOP;
END;