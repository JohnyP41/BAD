--11.1
CREATE FUNCTION LiczLata
(
    @data DATETIME
)
    RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YY,@data,GETDATE());
END;

SELECT nazwisko, dbo.LiczLata(zatrudniony) AS 'Staż Pracy'
FROM Pracownicy
--11.2
CREATE FUNCTION StazPracy
(
    @x INT
)
    RETURNS TABLE
AS
    RETURN SELECT nazwisko
           FROM   Pracownicy
           WHERE  dbo.LiczLata(zatrudniony) > @x;

SELECT *
FROM StazPracy(25);
--11.3
