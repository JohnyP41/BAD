IF OBJECT_ID('Udzial','U') IS NOT NULL
    DROP TABLE Udzial;
IF OBJECT_ID('Uczestnicy','U') IS NOT NULL
    DROP TABLE Uczestnicy;
IF OBJECT_ID('Kursy','U') IS NOT NULL
    DROP TABLE Kursy;

IF OBJECT_ID('MapujMiasta','U') IS NOT NULL
    DROP TABLE MapujMiasta;
IF OBJECT_ID('UczestnicyAktualnie','U') IS NOT NULL
    DROP TABLE UczestnicyAktualnie;

---------------------------------------------------------------

SET LANGUAGE polski
GO

CREATE TABLE Uczestnicy
(
    PESEL    CHAR(11) PRIMARY KEY,
    nazwisko VARCHAR(20) NOT NULL,
    miasto   VARCHAR(20) DEFAULT 'Poznań',
    email    VARCHAR(100),
    CONSTRAINT ck_ucz_pesel CHECK(Pesel LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE Kursy
(
    Kod        INT IDENTITY(100, 100) PRIMARY KEY,
    nazwa      VARCHAR(50) UNIQUE,
    liczba_dni INT,
    cena       AS liczba_dni * 1000,
    CONSTRAINT ck_kurs_dni CHECK(liczba_dni BETWEEN 1 AND 5)
);

CREATE TABLE Udzial
(
    uczestnik  CHAR(11) REFERENCES Uczestnicy(pesel),
    kurs       INT REFERENCES Kursy(kod),
    data_od    DATE,
    data_do    DATE,
    [status]   VARCHAR(20) CHECK([status] IN ('w trakcie','ukonczony', 'nieukonczony')),
    CONSTRAINT ck_udzial_data CHECK(data_do > data_od)
);

---------------------------------------------------------------

INSERT INTO Kursy(nazwa, liczba_dni) VALUES
	('Administracja MySQL'         , 3),
	('Analiza danych'              , 3),
	('MS Access (zaawansowany)'    , 2),
	('MySQL dla programistów'      , 2),
	('Programowanie VBA w Accessie', 1);

INSERT INTO Uczestnicy VALUES
	('91122895863', 'Lewicka',    'Poznań',         'alewi91@buziaczek.pl'),
    ('74080812482', 'Kowalski',   'Szczecin',       'kowal@cloud.net'),
    ('58100387129', 'Najgebauer', 'Lodz',           'jakub@najgebauer.com.pl'),
    ('69091729555', 'Muszka',     'P-ń',            'muszka@wp.pl'),
    ('83060448424', 'Jakubowicz', 'Bielskobiała',   'hulk@marvel.com'),
	('90121298347', 'Janicka',    'Bielsko Biala',  'janicka@amu.edu.pl')

INSERT INTO Udzial VALUES
	('91122895863', 100, '01-03-2015', '03-03-2015', 'ukonczony'),
    ('83060448424', 300, '12-10-2015', '13-10-2015', 'nieukonczony'),
    ('83060448424', 200, '15-11-2017', NULL,         'w trakcie'),
    ('91122895863', 400, '22-02-2014', '23-02-2014', 'nieukonczony'),
    ('69091729555', 100, '01-03-2015', '03-03-2015', 'ukonczony');

---------------------------------------------------------------

CREATE TABLE MapujMiasta
(
    forma_poprawna    varchar(20),
    forma_niepoprawna varchar(20)
);

INSERT INTO MapujMiasta VALUES
    ('Poznań',        'Poznan'),
    ('Poznań',        'P-ń'),
    ('Kraków',        'Krakow'),
    ('Łódź',          'Lodz'),
    ('Bielsko-Biała', 'Bielsko-Biala'),
    ('Bielsko-Biała', 'Bielsko Biala'),
    ('Bielsko-Biała', 'Bielsko Biała');

---------------------------------------------------------------

CREATE TABLE UczestnicyAktualnie
(
    PESEL    CHAR(11) PRIMARY KEY,
    nazwisko VARCHAR(20) NOT NULL,
	miasto   VARCHAR(20) DEFAULT 'Poznań',
    email    VARCHAR(100)
);

INSERT INTO UczestnicyAktualnie VALUES
	('91122895863', 'Lewicka',           'Poznań',        'alewi91@buziaczek.pl'),
    ('74080812482', 'Kowalski',          'Warszawa',      'kowal@cloud.net'),
    ('58100387129', 'Najgebauer',        'Lodz',          'jakub@najgebauer.com.pl'),
    ('69091729555', 'Muszka',            'Poznań',        'muszka@wp.pl'),
    ('83060448424', 'Jakubowicz',        'Bielsko-Biała', 'hulk@marvel.com'),
	('90121298347', 'Janicka-Wolska',    'Bielsko-Biała', 'janicka@amu.edu.pl'),
	('81080803031', 'Nowak',             'Mosina',        'nowakjan@gmail.com');

---------------------------------------------------------------

SELECT * FROM Uczestnicy;
SELECT * FROM Kursy;
SELECT * FROM Udzial;

--8.1
SELECT Kod, nazwa, liczba_dni, cena
INTO KursyKopia
FROM Kursy;
--8.2
--a)
INSERT INTO Uczestnicy
VALUES (84959234567, 'Przybylski', DEFAULT , 'plaljahn@gmail.com');
--b)blad duplikowania klucza glownego
--c)
INSERT INTO Udzial
VALUES (84959234567,(SELECT kod FROM Kursy WHERE nazwa = 'Analiza danych'),'2017-10-20','2017-10-22','ukonczony')
INSERT INTO  Udzial
SELECT '84959234567', kod, '2017-10-20', '2017-10-22', 'ukonczony'
FROM Kursy
WHERE nazwa = 'Analiza danych';
--8.3
--a
UPDATE Kursy
SET liczba_dni = liczba_dni + 1
WHERE nazwa LIKE '%MySQL%';
--b
ALTER TABLE Uczestnicy
ADD rok_urodzenia INT
UPDATE Uczestnicy
SET rok_urodzenia = LEFT(PESEL, 2) + 1900;
--8.4
UPDATE Uczestnicy	
	SET miasto = forma_poprawna
	FROM MapujMiasta
	WHERE miasto = forma_niepoprawna
--wersja pelna
UPDATE U	
	SET U.miasto = M.forma_poprawna
	FROM Uczestnicy U JOIN MapujMiasta M
	ON U.miasto = M.forma_niepoprawna;
--8.5xx
DELETE FROM Uczestnicy
WHERE nazwisko = 'Jakubowicz';

--a
SELECT PESEL
INTO #uczestnicyDousuniecia
FROM Uczestnicy
WHERE nazwisko = 'Jakubowicz'

DELETE FROM Udzial
WHERE uczestnik IN (SELECT PESEL FROM #uczestnicyDousuniecia)

DELETE FROM Uczestnicy
WHERE PESEL IN (SELECT PESEL FROM #uczestnicyDousuniecia)

--b
SELECT * 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Udzial'

ALTER TABLE Udzial
DROP CONSTRAINT FK_Udzial_uczestni_56E8E7AB

ALTER TABLE Udzial
ADD CONSTRAINT fk_udzia_uczest
	FOREIGN KEY (uczestnik) REFERENCES Uczestnicy(pesel)
	ON DELETE SET NULL
--c
SELECT * 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Udzial'

ALTER TABLE Udzial
DROP CONSTRAINT FK_Udzial_uczestni_56E8E7AB

ALTER TABLE Udzial
ADD CONSTRAINT fk_udzia_uczest
	FOREIGN KEY (uczestnik) REFERENCES Uczestnicy(pesel)
	ON DELETE CASCADE;
	
SELECT * FROM Udzial
DELETE FROM Uczestnicy
WHERE PESEL IN (SELECT PESEL FROM  #uczestnicyDousuniecia)
---8.6
MERGE Uczestnicy
USING UczestnicyAktualnie
ON    (Uczestnicy.pesel = UczestnicyAktualnie.pesel)
WHEN MATCHED THEN
	  UPDATE SET Uczestnicy.nazwisko = UczestnicyAktualnie.nazwisko
WHEN NOT MATCHED THEN
      INSERT (pesel, nazwisko, miasto, email)
      VALUES (UczestnicyAktualnie.pesel, UczestnicyAktualnie.nazwisko, UczestnicyAktualnie.miasto, UczestnicyAktualnie.email)
OUTPUT deleted.*, inserted.*;