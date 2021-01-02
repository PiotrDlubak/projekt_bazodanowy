-- tworzenie widoków do celeów analitycznych
use sklep;

create view v_produkty as (
  select
    p.id_produkt,
    p.produkt,
    p.kolor,
    p.rozmiar,
    p.cena_sprzedaży,
    pod.podkategoria,
    k.kategoria
  from
    produkty p
    left join podkategorie pod on p.id_podkategoria = pod.id_podkategoria
    left join kategorie k on pod.id_kategoria = k.id_kategoria
);

create view v_zakupy as (
  select
    p.id_produkt,
    p.produkt,
    p.kolor,
    p.rozmiar,
    p.cena_sprzedaży,
    p.podkategoria,
    p.kategoria,
    z.ilość,
    z.cena_zakupu
  from
    v_produkty p
    left join zakupy z on p.id_produkt = z.id_produkt
);

create view v_zamówienia as (
  select
    z.id_zamówienie,
    z.id_klient,
    z.data_zamówienia,
    z.data_wysyłki,
    z.data_odbioru,
    d.forma_dostawy,
    k.kanał_sprzedaz,
    p.forma_płatności,
    a.miasto as miasto_dostawy
  from
    zamówienia z
    left join formy_dostawy d on z.id_forma_dostawy = d.id_forma_dostawy
    left join kanały_sprzedaży k on z.id_kanał = k.id_kanał
    left join formy_płatności p on z.id_forma_płatności = p.id_forma_płatności
    left join adresy_dostawy a on z.id_adres_dostawy = a.id_adres_dostawy
);

create view v_klienci as (
  select
    k.id_klient,
    k.data_rejestracji,
    k.imie,
    k.nazwisko,
    k.nazwa,
    k.e_mail,
    k.telefon,
    t.typ_klienta
  from
    klienci k
    left join typy_klientów t on k.id_typ_klienta = t.id_typ_klienta
);


create view v_sprzedaż as (
   select
    z.id_zamówienie,
    p.produkt,
    p.kolor,
    p.rozmiar,
    p.cena_sprzedaży,
    s.ilość,
	s.id_produkt
from sprzedaż s
left join v_zamówienia z on s.id_zamówienie=z.id_zamówienie
left join v_produkty p on s.id_produkt=p.id_produkt

);

create view v_sprzedaż2 as (
   select
   s.id_sprzedaż,
    z.id_zamówienie,
    p.produkt,
    p.kolor,
    p.rozmiar,
    p.cena_sprzedaży,
    s.ilość,
    p.podkategoria,
	p.kategoria
from sprzedaż s
left join v_zamówienia z on s.id_zamówienie=z.id_zamówienie
left join v_produkty p on s.id_produkt=p.id_produkt
  );


  
  
  create view v_statystyki_zakupy as(
 SELECT distinct
	produkt, podkategoria, kategoria,
	SUM(ilość) OVER(PARTITION BY produkt,kategoria, podkategoria) AS liczba_produktów,
	SUM(ilość*cena_zakupu) OVER(PARTITION BY produkt,kategoria,podkategoria) AS wartosć_produktów,
    SUM(ilość) OVER() AS liczba_produktów_razem,
    SUM(ilość*cena_zakupu) OVER() AS wartosć_produktów_ogółem,
    SUM(ilość) OVER(PARTITION BY kategoria, podkategoria) AS liczba_produktów_podkategorii,
	SUM(ilość*cena_zakupu) OVER(PARTITION BY kategoria,podkategoria) AS wartosć_produktów_podkategorii,
    SUM(ilość) OVER(PARTITION BY kategoria) AS liczba_produktów_kategorii,
	SUM(ilość*cena_zakupu) OVER(PARTITION BY kategoria) AS wartosć_produktów_kategorii
FROM v_zakupy v
ORDER BY kategoria);
  
  
      
create view v_sprzedaż_zamówienia as(
 SELECT distinct 
	s.id_sprzedaż,
	z.id_zamówienie,
	s.produkt,
	s.kolor,
	s.rozmiar,
	s.cena_sprzedaży,
	s.ilość,
	s.podkategoria,
	s.kategoria,
	z.id_klient,
	z.data_zamówienia,
	z.data_wysyłki,
	z.data_odbioru,
	z.forma_dostawy,
	z.kanał_sprzedaz,
	z.forma_płatności,
	z.miasto_dostawy,
	k.typ_klienta
 FROM v_sprzedaż2 s
    left join v_zamówienia z on s.id_zamówienie=z.id_zamówienie
    left join v_klienci k on z.id_klient=k.id_klient

ORDER BY id_sprzedaż);

  
  
  
create view v_statystyki_sprzedaż as(
select distinct produkt, podkategoria, kategoria,
   SUM(ilość) OVER(PARTITION BY produkt,kategoria, podkategoria) AS liczba_produktów,
	SUM(ilość*cena_sprzedaży) OVER(PARTITION BY produkt,kategoria,podkategoria) AS wartosć_produktów,
    SUM(ilość) OVER() AS liczba_produktów_razem,
    SUM(ilość*cena_sprzedaży) OVER() AS wartosć_produktów_ogółem,
    SUM(ilość) OVER(PARTITION BY kategoria, podkategoria) AS liczba_produktów_podkategorii,
	SUM(ilość*cena_sprzedaży) OVER(PARTITION BY kategoria,podkategoria) AS wartosć_produktów_podkategorii,
    SUM(ilość) OVER(PARTITION BY kategoria) AS liczba_produktów_kategorii,
	SUM(ilość*cena_sprzedaży) OVER(PARTITION BY kategoria) AS wartosć_produktów_kategorii
    from
v_sprzedaż_zamówienia);



  
  
  
  
  
  
  
  