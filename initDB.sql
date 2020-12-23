CREATE DATABASE "ElectricityUsers";
CREATE SCHEMA public;

CREATE TABLE "Clients" (
  "ClientId" SERIAL PRIMARY KEY,
  "FirstName" varchar,
  "LastName" varchar,
  "PaymentDetailsId" int,
  "BirthDate" date,
  "Registration" varchar
);

CREATE TABLE "Cities" (
  "CityId" SERIAL PRIMARY KEY,
  "Name" varchar
);

CREATE TABLE "RealEstate" (
  "RealEstateId" SERIAL PRIMARY KEY,
  "ClientId" int,
  "Address" varchar,
  "LivingSpace" int
);

CREATE TABLE "PersonalAccounts" (
  "PersonalAccountId" SERIAL PRIMARY KEY,
  "RealEstateId" int,
  "Balance" money,
  "ClientId" int,
  "EnergyCounterId" int
);

CREATE TABLE "MonthlyInvoices" (
  "InvoiceId" SERIAL PRIMARY KEY,
  "CreatedAt" date,
  "EnergyUsed" int,
  "Total" money GENERATED ALWAYS AS ( "EnergyUsed" * 2.25 ) STORED,
  "PaymentDate" date,
  "CreatedBy" int,
  "RealEstateId" int,
  "PaymentDetailsId" int,
  "EnergyCounterId" int
);

CREATE TABLE "EnergyCounters" (
  "EnergyCounterId" SERIAL PRIMARY KEY,
  "LastCheckDate" date,
  "Model" varchar
);

CREATE TABLE "Offices" (
  "OfficeId" SERIAL PRIMARY KEY,
  "Address" varchar,
  "CityId" int
);

CREATE TABLE "PaymentDetails" (
  "PaymentDetailsId" SERIAL PRIMARY KEY,
  "CardNumber" varchar,
  "ExpirationDate" varchar,
  "Bank" varchar
);

CREATE TABLE "ClientsOffices" (
  "OfficeId" int,
  "ClientId" int,
  PRIMARY KEY ("OfficeId", "ClientId")
);

CREATE TABLE "Employees" (
  "EmployeeId" SERIAL PRIMARY KEY,
  "FirstName" varchar,
  "LastName" varchar,
  "BirthDate" date,
  "HireDate" date,
  "OfficeId" int,
  "Title" varchar,
  "Sex" char,
  "Address" varchar,
  "Phone" varchar,
  "ReportsTo" int
);

ALTER TABLE "Clients" ADD FOREIGN KEY ("PaymentDetailsId") REFERENCES "PaymentDetails" ("PaymentDetailsId") ON DELETE CASCADE;

ALTER TABLE "RealEstate" ADD FOREIGN KEY ("ClientId") REFERENCES "Clients" ("ClientId") ON DELETE CASCADE;

ALTER TABLE "PersonalAccounts" ADD FOREIGN KEY ("RealEstateId") REFERENCES "RealEstate" ("RealEstateId") ON DELETE CASCADE;

ALTER TABLE "PersonalAccounts" ADD FOREIGN KEY ("ClientId") REFERENCES "Clients" ("ClientId") ON DELETE CASCADE;

ALTER TABLE "PersonalAccounts" ADD FOREIGN KEY ("EnergyCounterId") REFERENCES "EnergyCounters" ("EnergyCounterId") ON DELETE CASCADE;

ALTER TABLE "MonthlyInvoices" ADD FOREIGN KEY ("CreatedBy") REFERENCES "Employees" ("EmployeeId") ON DELETE CASCADE;

ALTER TABLE "MonthlyInvoices" ADD FOREIGN KEY ("RealEstateId") REFERENCES "RealEstate" ("RealEstateId") ON DELETE CASCADE;

ALTER TABLE "MonthlyInvoices" ADD FOREIGN KEY ("PaymentDetailsId") REFERENCES "PaymentDetails" ("PaymentDetailsId") ON DELETE CASCADE;

ALTER TABLE "MonthlyInvoices" ADD FOREIGN KEY ("EnergyCounterId") REFERENCES "EnergyCounters" ("EnergyCounterId") ON DELETE CASCADE;

ALTER TABLE "Offices" ADD FOREIGN KEY ("CityId") REFERENCES "Cities" ("CityId") ON DELETE CASCADE;

ALTER TABLE "ClientsOffices" ADD FOREIGN KEY ("OfficeId") REFERENCES "Offices" ("OfficeId") ON DELETE CASCADE;

ALTER TABLE "ClientsOffices" ADD FOREIGN KEY ("ClientId") REFERENCES "Clients" ("ClientId") ON DELETE CASCADE;

ALTER TABLE "Employees" ADD FOREIGN KEY ("OfficeId") REFERENCES "Offices" ("OfficeId") ON DELETE CASCADE;

ALTER TABLE "Employees" ADD FOREIGN KEY ("ReportsTo") REFERENCES "Employees" ("EmployeeId") ON DELETE CASCADE;

INSERT INTO "Cities" ("Name")
SELECT 'Kiev'
UNION ALL SELECT 'Odessa'
UNION ALL SELECT 'Kharkiv'
UNION ALL SELECT 'Herson'
UNION ALL SELECT 'Lviv'
UNION ALL SELECT 'Cherkasy'
UNION ALL SELECT 'Dnipro'
UNION ALL SELECT 'Donetsk'
UNION ALL SELECT 'Zaporizhzhia'
UNION ALL SELECT 'Kryvyi Rih';

INSERT INTO "Offices" ("Address", "CityId")
SELECT 'Kurbasa ave. 4B', 1
UNION ALL SELECT 'Klavdiivska St. 40G', 2
UNION ALL SELECT 'Heroiv Dnipra St. 37', 3
UNION ALL SELECT 'Akhmatovoi St. 4', 4
UNION ALL SELECT 'Lomonosova St. 60/5', 5
UNION ALL SELECT 'Kharkivs''ke Hwy, 144B', 6
UNION ALL SELECT 'vul. Miry 40', 7
UNION ALL SELECT 'st. Svyatoyurievskaya 11A', 8
UNION ALL SELECT 'Radunska St 13', 9
UNION ALL SELECT 'vul. Derybasivska 3', 10;

INSERT INTO "Employees" ("FirstName", "LastName", "BirthDate", "HireDate", "OfficeId", "Title", "Sex", "Address", "Phone")
SELECT 'Mustafavi', 'Bykov', date '08-09-1978', date '10-14-2016', 1, 'Sales Manager', 'M', 'Sivkov st. 172', '+7 (958) 861-93-63'
UNION ALL SELECT 'Feodosia', 'Shashkova', date '01-03-1991', date '01-10-2017', 2, 'Accountant', 'F', 'Grazhdansky st. 33', '+7 (925) 655-61-88'
UNION ALL SELECT 'Fabriciy', 'Ermilov', date '09-28-1994', date '01-17-2017', 3, 'Secretary', 'M', '21st line st. 54', '+7 (973) 949-93-28'
UNION ALL SELECT 'Alexandr', 'Kudakovskiy', date '09-10-2002', date '11-17-2018', 4, 'Effective Manager', 'M', 'Oleny Teligy st. 69', '+7 (900) 493-99-75'
UNION ALL SELECT 'Roman', 'Krotov', date '01-18-2002', date '12-10-2018', 5, 'Chief Executive Officer', 'M', 'Pilotov st. 28', '+7 (962) 519-12-00'
UNION ALL SELECT 'Guldariga', 'Krymskaya', date '01-02-1970', date '03-15-2020', 6, 'Chief Technical Officer', 'F', 'Krasnoprudnata st. 180', '+7 (945) 685-34-29'
UNION ALL SELECT 'Sevastiana', 'Makarova', date '09-19-2000', date '06-25-2020', 7, 'Team Lead', 'F', 'Olimpiyskaya st. 159', '+7 (995) 774-75-13'
UNION ALL SELECT 'Lvova', 'Pychik', date '06-19-1991', date '08-9-2017', 8, 'Cleaning Manager', 'F', 'Panfilovcec st. 106', '+7 (937) 148-37-65'
UNION ALL SELECT 'Zhunus', 'Verhovskiy', date '11-10-1976', date '04-10-2018', 9, 'Database Architect', 'M', 'Paveleckaya st. 130', '+7 (910) 546-84-22'
UNION ALL SELECT 'Tabilya', 'Boytsova', date '05-29-1997', date '8-19-2019', 10, 'Call centre operator', 'F', 'Lesnaya st. 127', '+7 (926) 279-07-94';

INSERT INTO "PaymentDetails" ("CardNumber", "ExpirationDate", "Bank")
SELECT '4485611770999605', '08/2020', 'PrivatBank'
UNION ALL SELECT '4556833477886133', '12/2023', 'Bank Aval'
UNION ALL SELECT '4024007194644042', '01/2021', 'PrivatBank'
UNION ALL SELECT '4648716631407948', '07/2022', 'Tinkoff Bank'
UNION ALL SELECT '4556565095681666', '10/2023', 'Luminor Bank'
UNION ALL SELECT '2720358840673682', '08/2022', 'Swedbank'
UNION ALL SELECT '5352889089150873', '08/2021', 'Oschadbank'
UNION ALL SELECT '5104665164635983', '04/2025', 'Alfa Bank'
UNION ALL SELECT '344963136088741', '07/2023', 'Sberbank'
UNION ALL SELECT '8699610971086447', '01/2022', 'Bank of America';

INSERT INTO "Clients" ("FirstName", "LastName", "PaymentDetailsId", "BirthDate", "Registration")
SELECT 'Nurzida', 'Ignatyeva', 1, date '04-15-1976', 'Silikatnaya st. 137'
UNION ALL SELECT 'Pavlusha', 'Veselkov', 2, date '06-02-1971', 'Golovacheva st. 45'
UNION ALL SELECT 'Analia', 'Gromova', 3, date '02-14-1987', 'Pavskiy st. 27'
UNION ALL SELECT 'Bogdan', 'Sofiyskiy', 4, date '01-06-1983', 'Balaklavskiy st. 2'
UNION ALL SELECT 'Vitaliy', 'Zaharov', 5, date '12-25-1983', 'Energetikov st. 157'
UNION ALL SELECT 'Angelina', 'Bulgakova', 6, date '06-06-1974', 'Bronnaya st. 7'
UNION ALL SELECT 'Olga', 'Matviyenko', 7, date '04-14-1996', 'Kuznetskiy most st. 2'
UNION ALL SELECT 'Aleksei', 'Struchkov', 8, date '04-17-1972', 'Skorniazhnaya st. 71'
UNION ALL SELECT 'Elizaveta', 'Navarskaya', 9, date '12-13-1994', 'Akademika Komarova st. 89'
UNION ALL SELECT 'Maksim', 'Demyanov', 10, date '09-07-1971', 'Melitopolskiy proyezd st. 187';

INSERT INTO "RealEstate" ("ClientId", "Address", "LivingSpace")
SELECT 1, 'Elohovskaya st. 104', 186
UNION ALL SELECT 2, 'Tipanova st. 17', 96
UNION ALL SELECT 3, 'Holmistaya st. 108', 85
UNION ALL SELECT 4, 'Troitskaya st. 15', 67
UNION ALL SELECT 5, 'Parashutnaya st. 65', 122
UNION ALL SELECT 6, 'Savina st. 60', 110
UNION ALL SELECT 7, 'Voskova st. 125', 45
UNION ALL SELECT 8, 'Yuzhnaya st. 25', 77
UNION ALL SELECT 9, 'Yegorova st. 133', 30
UNION ALL SELECT 10, 'Akademika Glushko st. 58', 256
UNION ALL SELECT 5, 'Marata st. 86', 134
UNION ALL SELECT 3, 'Semenovskaya st. 125', 76;

INSERT INTO "EnergyCounters" ("LastCheckDate", "Model")
SELECT date '07-15-2018', 'HRN 111L'
UNION ALL SELECT date '08-19-2019', 'Nik 2307'
UNION ALL SELECT date '03-22-2020', 'Iskra ME162'
UNION ALL SELECT date '05-17-2019', 'Nik 2307'
UNION ALL SELECT date '01-10-2017', 'Teletec MTX 3R30'
UNION ALL SELECT date '02-08-2019', 'PLC 2 MTX'
UNION ALL SELECT date '12-13-2016', 'Nik 2307'
UNION ALL SELECT date '06-22-2019', 'Nik 2307'
UNION ALL SELECT date '04-07-2018', 'Hager TE360'
UNION ALL SELECT date '11-29-2015', 'Nik 2307'
UNION ALL SELECT date '09-13-2016', 'Iskra MT174'
UNION ALL SELECT date '11-28-2019', 'Nik 2307';

INSERT INTO "PersonalAccounts" ("RealEstateId", "Balance", "ClientId", "EnergyCounterId")
SELECT 1, 120, 1, 1
UNION ALL SELECT 2, 2230, 2, 2
UNION ALL SELECT 3, 1250, 3, 3
UNION ALL SELECT 4, 10124, 4, 4
UNION ALL SELECT 5, 6432, 5, 5
UNION ALL SELECT 6, 2897, 6, 6
UNION ALL SELECT 7, 4580, 7, 7
UNION ALL SELECT 8, 22320, 8, 8
UNION ALL SELECT 9, 1324, 9, 9
UNION ALL SELECT 10, 1572, 10, 10
UNION ALL SELECT 11, 2230, 5, 11
UNION ALL SELECT 12, 2230, 3, 12;

INSERT INTO "ClientsOffices" ("OfficeId", "ClientId")
SELECT 1, 1
UNION ALL SELECT 2, 2
UNION ALL SELECT 3, 3
UNION ALL SELECT 4, 4
UNION ALL SELECT 5, 5
UNION ALL SELECT 6, 6
UNION ALL SELECT 7, 7
UNION ALL SELECT 8, 8
UNION ALL SELECT 9, 9
UNION ALL SELECT 10, 10
UNION ALL SELECT 5, 2
UNION ALL SELECT 8, 10;

INSERT INTO "MonthlyInvoices" ("CreatedAt", "EnergyUsed", "PaymentDate", "CreatedBy", "RealEstateId", "PaymentDetailsId", "EnergyCounterId")
SELECT date '11-15-2019', 1230, date '11-20-2019', 1, 1, 1, 1
UNION ALL SELECT date '06-12-2018', 1737, date '06-22-2018', 2, 2, 2, 2
UNION ALL SELECT date '11-15-2019', 1230, date '11-23-2019', 3, 3, 3, 3
UNION ALL SELECT date '12-13-2019', 1543, date '12-16-2019', 4, 4, 4, 4
UNION ALL SELECT date '05-11-2018', 846, date '05-11-2018', 5, 5, 5, 5
UNION ALL SELECT date '03-25-2017', 926, date '03-27-2017', 6, 6, 6, 6
UNION ALL SELECT date '12-17-2020', 858, date '12-29-2020', 7, 7, 7, 7
UNION ALL SELECT date '06-06-2018', 183, date '06-12-2018', 8, 8, 8, 8
UNION ALL SELECT date '03-12-2017', 140, date '03-15-2017', 9, 9, 9, 9
UNION ALL SELECT date '02-04-2016', 935, date '02-05-2016', 10, 10, 10, 10
UNION ALL SELECT date '05-09-2019', 564, date '05-11-2019', 4, 11, 5, 11
UNION ALL SELECT date '06-24-2017', 784, date '07-5-2017', 5, 12, 3, 12;

CREATE OR REPLACE FUNCTION "GetTables"()
RETURNS TABLE(
  "TableName" varchar
)
AS $$
BEGIN
    RETURN QUERY SELECT cast(table_name AS varchar) FROM information_schema.tables
    WHERE table_schema = 'public';
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "DeleteRow"(tableName text, columnName text, id int) RETURNS VOID
AS $$
BEGIN
  EXECUTE format('DELETE FROM "%s" WHERE "%s" = %s;', tableName, columnName, id);
END
$$ LANGUAGE plpgsql;
