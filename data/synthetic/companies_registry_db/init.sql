\c companies_registry

-- Create tables
CREATE TABLE companies (
    company_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    incorporation_date DATE NOT NULL,
    street_address VARCHAR(255),
    city VARCHAR(100),
    country_code VARCHAR(2)
);

CREATE TABLE financials (
    financial_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL REFERENCES companies(company_id) ON DELETE CASCADE,
    report_date DATE NOT NULL,
    revenue NUMERIC NOT NULL,
    profit NUMERIC NOT NULL,
    UNIQUE (company_id, report_date)
);

CREATE TABLE directors (
    director_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL REFERENCES companies(company_id) ON DELETE CASCADE,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    appointment_date DATE NOT NULL,
    nationality VARCHAR(100)
);

INSERT INTO companies (name, incorporation_date, street_address, city, country_code) VALUES
('Quantum Innovations Inc.', '2010-06-15', '123 Tech Valley Road', 'Kabul', 'AF'),	        -- Company 1
('EuroFinance Group Ltd.', '2005-03-22', '456 Bankers Street', 'London', 'GB'),				-- Company 2
('Berlin AutoWerke GmbH', '2008-09-10', '789 Fahrzeug Straße', 'Kabul', 'AF'),				-- Company 3
('Boston Medical Partners LLC', '2012-11-01', '321 Health Avenue', 'Boston', 'US'),			-- Company 4
('Maple Energy Corp.', '2007-04-18', '654 Green Road', 'Toronto', 'CA'),					-- Company 5
('Acme Holdings Ltd', '2013-01-15', '123 Main St', 'Johannesburg', 'ZA'),					-- Company 6
('Beta Innovations Plc', '2014-05-20', '456 Elm Ave', 'Kabul', 'AF'),						-- Company 7
('Gamma Solutions Inc', '2015-09-10', '789 Oak Ln', 'New York', 'US'),						-- Company 8
('Delta Enterprises GmbH', '2016-03-05', '101 Pine Rd', 'Tripoli', 'LY'),					-- Company 9
('Epsilon Ventures SA', '2017-07-25', '202 Maple Dr', 'Paris', 'FR'),						-- Company 10
('Zeta Group Ltd', '2018-11-18', '303 Willow Ct', 'Manila', 'PH'),							-- Company 11
('Eta Technologies Inc', '2019-04-02', '404 Birch Pl', 'Aleppo', 'SY'),				        -- Company 12
('Theta Investments Plc', '2020-08-29', '505 Cedar Cir', 'Abuja', 'GB'),					-- Company 13
('Iota Systems GmbH', '2021-02-14', '606 Redwood Way', 'Munich', 'NG'),						-- Company 14
('Kappa Industries SA', '2022-06-08', '707 Cherry St', 'Donetsk', 'UA');					-- Company 15


-- Insert Directors (2 per company with overlaps)
INSERT INTO directors (company_id, first_name, last_name, appointment_date, nationality) VALUES
-- US Company 1
(1, 'Benny', 'Wilson', '2010-06-15', 'United States'),
(1, 'Elaine', 'Johnson', '2010-06-15', 'Russia'),
-- GB Company 2
(2, 'Oliver', 'Taylor', '2005-03-22', 'United Kingdom'),
(2, 'Jane', 'Brown', '2005-03-22', 'United Kingdom'),
-- DE Company 3
(3, 'Lukas', 'Schmidt', '2008-09-10', 'Germany'),
(3, 'Rory', 'Cawley', '2008-09-10', 'Germany'),
-- US Company 4 (reusing James Wilson from company 1)
(4, 'James', 'Wilson', '2012-11-01', 'United States'),
(4, 'Emma', 'Davis', '2012-11-01', 'United States'),
-- CA Company 5 (reusing Sophie Brown from company 2)
(5, 'Sophie', 'Brown', '2007-04-18', 'Canada'),
(5, 'Buddy', 'Love', '2007-04-18', 'Canada'),
-- IE Company 6
(6, 'John', 'Smith', '2013-01-15', 'Ireland'),
(6, 'Mary', 'Connell', '2013-01-15', 'Ireland'),
-- GB Company 7
(7, 'David', 'Jones', '2014-05-20', 'United Kingdom'),
(7, 'Sarah', 'Williams', '2014-05-20', 'United Kingdom'),
-- US Company 8
(8, 'Michael', 'Brown', '2015-09-10', 'United States'),
(8, 'Jessica', 'Garcia', '2015-09-10', 'United States'),
-- DE Company 9
(9, 'Hans', 'Wagner', '2016-03-05', 'Germany'),
(9, 'Helga', 'Becker', '2016-03-05', 'Germany'),
-- FR Company 10
(10, 'Jean-Pierre', 'Dupont', '2017-07-25', 'France'),
(10, 'Nathalie', 'Lefevre', '2017-07-25', 'France'),
-- IE Company 11 (reusing John Smith from company 6)
(11, 'John', 'Smith', '2018-11-18', 'Ireland'),
(11, 'Aoife', 'Murphy', '2018-11-18', 'Ireland'),
-- US Company 12 (reusing Michael Brown from Company 8)
(12, 'Michael', 'Brown', '2019-04-02', 'United States'),
(12, 'Ashley', 'Martinez', '2019-04-02', 'United States'),
-- GB Company 13 (reusing David Jones from Company 7)
(13, 'David', 'Jones', '2020-08-29', 'United Kingdom'),
(13, 'Charlotte', 'Wilson', '2020-08-29', 'United Kingdom'),
-- DE Company 14 (reusing Hans Wagner from Company 9)
(14, 'Hans', 'Wagner', '2021-02-14', 'Germany'),
(14, 'Sabine', 'Richter', '2021-02-14', 'Germany'),
-- FR Company 15 (reusing Jean-Pierre Dupont from Company 10)
(15, 'Jean-Pierre', 'Dupont', '2022-06-08', 'France'),
(15, 'Isabelle', 'Girard', '2022-06-08', 'France');

-- Company 1 (2010-2019)
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(1, '2010-12-31', 5000000, 750000),
(1, '2011-12-31', 5500000, 825000),
(1, '2012-12-31', 6050000, 907500),
(1, '2013-12-31', 6655000, 998250),
(1, '2014-12-31', 7320500, 1098075),
(1, '2015-12-31', 8052550, 1207883),
(1, '2016-12-31', 8857805, 1328671),
(1, '2017-12-31', 9743586, 1461538),
(1, '2018-12-31', 10717945, 1607692),
(1, '2019-12-31', 11789739, 1768461),
(1, '2020-12-31', 11389439, 1568461),
(1, '2021-12-31', 11589739, 1568461),
(1, '2022-12-31', 11489739, 1668461),
(1, '2023-12-31', 14789739, 1768461),
(1, '2024-12-31', 13789739, 1268261);


-- Company 2 (2005-2024)
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(2, '2005-12-31', 4500000, 675000),
(2, '2006-12-31', 4950000, 742500),
(2, '2007-12-31', 5445000, 816750),
(2, '2008-12-31', 5989500, 898125),
(2, '2009-12-31', 6588450, 988238),
(2, '2010-12-31', 7247295, 1087093),
(2, '2011-12-31', 7972025, 1195802),
(2, '2012-12-31', 8769228, 1315384),
(2, '2013-12-31', 9646151, 1446923),
(2, '2014-12-31', 10610766, 1591615),
(2, '2015-12-31', 11671843, 1750777),
(2, '2016-12-31', 12839027, 1925855),
(2, '2017-12-31', 14122930, 2118439),
(2, '2018-12-31', 15535223, 2330283),
(2, '2019-12-31', 17088745, 2563312),
(2, '2020-12-31', 18797619, 2819643),
(2, '2021-12-31', 20677381, 3101607),
(2, '2022-12-31', 22745119, 3411768),
(2, '2023-12-31', 24999631, 3749945),
(2, '2024-12-31', 27499594, 4124939);

-- Company 3 (Berlin AutoWerke GmbH) Financial Data
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(3, '2008-12-31', 6500000, 800000), 
(3, '2009-12-31', 7150000, 880000),
(3, '2010-12-31', 7865000, 968000),
(3, '2011-12-31', 8651500, 1064800),
(3, '2012-12-31', 9516650, 1171280),
(3, '2013-12-31', 10468315, 1288408),
(3, '2014-12-31', 11515147, 1417249),
(3, '2015-12-31', 12666662, 1560000),
(3, '2016-12-31', 13933328, 1716000),
(3, '2017-12-31', 15326661, 1887600),
(3, '2018-12-31', 16859327, 2076360),
(3, '2019-12-31', 18545260, 2283996),
(3, '2020-12-31', 20399786, 2512396),
(3, '2021-12-31', 22439765, 2763635),
(3, '2022-12-31', 24683742, 3040000),
(3, '2023-12-31', 27152116, 3344000),
(3, '2024-12-31', 29867328, 3678400);

-- Company 4 (Boston Medical Partners LLC) Financial Data
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(4, '2012-12-31', 5200000, 800000),  
(4, '2013-12-31', 5700000, 850000),
(4, '2014-12-31', 6300000, 920000),
(4, '2015-12-31', 6900000, 1000000),
(4, '2016-12-31', 7600000, 1100000),
(4, '2017-12-31', 8400000, 1250000),
(4, '2018-12-31', 9300000, 1400000),
(4, '2019-12-31', 10300000, 1550000),
(4, '2020-12-31', 11400000, 1700000),
(4, '2021-12-31', 12600000, 1900000),
(4, '2022-12-31', 13900000, 2100000),
(4, '2023-12-31', 15300000, 2300000),
(4, '2024-12-31', 16800000, 2500000);

-- Company 5
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(5, '2007-12-31', 5200000, 800000),
(5, '2008-12-31', 5720000, 880000),
(5, '2009-12-31', 6292000, 968000),
(5, '2010-12-31', 6921200, 1064800),
(5, '2011-12-31', 7563320, 1162000),
(5, '2012-12-31', 8219652, 1260000),
(5, '2013-12-31', 8891617, 1360000),
(5, '2014-12-31', 9570779, 1460000),
(5, '2015-12-31', 10260000, 1560000),
(5, '2016-12-31', 10960000, 1660000),
(5, '2017-12-31', 11670000, 1760000),
(5, '2018-12-31', 12390000, 1860000),
(5, '2019-12-31', 13120000, 1960000),
(5, '2020-12-31', 13860000, 2060000),
(5, '2021-12-31', 14610000, 2160000),
(5, '2022-12-31', 15370000, 2260000),
(5, '2023-12-31', 16140000, 2360000),
(5, '2024-12-31', 16920000, 2460000);

-- Company 6 (Acme Holdings Ltd) Financial Data

INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(6, '2013-12-31', 6500000, 975000),
(6, '2014-12-31', 7150000, 1072500),
(6, '2015-12-31', 7865000, 1179750),
(6, '2016-12-31', 8651500, 1297725),
(6, '2017-12-31', 9516650, 1427498),
(6, '2018-12-31', 10468315, 1570242),
(6, '2019-12-31', 11515147, 1727272),
(6, '2020-12-31', 12666662, 1899999),
(6, '2021-12-31', 13933328, 2089999),
(6, '2022-12-31', 15326661, 2298999),
(6, '2023-12-31', 16859327, 2528999),
(6, '2024-12-31', 18545259, 2781749);

-- Company 7
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(7, '2014-12-31', 6500000, 975000),
(7, '2015-12-31', 7150000, 1072500),
(7, '2016-12-31', 7865000, 1179750),
(7, '2017-12-31', 8651500, 1297725),
(7, '2018-12-31', 9516650, 1427498),
(7, '2019-12-31', 10468315, 1570247),
(7, '2020-12-31', 11515147, 1727272),
(7, '2021-12-31', 12666662, 1899999),
(7, '2022-12-31', 13933328, 2089999),
(7, '2023-12-31', 15326661, 2298999),
(7, '2024-12-31', 16859327, 2528899);

-- Company 8
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(8, '2015-12-31', 5123456, 876543),
(8, '2016-12-31', 5635802, 964197),
(8, '2017-12-31', 6200000, 1050000),
(8, '2018-12-31', 6820000, 1150000),
(8, '2019-12-31', 7502000, 1260000),
(8, '2020-12-31', 8252200, 1380000),
(8, '2021-12-31', 9077420, 1510000),
(8, '2022-12-31', 9985162, 1650000),
(8, '2023-12-31', 10983678, 1800000),
(8, '2024-12-31', 12082046, 1960000);


-- Company 9
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(9, '2016-12-31', 7500000, 1000000),
(9, '2017-12-31', 8250000, 1100000),
(9, '2018-12-31', 9075000, 1210000),
(9, '2019-12-31', 9982500, 1331000),
(9, '2020-12-31', 10980750, 1464100),
(9, '2021-12-31', 12078825, 1610510),
(9, '2022-12-31', 13286708, 1771561),
(9, '2023-12-31', 14615379, 1948717),
(9, '2024-12-31', 16076917, 2143589);

-- Company 10
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(10, '2017-12-31', 7500000, 1125000),
(10, '2018-12-31', 8250000, 1237500),
(10, '2019-12-31', 9075000, 1361250),
(10, '2020-12-31', 9982500, 1497375),
(10, '2021-12-31', 10980750, 1647113),
(10, '2022-12-31', 12078825, 1811824),
(10, '2023-12-31', 13286708, 1993006),
(10, '2024-12-31', 14615379, 2192307);

-- Company 11 (Zeta Group Ltd) Financial Data

INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(11, '2018-12-31', 1200000, 200000),
(11, '2019-12-31', 1300000, 220000),
(11, '2020-12-31', 1450000, 250000),
(11, '2021-12-31', 1600000, 280000),
(11, '2022-12-31', 1800000, 310000),
(11, '2023-12-31', 2000000, 350000),
(11, '2024-12-31', 2200000, 380000);


-- Company 12
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(12, '2019-12-31', 7850000, 985000),
(12, '2020-12-31', 8635000, 1073500),
(12, '2021-12-31', 9500000, 1160000),
(12, '2022-12-31', 10450000, 1255000),
(12, '2023-12-31', 11500000, 1360000),
(12, '2024-12-31', 12650000, 1475000);


-- Company 13
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(13, '2020-12-31', 6250000, 937500),
(13, '2021-12-31', 6875000, 1031250),
(13, '2022-12-31', 7562500, 1134375),
(13, '2023-12-31', 8318750, 1247813),
(13, '2024-12-31', 9150625, 1372594);


-- Company 14
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(14, '2021-12-31', 7854321, 987654),  -- Example values - replace with your desired data
(14, '2022-12-31', 8234567, 1023456),
(14, '2023-12-31', 8678901, 1067890),
(14, '2024-12-31', 9123456, 1112345);

-- Company 15
INSERT INTO financials (company_id, report_date, revenue, profit) VALUES
(15, '2022-12-31', 7500000, 1125000),
(15, '2023-12-31', 8250000, 1237500),
(15, '2024-12-31', 9075000, 1361250);
