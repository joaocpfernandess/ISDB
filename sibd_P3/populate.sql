----------------------------------------------------------------------------
-- Loading Data to Tables
----------------------------------------------------------------------------
-- Insert into table 'country'
----------------------------------------------------------------------------
INSERT INTO country
VALUES
   ('PRT','https://upload.wikimedia.org/wikipedia/commons/5/5c/Flag_of_Portugal.svg','Portugal'),
   ('FRA','https://en.wikipedia.org/wiki/File:Flag_of_France.svg#/media/File:Flag_of_France.svg','France'),
   ('ESP','https://en.wikipedia.org/wiki/Flag_of_Spain#/media/File:Bandera_de_Espa%C3%B1a.svg','Spain'),
   ('ITA','https://pt.wikipedia.org/wiki/Bandeira_da_It%C3%A1lia#/media/Ficheiro:Flag_of_Italy.svg','Italy');
----------------------------------------------------------------------------
-- Insert into table 'sailor'
----------------------------------------------------------------------------
INSERT INTO sailor
VALUES
   ('Joao','Goncalves Santos','joao.santos@gmail.com'),
   ('Miguel','Pereira Dos Santos','miguel.santos@gmail.com'),
   ('Arnold','Mcalister Silver Santos','arnold.santos@hotmail.com'),
   ('Francois','Baudin Flobert','francois.flobert@hotmail.com'),
   ('Rita','Leite','rita.leite@gmail.com'),
   ('Joao','Fernandes','joao.fernandes@gmail.com'),
   ('Marina','Antonio Peres Vaz','marina.vaz@gmail.com'),
   ('Filipe','Martins','filipe.martins@gmail.com'),
   ('Jane','Walter Doe','jane.doe@gmail.com'),
   ('John','Fritz Doe','john.doe@gmail.com'),
   ('Julia','Mancini Bianchi','julia.bianchi@hotmail.com'),
   ('Valentino','Marino Rossi','valentino.rossi@gmail.com');
----------------------------------------------------------------------------
-- Insert into table 'senior'
----------------------------------------------------------------------------
INSERT INTO senior
   SELECT email
   FROM sailor
   WHERE email IN ('miguel.santos@gmail.com','arnold.santos@hotmail.com','joao.fernandes@gmail.com',
                          'filipe.martins@gmail.com','john.doe@gmail.com','valentino.rossi@gmail.com');
----------------------------------------------------------------------------
-- Insert into table 'junior'
----------------------------------------------------------------------------
INSERT INTO junior
   SELECT email
   FROM sailor
   WHERE email IN ('joao.santos@gmail.com','francois.flobert@hotmail.com','rita.leite@gmail.com',
                          'marina.vaz@gmail.com','jane.doe@gmail.com','julia.bianchi@hotmail.com');
----------------------------------------------------------------------------
-- Insert into table 'location'
----------------------------------------------------------------------------
INSERT INTO location
VALUES
   (49.630001,-1.620000,'Cherbourg','France'),
   (43.296398,5.370000,'Marseille','France'),
   (43.675819,7.289429,'Nice','France'),
   (37.129665,-8.669586,'Lagos','Portugal'),
   (38.697900,-9.421460,'Cascais','Portugal'),
   (41.150223,-8.629932,'Porto','Portugal'),
   (36.533333,-6.283333,'Cadiz','Spain'),
   (41.390205,2.154007,'Barcelona','Spain'),
   (44.4264,8.91519,'Genoa','Italy'),
   (40.853294,14.305573,'Naples','Italy'),
   (38.116669,13.366667,'Palermo','Italy');
----------------------------------------------------------------------------
-- Insert into table 'boat_class'
----------------------------------------------------------------------------
INSERT INTO boat_class
VALUES
   ('ClassA',16),
   ('Class1',26),
   ('Class2',40),
   ('Class3',65),
   ('Class4',100);
----------------------------------------------------------------------------
-- Insert into table 'sailing_certificate'
----------------------------------------------------------------------------
INSERT INTO sailing_certificate
VALUES
   ('2021-12-09','2023-12-09','miguel.santos@gmail.com','Class2'),
   ('2022-12-09','2023-12-09','miguel.santos@gmail.com','Class1'),
   ('2022-10-06','2023-09-06','joao.santos@gmail.com','ClassA'),
   ('2022-09-06','2023-09-06','joao.santos@gmail.com','Class2'),
   ('2023-01-02','2024-01-02','francois.flobert@hotmail.com','Class4'),
   ('2021-12-30','2022-12-30','rita.leite@gmail.com','Class3'),
   ('2022-12-09','2024-12-09','jane.doe@gmail.com','Class4'),
   ('2023-01-02','2024-01-02','filipe.martins@gmail.com','Class4'),
   ('2023-05-01','2023-12-30','john.doe@gmail.com','ClassA'),
   ('2022-01-01','2022-12-30','joao.fernandes@gmail.com','Class4'),
   ('2022-06-01','2022-12-30','valentino.rossi@gmail.com','Class2'),
   ('2023-01-02','2024-01-02','valentino.rossi@gmail.com','Class4'),
   ('2023-05-01','2023-12-30','julia.bianchi@hotmail.com','Class4');
----------------------------------------------------------------------------
-- Insert into table 'valid_for'
----------------------------------------------------------------------------
INSERT INTO valid_for
VALUES
   ('Portugal',40,'miguel.santos@gmail.com','2021-12-09'),
   ('Portugal',26,'miguel.santos@gmail.com','2022-12-09'),
   ('Portugal',16,'joao.santos@gmail.com','2022-09-06'),
   ('Portugal',65,'rita.leite@gmail.com','2021-12-30'),
   ('Spain',65,'rita.leite@gmail.com','2021-12-30'),
   ('Portugal',40,'valentino.rossi@gmail.com','2022-06-01'),
   ('Spain',100,'valentino.rossi@gmail.com','2023-01-02'),
   ('Portugal',100,'valentino.rossi@gmail.com','2023-01-02'),
   ('Spain',40,'valentino.rossi@gmail.com','2022-06-01'),
   ('France',40,'valentino.rossi@gmail.com','2022-06-01'),
   ('France',100,'valentino.rossi@gmail.com','2023-01-02'),
   ('Italy',40,'valentino.rossi@gmail.com','2022-06-01'),
   ('Italy',100,'valentino.rossi@gmail.com','2023-01-02'),
   ('France',100,'francois.flobert@hotmail.com','2023-01-02'),
   ('France',100,'filipe.martins@gmail.com','2023-01-02'),
   ('France',100,'joao.fernandes@gmail.com','2022-01-01'),
   ('Portugal',100,'joao.fernandes@gmail.com','2022-01-01'),
   ('Portugal',100,'jane.doe@gmail.com','2022-12-09'),
   ('Italy',100,'julia.bianchi@hotmail.com','2023-05-01'),
   ('Portugal',16,'john.doe@gmail.com','2023-05-01');
----------------------------------------------------------------------------
-- Insert into table 'boat'
----------------------------------------------------------------------------
INSERT INTO boat
VALUES
   ('Portugal',2020,'PT-00000022-80-01','Julia',14,'ClassA'),
   ('Spain', 2020,'ES-12003500-11-01','Julia',14,'ClassA'),
   ('Portugal',2018,'PT-12345678-90-12','O Navegante',35,'Class2'),
   ('France',1999,'FR-12345678-90-12','Boat01',75,'Class4'),
   ('France',2019,'FR-12345678-88-11','Le Nourrisson',80,'Class4'),
   ('Portugal',2021,'PT-00000000-11-11','Barquinho da Esperanca',21,'Class1'),
   ('Portugal',2021,'PT-12020033-11-11','O Infante',32,'Class2'),
   ('Portugal',2011,'PT-80100534-11-11','O Gigante dos Mares',45,'Class3'),
   ('Italy',2021,'IT-22000001-09-20','Stella Marina',36,'Class2'),
   ('Italy',2021,'IT-00000012-11-14','Il Re Dei Mari',40,'Class2'),
   ('Italy',2020,'IT-11000012-03-10','Il Re Dei Mari',80,'Class4');
----------------------------------------------------------------------------
-- Insert into table 'date_interval'
----------------------------------------------------------------------------
INSERT INTO date_interval
VALUES
   ('2022-12-15','2022-12-16'),
   ('2022-12-15','2022-12-20'),
   ('2023-05-13','2023-05-20'),
   ('2023-01-10','2023-05-23'),
   ('2023-05-28','2023-06-22');
----------------------------------------------------------------------------
-- Insert into table 'reservation'
----------------------------------------------------------------------------
INSERT INTO reservation
VALUES
   ('2022-12-15','2022-12-16','Portugal','PT-12345678-90-12','miguel.santos@gmail.com'),
   ('2022-12-15','2022-12-20','Portugal','PT-80100534-11-11','arnold.santos@hotmail.com'),
   ('2022-12-15','2022-12-20','France','FR-12345678-90-12','john.doe@gmail.com'),
   ('2022-12-15','2022-12-20','Portugal','PT-12020033-11-11','valentino.rossi@gmail.com'),
   ('2023-05-13','2023-05-20','Portugal','PT-00000022-80-01','john.doe@gmail.com'),
   ('2023-01-10','2023-05-23','France','FR-12345678-88-11','valentino.rossi@gmail.com'),
   ('2023-05-28','2023-06-22','Italy','IT-11000012-03-10','valentino.rossi@gmail.com');
----------------------------------------------------------------------------
-- Insert into table 'authorised'
----------------------------------------------------------------------------
INSERT INTO authorised
VALUES
   ('2022-12-15','2022-12-16','Portugal','PT-12345678-90-12','miguel.santos@gmail.com'),
   ('2022-12-15','2022-12-20','Portugal','PT-80100534-11-11','arnold.santos@hotmail.com'),
   ('2022-12-15','2022-12-20','Portugal','PT-80100534-11-11','rita.leite@gmail.com'),
   ('2022-12-15','2022-12-20','Portugal','PT-80100534-11-11','joao.santos@gmail.com'),
   ('2022-12-15','2022-12-20','France','FR-12345678-90-12','joao.fernandes@gmail.com'),
   ('2022-12-15','2022-12-20','France','FR-12345678-90-12','jane.doe@gmail.com'),
   ('2022-12-15','2022-12-20','France','FR-12345678-90-12','francois.flobert@hotmail.com'),
   ('2022-12-15','2022-12-20','Portugal','PT-12020033-11-11','valentino.rossi@gmail.com'),
   ('2023-05-13','2023-05-20','Portugal','PT-00000022-80-01','john.doe@gmail.com'),
   ('2023-01-10','2023-05-23','France','FR-12345678-88-11','valentino.rossi@gmail.com'),
   ('2023-01-10','2023-05-23','France','FR-12345678-88-11','filipe.martins@gmail.com'),
   ('2023-01-10','2023-05-23','France','FR-12345678-88-11','francois.flobert@hotmail.com'),
   ('2023-01-10','2023-05-23','France','FR-12345678-88-11','joao.santos@gmail.com'),
   ('2023-05-28','2023-06-22','Italy','IT-11000012-03-10','julia.bianchi@hotmail.com'),
   ('2023-05-28','2023-06-22','Italy','IT-11000012-03-10','valentino.rossi@gmail.com'),
   ('2023-05-28','2023-06-22','Italy','IT-11000012-03-10','john.doe@gmail.com');
----------------------------------------------------------------------------
-- Insert into table 'trip'
----------------------------------------------------------------------------
INSERT INTO trip
VALUES
   ('2022-12-15','2022-12-16','0123456789',41.150223,-8.629932,37.129665,-8.669586,'miguel.santos@gmail.com','2022-12-15','2022-12-16','Portugal','PT-12345678-90-12'),
   ('2022-12-15','2022-12-15','0111456789',37.129665,-8.669586,38.697900,-9.421460,'rita.leite@gmail.com','2022-12-15','2022-12-20','Portugal','PT-80100534-11-11'),
   ('2022-12-16','2022-12-17','0111456789',38.697900,-9.421460,41.150223,-8.629932,'rita.leite@gmail.com','2022-12-15','2022-12-20','Portugal','PT-80100534-11-11'),
   ('2022-12-18','2022-12-19','0111456789',41.150223,-8.629932,36.533333,-6.283333,'rita.leite@gmail.com','2022-12-15','2022-12-20','Portugal','PT-80100534-11-11'),
   ('2022-12-15','2022-12-18','1000000011',49.630001,-1.620000,41.150223,-8.629932,'joao.fernandes@gmail.com','2022-12-15','2022-12-20','France','FR-12345678-90-12'),
   ('2022-12-19','2022-12-20','1000000011',41.150223,-8.629932,37.129665,-8.669586,'jane.doe@gmail.com','2022-12-15','2022-12-20','France','FR-12345678-90-12'),
   ('2023-05-13','2023-05-16','1110001110',41.150223,-8.629932,37.129665,-8.669586,'john.doe@gmail.com','2023-05-13','2023-05-20','Portugal','PT-00000022-80-01'),
   ('2023-01-10','2023-01-18','1110002234',41.390205,2.154007,43.296398,5.370000,'valentino.rossi@gmail.com','2023-01-10','2023-05-23','France','FR-12345678-88-11'),
   ('2023-02-12','2023-02-15','1110002234',43.296398,5.370000,43.675819,7.289429,'francois.flobert@hotmail.com','2023-01-10','2023-05-23','France','FR-12345678-88-11'),
   ('2023-04-20','2023-04-24','1110002234',43.675819,7.289429,44.4264,8.91519,'valentino.rossi@gmail.com','2023-01-10','2023-05-23','France','FR-12345678-88-11'),
   ('2023-05-29','2023-06-02','2103051134',44.4264,8.91519,40.853294,14.305573,'julia.bianchi@hotmail.com','2023-05-28','2023-06-22','Italy','IT-11000012-03-10'),
   ('2023-06-18','2023-06-22','2103051134',40.853294,14.305573,38.116669,13.366667,'julia.bianchi@hotmail.com','2023-05-28','2023-06-22','Italy','IT-11000012-03-10');
----------------------------------------------------------------------------
-- END
----------------------------------------------------------------------------