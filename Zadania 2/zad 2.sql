--drop DATABASE Projekty
--GO

CREATE DATABASE ProjektyX
GO

USE ProjektyX
GO

SET LANGUAGE polski
GO

-------- USUÑ TABELE

IF OBJECT_ID('Realizacje', 'U') IS NOT NULL 
	DROP TABLE Realizacje;

IF OBJECT_ID('Projekty', 'U') IS NOT NULL 
	DROP TABLE Projekty;

IF OBJECT_ID('Pracownicy', 'U') IS NOT NULL 
	DROP TABLE Pracownicy;

IF OBJECT_ID('Stanowiska', 'U') IS NOT NULL 
	DROP TABLE Stanowiska;

--------- CREATE - UTWÓRZ TABELE I POWI¥ZANIA

CREATE TABLE Stanowiska(
    nazwa      VARCHAR(10) PRIMARY KEY,
    placa_min  MONEY,
    placa_max  MONEY,
    CHECK (placa_min < placa_max)
);

CREATE TABLE Pracownicy(
    id           INT NOT NULL PRIMARY KEY,
    nazwisko     VARCHAR(20) NOT NULL,
    szef         INT REFERENCES Pracownicy(id),
    placa        MONEY,
    dod_funkc    MONEY,
    stanowisko   VARCHAR(10) REFERENCES Stanowiska(nazwa),
    zatrudniony  DATETIME
);

CREATE TABLE Projekty(
    id               INT IDENTITY(10,10) NOT NULL PRIMARY KEY,
    nazwa            VARCHAR(20) NOT NULL UNIQUE,
    dataRozp         DATETIME NOT NULL,
    dataZakonczPlan  DATETIME NOT NULL,
    dataZakonczFakt  DATETIME NULL,
    kierownik        INT REFERENCES Pracownicy(id),
    stawka           MONEY
);

CREATE TABLE Realizacje(
    idProj  INT REFERENCES Projekty(id),
    idPrac  INT REFERENCES Pracownicy(id),
    godzin  REAL DEFAULT 8
);

GO

---------- INSERT - WSTAW DANE

INSERT INTO Stanowiska VALUES ('profesor',   3000, 5000);
INSERT INTO Stanowiska VALUES ('adiunkt',    2000, 3000);
INSERT INTO Stanowiska VALUES ('doktorant',   900, 1300);
INSERT INTO Stanowiska VALUES ('sekretarka', 1500, 2500);
INSERT INTO Stanowiska VALUES ('techniczny', 1500, 2500);
INSERT INTO Stanowiska VALUES ('dziekan',    2700, 4800);

INSERT INTO Pracownicy VALUES (1,  'Wachowiak', NULL, 4500,  900,   'profesor', '01-09-1980');
INSERT INTO Pracownicy VALUES (2,  'Jankowski',    1, 2500, NULL,    'adiunkt', '01-09-1990');
INSERT INTO Pracownicy VALUES (3,  'Fio³kowska',   1, 2550, NULL,    'adiunkt', '01-01-1985');
INSERT INTO Pracownicy VALUES (4,  'Mielcarz',     1, 4000,  400,   'profesor', '01-12-1980');
INSERT INTO Pracownicy VALUES (5,  'Ró¿ycka',      4, 2800,  200,   'profesor', '01-09-2001');
INSERT INTO Pracownicy VALUES (6,  'Miko³ajski',   4, 1000, NULL,  'doktorant', '01-10-2002');
INSERT INTO Pracownicy VALUES (7,  'Wójcicki',     5, 1350, NULL,  'doktorant', '01-10-2003');
INSERT INTO Pracownicy VALUES (8,  'Listkiewicz',  1, 2200, NULL, 'sekretarka', '01-09-1980');
INSERT INTO Pracownicy VALUES (9,  'Wróbel',       1, 1900,  300, 'techniczny', '01-01-1999');
INSERT INTO Pracownicy VALUES (10, 'Andrzejewicz', 5, 2900, NULL,    'adiunkt', '01-01-2002');

INSERT INTO Projekty VALUES ('e-learning',     '01-01-2015', '31-05-2016',         NULL, 5, 100);
INSERT INTO Projekty VALUES ('web service',    '10-11-2009', '31-12-2010', '20-04-2011', 4,  90);
INSERT INTO Projekty VALUES ('semantic web',   '01-09-2017', '01-09-2019',         NULL, 4,  85);
INSERT INTO Projekty VALUES ('neural network', '01-01-2008', '30-06-2010', '30-06-2010', 1, 120);
INSERT INTO Projekty VALUES ('analiza danych', GETDATE(), DATEADD(YY, 2, GETDATE()), NULL, 10, 100);

INSERT INTO Realizacje VALUES (10,  5, 8);
INSERT INTO Realizacje VALUES (10, 10, 6);
INSERT INTO Realizacje VALUES (10,  9, 2);
INSERT INTO Realizacje VALUES (20,  4, 8);
INSERT INTO Realizacje VALUES (20,  6, 8);
INSERT INTO Realizacje VALUES (20,  9, 2);
INSERT INTO Realizacje VALUES (30,  4, 8);
INSERT INTO Realizacje VALUES (30,  6, 6);
INSERT INTO Realizacje VALUES (30, 10, 6);
INSERT INTO Realizacje VALUES (30,  9, 2);
INSERT INTO Realizacje VALUES (40,  1, 8);
INSERT INTO Realizacje VALUES (40,  2, 4);
INSERT INTO Realizacje VALUES (40,  3, 4);
INSERT INTO Realizacje VALUES (40,  9, 2);

------------ SELECT

SELECT * FROM Stanowiska;
SELECT * FROM Pracownicy;
SELECT * FROM Projekty;
SELECT * FROM Realizacje;

--2.1
SELECT P.nazwisko,P.placa,P.stanowisko,S.placa_min,S.placa_max
FROM Pracownicy P INNER JOIN Stanowiska S
ON   P.stanowisko = S.nazwa;
--2.2
SELECT P.nazwisko,P.placa,P.stanowisko,S.placa_min,S.placa_max
FROM Pracownicy P INNER JOIN Stanowiska S
ON   P.stanowisko = S.nazwa
WHERE P.stanowisko='doktorant' AND P.placa NOT BETWEEN 900 AND 1300;
--2.3
SELECT P.nazwisko,Pr.nazwa AS 'projekt'
FROM Pracownicy P INNER JOIN Realizacje R
ON P.id = R.idPrac
INNER JOIN Projekty Pr
ON R.idProj = Pr.id
ORDER BY P.nazwisko;
--2.4
SELECT P1.nazwisko,P2.nazwisko AS 'szef'
FROM Pracownicy P1 JOIN Pracownicy P2
ON   P1.szef = P2.id;
--2.5
SELECT P1.nazwisko,P2.nazwisko  AS 'szef'
FROM Pracownicy P1 LEFT OUTER JOIN Pracownicy P2
ON   P1.szef = P2.id;
--2.6
SELECT Pr.nazwisko
FROM   Pracownicy Pr LEFT OUTER JOIN Projekty P
ON     Pr.id = P.kierownik
WHERE  P.id IS NULL;
--2.7
SELECT p.nazwisko
FROM Pracownicy p LEFT OUTER JOIN Realizacje r
ON p.id = r.idPrac
AND r.idProj = 10
WHERE r.idPrac IS NULL;
--2.8
SELECT p.nazwisko
FROM Pracownicy p INNER JOIN Pracownicy r
ON p.id = r.id
WHERE p.nazwisko = r.nazwisko and p.id != r.id
--2.9
SELECT S1.placa_min AS 'adiunkt', S2.placa_min AS 'doktorant',S3.placa_min AS 'dziekan',S4.placa_min AS 'profesor'
FROM (SELECT placa_min FROM Stanowiska WHERE nazwa = 'adiunkt') AS S1 
CROSS JOIN (SELECT placa_min FROM Stanowiska WHERE nazwa = 'doktorant') AS S2
CROSS JOIN (SELECT placa_min FROM Stanowiska WHERE nazwa = 'dziekan') AS S3
CROSS JOIN (SELECT placa_min FROM Stanowiska WHERE nazwa = 'profesor') AS S4;
--2.10
SELECT P.nazwisko 
FROM Pracownicy P LEFT OUTER JOIN Realizacje R
ON P.id=R.idPrac
LEFT OUTER JOIN Projekty P1
ON R.idPrac=P1.kierownik
WHERE P1.id!=R.idProj AND P1.kierownik=R.idProj;