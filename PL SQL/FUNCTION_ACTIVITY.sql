CREATE OR REPLACE FUNCTION INSERT1
RETURN NUMBER
IS
MAX_ID NUMBER;
RES NUMBER;


BEGIN
SELECT MAX(ID) into MAX_ID FROM CUSTOMERS;
RES:= MAX_ID + 1;
return RES;

END;

---------------------------------------------------------------------------

DECLARE
A NUMBER;
BEGIN
A:= INSERT1();

INSERT INTO CUSTOMERS
VALUES (A, 'SAMIRACHICA', 23, 'CAVITE',1000, SYSDATE );

END;




