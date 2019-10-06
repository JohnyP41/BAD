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

-----5.1
CREATE VIEW AktualneProjekty(nazwa,kierownik,"licz pracownikow")
AS
(
	SELECT nazwa,		
	(SELECT nazwisko					
	FROM Pracownicy
	WHERE Projekty.kierownik = Pracownicy.id),
	(SELECT	COUNT(idPrac)
	FROM Realizacje
	WHERE idProj = Projekty.id 
	GROUP BY idProj)
	FROM Projekty
	WHERE dataZakonczFakt IS NULL
);
GO
SELECT *
FROM   AktualneProjekty;

SELECT TOP 1 nazwa, "licz pracownikow"
FROM AktualneProjekty
ORDER BY "licz pracownikow" DESC;
-----5.2
CREATE VIEW tmp1
AS
(
    SELECT placa 
    FROM   Pracownicy
    
    UNION ALL
    
    SELECT placa 
    FROM   Pracownicy
);
GO
 
CREATE VIEW tmp2
AS
(
    SELECT placa 
    FROM   tmp1 T1
    WHERE  (SELECT COUNT(*) 
            FROM   Pracownicy) <= (SELECT COUNT(*) 
                                   FROM   tmp1 T2 
                                   WHERE  T2.placa >= T1.placa)
           AND (SELECT COUNT(*) 
                FROM   Pracownicy) <= (SELECT COUNT(*) 
                                       FROM   tmp1 T3 
                                       WHERE  T3.placa <= T1.placa)
);
GO
SELECT * 
FROM   tmp2
 
CREATE VIEW Zagadka
AS
(
    SELECT AVG(DISTINCT placa) 'zagadkowa wartosc' 
    FROM   tmp2
);
GO


SELECT *
FROM   Zagadka;
SELECT 'Perspektywa Zagadka wyznacza œrednia arytmetyczna p³ac pracowników zarabiaj¹cych pomiedzy 2500-2550.' [rozwiazanie];
-----5.3
     WITH CTE_Podwladni(nazwisko, id, poziom)
     AS
     (
        SELECT nazwisko,
               id,
               0
        FROM Pracownicy
        WHERE nazwisko = 'Mielcarz'
 
        UNION ALL
 
 
        SELECT P.nazwisko,
                P.id,
                T.poziom + 1
        FROM Pracownicy P
                JOIN CTE_Podwladni T
                ON P.szef = T.id
     )
        SELECT nazwisko,poziom
        FROM CTE_Podwladni
        WHERE poziom > 0;
---5.4 
      WITH CTE_Przelozeni(nazwisko, szef, poziom)
      AS
      (
        SELECT nazwisko,
               szef,
               0
        FROM Pracownicy
        WHERE nazwisko = 'Andrzejewicz'
 
        UNION ALL
 
 
        SELECT P.nazwisko,
                P.szef,
                T.poziom + 1
        FROM Pracownicy P
                JOIN CTE_Przelozeni T
                ON T.szef = P.id
     )
       SELECT nazwisko,poziom
       FROM CTE_Przelozeni
       WHERE poziom > 0;