-- analiza danych

use sklep;


-- ANALIZA SPRZEDAŻY





DELIMITER $$
CREATE PROCEDURE sprzedazProduktKolorRozmiar (
	IN pkolor char(20),
    IN prozmiar char(20))
BEGIN
     SELECT 
        s.id_sprzedaż AS id_sprzedaż,
        sklep.z.id_zamówienie AS id_zamówienie,
        sklep.p.produkt AS produkt,
        sklep.p.kolor AS kolor,
        sklep.p.rozmiar AS rozmiar,
        sklep.p.cena_sprzedaży AS cena_sprzedaży,
        s.ilość AS ilość,
        sklep.p.podkategoria AS podkategoria,
        sklep.p.kategoria AS kategoria
    FROM
        (sklep.sprzedaż s
        LEFT JOIN sklep.v_zamówienia z ON ((s.id_zamówienie = sklep.z.id_zamówienie)))
        LEFT JOIN sklep.v_produkty p ON ((s.id_produkt = sklep.p.id_produkt))
       WHERE kolor=pkolor and  rozmiar=prozmiar;
END$$
DELIMITER ;



   CALL sprzedazProduktKolorRozmiar('biały', 'xl');





-- ilość sprzedazy ogółem


DELIMITER $$
CREATE PROCEDURE sprzedazIlosc ()
BEGIN
	DECLARE iloscTotal INT;
	SELECT sum(ilość) as ilosć into iloscTotal from v_sprzedaż; 
	select iloscTotal;
END$$
DELIMITER ;

CALL sprzedazIlosc;



-- wartosc zakupów ogółem

DELIMITER $$
CREATE PROCEDURE sprzedazWartosc ()
BEGIN
	DECLARE wartoscTotal FLOAT ;
    select sum(ilość*cena_sprzedaży) as wartość into wartoscTotal from v_sprzedaż;
	select wartoscTotal;
END$$
DELIMITER ;


CALL sprzedazWartosc;



-- ilośc zakupów ogółem - parametr

DELIMITER $$
CREATE PROCEDURE sprzedazIloscParametr (OUT totalIlosc INT)
BEGIN
	SELECT sum(ilość)
	INTO totalIlosc
	FROM v_sprzedaż;
END$$
DELIMITER ;


CALL sprzedazIloscParametr(@totalIlosc);
SELECT @totalIlosc AS 'ilośc produktów';


-- wartość zakupów ogółem - parametr



DELIMITER $$
CREATE PROCEDURE sprzedazWartoscParametr (OUT totalWartosc INT)
BEGIN
	SELECT sum(ilość*cena_sprzedaży)
	INTO totalWartosc
	FROM v_sprzedaż;
END$$
DELIMITER ;


CALL sprzedazWartoscParametr(@totalwartosc);
SELECT @totalWartosc AS 'wartośc produktów';






-- ilośc i wartość sprzedaży wg kategorii i podkategorii

 SELECT distinct
	kategoria,podkategoria,
	SUM(ilość) OVER(PARTITION BY kategoria, podkategoria) AS liczba_produktów_wg_kategorii,
    SUM(ilość*cena_sprzedaży) OVER(PARTITION BY kategoria, podkategoria) AS wartosć_produktów_wg_kategorii
FROM v_sprzedaż_zamówienia
ORDER BY kategoria, podkategoria;


-- ilośc i wartość zakupów wg produktu 

 SELECT distinct
	produkt,
	SUM(ilość) OVER(PARTITION BY produkt) AS liczba_produktów,
	SUM(ilość*cena_sprzedaży) OVER(PARTITION BY produkt) AS wartosć_produktów
FROM v_sprzedaż_zamówienia;




-- top N produktów w kategorii -  ilości
    
DELIMITER $$
CREATE PROCEDURE sprzedazKategoriaIloscTopN(
	IN ile INT,
    IN pKategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
kategoria, podkategoria,produkt, ilość ,
DENSE_RANK() OVER( partition by kategoria ORDER BY ilość  DESC) AS ranking
 from v_sprzedaż_zamówienia  
 order by kategoria, ranking)
SELECT kategoria, produkt, ilość, ranking FROM cte1 
where cte1.ranking <=ile AND kategoria=pkategoria;
END$$
DELIMITER ;


CALL sprzedazKategoriaIloscTopN(2, 'odzież męska');


-- top N produków w podkategorii -  ilości
    
DELIMITER $$
CREATE PROCEDURE sprzedazPodkategoriaIloscTopN(
	IN ile INT,
    IN pPodkategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
kategoria, podkategoria,produkt, ilość ,
DENSE_RANK() OVER( partition by podkategoria ORDER BY ilość  DESC) AS ranking
 from v_sprzedaż_zamówienia  
 order by podkategoria, ranking)
SELECT podkategoria, produkt, ilość, ranking FROM cte1 
where cte1.ranking <=ile AND podkategoria=pPodkategoria;
END$$
DELIMITER ;

CALL sprzedazPodkategoriaIloscTopN(3, 'T-shirt');




-- top N produktów w kategorii -  wartości
    
DELIMITER $$
CREATE PROCEDURE sprzedazKategoriaWartoscTopN(
	IN ile INT,
    IN pKategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
kategoria, podkategoria,produkt, (ilość*cena_sprzedaży) as wartosc ,
DENSE_RANK() OVER( partition by kategoria ORDER BY (ilość*cena_sprzedaży) DESC) AS ranking
 from v_sprzedaż_zamówienia  
 order by kategoria, ranking)
SELECT kategoria, produkt,wartosc, ranking FROM cte1 
where cte1.ranking <=ile AND kategoria=pkategoria;
END$$
DELIMITER ;


CALL sprzedazKategoriaWartoscTopN(3, 'odzież męska');



-- top N produktów w podkategorii -  wartości
    
DELIMITER $$
CREATE PROCEDURE sprzedazPodkategoriaWartoscTopN(
	IN ile INT,
    IN pPodkategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
podkategoria,produkt, (ilość*cena_sprzedaży) as wartosc ,
DENSE_RANK() OVER( partition by podkategoria ORDER BY (ilość*cena_sprzedaży) DESC) AS ranking
 from v_sprzedaż_zamówienia   
 order by podkategoria, ranking)
SELECT podkategoria, produkt,wartosc, ranking FROM cte1 
where cte1.ranking <=ile AND podkategoria=pPodkategoria;
END$$
DELIMITER ;

CALL sprzedazPodkategoriaWartoscTopN(3, 'bokserki');



-- top  3 kategorii wg liczby produktów

 SELECT distinct
	kategoria,
	SUM(ilość) OVER(PARTITION BY kategoria) AS liczba_produktów
FROM v_sprzedaż_zamówienia
ORDER BY liczba_produktów desc limit 3;


-- top  3 podkategorii wg liczby produktów

 SELECT distinct
	podkategoria,
	SUM(ilość) OVER(PARTITION BY podkategoria) AS liczba_produktów
FROM v_sprzedaż_zamówienia
ORDER BY liczba_produktów desc limit 3;

--  top 10 produktów  wg liczby produktów

 SELECT distinct
	produkt,
	SUM(ilość) OVER(PARTITION BY produkt) AS liczba_produktów
FROM v_sprzedaż_zamówienia
ORDER BY liczba_produktów desc limit 10;



 -- procentowy udział wartości produktów
 
SELECT distinct
	produkt, SUM(ilość*cena_sprzedaży) OVER(PARTITION BY produkt) AS wartosć_produktów,
SUM(ilość*cena_sprzedaży) OVER(PARTITION BY produkt)/@totalWartosc*100 as proc_udział_w_całosci
FROM v_sprzedaż
order by  proc_udział_w_całosci desc;


-- procentowy udział ilości kategorii

SELECT distinct
	kategoria, SUM(ilość*cena_sprzedaży) OVER(PARTITION BY kategoria) AS wartosć_produktów, 
round(SUM(ilość*cena_sprzedaży) OVER(PARTITION BY kategoria)/@totalWartosc*100,2) as proc_udział_w_całosci
FROM v_sprzedaż_zamówienia
order by  proc_udział_w_całosci desc;

-- procentowy udział ilości podkategorii


SELECT distinct
	podkategoria, SUM(ilość*cena_sprzedaży) OVER(PARTITION BY podkategoria) AS wartosć_produktów, 
round(SUM(ilość*cena_sprzedaży) OVER(PARTITION BY podkategoria)/@totalWartosc*100,2) as proc_udział_w_całosci
FROM v_sprzedaż_zamówienia
order by  proc_udział_w_całosci desc;



 -- procentowy udział ilości produktów
 
SELECT distinct
	produkt, SUM(ilość) OVER(PARTITION BY produkt) AS wartosć_produktów,
SUM(ilość) OVER(PARTITION BY produkt)/@totalIlosc*100 as proc_udział_w_całosci
FROM v_sprzedaż
order by  proc_udział_w_całosci desc;


-- procentowy udział ilości kategorii

SELECT distinct
	kategoria, SUM(ilość) OVER(PARTITION BY kategoria) AS wartosć_produktów, 
round(SUM(ilość) OVER(PARTITION BY kategoria)/@totalIlosc*100,2) as proc_udział_w_całosci
FROM v_sprzedaż_zamówienia
order by  proc_udział_w_całosci desc;

-- procentowy udział ilości podkategorii


SELECT distinct
	podkategoria, SUM(ilość) OVER(PARTITION BY podkategoria) AS wartosć_produktów, 
round(SUM(ilość) OVER(PARTITION BY podkategoria)/@totalIlosc*100,2) as proc_udział_w_całosci
FROM v_sprzedaż_zamówienia
order by  proc_udział_w_całosci desc;




-- sprzedaż wg kwartałów ogółem

select distinct quarter(data_wysyłki) as kwartał,
   SUM(ilość) OVER(PARTITION BY quarter(data_wysyłki)) AS liczba_produktów,
  SUM(ilość*cena_sprzedaży) OVER(PARTITION BY quarter(data_wysyłki)) AS wartosć_produktów
    from
v_sprzedaż_zamówienia
order by kwartał;



-- sprzedaż wg produktów i  kwartałów

select distinct quarter(data_wysyłki) as kwartał,produkt, -- podkategoria, kategoria,
   SUM(ilość) OVER(PARTITION BY quarter(data_wysyłki), produkt) AS liczba_produktów,
  SUM(ilość*cena_sprzedaży) OVER(PARTITION BY quarter(data_wysyłki), produkt) AS wartosć_produktów
    from
v_sprzedaż_zamówienia
order by kwartał;


-- sprzedaż wg podkategorii i kwartałów

select distinct quarter(data_wysyłki) as kwartał, podkategoria, --  kategoria,
   SUM(ilość) OVER(PARTITION BY quarter(data_wysyłki), podkategoria) AS liczba_produktów,
  SUM(ilość*cena_sprzedaży) OVER(PARTITION BY quarter(data_wysyłki), podkategoria) AS wartosć_produktów
    from
v_sprzedaż_zamówienia
order by kwartał;

-- sprzedaż wg kategorii i kwartałów

select distinct quarter(data_wysyłki) as kwartał, kategoria,
   SUM(ilość) OVER(PARTITION BY quarter(data_wysyłki), kategoria) AS liczba_produktów,
  SUM(ilość*cena_sprzedaży) OVER(PARTITION BY quarter(data_wysyłki), kategoria) AS wartosć_produktów
    from
v_sprzedaż_zamówienia
order by kwartał;


-- wartośc sprzedaży wg formy dostawy 
select distinct forma_dostawy,
sum(ilość*cena_sprzedaży) over ( partition by forma_dostawy) as wartość_sprzedaży
 from v_sprzedaż_zamówienia
 order by wartość_sprzedaży desc;

-- wartośc sprzedaży wg kanału sprzedaży

select distinct kanał_sprzedaz,
sum(ilość*cena_sprzedaży) over ( partition by kanał_sprzedaz) as wartość_sprzedaży
 from v_sprzedaż_zamówienia
 order by wartość_sprzedaży desc;
 
 -- wartośc sprzedaży wg formy płatności

select distinct forma_płatności,
sum(ilość*cena_sprzedaży) over ( partition by forma_płatności) as wartość_sprzedaży
 from v_sprzedaż_zamówienia
 order by wartość_sprzedaży desc;
 
 -- wartośc sprzedaży wg  miasta dostawy
 
 select distinct miasto_dostawy,
sum(ilość*cena_sprzedaży) over ( partition by miasto_dostawy) as wartość_sprzedaży
 from v_sprzedaż_zamówienia
 order by wartość_sprzedaży desc;
 
 -- wartośc sprzedaży wg  typu klienta

 select distinct typ_klienta,
sum(ilość) over ( partition by typ_klienta) as wartość_sprzedaży
 from v_sprzedaż_zamówienia
 order by wartość_sprzedaży desc;
 

-- sprzedaż wg formy dostawy
select distinct forma_dostawy,
sum(ilość) over ( partition by forma_dostawy) as liczba_sprzedaży
 from v_sprzedaż_zamówienia
 order by liczba_sprzedaży desc;

-- sprzedaż wg kanału sprzedazy

select distinct kanał_sprzedaz,
sum(ilość) over ( partition by kanał_sprzedaz) as liczba_sprzedaży
 from v_sprzedaż_zamówienia
 order by liczba_sprzedaży desc;
 
 -- sprzedaż wg formy płatności

select distinct forma_płatności,
sum(ilość) over ( partition by forma_płatności) as liczba_sprzedaży
 from v_sprzedaż_zamówienia
 order by liczba_sprzedaży desc;
 
 -- sprzedaż wg  miasta dostawy
 
 select distinct miasto_dostawy,
sum(ilość) over ( partition by miasto_dostawy) as liczba_sprzedaży
 from v_sprzedaż_zamówienia
 order by liczba_sprzedaży desc;
 
 -- sprzedaż wg  typu klienta

 select distinct typ_klienta,
sum(ilość) over ( partition by typ_klienta) as liczba_sprzedaży
 from v_sprzedaż_zamówienia
 order by liczba_sprzedaży desc;





-- kategorie wg koloru - ilosci - tabela przestawna

SELECT 
    kategoria,
    SUM(CASE
        WHEN kolor = 'biały' THEN ilość
        ELSE 0
    END) AS 'biały',
    SUM(CASE
        WHEN kolor = 'bordowy' THEN ilość
        ELSE 0
    END) AS 'bordowy',
    SUM(CASE
        WHEN kolor = 'brązowy' THEN ilość
        ELSE 0
    END) AS 'brązowy',
    SUM(CASE
        WHEN kolor = 'czarny' THEN ilość
        ELSE 0
    END) AS 'czarny',
    SUM(CASE
        WHEN kolor = 'granatowy' THEN ilość
        ELSE 0
    END) AS 'granatowy',
    SUM(CASE
        WHEN kolor = 'niebieski' THEN ilość
        ELSE 0
    END) AS 'niebieski',
    SUM(CASE
        WHEN kolor = 'popiel' THEN ilość
        ELSE 0
    END) AS 'popielaty',
    SUM(CASE
        WHEN kolor = 'zielony' THEN ilość
        ELSE 0
    END) AS 'zielony'
FROM
    v_sprzedaż_zamówienia
GROUP BY kategoria;



-- podkategorie wg koloru - wartosci - tabela przestawna

SELECT 
    podkategoria,
    SUM(CASE
        WHEN kolor = 'biały' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'biały',
    SUM(CASE
        WHEN kolor = 'bordowy' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'bordowy',
    SUM(CASE
        WHEN kolor = 'brązowy' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'brązowy',
    SUM(CASE
        WHEN kolor = 'czarny' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'czarny',
    SUM(CASE
        WHEN kolor = 'granatowy' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'granatowy',
    SUM(CASE
        WHEN kolor = 'niebieski' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'niebieski',
    SUM(CASE
        WHEN kolor = 'popiel' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'popielaty',
    SUM(CASE
        WHEN kolor = 'zielony' THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'zielony'
FROM
    v_sprzedaż_zamówienia
GROUP BY podkategoria;

-- wartośc sprzedaży wg podkategori i kwartałów
 
SELECT 
    podkategoria,
    SUM(CASE
        WHEN QUARTER(data_wysyłki) = 1 THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'Q1',
    SUM(CASE
        WHEN QUARTER(data_wysyłki) = 2 THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'Q2',
    SUM(CASE
        WHEN QUARTER(data_wysyłki) = 3 THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'Q3',
    SUM(CASE
        WHEN QUARTER(data_wysyłki) = 4 THEN ilość
        ELSE 0
    END) * cena_sprzedaży AS 'Q4'
FROM
    v_sprzedaż_zamówienia
GROUP BY podkategoria;




-- sprzedaż wg koloru i rozmiaru - ilosci - tabela przestawna

DELIMITER $$
CREATE PROCEDURE sprzedazRozmiarKolorKategoria(IN pKategoria char(20))
BEGIN
SELECT 
	kategoria,podkategoria,rozmiar,
	sum(case WHEN kolor='biały' then ilość ELSE 0 END) as 'biały',
	sum(case WHEN kolor='bordowy' then ilość ELSE 0 END) as 'bordowy',
	sum(case WHEN kolor='brązowy' then ilość ELSE 0 END) as 'brązowy',
	sum(case WHEN kolor='czarny' then ilość ELSE 0 END) as 'czarny',
	sum(case WHEN kolor='granatowy' then ilość ELSE 0 END) as 'granatowy',
	sum(case WHEN kolor='niebieski' then ilość ELSE 0 END) as 'niebieski',
	sum(case WHEN kolor='popiel' then ilość ELSE 0 END) as 'popielaty',
	sum(case WHEN kolor='zielony' then ilość ELSE 0 END) as 'zielony'
    FROM
    v_sprzedaż_zamówienia
    group by rozmiar, podkategoria
having kategoria=pKategoria;
END$$
DELIMITER ;


   CALL sprzedazRozmiarKolorKategoria('spodnie');



-- sumy częsciowe wg kategorii i podkategorii - ilosci i wartości

SELECT 
    IF(GROUPING(kategoria) = 1,
        'RAZEM KATEGORIE',
        kategoria) AS Kategoria,
    IF(GROUPING(podkategoria) = 1,
        'suma podkategorii',
        podkategoria) AS podkategoria,
    SUM(ilość) AS ILOŚĆ,
    SUM(ilośĆ * cena_sprzedaży) AS WARTOŚĆ
FROM
    v_sprzedaż_zamówienia
GROUP BY kategoria , podkategoria WITH ROLLUP;



-- sumy częsciowe wg kategorii - ilości i wartości

SELECT 
    IF(GROUPING(kategoria) = 1,
        'RAZEM KATEGORIE',
        kategoria) AS Kategoria,
    SUM(ilość) AS ILOŚC,
    SUM(ilośĆ * cena_sprzedaży) AS WARTOŚĆ
FROM
    v_sprzedaż_zamówienia
GROUP BY kategoria WITH ROLLUP;
 
 
 







 