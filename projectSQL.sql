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
		date,
		sum(confirmed) AS sum_congo
	FROM covid19_basic_differences
	WHERE country LIKE '%congo%'
		AND confirmed IS NOT NULL
		AND confirmed >= 0
	GROUP BY date;
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


# *** POMOCNA TABULKA lookup table - population neobsazene v economies ***
CREATE OR REPLACE TABLE t_michal_boucek_sqlfinal_lookup_table_temp AS
SELECT
	country,
	population
FROM lookup_table
WHERE province IS NULL -- cele soucty populace ve state
	AND country IN ('Holy See', 'Taiwan*', 'West Bank and Gaza');
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
SELECT
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
UPDATE t_michal_boucek_sqlfinal_weather_temp AS t, cities AS c -- pripojeni country podle mest
SET t.country = c.country
WHERE t.city = c.city
	AND c.capital = 'primary';
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
#CREATE OR REPLACE TABLE t_michal_boucek_projekt_SQL_final AS -- pouze pro vyvoj - pak odkomentovat
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
		WHEN weekday(cbd.`date`) IN (5,6) THEN 1 ELSE 0
	END AS flag_weekend,
	CASE
		WHEN cbd.`date` BETWEEN '2019-12-22' AND '2020-03-19' THEN 0
		WHEN cbd.`date` BETWEEN '2020-03-20' AND '2020-06-19' THEN 1
		WHEN cbd.`date` BETWEEN '2020-06-20' AND '2020-09-21' THEN 2
		WHEN cbd.`date` BETWEEN '2020-09-22' AND '2020-12-20' THEN 3
		WHEN cbd.`date` BETWEEN '2020-12-21' AND '2021-03-19' THEN 0
		WHEN cbd.`date` BETWEEN '2021-03-20' AND '2021-06-20' THEN 1
		ELSE 'out of range'
	END AS season,
	ROUND(c.population_density) AS 'population_density/km2',
	ROUND(e.GDP/e.population,1) AS 'GDP_2020_per_inhabitant (USD)',
	ginitab.gini AS gini,
	ginitab.gini_year AS gini_year,
	e2019.mortaliy_under5 AS mortality_under5,
	c.median_age_2018,
	r.religion,
	ROUND((r.population/r_sum.ssum)*100,2) AS percent_religion,
	ROUND(le2015.life_expectancy-le1965.life_expectancy) AS 'life_expectancy_diff_2015-1965',
	temp.avg_daily_temp AS 'avg_daily_temp °C', -- prumerna denni teplota v case 6:00-18:00
	rhours.raining_hours, -- pocet hodin, kdy srazky byly nenulove
	mgust.maxgust AS 'max_gust km/h'
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
		ROUND(AVG(SUBSTRING_INDEX(temp, ' ', 1)),2) AS avg_daily_temp
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
			WHEN count(DISTINCT `time`) IS NULL THEN 0 ELSE count(DISTINCT `time`)
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
		MAX(SUBSTRING_INDEX(gust, ' ', 1)) AS maxgust
	FROM t_michal_boucek_sqlfinal_weather_temp
	GROUP BY country, `date`
) AS mgust
	ON mgust.country = cbd.country
	AND mgust.`date` = cbd.`date`
WHERE cbd.country = 'Congo' -- pouze pro vyvoj
	AND cbd.date = '2020-02-09' -- pouze pro vyvoj
ORDER BY cbd.country, cbd.`date`, r.religion
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