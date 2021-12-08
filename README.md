# :pushpin: Video-Rental-Shop-Data-Warehouse-Design

 :o: Prvi korak u projektovanju skladišta podataka jeste najpre upoznavanje i razumevanje sistema, kao i samih izvornih podataka, a zatim i identifikovanje poslovnih procesa u organizaciji i definisanje potreba krajnjeg korisnika. Jedna od najboljih tehnika za određivanje poslovne funkcije je odgovor na pitanja ko, gde, šta, zašto i kako je od poslovnog interesa za organizaciju. Naredni korak je prečišćavanje podataka kako ne bi došlo do nagomilavanja onih podataka koji nisu od značaja za izradu ovog projekta. Nakon ovog koraka slede koraci koji se odnose na rešavanje problema koji se tiču određivanja granularnosti, kao i tabela dimenzija i tabele činjenica. Tabele dimenzija sadrže deskriptivne tekstualne informacije, dok tabela činjenica sadrži kvantitativne podatke o poslovanju. Tabela činjenica bi trebalo da bude što je moguće detaljnije, što bi omogućilo da se podaci sagledaju iz najvećeg mogućeg broja perspektiva. Zatim je neophodno kreirati DDL naredbe uz pomoć kojih se kreiraju sve tabele dimenzija za tipove entiteta koji se nalaze u realnom sistemu, a zatim je neophodno i dodatno kreirati vremensku dimenziju. Nakon kreiranih tabela dimenzija potrebno je kreirati tabelu činjenica koja sadrži strane ključeve svih dimenzija.
 
 :o: Na narednoj fotografiji prikazan je tipičan dimenzioni model, odnosno OLAP (zvezda) šema koja sadrži tabelu činjenica *Rental_fact* koja je povezana sa više tabela dimenzija.
 
 ![29](https://user-images.githubusercontent.com/61964257/145215981-f37aa6bd-002b-49a9-8f79-2f49b4cff847.PNG)
 
:o: Na pitanje ko odgovara grupa koja uključuje tabele dimenzija *Staff* i *Customer*, dok na pitanje gde se događaj desio odgovara grupa koju čini dimenzija *Store*. Tabela dimenzija *Date* jeste zapravo kalendar koji se koristi za obeležavanje i datuma zakupa, kao i datuma povratka i odgovara na pitanje kada. Grupa koja odgovara na pitanja šta, zašto i kako se desio događaj uključuje 3 dimenzije i to dimenzije *Film*, *Category* i *Actor* koje predstavljaju predmet iznajmljivanja.

### :red_circle: Specifikacija zahtevanih mera

:o: Tabela činjenica sadži neke numeričke tipove poslovnih pokazatelja koji na neki način održavaju uspeh i to su:
1. *customer_rental_duration* - trajanje zakupa kupca u danima
2. *customer_exceeded* - broj prekoračenih dana kupca u zavisnosti od dozvoljenog trajanja zakupa
3. *customer_amount* - cena po iznajmljenom kupcu za određenog korisnika
4. *customer_overdraft_amount* - prekoračen iznos cene ukoliko film nije vraćen u dogovorenom roku
 
 
 
