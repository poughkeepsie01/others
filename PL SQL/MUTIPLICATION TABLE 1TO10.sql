DECLARE
BEGIN
FOR A IN 1..10
LOOP
    FOR B IN 1..10
    LOOP
    DBMS_OUTPUT.PUT(A*B);
    DBMS_OUTPUT.PUT('|');
    END LOOP;
DBMS_OUTPUT.PUT_LINE(' ');
END LOOP;
END;