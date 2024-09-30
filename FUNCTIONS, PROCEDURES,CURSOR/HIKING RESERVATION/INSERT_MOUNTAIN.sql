CREATE OR REPLACE PROCEDURE MOUNTAIN_INSERT (V_MT_ID             VARCHAR2,
                                             V_MOUNTAIN          VARCHAR2,
                                             V_LOCATIONS         VARCHAR2,
                                             V_SLOTS             NUMBER,
                                             V_AVAILABLE_DATE    VARCHAR2,
                                             V_PACKAGE_RATE      NUMBER,
                                             V_DIFFICULTY        VARCHAR2,
                                             V_ELEVATION         VARCHAR2,
                                             V_ITINERARY         VARCHAR2,
                                             V_INFORMATION       VARCHAR2)
IS
BEGIN
   INSERT INTO HIKE_RESERVATION_LIST
        VALUES (V_MT_ID,
                V_MOUNTAIN,
                V_LOCATIONS,
                V_SLOTS,
                V_AVAILABLE_DATE,
                V_PACKAGE_RATE,
                V_DIFFICULTY,
                V_ELEVATION,
                V_ITINERARY,
                V_INFORMATION);

   COMMIT;
END;

