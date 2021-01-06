
use sklep;

-- produkty wg koloru i rozmiaru


DELIMITER $$
CREATE PROCEDURE zakupyProduktKolorRozmiar (
	IN pkolor char(20),
    IN prozmiar char(20))
BEGIN
SELECT 
        p.id_produkt AS id_produkt,
        p.produkt AS produkt,
        p.kolor AS kolor,
        p.rozmiar AS rozmiar,
        p.cena_sprzedaży AS cena_sprzedaży,
        pod.podkategoria AS podkategoria,
        k.kategoria AS kategoria
    FROM
        (sklep.produkty p
        LEFT JOIN sklep.podkategorie pod ON ((p.id_podkategoria = pod.id_podkategoria)))
        LEFT JOIN sklep.kategorie k ON ((pod.id_kategoria = k.id_kategoria))
        WHERE kolor=pkolor and  rozmiar=prozmiar;
END$$
DELIMITER ;


CALL zakupyProduktKolorRozmiar('biały', 'xl');



-- ilość zakupów ogółem


DELIMITER $$
CREATE PROCEDURE zakupyIlosc ()
BEGIN
	DECLARE iloscTotal INT;
	SELECT sum(ilość) as ilosć into iloscTotal from zakupy; 
	select iloscTotal;
END$$
DELIMITER ;

CALL zakupyIlosc;



-- wartosc zakupów ogółem

DELIMITER $$
CREATE PROCEDURE zakupyWartosc ()
BEGIN
	DECLARE wartoscTotal FLOAT ;
    select sum(ilość*cena_zakupu) as wartość into wartoscTotal from zakupy;
	select wartoscTotal;
END$$
DELIMITER ;

CALL zakupyWartosc;


-- ilośc zakupów ogółem - parametr

DELIMITER $$
CREATE PROCEDURE zakupyIloscParametr (OUT totalIlosc INT)
BEGIN
	SELECT sum(ilość)
	INTO totalIlosc
	FROM zakupy;
END$$
DELIMITER ;


CALL zakupyIloscParametr(@totalIlosc);
SELECT @totalIlosc as 'ilośc produktów';


-- wartość zakupów ogółem - parametr



DELIMITER $$
CREATE PROCEDURE zakupyWartoscParametr (OUT totalWartosc INT)
BEGIN
	SELECT sum(ilość*cena_zakupu)
	INTO totalWartosc
	FROM zakupy;
END$$
DELIMITER ;


CALL zakupyWartoscParametr(@totalwartosc);
SELECT @totalWartosc as 'wartośc produktów';



-- ilośc i wartość zakupów wg kategorii i podkategorii

 SELECT distinct
	kategoria,podkategoria,
	SUM(ilość) OVER(PARTITION BY kategoria, podkategoria) AS liczba_produktów_wg_kategorii,
    SUM(ilość*cena_zakupu) OVER(PARTITION BY kategoria, podkategoria) AS wartosć_produktów_wg_kategorii
FROM v_zakupy
ORDER BY kategoria, podkategoria;


-- ilośc i wartość zakupów wg produktu 

 SELECT distinct
	produkt,
	SUM(ilość) OVER(PARTITION BY produkt) AS liczba_produktów,
	SUM(ilość*cena_zakupu) OVER(PARTITION BY produkt) AS wartosć_produktów
FROM v_zakupy;




-- top N produktów w kategorii -  ilości
    
DELIMITER $$
CREATE PROCEDURE kategoriaIloscTopN(
	IN ile INT,
    IN pKategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
kategoria, podkategoria,produkt, ilość ,
DENSE_RANK() OVER( partition by kategoria ORDER BY ilość  DESC) AS ranking
 from v_zakupy  
 order by kategoria, ranking)
SELECT kategoria, produkt, ilość, ranking FROM cte1 
where cte1.ranking <=ile AND kategoria=pkategoria;
END$$
DELIMITER ;


CALL kategoriaIloscTopN(2, 'odzież męska');


-- top N produktów w podkategorii -  ilości
    
DELIMITER $$
CREATE PROCEDURE podkategoriaIloscTopN(
	IN ile INT,
    IN pPodkategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
kategoria, podkategoria,produkt, ilość ,
DENSE_RANK() OVER( partition by podkategoria ORDER BY ilość  DESC) AS ranking
 from v_zakupy  
 order by podkategoria, ranking)
SELECT podkategoria, produkt, ilość, ranking FROM cte1 
where cte1.ranking <=ile AND podkategoria=pPodkategoria;
END$$
DELIMITER ;

CALL podkategoriaIloscTopN(3, 'T-shirt');



-- top N produktów w kategorii -  wartość
    
DELIMITER $$
CREATE PROCEDURE kategoriaWartoscTopN(
	IN ile INT,
    IN pKategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
kategoria, podkategoria,produkt, (ilość*cena_zakupu) as wartosc ,
DENSE_RANK() OVER( partition by kategoria ORDER BY (ilość*cena_zakupu) DESC) AS ranking
 from v_zakupy  
 order by kategoria, ranking)
SELECT kategoria, produkt,wartosc, ranking FROM cte1 
where cte1.ranking <=ile AND kategoria=pkategoria;
END$$
DELIMITER ;


CALL kategoriaWartoscTopN(3, 'odzież męska');



-- top N produktów w podkategorii -  wartości
    
DELIMITER $$
CREATE PROCEDURE podkategoriaWartoscTopN(
	IN ile INT,
    IN pPodkategoria char(20))
BEGIN
WITH
cte1 AS (select distinct
podkategoria,produkt, (ilość*cena_zakupu) as wartosc ,
DENSE_RANK() OVER( partition by podkategoria ORDER BY (ilość*cena_zakupu) DESC) AS ranking
 from v_zakupy  
 order by podkategoria, ranking)
SELECT podkategoria, produkt,wartosc, ranking FROM cte1 
where cte1.ranking <=ile AND podkategoria=pPodkategoria;
END$$
DELIMITER ;


CALL podkategoriaWartoscTopN(3, 'bokserki');



-- top  3 kategorii wg liczby produktów

 SELECT distinct
	kategoria,
	SUM(ilość) OVER(PARTITION BY kategoria) AS liczba_produktów
FROM v_zakupy
ORDER BY liczba_produktów desc limit 3;


-- top  3 podkategorii wg liczby produktów

 SELECT distinct
	podkategoria,
	SUM(ilość) OVER(PARTITION BY podkategoria) AS liczba_produktów
FROM v_zakupy
ORDER BY liczba_produktów desc limit 3;

--  top 10 produktów  wg liczby produktów

 SELECT distinct
	produkt,
	SUM(ilość) OVER(PARTITION BY produkt) AS liczba_produktów
FROM v_zakupy
ORDER BY liczba_produktów desc limit 10;




 -- procentowy udział wartosci produktów 
 
SELECT distinct
	produkt, SUM(ilość*cena_zakupu) OVER(PARTITION BY produkt) AS wartosć_produktów,
SUM(ilość*cena_zakupu) OVER(PARTITION BY produkt)/@totalWartosc*100 as proc_udział_w_całosci
FROM v_zakupy
order by  proc_udział_w_całosci desc;


-- procentowy udział wartosci kategorii 

SELECT distinct
	kategoria, SUM(ilość*cena_zakupu) OVER(PARTITION BY kategoria) AS wartosć_produktów, 
round(SUM(ilość*cena_zakupu) OVER(PARTITION BY kategoria)/@totalWartosc*100,2) as proc_udział_w_całosci
FROM v_zakupy
order by  proc_udział_w_całosci desc;

-- procentowy udział wartosci podkategorii


SELECT distinct
	podkategoria, SUM(ilość*cena_zakupu) OVER(PARTITION BY podkategoria) AS wartosć_produktów, 
round(SUM(ilość*cena_zakupu) OVER(PARTITION BY podkategoria)/@totalWartosc*100,2) as proc_udział_w_całosci
FROM v_zakupy
order by  proc_udział_w_całosci desc;


 -- procentowy udział ilości produktów
 
SELECT distinct
	produkt, SUM(ilość) OVER(PARTITION BY produkt) AS wartosć_produktów,
SUM(ilość) OVER(PARTITION BY produkt)/@totalIlosc*100 as proc_udział_w_całosci
FROM v_zakupy
order by  proc_udział_w_całosci desc;


-- procentowy udział ilości kategorii

SELECT distinct
	kategoria, SUM(ilość) OVER(PARTITION BY kategoria) AS wartosć_produktów, 
round(SUM(ilość) OVER(PARTITION BY kategoria)/@totalIlosc*100,2) as proc_udział_w_całosci
FROM v_zakupy
order by  proc_udział_w_całosci desc;

-- procentowy udział ilości  podkategorii 


SELECT distinct
	podkategoria, SUM(ilość) OVER(PARTITION BY podkategoria) AS wartosć_produktów, 
round(SUM(ilość) OVER(PARTITION BY podkategoria)/@totalIlosc*100,2) as proc_udział_w_całosci
FROM v_zakupy
order by  proc_udział_w_całosci desc;




-- kategorie wg koloru - ilości - tabela przestawna

select kategoria,
sum(case WHEN kolor='biały' then ilość ELSE 0 END) as 'biały',
sum(case WHEN kolor='bordowy' then ilość ELSE 0 END) as 'bordowy',
sum(case WHEN kolor='brązowy' then ilość ELSE 0 END) as 'brązowy',
sum(case WHEN kolor='czarny' then ilość ELSE 0 END) as 'czarny',
sum(case WHEN kolor='granatowy' then ilość ELSE 0 END) as 'granatowy',
sum(case WHEN kolor='niebieski' then ilość ELSE 0 END) as 'niebieski',
sum(case WHEN kolor='popiel' then ilość ELSE 0 END) as 'popielaty',
sum(case WHEN kolor='zielony' then ilość ELSE 0 END) as 'zielony'
from v_zakupy
group by kategoria;



-- podkategorie wg koloru - wartości - tabela przestawna

select podkategoria,
sum(case WHEN kolor='biały' then ilość ELSE 0 END)* cena_zakupu as 'biały',
sum(case WHEN kolor='bordowy' then ilość ELSE 0 END)* cena_zakupu as 'bordowy',
sum(case WHEN kolor='brązowy' then ilość ELSE 0 END)* cena_zakupu as 'brązowy',
sum(case WHEN kolor='czarny' then ilość ELSE 0 END)* cena_zakupu as 'czarny',
sum(case WHEN kolor='granatowy' then ilość ELSE 0 END)* cena_zakupu as 'granatowy',
sum(case WHEN kolor='niebieski' then ilość ELSE 0 END)* cena_zakupu as 'niebieski',
sum(case WHEN kolor='popiel' then ilość ELSE 0 END) * cena_zakupu as 'popielaty',
sum(case WHEN kolor='zielony' then ilość ELSE 0 END) * cena_zakupu as 'zielony'
from v_zakupy
group by podkategoria;



-- kategorie wg koloru i rozmiaru - ilosci - tabela przestawna

DELIMITER $$
CREATE PROCEDURE zakupyRozmiarKolorKategoria(IN pKategoria char(20))
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
    v_zakupy
    group by rozmiar, podkategoria
having kategoria=pKategoria;
END$$
DELIMITER ;


   CALL zakupyRozmiarKolorKategoria('spodnie');



-- sumy częsciowe wg kategorii i podkategorii - ilosci i wartości

 SELECT 
 IF(GROUPING(kategoria)=1,'RAZEM KATEGORIE', kategoria) as Kategoria, 
 IF(GROUPING(podkategoria)=1, 'suma podkategorii', podkategoria) as podkategoria, 
 SUM(ilość) as ILOŚĆ,
 sum(ilośĆ*cena_zakupu) as WARTOŚĆ
 FROM v_zakupy
 GROUP BY kategoria,podkategoria
 WITH ROLLUP;


-- sumy częsciowe wg kategorii - ilości i wartości

 SELECT  IF(GROUPING(kategoria)=1,'RAZEM KATEGORIE', kategoria) as Kategoria, 
 SUM(ilość) as ILOŚC,
  sum(ilośĆ*cena_zakupu) as WARTOŚĆ
 FROM v_zakupy
 GROUP BY kategoria
 WITH ROLLUP;
 
 
 
