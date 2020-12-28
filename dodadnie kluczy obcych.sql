
use sklep;

  

-- dodatnie kluczy obcych


ALTER TABLE klienci
  ADD CONSTRAINT fk_klient_typ FOREIGN KEY (id_typ_klienta) REFERENCES typy_klientów (id_typ_klienta);

ALTER TABLE podkategorie
  ADD CONSTRAINT fk_podkategoria_kategoria FOREIGN KEY (id_kategoria) REFERENCES kategorie (id_kategoria);

ALTER TABLE produkty
  ADD CONSTRAINT fk_produkt_podkategoria FOREIGN KEY (id_podkategoria) REFERENCES podkategorie (id_podkategoria);

ALTER TABLE sprzedaż
  ADD CONSTRAINT fk_sprzedaz_produkt FOREIGN KEY (id_produkt) REFERENCES produkty (id_produkt),
  ADD CONSTRAINT fk_sprzedaz_zam FOREIGN KEY (id_zamówienie) REFERENCES zamówienia (id_zamówienie);
 
ALTER TABLE zakupy
  ADD CONSTRAINT fk_zakupy_prod FOREIGN KEY (id_produkt) REFERENCES produkty (id_produkt);
 
ALTER TABLE zamówienia
  ADD CONSTRAINT fk_zamowienia_adres FOREIGN KEY (id_adres_dostawy) REFERENCES adresy_dostawy (id_adres_dostawy),
  ADD CONSTRAINT fk_zamowienia_dostawy FOREIGN KEY (id_forma_dostawy) REFERENCES formy_dostawy (id_forma_dostawy),
  ADD CONSTRAINT fk_zamowienia_kanal FOREIGN KEY (id_kanał) REFERENCES kanały_sprzedaży (id_kanał),
  ADD CONSTRAINT fk_zamowienia_klient FOREIGN KEY (id_klient) REFERENCES klienci (id_klient),
  ADD CONSTRAINT fk_zamowienia_płatnosc FOREIGN KEY (id_forma_płatności) REFERENCES formy_płatności (id_forma_płatności);
  



 -- tworzenie indexów


CREATE INDEX idx_adresy_dostawy ON adresy_dostawy (id_adres_dostawy);
CREATE INDEX idx_formy_dostawy ON formy_dostawy(id_forma_dostawy);
CREATE INDEX idx_formy_płatności ON formy_płatności(id_forma_płatności);
CREATE INDEX idx_kanały_sprzedaży ON kanały_sprzedaży(id_kanał);
CREATE INDEX idx_kategorie ON kategorie(id_kategoria);
CREATE INDEX idx_klienci ON klienci (id_klient);
CREATE INDEX idx_podkategorie ON podkategorie(id_podkategoria);
CREATE INDEX idx_produkty ON produkty(id_produkt);
CREATE INDEX idx_sprzedaż ON sprzedaż(id_sprzedaż);
CREATE INDEX idx_typy_klientów ON typy_klientów(id_typ_klienta);
CREATE INDEX idx_zakupy ON zakupy (id_zakup);
CREATE INDEX idx_zamówienia ON zamówienia(id_zamówienie);

