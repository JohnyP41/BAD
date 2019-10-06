--8.1
select Kod, nazwa, liczba_dni, cena
into KursyKopia
from kursy
--nie

--zad2
---a
insert into Uczestnicy
VALUES (12345678912, 'Przybyla', default , 'wojprz@st.amu.edu.pl');
--bblad duplikowania primary key
--c
insert into Udzial
	select '12345678912', kod, '2017-10-20', '2017-10-22', 'ukonczony'
	from Kursy
	where nazwa = 'Analiza danych'	

--zad3
--a
UPDATE Kursy
SET liczba_dni = liczba_dni + 1
where nazwa like '%MySQL%'

--b
ALTER TABLE Uczestnicy
ADD rok_urodzenia int
update Uczestnicy
set rok_urodzenia = LEFT(PESEL, 2) + 1900
--zad4
update U	
	set U.miasto = M.forma_poprawna
	from Uczestnicy U join MapujMiasta M
	on U.miasto = M.forma_niepoprawna
--zad5

--a
select PESEL
into #uczestnicy_do_usuniecia
from Uczestnicy
where nazwisko = 'Jakubowicz'

delete from Udzial
where uczestnik in (select pesel from #uczestnicy_do_usuniecia)

delete from Uczestnicy
where PESEL in (select PESEL from #uczestnicy_do_usuniecia)

--b
select * 
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where TABLE_NAME = 'Udzial'

alter table udzial
drop constraint FK_Udzial_uczestni_56E8E7AB

alter table udzial
add constraint fk_udzia_uczest
	foreign key (uczestnik) references Uczestnicy(pesel)
	on delete set null
-----

