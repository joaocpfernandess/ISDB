----------------------------------------------------------------------------
-------- Loading Data to Tables --------------------------------------------
----------------------------------------------------------------------------

------------Inserting Countries into country table--------------------------
INSERT INTO country(country_name, iso_code, country_flag)
VALUES
    ('Portugal','PR','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Portugal.svg/255px-Flag_of_Portugal.svg.png'),
    ('France','FR','https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Flag_of_France_%28lighter_variant%29.svg/250px-Flag_of_France_%28lighter_variant%29.svg.png'),
    ('Spain','ES','https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Bandera_de_Espa%C3%B1a.svg/1200px-Bandera_de_Espa%C3%B1a.svg.png');

-----------Inserting Sailors-----------------------------------------------
INSERT INTO sailor(sailor_email,sailor_first_name, sailor_surname)
VALUES
    ('joao.santos@gmail.com','Joao','Santos'),
    ('miguel.santos@gmail.com','Miguel','Dos Santos'),
    ('rita.leite@gmail.com', 'Rita', 'Leite'),
    ('joao.fernandes@gmail.com','Joao','Fernandes'),
    ('marina.vaz@gmail.com','Marina','Vaz'),
    ('filipe.martins@gmail.com','Filipe','Martins'),
    ('jane.doe@gmail.com','Jane','Doe'),
    ('john.doe@gmail.com','John','Doe');

----------Inserting Ranks of Sailors--------------------------------------
INSERT INTO senior(senior_email,senior_first_name, senior_surname)
SELECT sailor_email,sailor_first_name, sailor_surname
FROM sailor
WHERE sailor_email='miguel.santos@gmail.com' OR sailor_email='joao.fernandes@gmail.com' OR sailor_email='filipe.martins@gmail.com' OR sailor_email='john.doe@gmail.com';

INSERT INTO junior(junior_email,junior_first_name,junior_surname)
SELECT sailor_email,sailor_first_name,sailor_surname
FROM sailor WHERE sailor_email='joao.santos@gmail.com' OR sailor_email='rita.leite@gmail.com' OR sailor_email='marina.vaz@gmail.com' OR sailor_email='jane.doe@gamil.com';

--------Inserting Locations to location table-----------------------------
INSERT INTO location(authority_of,latitude,longitude,location_name)
SELECT country_name,49.630001,-1.620000, 'Cherbourg'
FROM country
WHERE country_name='France';

INSERT INTO location(authority_of,latitude,longitude,location_name)
SELECT country_name,37.129665, -8.669586, 'Lagos'
FROM country
WHERE country_name='Portugal';

INSERT INTO location(authority_of,latitude,longitude,location_name)
SELECT country_name, 41.150223, -8.629932, 'Porto'
FROM country
WHERE country_name='Portugal';

INSERT INTO location(authority_of,latitude,longitude,location_name)
SELECT country_name, 37.3826,  -5.99629, 'Sevilha'
FROM country
WHERE country_name='Spain';

---------------------Inserting Possible Boat Classes----------------
INSERT INTO boat_class(class_name,max_length)
VALUES
    ('ClassA',16),
    ('Class1',26),
    ('Class2',40),
    ('Class3',65),
    ('Class4',100);

--------Inserting Certifications of the Sailors and Validity-----------
INSERT INTO sailing_certificate(sailor_email,for_class_name,issue_date,expiry_date)
VALUES
    ('miguel.santos@gmail.com','Class2','09-12-21','09-12-23'),
    ('miguel.santos@gmail.com','Class1','01-12-22','09-12-23'),
    ('joao.santos@gmail.com','ClassA','09-06-21','09-08-23'),
    ('rita.leite@gmail.com','Class3','09-12-21','09-12-23'),
    ('jane.doe@gmail.com','Class4','09-12-22','09-12-24'),
    ('john.doe@gmail.com','ClassA','31-12-21','15-12-23'),
    ('joao.fernandes@gmail.com','Class4','01-01-20','01-01-25');

INSERT INTO valid_for(country_name,sailor_email,issue_date,expiry_date)
SELECT 'Portugal', sailor_email,issue_date,expiry_date
FROM sailing_certificate
WHERE for_class_name='Class4' OR sailor_email='miguel.santos@gmail.com';


INSERT INTO valid_for(country_name,sailor_email,issue_date,expiry_date)
SELECT 'Spain', sailor_email,issue_date,expiry_date
FROM sailing_certificate;

INSERT INTO valid_for(country_name,sailor_email,issue_date,expiry_date)
SELECT 'France', sailor_email,issue_date,expiry_date
FROM sailing_certificate
WHERE sailor_email='jane.doe@gmail.com';

---------Insert boats ----------------------------------------------------------
INSERT INTO boat(country_registration,cni,boat_name,length,year_registration,class_name)
VALUES
    ('Portugal','PT-00000000-00-01','Julia',14,2020,'ClassA'),
    ('Spain', 'ES-00000000-00-01','Julia',14,2020,'ClassA'),
    ('Portugal','PT-12345678-90-12','Navegante',35,2018,'Class2'),
    ('France','FR-12345678-90-12','Boat01',75,1999,'Class4'),
    ('Portugal','PT-00000000-11-11','Barquinho da Esperanca',21,2021,'Class1');


--------------Insert Reservations and Trips-----------------------------------------
INSERT INTO date_interval(start_date,end_date)
VALUES
    ('15-12-22','20-12-22'),
    ('15-12-22','16-12-22'),
    ('13-05-23','20-05-23'),
    ('24-05-23','26-05-23');

INSERT INTO reservation(boat_country_reg,cni,start_date,end_date,responsible)
SELECT res_boat.country_registration, res_boat.cni, date_int.start_date,date_int.end_date,'miguel.santos@gmail.com'
FROM boat as res_boat, date_interval as date_int
WHERE res_boat.country_registration='Portugal' AND res_boat.cni='PT-12345678-90-12' AND date_int.end_date!='20-12-22';

INSERT INTO reservation(boat_country_reg,cni,start_date,end_date,responsible)
SELECT 'France', 'FR-12345678-90-12', start_date,end_date, 'john.doe@gmail.com'
FROM date_interval
WHERE end_date='20-12-22';

INSERT INTO reservation(boat_country_reg,cni,start_date,end_date,responsible)
VALUES ('Portugal','PT-00000000-00-01','13-05-23','20-05-23','joao.fernandes@gmail.com');

INSERT INTO authorised(boat_country_reg, cni,sailor_email,start_date, end_date)
SELECT res.boat_country_reg, res.cni,res.responsible,res.start_date,res.end_date
FROM reservation as res;

INSERT INTO authorised(boat_country_reg, cni,sailor_email,start_date, end_date)
VALUES
    ('Portugal','PT-00000000-00-01','john.doe@gmail.com','13-05-23','20-05-23');


INSERT INTO authorised(boat_country_reg, cni,sailor_email,start_date, end_date)
SELECT res.boat_country_reg, res.cni,sailor.sailor_email,res.start_date,res.end_date
FROM reservation as res, sailor
WHERE res.responsible='john.doe@gmail.com' AND sailor.sailor_email!='john.doe@gmail.com';

INSERT INTO trip(boat_country_reg,cni,start_date,end_date,take_off_date,arrival_date,insurance, from_latitude,
                 from_longitude,to_latitude,to_longitude,skipper)
VALUES
    ('Portugal', 'PT-12345678-90-12','2022-12-15','2022-12-16','2022-12-15','2022-12-16','0123456789',41.150223, -8.629932,37.129665, -8.669586,'miguel.santos@gmail.com'),
    ('France','FR-12345678-90-12','2022-12-15','2022-12-20','2022-12-17','2022-12-19','0000000001',49.630001,-1.620000,49.630001,-1.620000,'jane.doe@gmail.com'),
    ('France','FR-12345678-90-12','2022-12-15','2022-12-20','2022-12-15','2022-12-16','0000000001',37.3826,  -5.99629,41.150223, -8.629932,'joao.fernandes@gmail.com'),
    ('Portugal','PT-00000000-00-01','13-05-23','20-05-23','13-05-23','16-05-23','1110001110',41.150223, -8.629932,37.129665, -8.669586,'john.doe@gmail.com')

-----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------



