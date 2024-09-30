DECLARE
   a   NUMBER (2);
   b   NUMBER (2);

BEGIN
   FOR a IN  1 .. &a
   LOOP
      FOR b IN  1 .. a
      LOOP
      DBMS_OUTPUT.put ('*');
         END LOOP;
      DBMS_OUTPUT.put_line (' ');
   END LOOP;
   
   
END;