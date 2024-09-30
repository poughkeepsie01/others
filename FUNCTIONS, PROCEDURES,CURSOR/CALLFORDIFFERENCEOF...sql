DECLARE
RESULT VARCHAR2(30);

BEGIN
A:= DEPT_FUNC(90);
DBMS_OUTPUT.PUT_LINE(RESULT);

END;

-------------------------------------------------------------------------------

EXECUTE DEPT_PROC(90);




