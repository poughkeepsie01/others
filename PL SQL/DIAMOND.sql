DECLARE
   A   NUMBER;
   B   NUMBER;
   C   NUMBER := &A;
   D   NUMBER;
BEGIN
   FOR A IN 1 .. C
   LOOP
      FOR B IN 1 .. C - A
      LOOP
         DBMS_OUTPUT.PUT ('t');
      END LOOP;

      FOR D IN 1 .. A
      LOOP
         DBMS_OUTPUT.PUT ('*');
      END LOOP;

      DBMS_OUTPUT.PUT_LINE (' ');
   END LOOP;



--   FOR A IN REVERSE 1 .. C
--   LOOP
--      FOR B IN 1 .. C - A
--      LOOP
--         DBMS_OUTPUT.PUT ('r');
--      END LOOP;
--
--      FOR D IN REVERSE 1 .. A
--      LOOP
--         DBMS_OUTPUT.PUT ('*');
--      END LOOP;
--
--      DBMS_OUTPUT.PUT_LINE (' ');
--   END LOOP;
END;