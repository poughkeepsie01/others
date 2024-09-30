DECLARE
   A   NUMBER;
   C   NUMBER := &C;
   S   NUMBER := 1;
BEGIN
   FOR A IN 2 .. C / 2
   LOOP
      IF MOD (C, A) = 0 THEN
         S := 0;                                                   --COMPOSITE
         EXIT;
      END IF;
   END LOOP;

   IF S = 1
   THEN                                                                --PRIME
      DBMS_OUTPUT.PUT_LINE (C || ': PRIME');
   ELSE
      DBMS_OUTPUT.PUT_LINE (C || ': COMPOSITE ');
   END IF;
END;