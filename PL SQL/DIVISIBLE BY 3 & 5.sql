DECLARE
   NUM   NUMBER := &N;
BEGIN
   IF MOD (NUM, 3) = 0 AND MOD (NUM, 5) = 0
   THEN
      DBMS_OUTPUT.PUT_LINE ('Divisible by 3 and 5');
   ELSIF MOD (NUM, 3) = 0
   THEN
      DBMS_OUTPUT.PUT_LINE ('Divisible by 3');
   ELSIF MOD (NUM, 5) = 0
   THEN
      DBMS_OUTPUT.PUT_LINE ('Divisible by 5');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('The input number is not divisible by 3 or 5.');
   END IF;
END;