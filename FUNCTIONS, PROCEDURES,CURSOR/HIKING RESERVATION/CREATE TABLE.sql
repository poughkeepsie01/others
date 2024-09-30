CREATE TABLE HIKE_RESERVATION (         TRANSACTION_NUM NUMBER PRIMARY KEY,
                                        NAME VARCHAR2(30),
                                        AGE NUMBER(2),
                                        GENDER VARCHAR(2),
                                        NUM_OF_JOINERS NUMBER(2) NOT NULL,
                                        MOUNTAIN_PICK VARCHAR(30) NOT NULL,
                                        DOWNPAYMENT VARCHAR2(30),
                                        STATUS VARCHAR2(30),
                                        CREATION_DATE DATE,
                                        LAST_UPDATE_DATE DATE,
                                        
                                        
                                        CONSTRAINT MT_FK FOREIGN KEY(MOUNTAIN_PICK)
                                REFERENCES HIKE_RESERVATION_LIST(MT_ID)
                                        );


SELECT *  FROM  HIKE_RESERVATION

--DROP TABLE  HIKE_RESERVATION_LIST

CREATE TABLE HIKE_RESERVATION_LIST
(
   MT_ID            VARCHAR2 (30) PRIMARY KEY ,
   MOUNTAIN         VARCHAR2 (30),
   LOCATIONS        VARCHAR2 (30),
   SLOTS            NUMBER,
   AVAILABLE_DATE   VARCHAR2 (30),
   PACKAGE_RATE     NUMBER,
   DIFFICULTY       VARCHAR2 (30),
   ELEVATION        VARCHAR2 (30),
   ITINERARY        VARCHAR2 (4000),
   INFORMATION
);

INSERT INTO HIKE_RESERVATION_LIST
     VALUES (  'M1',
               'MT. APO',
               'DAVAO and NORTH COTABATO',
               10,
               '10/08/22 - 10/11/22',
               7700,
               '7/10',
               '2956 MASL',
               '
Day 1

01:00 AM Registration in Davao. We suggest arriving in Davao one day ahead.
01:30 AM Departure from Davao City to Mt. Apo jump-off point.
04:00 AM Estimated Time of Arrival (ETA) Kapatagan. Transfer vehicle.
05:30 AM ETA Jump-off point. Orientation. Start trek.
02:00 PM ETA Camp 1. Set up camp.
05:00 PM Early dinner. Early nights out for the summit assault the next day.

Day 2

04:00 AM Wake up call and final preparation for the trek.
04:30 AM Start trek to summit. Sunrise at the summit. Breakfast. Explore the other peaks.
09:30 AM Start descent to Camp site.
11:30 AM Continue descent back to the campsite.
03:00 PM ETA campsite.
06:00 PM Early Dinner.
07:30 PM Lights out.

Day 3

04:30 AM Wake up call. Breakfast.
06:00 AM Start descent. Descend on the same trail.
04:00 PM ETA jump-off point. Board vehicle back to Davao City.
08:00 PM ETA Davao City.');



INSERT INTO HIKE_RESERVATION_LIST
     VALUES (  'M2',
               'MT. PULAG',
               'BOKOD, BENGUET',
               10,
               '10/15/22 - 10/17/22',
               5600,
               '4/10',
               '2926 MASL',
               '
Day 0

10:00 PM Meet up at Victory Liner, Pasay. (Departure is on the evening before the first day of the hike)

Day 1

04:30 AM ETA Baguio. Board Jeepney. Breakfast and side trips along the way.
09:00 AM ETA D.E.N.R. Station for orientation.
10:00 AM Depart for Homestay.
11:00 AM Arrival at Homestay. Check in. Lunch. Free time.
06:00 PM Dinner
08:00 PM Lights out for the early trek the next day.

Day 2

12:15 AM Wake-up call. Light meal. Depart for Ranger Station.
01:00 AM ETA Ranger Station. Start trek.
04:00 AM ETA Camp 2. Rest.
05:30 AM ETA Mt. Pulag Summit. Enjoy the view.
07:30 AM Descend back to Ranger Station
11:30 AM ETA Ranger Station. Head to Homestay.
12:10 PM ETA Homestay. Lunch and Wash-up.
02:00 PM ETD to Baguio City. Souvenir at DENR(optional)
04:30 PM ETA Baguio City. Free time. Market and Dinner.
09:00 PM Depart back to Manila (03:00 AM ETA Manila - the morning after Day 2)');

INSERT INTO HIKE_RESERVATION_LIST
     VALUES (  'M3',
               'MT. PINATUBO',
               'CAPAS, TARLAC',
               10,
               '10/22/22',
               3700,
               '2/10',
               '960 MASL',
               '
Day 1

02:00 AM Meet up and Registration at McDonald''s El Pueblo, Ortigas.
02:30 AM Depart for Mt. Pinatubo, Capas.
05:30 AM Estimated Time of Arrival (ETA)at Mt. Pinatubo DENR.
06:00 AM Board 4x4 and Start Ride to Mt. Pinatubo jump off point.
08:00 AM End of 4x4 ride. Start hike. (At some occasions, 4x4 ride may reach the foot of Mt. Pinatubo, making the trek just 30 minutes.)
10:00 AM ETA Mt. Pinatubo Crater. Rest and explore the area.Early lunch.
11:00 AM Start descent.
01:30 PM Arrival at 4x4 stop. Board 4x4 to jump off.
03:00 PM ETA Mt. Pinatubo DENR. Wash up.
04:00 PM Depart for Manila.
07:30 PM ETA Manila.');


INSERT INTO HIKE_RESERVATION_LIST
     VALUES (  'M4',
               'MT. HALCON',
               'BACO, ORIENTAL MINDORO',
               10,
              '10/28/22 - 11/02/22',
               7000,
               '9/10',
               '2582 MASL',
               '
Day 1

06:00 AM Meet up at Jam Bus Station (Buendia corner Taft)
06:30 AM ETD Manila to Batangas Pier
09:30 AM ETA batangas Prier to Calapan
02:30 PM Baco Municipal hall to Jump off point
03:30 PM ETA Jump off point. Free time
05:15 PM ETA Aplaya Campsite
06:30 PM Dinner. Socials. Lights out
06:30 PM Dinner. Socials. Lights out.

Day 2

12:00 AM Lunch along the trail
06:00 AM Wake up call. Breakfast
07:00 AM Start Trek
05:15 PM ETA Aplaya Campsite
06:30 PM Dinner. Socials. Lights out

Day 3

12:30 AM Lunch along the trail or Camp 2
06:30 AM Wake up call. Breakfast
07:30 AM Start trek
09:30 AM ETA Dulangan River
04:30 PM ETA Knife Edge Ridge
06:30 PM Dinner. Socials. Lights out

Day 4

12:30 AM Lunch along Dulangan River
05:30 AM Wake up call. Watch Sunrise. Breakfast
07:30 AM Start descent
04:30 PM ETA Aplaya Campsite
06:30 PM Dinner. Socials. Lights out

Day 5

12:30 AM Lunch along the trail
01:30 AM ETA Manila
06:30 AM Wake up call. Breakfast
07:30 AM Start descent
04:30 PM End of hike
05:30 PM Back to Calapan
07:30 PM ETA Calapan. Driver
09:30 PM Ferry back to Batangas
11:30 PM ETA Batangas. Bus back to Manila');


INSERT INTO HIKE_RESERVATION_LIST
     VALUES (  'M5',
               'MT. KANLAON',
               'BACOLOD',
               10,
               '11/05/22 - 11/08/22',
               5000,
               '7/10',
               '2435 MASL',
               '
Day 0

07:00 PM Travel to Bacolod

Day 1

07:00 AM Registration and Breakfast
08:00 AM ETD Bacolod to Guintubdan
09:00 AM Last supply stop. Purchase packed lunch
10:30 AM ETA Guintubdan Jump Off Point.
11:00 AM Orientation. Option to have early lunch
12:00 PM Start Trek to Camp 1
01:00 PM Side trip to Falls
01:30 PM Continue Trek
05:00 PM ETA Camp 1. Set Camp
07:00 PM Dinner. Socials

Day 2

06:00 AM Breakfast. Break Camp
07:00 AM Start trek to Saddle Point Camp Site
11:00 AM ETA Saddle Point Camp Site
11:30 AM Assault to Peak
12:00 PM ETA Peak. Picture taking
01:00 PM Start Descent to Saddle Point Camp Site
01:30 PM ETA Saddle Point Camp Site. Set Camp. Lunch
02:30 PM Rest. Option to Visit and Explore Margaha Valley
06:00 PM Watch Sunset. Prepare Dinner
07:00 PM Dinner. Socials

Day 3

06:00 AM Wake up call. Prepare Breakfast
07:00 AM Breakfast. Break Camp
08:00 AM Start Descent to Guintubdan Jump Off Point
11:00 AM ETA Guintubdan. Swim. Wash Up
12:00 PM Lunch
01:00 PM ETD Guintubdan to Bacolod
03:00 PM ETA Bacolod');