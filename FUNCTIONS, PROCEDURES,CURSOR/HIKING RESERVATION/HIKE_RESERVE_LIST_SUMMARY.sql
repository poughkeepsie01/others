CREATE OR REPLACE PROCEDURE TIPKT.HIKE_RESERVE_LIST_SUMMARY (T_NUM NUMBER)
AS
   R_NAME                         VARCHAR2 (30);
   R_NUM_OF_JOINERS               NUMBER;
   R_MOUNTAIN_PICK                VARCHAR2 (30);
   H_MOUNTAIN                     VARCHAR2 (30);
   H_INFORMATION                  VARCHAR2 (4000);
   H_LOCATIONS                    VARCHAR2 (30);
   H_AVAILABLE_DATE               VARCHAR2 (30);
   H_PACKAGE_RATE                 NUMBER;
   H_DIFFICULTY                   VARCHAR2 (30);
   H_ELEVATION                    VARCHAR2 (30);
   H_ITINERARY                    VARCHAR2 (4000);
V_DOWNPAYMENT                      VARCHAR2 (30); 

   CURSOR C_HIKE_RESERVE_LIST_SUMM
   IS
      SELECT HR.NAME,
             HR.NUM_OF_JOINERS,
             HR.MOUNTAIN_PICK,
             HRL.MOUNTAIN,
             HRL.INFORMATION,
             HRL.LOCATIONS,
             HRL.AVAILABLE_DATE,
             HRL.PACKAGE_RATE,
             HRL.DIFFICULTY,
             HRL.ELEVATION,
             HRL.ITINERARY
        INTO R_NAME,
             R_NUM_OF_JOINERS,
             R_MOUNTAIN_PICK,
             H_MOUNTAIN,
             H_INFORMATION,
             H_LOCATIONS,
             H_AVAILABLE_DATE,
             H_PACKAGE_RATE,
             H_DIFFICULTY,
             H_ELEVATION,
             H_ITINERARY
        FROM HIKE_RESERVATION HR, HIKE_RESERVATION_LIST HRL
       WHERE     HR.MOUNTAIN_PICK = HRL.MT_ID
             AND HR.TRANSACTION_NUM = T_NUM
             AND HR.DOWNPAYMENT = 'Y';
             
             
   C_HIKE_RESERVE_LIST_SUMM_REC   C_HIKE_RESERVE_LIST_SUMM%ROWTYPE;
   
BEGIN   
      OPEN C_HIKE_RESERVE_LIST_SUMM;

      LOOP
      
         FETCH C_HIKE_RESERVE_LIST_SUMM INTO C_HIKE_RESERVE_LIST_SUMM_REC;

         EXIT WHEN C_HIKE_RESERVE_LIST_SUMM%NOTFOUND;

         DBMS_OUTPUT.PUT_LINE ('TR#: ' || T_NUM);
         DBMS_OUTPUT.PUT_LINE (
               'WELCOME TO TRAIL ADVENTours!  '
            || C_HIKE_RESERVE_LIST_SUMM_REC.NAME
            || '.');
         DBMS_OUTPUT.PUT (
               'Enjoy the trail to '
            || C_HIKE_RESERVE_LIST_SUMM_REC.INFORMATION
            || ' '
            || C_HIKE_RESERVE_LIST_SUMM_REC.MOUNTAIN);
         DBMS_OUTPUT.PUT_LINE (
            ' ON ' || C_HIKE_RESERVE_LIST_SUMM_REC.AVAILABLE_DATE);
         DBMS_OUTPUT.PUT_LINE (
            'JOINERS: ' || C_HIKE_RESERVE_LIST_SUMM_REC.NUM_OF_JOINERS);
         DBMS_OUTPUT.PUT_LINE (
            'LOCATION: ' || C_HIKE_RESERVE_LIST_SUMM_REC.LOCATIONS);
         DBMS_OUTPUT.PUT_LINE (
            'PACKAGE_RATE: ' || C_HIKE_RESERVE_LIST_SUMM_REC.PACKAGE_RATE);
         DBMS_OUTPUT.PUT_LINE (
            'DIFFICULTY: ' || C_HIKE_RESERVE_LIST_SUMM_REC.DIFFICULTY);
         DBMS_OUTPUT.PUT_LINE (
            'ELEVATION: ' || C_HIKE_RESERVE_LIST_SUMM_REC.ELEVATION);
         DBMS_OUTPUT.PUT_LINE (
            '  <<ITINERARY>> ' || C_HIKE_RESERVE_LIST_SUMM_REC.ITINERARY);

         DBMS_OUTPUT.PUT_LINE ('  ');
      END LOOP;

     CLOSE C_HIKE_RESERVE_LIST_SUMM;
   END;
/