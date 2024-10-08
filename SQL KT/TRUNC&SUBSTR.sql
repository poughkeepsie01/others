SELECT TRUNC(MONTHS_BETWEEN (SYSDATE, DATE_OF_BIRTH) /12) AGE,
        TO_CHAR(DATE_OF_BIRTH,'MM/DD/YYYY') DATE_OF_BIRTH,
        TRUNC(MONTHS_BETWEEN (SYSDATE, START_DATE) /12)  YEARS_OF_SERVICE ,
        FULL_NAME 

FROM PER_ALL_PEOPLE_F
WHERE DATE_OF_BIRTH= TO_DATE('&V_DATE_OF_BIRTH', 'MMDDYYYY');

------------------------------------------------------------------------------

SELECT TRUNC(TRUNC(SYSDATE- DATE_OF_BIRTH) /365) AGE,
        TO_CHAR(DATE_OF_BIRTH,'MM/DD/YYYY') DATE_OF_BIRTH,
        TRUNC(TRUNC (SYSDATE- START_DATE) /365)  YEARS_OF_SERVICE ,
        FULL_NAME 

FROM PER_ALL_PEOPLE_F
WHERE DATE_OF_BIRTH= TO_DATE('&V_DATE_OF_BIRTH', 'MMDDYYYY');
-------------------------------------------------------------------------------

SELECT FULL_NAME,SUBSTR(FULL_NAME,1,8) NAME,  TO_CHAR (DATE_OF_BIRTH,'DL') YEAR_OF_BIRTH
FROM PER_ALL_PEOPLE_F