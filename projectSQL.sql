# *** POMOCNA TABULKA covid19_basic_differences ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_covid19_basic_differences_temp AS
SELECT
	`date`,
	country,
	confirmed
FROM covid19_basic_differences
WHERE confirmed IS NOT NULL
	AND confirmed >= 0; -- vynechat NULL a zaporne hodnoty
# sjednoceni nazvu
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Myanmar'
	WHERE country = 'Burma';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Cape Verde'
	WHERE country = 'Cabo Verde';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Ivory Coast'
	WHERE country = 'Cote d\'Ivoire';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Czech Republic'
	WHERE country = 'Czechia';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Swaziland'
	WHERE country = 'Eswatini';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'South Korea'
	WHERE country = 'Korea, South';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Russian Federation'
	WHERE country = 'Russia';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Taiwan'
	WHERE country = 'Taiwan*';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'United States'
	WHERE country = 'US';

# Congo - nastaveni confirmed jako soucet Brazzaville + Kinshasa
DELETE FROM t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	WHERE country LIKE '%kinshasa%';
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp 
	SET country = 'Congo'
	WHERE country LIKE '%brazzaville%';
CREATE OR REPLACE TABLE t_congo_sum AS -- pomocna tabulka - soucet Brazzaville + Kinshasa
	SELECT
		`date`,
		SUM(confirmed) AS sum_congo
	FROM covid19_basic_differences
	WHERE country LIKE '%congo%'
		AND confirmed IS NOT NULL
		AND confirmed >= 0
	GROUP BY `date`;
UPDATE t_michal_boucek_sqlfinal_covid19_basic_differences_temp AS t1, t_congo_sum AS t2 -- nahrani sumy
	SET t1.confirmed = t2.sum_congo
	WHERE t1.country = 'Congo'
		AND t1.`date` = t2.`date`;
DROP TABLE IF EXISTS t_congo_sum; -- smazani pomocne tabulky


# ***  POMOCNA TABULKA covid19_tests ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_covid19_tests_temp AS
SELECT
	country,
	entity,
	`date`,
	tests_performed
FROM covid19_tests
WHERE tests_performed IS NOT NULL
	AND tests_performed >= 0; -- pouze kladne hodnoty
# sjednoceni nazvu
UPDATE t_michal_boucek_sqlfinal_covid19_tests_temp 
	SET country = 'Congo'
	WHERE country = 'Democratic Republic of Congo';
UPDATE t_michal_boucek_sqlfinal_covid19_tests_temp 
	SET country = 'North Macedonia'
	WHERE country = 'Macedonia';
UPDATE t_michal_boucek_sqlfinal_covid19_tests_temp 
	SET country = 'Ivory Coast'
	WHERE country = 'Cote d\'Ivoire';
UPDATE t_michal_boucek_sqlfinal_covid19_tests_temp 
	SET country = 'Russian Federation'
	WHERE country = 'Russia';


# ***  POMOCNA TABULKA economies ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_economies_temp AS
SELECT
	country,
	`year`,
	GDP,
	population,
	gini,
	mortaliy_under5
FROM economies
WHERE country IS NOT NULL;
# sjednoceni nazvu
DELETE FROM t_michal_boucek_sqlfinal_economies_temp -- vymaz duplicity
	WHERE country = 'Congo';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Congo'
	WHERE country = 'The Democratic Republic of Congo';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Bahamas'
	WHERE country = 'Bahamas, The';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Brunei'
	WHERE country = 'Brunei Darussalam';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Cape Verde'
	WHERE country = 'Cabo Verde';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Micronesia'
	WHERE country = 'Micronesia, Fed. Sts.';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Saint Kitts and Nevis'
	WHERE country = 'St. Kitts and Nevis';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Saint Lucia'
	WHERE country = 'St. Lucia';
UPDATE t_michal_boucek_sqlfinal_economies_temp 
	SET country = 'Saint Vincent and the Grenadines'
	WHERE country = 'St. Vincent and the Grenadines';


# *** POMOCNA TABULKA lookup table - population neobsazene v economies pro rok 2020 ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_lookup_table_temp AS
SELECT
	country,
	population
FROM lookup_table
WHERE province IS NULL -- cele soucty populace ve state
	AND country IN ('Eritrea', 'Holy See', 'Taiwan*', 'West Bank and Gaza');
# sjednoceni nazvu
UPDATE t_michal_boucek_sqlfinal_lookup_table_temp 
	SET country = 'Taiwan'
	WHERE country = 'Taiwan*';


# *** POMOCNA TABULKA countries ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_countries_temp AS
SELECT
	country,
	population_density,
	median_age_2018
FROM countries
WHERE country IS NOT NULL;
# sjednoceni nazvu
UPDATE t_michal_boucek_sqlfinal_countries_temp 
	SET country = 'Fiji'
	WHERE country = 'Fiji Islands';
UPDATE t_michal_boucek_sqlfinal_countries_temp 
	SET country = 'Holy See'
	WHERE country = 'Holy See (Vatican City State)';
UPDATE t_michal_boucek_sqlfinal_countries_temp 
	SET country = 'Libya'
	WHERE country = 'Libyan Arab Jamahiriya';
UPDATE t_michal_boucek_sqlfinal_countries_temp 
	SET country = 'Micronesia'
	WHERE country = 'Micronesia, Federated States of';


# *** POMOCNA TABULKA religions ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_religions_temp AS
SELECT
	country,
	religion,
	population
FROM religions
WHERE country IS NOT NULL
	AND `year` = 2020;
# sjednoceni nazvu
DELETE FROM t_michal_boucek_sqlfinal_religions_temp
	WHERE country = 'Congo';
UPDATE t_michal_boucek_sqlfinal_religions_temp 
	SET country = 'Congo'
	WHERE country = 'The Democratic Republic of Congo';
UPDATE t_michal_boucek_sqlfinal_religions_temp 
	SET country = 'Micronesia'
	WHERE country = 'Federated States of Micronesia';
UPDATE t_michal_boucek_sqlfinal_religions_temp 
	SET country = 'Saint Kitts and Nevis'
	WHERE country = 'St. Kitts and Nevis';
UPDATE t_michal_boucek_sqlfinal_religions_temp 
	SET country = 'Saint Lucia'
	WHERE country = 'St. Lucia';
UPDATE t_michal_boucek_sqlfinal_religions_temp 
	SET country = 'Saint Vincent and the Grenadines'
	WHERE country = 'St. Vincent and the Grenadines';


# *** POMOCNA TABULKA life_expectancy ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_life_expectancy_temp AS
SELECT
	country,
	`year`,
	life_expectancy
FROM life_expectancy
WHERE country IS NOT NULL
	AND `year` IN (2015, 1965);
# sjednoceni nazvu
DELETE FROM t_michal_boucek_sqlfinal_life_expectancy_temp
	WHERE country = 'Congo';
UPDATE t_michal_boucek_sqlfinal_life_expectancy_temp 
	SET country = 'Congo'
	WHERE country = 'The Democratic Republic of Congo';
UPDATE t_michal_boucek_sqlfinal_life_expectancy_temp 
	SET country = 'Holy See'
	WHERE country = 'Vatican';
UPDATE t_michal_boucek_sqlfinal_life_expectancy_temp 
	SET country = 'Micronesia'
	WHERE country = 'Micronesia (country)';
UPDATE t_michal_boucek_sqlfinal_life_expectancy_temp 
	SET country = 'Timor-Leste' -- pro Timor-Leste pouzita data pro cely Timor
	WHERE country = 'Timor';


# *** POMOCNA TABULKA weather ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_weather_temp AS
SELECT DISTINCT -- filtrovat duplicity - Vienna, Prague
	`time`,
	temp,
	gust,
	rain,
	DATE(`date`) AS 'date',
	city
FROM weather
WHERE city IS NOT NULL;

UPDATE t_michal_boucek_sqlfinal_weather_temp  -- oprava nazvu mesta podle tabulky cities
	SET city = 'Kyiv'
	WHERE city = 'Kiev';
ALTER TABLE t_michal_boucek_sqlfinal_weather_temp -- novy sloupec country
	ADD COLUMN country TEXT;
CREATE OR REPLACE TABLE t_michal_boucek_cities_temp AS -- pripojeni country podle mest
SELECT DISTINCT
	c.country, c.city
FROM cities AS c
JOIN t_michal_boucek_sqlfinal_weather_temp AS w
	ON c.city = w.city
	AND c.capital = 'primary';
UPDATE t_michal_boucek_sqlfinal_weather_temp AS t, t_michal_boucek_cities_temp AS c
SET t.country = c.country
WHERE t.city = c.city;
DROP TABLE t_michal_boucek_cities_temp;

# sjednoceni nazvu
UPDATE t_michal_boucek_sqlfinal_weather_temp 
	SET country = 'North Macedonia'
	WHERE country = 'Macedonia';
UPDATE t_michal_boucek_sqlfinal_weather_temp
	SET country = 'Russian Federation'
	WHERE country = 'Russia';
UPDATE t_michal_boucek_sqlfinal_weather_temp
	SET country = 'Czech Republic'
	WHERE country = 'Czechia';


# *** VYSLEDNA TABULKA ***
CREATE OR REPLACE TABLE t_michal_boucek_projekt_SQL_final AS
SELECT
	cbd.country,
	cbd.`date`,
	cbd.confirmed,
	t.tests_performed,
	t.entity,
	CASE
		WHEN e.population IS NOT NULL THEN e.population ELSE lt.population
	END AS population,
	CASE
		WHEN WEEKDAY(cbd.`date`) IN (5,6) THEN 1 ELSE 0
	END AS flag_weekend,
	CASE
		WHEN (MONTH(cbd.`date`) = 12 AND DAY(cbd.`date`) >= 21)
			OR MONTH(cbd.`date`) IN (1, 2)
			OR ((MONTH(cbd.`date`) = 3 AND DAY(cbd.`date`) <= 19))
			THEN 0 -- zima
		WHEN (MONTH(cbd.`date`) = 3 AND DAY(cbd.`date`) >= 20)
			OR MONTH(cbd.`date`) IN (4, 5)
			OR ((MONTH(cbd.`date`) = 6 AND DAY(cbd.`date`) <= 19))
			THEN 1 -- jaro
		WHEN (MONTH(cbd.`date`) = 6 AND DAY(cbd.`date`) >= 20)
			OR MONTH(cbd.`date`) IN (7, 8)
			OR ((MONTH(cbd.`date`) = 9 AND DAY(cbd.`date`) <= 21))
			THEN 2 -- leto
		WHEN (MONTH(cbd.`date`) = 9 AND DAY(cbd.`date`) >= 22)
			OR MONTH(cbd.`date`) IN (10, 11)
			OR ((MONTH(cbd.`date`) = 12 AND DAY(cbd.`date`) <= 20))
			THEN 3 -- podzim
	END AS season, -- neuvazuje se mezirocni posun zacatku/koncu rocnich obdobi +- 1-2 dny
	ROUND(c.population_density) AS 'population_density/km^2',
	CASE
		WHEN e.population IS NOT NULL THEN ROUND(GDPtab.GDP/e.population,1) ELSE ROUND(GDPtab.GDP/lt.population,1)
	END AS 'GDP_per_inhabitant_in_USD',
	GDPtab.GDP_year AS GDP_year,
	ginitab.gini AS gini,
	ginitab.gini_year AS gini_year,
	e2019.mortaliy_under5 AS mortality_under5,
	c.median_age_2018,
	r.religion,
	ROUND((r.population/r_sum.ssum)*100,2) AS percent_religion_2020,
	ROUND(le2015.life_expectancy-le1965.life_expectancy) AS 'life_expectancy_diff_2015-1965',
	temp.avg_daily_temp AS 'avg_daily_temp_degC', -- prumerna denni teplota ve ??C v case 6:00-18:00
	rhours.raining_hours, -- pocet hodin, kdy srazky byly nenulove
	mgust.maxgust AS 'max_gust_km/h'
FROM t_michal_boucek_sqlfinal_covid19_basic_differences_temp AS cbd
LEFT JOIN t_michal_boucek_sqlfinal_covid19_tests_temp AS t
	ON cbd.country = t.country
	AND cbd.`date` = t.`date`
LEFT JOIN t_michal_boucek_sqlfinal_economies_temp AS e
	ON e.country = cbd.country
	AND e.`year` = 2020 -- data roku 2020, pro 2021 nejsou
LEFT JOIN t_michal_boucek_sqlfinal_lookup_table_temp AS lt
	ON lt.country = cbd.country
LEFT JOIN t_michal_boucek_sqlfinal_countries_temp AS c
	ON c.country = cbd.country
LEFT JOIN ( -- GDP agregace - nejaktualnejsi dostupny rok pro kazdou zemi
	SELECT 
		country,
		MAX(`year`) AS GDP_year,
		GDP
	FROM t_michal_boucek_sqlfinal_economies_temp
	WHERE GDP IS NOT NULL
	GROUP BY country
) AS GDPtab
	ON cbd.country = GDPtab.country
LEFT JOIN ( -- gini agregace - nejaktualnejsi dostupny rok pro kazdou zemi
	SELECT 
		country,
		MAX(`year`) AS gini_year,
		gini
	FROM t_michal_boucek_sqlfinal_economies_temp
	WHERE gini IS NOT NULL
	GROUP BY country
) AS ginitab
	ON cbd.country = ginitab.country
LEFT JOIN t_michal_boucek_sqlfinal_economies_temp AS e2019
	ON e2019.country = cbd.country
	AND e2019.`year` = 2019
LEFT JOIN t_michal_boucek_sqlfinal_religions_temp AS r
	ON r.country = cbd.country
LEFT JOIN (
	SELECT 
		country,
		SUM(population) AS ssum
	FROM t_michal_boucek_sqlfinal_religions_temp
	GROUP BY country
) AS r_sum
	ON cbd.country = r_sum.country
LEFT JOIN t_michal_boucek_sqlfinal_life_expectancy_temp AS le2015
	ON le2015.country = cbd.country
	AND le2015.`year` = 2015
LEFT JOIN t_michal_boucek_sqlfinal_life_expectancy_temp AS le1965
	ON le1965.country = cbd.country
	AND le1965.`year` = 1965	
LEFT JOIN (
	SELECT
		country,
		`date`,
		ROUND(AVG(REPLACE(temp, ' ??c', '')),2) AS avg_daily_temp
	FROM t_michal_boucek_sqlfinal_weather_temp
	WHERE CAST(`time` AS TIME) BETWEEN '6:00' AND '18:00'
	GROUP BY country, `date`
) AS temp
	ON temp.country = cbd.country
	AND temp.`date` = cbd.`date`	
LEFT JOIN (
	SELECT
		country,
		`date`,
		CASE
			WHEN COUNT(DISTINCT `time`) IS NULL THEN 0 ELSE COUNT(DISTINCT `time`)
		END AS raining_hours 
	FROM t_michal_boucek_sqlfinal_weather_temp
	WHERE rain != '0.0 mm'
	GROUP BY country, `date`
) AS rhours
	ON rhours.country = cbd.country
	AND rhours.`date` = cbd.`date`
LEFT JOIN (
	SELECT
		country,
		`date`,
		MAX(REPLACE(gust, ' km/h', '')) AS maxgust
	FROM t_michal_boucek_sqlfinal_weather_temp
	GROUP BY country, `date`
) AS mgust
	ON mgust.country = cbd.country
	AND mgust.`date` = cbd.`date`
ORDER BY cbd.country, cbd.`date`
;

# *** VYMAZ POMOCNYCH TABULEK ***
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_weather_temp;
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_covid19_basic_differences_temp;
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_covid19_tests_temp;
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_economies_temp;
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_lookup_table_temp;
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_countries_temp;
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_religions_temp;
DROP TABLE IF EXISTS t_michal_boucek_sqlfinal_life_expectancy_temp;