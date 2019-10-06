---6.1
CREATE TABLE Uczestnicy
(
    PESEL       VARCHAR(11) CONSTRAINT p PRIMARY KEY,
    nazwisko	VARCHAR(100) NOT NULL,
    miasto		VARCHAR(100) CONSTRAINT m DEFAULT 'Poznań',
);
CREATE TABLE Kursy
(
    Kod       	INT IDENTITY(1,3) CONSTRAINT kod PRIMARY KEY,
    nazwa	  	VARCHAR(100) CONSTRAINT naz UNIQUE ,
    liczba_dni	INT,CONSTRAINT liczba CHECK (liczba_dni BETWEEN 1 AND 5),
	cena		AS (liczba_dni*1000)
);
CREATE TABLE Udzial
(
    uczestnik   VARCHAR(11) FOREIGN KEY REFERENCES Uczestnicy(PESEL),
    kurs		INT FOREIGN KEY REFERENCES Kursy(Kod),
    data_od		DATE,
	data_do		DATE,CONSTRAINT data CHECK (data_do > data_od),
	status		VARCHAR(30) CONSTRAINT stat CHECK (status IN ('w trakcie', 'ukonczony', 'nie ukonczony')),
	UNIQUE(uczestnik,kurs,data_od)
);
--6.2
--6.3
ALTER TABLE Uczestnicy
ADD CONSTRAINT PESEL CHECK (PESEL NOT LIKE '%[^0-9]%' AND LEN(PESEL)=11);

ALTER TABLE Udzial 
ADD id INT PRIMARY KEY;

ALTER TABLE Kursy 
DROP CONSTRAINT liczba;
--6.4
ALTER TABLE Kursy 
ADD CONSTRAINT Kod (CREATE SEQUENCE kod);
--6.5
IF OBJECT_ID('Udzial', 'U') IS NOT NULL 
    DROP TABLE Udzial;
IF OBJECT_ID('Uczestnicy', 'U') IS NOT NULL 
    DROP TABLE Uczestnicy;
IF OBJECT_ID('Kursy', 'U') IS NOT NULL 
    DROP TABLE Kursy;