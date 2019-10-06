--12.1--
--a)
CREATE TRIGGER zad1_a ON Pracownicy
AFTER UPDATE
AS
IF (SELECT placa FROM deleted) > (SELECT placa FROM inserted)
	BEGIN
		PRINT 'Nie mozna obnizac placy!'
		UPDATE Pracownicy
		SET placa = (SELECT placa FROM deleted)
		WHERE id = (SELECT id FROM deleted)
	END
GO
--b)
CREATE TRIGGER zad1_b ON Pracownicy
AFTER UPDATE
AS
	IF EXISTS
		(SELECT * 
			FROM deleted d JOIN inserted i
			ON d.id = i.id
			WHERE d.placa > i.placa)
	BEGIN
		PRINT 'Nie mozna obnizac placy!'
		UPDATE Pracownicy
		SET placa = (SELECT placa FROM deleted)
		WHERE id = (SELECT id FROM deleted)
	END
GO
--12.2
---a)
CREATE TRIGGER zad2_a ON Pracownicy
AFTER UPDATE
AS
IF UPDATE(placa)
	BEGIN
		UPDATE Pracownicy
		SET 	pracownicy.placa = pracownicy.placa + 0.5 * (i.placa - d.placa)
		FROM deleted d, inserted i
		WHERE d.id = i.id AND Pracownicy.szef = d.id
	END
GO
--b)
--12.3
CREATE TRIGGER zad3 ON Projekty
INSTEAD OF DELETE
AS
        BEGIN
                UPDATE Projekty
                SET     Projekty.status=0
                FROM deleted d
                WHERE Projekty.nazwa=d.nazwa
        END
GO
