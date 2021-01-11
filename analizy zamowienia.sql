
-- ANALIZA ZAMÓWIEŃ

use sklep;




-- liczba zamówień
select distinct  count(id_zamówienie) as liczba_zamowień
    from zamówienia;

-- liczba zamóweień wg kwartałów
select distinct quarter(data_zamówienia) as kwartał,
count(id_zamówienie) OVER(PARTITION BY quarter(data_zamówienia)) as liczba_zamowień
    from zamówienia;
    
    
-- zamówienia wg formy dostawy
select distinct forma_dostawy,
count(id_zamówienie) over ( partition by forma_dostawy) as liczba_zamówień
 from v_zamówienia
 order by liczba_zamówień desc;

-- zamówienia wg kanału sprzedazy

select distinct kanał_sprzedaz,
count(id_zamówienie) over ( partition by kanał_sprzedaz) as liczba_zamówień
 from v_zamówienia
 order by liczba_zamówień desc;
 
 -- zamówienia wg płatności

select distinct forma_płatności,
count(id_zamówienie) over ( partition by forma_płatności) as liczba_zamówień
 from v_zamówienia
 order by liczba_zamówień desc;
 
 -- zamówienia wg  miasta dostawy
 
 select distinct miasto_dostawy,
count(id_zamówienie)over ( partition by miasto_dostawy) as liczba_zamówień
 from v_zamówienia
 order by liczba_zamówień desc;
 
 
 -- czas oczekiwania na realizację zamówienia (wysyłka) i dostarczenia towaru
 
select id_zamówienie,
DATEDIFF(data_wysyłki,data_zamówienia) as liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia,
DATEDIFF(data_odbioru,data_zamówienia) as liczba_dni_oczekiwania_na_odbiór_od_zamówienia,
DATEDIFF(data_odbioru,data_wysyłki) as liczba_dni_oczekiwania_na_odbiór_od_wysyłki
from v_zamówienia;

-- max, min średnia liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia,

WITH
  cte1 AS (select distinct
DATEDIFF(data_wysyłki,data_zamówienia) as liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia
from v_zamówienia)
SELECT max(liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia) as max_liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia,
min(liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia) as min_liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia,
round(avg(liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia),1) as średnia_liczba_dni_oczekiwania_na_wysyłkę_od_zamówienia
FROM cte1 ;

-- max, min średnia liczba_dni_oczekiwania_na_odtrzymanie_od_zamówienia,

WITH
  cte1 AS (select distinct
DATEDIFF(data_odbioru,data_zamówienia) as liczba_dni_oczekiwania_na_odbiór_od_zamówienia
from v_zamówienia)
SELECT max(liczba_dni_oczekiwania_na_odbiór_od_zamówienia) as max_liczba_dni_oczekiwania_na_odbiór_od_zamówienia,
min(liczba_dni_oczekiwania_na_odbiór_od_zamówienia) as min_liczba_dni_oczekiwania_na_odbiór_od_zamówienia,
round(avg(liczba_dni_oczekiwania_na_odbiór_od_zamówienia),1) as średnia_liczba_dni_oczekiwania_na_odbiór_od_zamówienia
FROM cte1 ;

-- wartosć sprzedaży narastająco

select distinct
month(data_wysyłki) as m_c, sum(ilość*cena_sprzedaży) as suma,
sum(sum(ilość*cena_sprzedaży)) over (order by month(data_wysyłki) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sprzedaż_skumulowana
from v_sprzedaż_zamówienia
group by month(data_wysyłki)
order by month(data_wysyłki);

-- zmiany wartości sprzedaży w czasie 

select distinct
month(data_wysyłki) as m_c, 
sum(ilość*cena_sprzedaży) as suma, 
lag(sum(ilość*cena_sprzedaży)) over (order by month(data_wysyłki)) as suma_poprzednia,
round((sum(ilość*cena_sprzedaży)/lag(sum(ilość*cena_sprzedaży)) over (order by month(data_wysyłki))-1)*100,2) as procent_zmiany,
case 
when round((sum(ilość*cena_sprzedaży)/lag(sum(ilość*cena_sprzedaży)) over (order by month(data_wysyłki))-1)*100,2)>0 then 'wzrost'
when round((sum(ilość*cena_sprzedaży)/lag(sum(ilość*cena_sprzedaży)) over (order by month(data_wysyłki))-1)*100,2)<0 then 'spadek'
when round((sum(ilość*cena_sprzedaży)/lag(sum(ilość*cena_sprzedaży)) over (order by month(data_wysyłki))-1)*100,2)=0 then 'b/z'
else null
end as zmiana
from v_sprzedaż_zamówienia
group by month(data_wysyłki)
order by month(data_wysyłki);

