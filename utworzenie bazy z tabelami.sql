CREATE DATABASE sklep;
use sklep;
CREATE TABLE adresy_dostawy
(
    id_adres_dostawy integer NOT NULL AUTO_INCREMENT,
    miasto varchar(25) ,
    ulica varchar(25) ,
    nr integer NOT NULL,
    uwagi varchar(25) ,
    CONSTRAINT pk_adresy_dostawy PRIMARY KEY (id_adres_dostawy)
);




CREATE TABLE formy_dostawy
(
    id_forma_dostawy integer NOT NULL AUTO_INCREMENT,
    forma_dostawy varchar(25),
    CONSTRAINT pk_formy_dostawy PRIMARY KEY (id_forma_dostawy)
);

CREATE TABLE formy_płatności
(
    id_forma_płatności integer NOT NULL AUTO_INCREMENT,
    forma_płatności varchar(12),
    CONSTRAINT pk_formy_płatności PRIMARY KEY (id_forma_płatności)
);



CREATE TABLE kanały_sprzedaży
(

    id_kanał integer NOT NULL AUTO_INCREMENT,
    kanał_sprzedaz varchar(25),
    CONSTRAINT pk_kanały_sprzedaży PRIMARY KEY (id_kanał)
);

CREATE TABLE kategorie
(
    id_kategoria integer NOT NULL AUTO_INCREMENT,
    kategoria varchar(25),
    CONSTRAINT pk_kategoria PRIMARY KEY (id_kategoria)
);


CREATE TABLE klienci
(
    id_klient integer NOT NULL AUTO_INCREMENT,
    data_rejestracji date,
    imie varchar(12),
    nazwisko varchar(12),
    nazwa varchar(255),
    e_mail varchar(45),
    telefon integer NOT NULL,
    id_typ_klienta integer NOT NULL,
    CONSTRAINT pk_klienci PRIMARY KEY (id_klient)
);


   
 CREATE TABLE podkategorie
(
    id_podkategoria integer NOT NULL AUTO_INCREMENT,
    podkategoria varchar(25),
    id_kategoria integer NOT NULL,
    CONSTRAINT pk_podkategoria PRIMARY KEY (id_podkategoria)
 );
   
  
   
   
 CREATE TABLE produkty
(
    id_produkt integer NOT NULL AUTO_INCREMENT,
    kod_produkt varchar(12),
    produkt varchar(45),
    kolor varchar(12),
    rozmiar varchar(5),
    cena_sprzedaży decimal(10,2),
    id_podkategoria integer NOT NULL,
    CONSTRAINT pk_produkty PRIMARY KEY (id_produkt)
)  ;

   
   
  CREATE TABLE sprzedaż
(
    id_sprzedaż integer NOT NULL AUTO_INCREMENT,
    id_zamówienie integer NOT NULL,
    id_produkt integer NOT NULL,
    ilość integer NOT NULL,
    CONSTRAINT pk_sprzedaż PRIMARY KEY (id_sprzedaż)
) ;
   
  
  
  
 CREATE TABLE typy_klientów
(
    id_typ_klienta integer NOT NULL AUTO_INCREMENT,
    typ_klienta varchar(15),
    CONSTRAINT pk_typy_klientów PRIMARY KEY (id_typ_klienta)
) ;
  
  
 
  
  
  CREATE TABLE zakupy
(
    id_zakup integer NOT NULL AUTO_INCREMENT,
    id_produkt integer NOT NULL,
    ilość integer NOT NULL,
    cena_zakupu numeric(10,2),
    CONSTRAINT pk_zakupy PRIMARY KEY (id_zakup)
);

  
  
  
  
CREATE TABLE zamówienia
(
    id_zamówienie integer NOT NULL AUTO_INCREMENT,
    id_klient integer NOT NULL,
    data_zamówienia date,
    data_wysyłki date,
    data_odbioru date,
    id_forma_płatności integer NOT NULL,
    id_kanał integer NOT NULL,
    id_forma_dostawy integer NOT NULL,
    data_zapłaty date,
    id_adres_dostawy integer NOT NULL,
    CONSTRAINT pk_zamówienia PRIMARY KEY (id_zamówienie)
);
  
  
  