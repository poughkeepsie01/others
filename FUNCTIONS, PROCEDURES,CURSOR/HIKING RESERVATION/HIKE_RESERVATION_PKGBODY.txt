CREATE OR REPLACE PACKAGE BODY HIKE_RESERVATION_PKG
AS
   PROCEDURE HIKE_RESERVE_LIST_VIEW
   AS
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('..WELCOME TO TRAIL ADVENTours!  ');
      DBMS_OUTPUT.PUT_LINE (' ');

      FOR C_HIKE_RESERVE_LIST_FOR IN (SELECT MT_ID,
                                             MOUNTAIN,
                                             LOCATIONS,
                                             SLOTS,
                                             AVAILABLE_DATE,
                                             PACKAGE_RATE,
                                             DIFFICULTY,
                                             ELEVATION
                                        FROM HIKE_RESERVATION_LIST)
      LOOP
         DBMS_OUTPUT.PUT (C_HIKE_RESERVE_LIST_FOR.MT_ID);
         DBMS_OUTPUT.PUT_LINE (' -' || C_HIKE_RESERVE_LIST_FOR.MOUNTAIN);
         DBMS_OUTPUT.PUT_LINE ('Slots:  ' || C_HIKE_RESERVE_LIST_FOR.SLOTS);
         DBMS_OUTPUT.PUT_LINE (
            'Location:  ' || C_HIKE_RESERVE_LIST_FOR.LOCATIONS);
         DBMS_OUTPUT.PUT_LINE (
            'Available Date:  ' || C_HIKE_RESERVE_LIST_FOR.AVAILABLE_DATE);
         DBMS_OUTPUT.PUT_LINE (
            'Package Rate:  ' || C_HIKE_RESERVE_LIST_FOR.PACKAGE_RATE);
         DBMS_OUTPUT.PUT_LINE (
            'Difficulty:  ' || C_HIKE_RESERVE_LIST_FOR.DIFFICULTY);
         DBMS_OUTPUT.PUT_LINE (
            'Elevation:  ' || C_HIKE_RESERVE_LIST_FOR.ELEVATION);


         DBMS_OUTPUT.PUT_LINE (' ');
      END LOOP;
   END HIKE_RESERVE_LIST_VIEW;

   PROCEDURE HIKE_RESERVE_LIST_INSERT (
      V_NAME              HIKE_RESERVATION.NAME%TYPE,
      V_AGE               HIKE_RESERVATION.AGE%TYPE,
      V_GENDER            HIKE_RESERVATION.GENDER%TYPE,
      V_NUM_OF_JOINERS    HIKE_RESERVATION.NUM_OF_JOINERS%TYPE,
      V_MOUNTAIN_PICK     HIKE_RESERVATION.MOUNTAIN_PICK%TYPE)
   IS
      V_MT_ID          HIKE_RESERVATION_LIST.MT_ID%TYPE;
      INVALID_GENDER   EXCEPTION;
      INVALID_AGE      EXCEPTION;
   BEGIN
      SELECT MT_ID
        INTO V_MT_ID
        FROM HIKE_RESERVATION_LIST
       WHERE MT_ID = V_MOUNTAIN_PICK;


      IF V_MT_ID != V_MOUNTAIN_PICK
      THEN
         RAISE NO_DATA_FOUND;
      ELSIF V_GENDER NOT IN ('F', 'M')
      THEN
         RAISE INVALID_GENDER;
      ELSIF V_AGE NOT BETWEEN 18 AND 70
      THEN
         RAISE INVALID_AGE;
      ELSE
         INSERT INTO HIKE_RESERVATION
              VALUES (TRANSAC_NUM.NEXTVAL,
                      V_NAME,
                      V_AGE,
                      V_GENDER,
                      V_NUM_OF_JOINERS,
                      V_MOUNTAIN_PICK,
                      NULL,
                      NULL,
                      SYSDATE,
                      NULL);

         COMMIT;
         DBMS_OUTPUT.PUT_LINE ('New Record Inserted.');
      END IF;

      UPDATE HIKE_RESERVATION
         SET STATUS = 'JOINED'
       WHERE MOUNTAIN_PICK = V_MOUNTAIN_PICK;

      COMMIT;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RAISE_APPLICATION_ERROR (-20000, 'No mountain found.');
      WHEN INVALID_GENDER
      THEN
         RAISE_APPLICATION_ERROR (-20000, 'Gender input is invalid.');
      WHEN INVALID_AGE
      THEN
         RAISE_APPLICATION_ERROR (-20000,
                                  'Adults aged 18 to 70 can only register.');
   END HIKE_RESERVE_LIST_INSERT;

   PROCEDURE HIKE_RESERVE_LIST_CONFIRM (T_NUM NUMBER)
   IS
      V_NUM_OF_JOINERS   VARCHAR2 (30);
      V_MOUNTAIN_PICK    VARCHAR2 (30);
      V_DOWNPAYMENT      VARCHAR2 (30);
      V_STATUS           VARCHAR2 (30);
   BEGIN
      SELECT NUM_OF_JOINERS,
             MOUNTAIN_PICK,
             DOWNPAYMENT,
             STATUS
        INTO V_NUM_OF_JOINERS,
             V_MOUNTAIN_PICK,
             V_DOWNPAYMENT,
             V_STATUS
        FROM HIKE_RESERVATION
       WHERE TRANSACTION_NUM = T_NUM;

      IF V_STATUS = 'JOINED'
      THEN
         UPDATE HIKE_RESERVATION
            SET STATUS = 'CONFIRMED',
                DOWNPAYMENT = 'Y',
                LAST_UPDATE_DATE = SYSDATE
          WHERE TRANSACTION_NUM = T_NUM AND STATUS = 'JOINED';

         SELECT NUM_OF_JOINERS, MOUNTAIN_PICK
           INTO V_NUM_OF_JOINERS, V_MOUNTAIN_PICK
           FROM HIKE_RESERVATION
          WHERE TRANSACTION_NUM = T_NUM;

         UPDATE HIKE_RESERVATION_LIST
            SET SLOTS = SLOTS - V_NUM_OF_JOINERS
          WHERE MT_ID = V_MOUNTAIN_PICK;

         COMMIT;
         DBMS_OUTPUT.PUT_LINE ('RESERVATION CONFIRMED!');
      ELSE
         DBMS_OUTPUT.PUT_LINE ('ALREADY CONFIRMED!');
      END IF;
   END HIKE_RESERVE_LIST_CONFIRM;

   PROCEDURE HIKE_RESERVE_LIST_SUMMARY (T_NUM NUMBER)
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
   END HIKE_RESERVE_LIST_SUMMARY;

   PROCEDURE HIKE_RESERVE_LIST_CANCEL (T_NUM NUMBER)
   AS
      V_NUM_OF_JOINERS   VARCHAR2 (30);
      V_MOUNTAIN_PICK    VARCHAR2 (30);
      V_STATUS           VARCHAR2 (30);
      V_DOWNPAYMENT      VARCHAR2 (30);
   BEGIN
      SELECT NUM_OF_JOINERS,
             MOUNTAIN_PICK,
             DOWNPAYMENT,
             STATUS
        INTO V_NUM_OF_JOINERS,
             V_MOUNTAIN_PICK,
             V_DOWNPAYMENT,
             V_STATUS
        FROM HIKE_RESERVATION
       WHERE TRANSACTION_NUM = T_NUM;

      IF V_STATUS = 'CONFIRMED'
      THEN
         UPDATE HIKE_RESERVATION
            SET STATUS = 'CANCELLED',
                DOWNPAYMENT = 'X',
                LAST_UPDATE_DATE = SYSDATE
          WHERE TRANSACTION_NUM = T_NUM AND STATUS = 'CONFIRMED';

         COMMIT;
         DBMS_OUTPUT.PUT_LINE ('RESERVATION CANCELLED.');

         UPDATE HIKE_RESERVATION_LIST
            SET SLOTS = SLOTS + V_NUM_OF_JOINERS
          WHERE MT_ID = V_MOUNTAIN_PICK;

         COMMIT;
      ELSE
         DBMS_OUTPUT.PUT_LINE ('ALREADY CANCELLED!');
      END IF;
   END HIKE_RESERVE_LIST_CANCEL;
END HIKE_RESERVATION_PKG;
/