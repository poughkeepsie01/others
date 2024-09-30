CREATE OR REPLACE PROCEDURE HIKE_RESERVE_LIST_VIEW
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
      
      END;