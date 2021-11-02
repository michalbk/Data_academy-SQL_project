# *** priprava samostatne tabulky weather pro dalsi rozbor ***
CREATE OR REPLACE TABLE t_michal_boucek_weather_projekt_sql_final AS
SELECT
	`time`,
	temp,
	gust,
	rain,
	DATE(`date`) AS 'date',
	city
FROM weather
WHERE city IS NOT NULL
;
UPDATE t_michal_boucek_weather_projekt_sql_final -- oprava nazvu podle tab cities
	SET city = 'Kyiv'
	WHERE city = 'Kiev'
;
ALTER TABLE t_michal_boucek_weather_projekt_sql_final
	ADD COLUMN country TEXT
;
UPDATE t_michal_boucek_weather_projekt_sql_final AS t, cities AS c -- doplneni zemi
SET t.country = c.country
WHERE t.city = c.city
	AND c.capital = 'primary'
;

# *** tabulka konecnych dat
#CREATE OR REPLACE TABLE t_michal_boucek_projekt_SQL_final AS -- pouze pro vyvoj - pak odkomentovat
SELECT
	cbd.country,
	cbd.`date`,
	cbd.confirmed,
	CASE
		WHEN t.tests_performed < 0 THEN 'invalid value' ELSE t.tests_performed
	END AS tests_performed,
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
FROM covid19_basic_differences AS cbd
LEFT JOIN covid19_tests AS t
	ON cbd.country = t.country
	AND cbd.`date` = t.`date`
LEFT JOIN economies AS e
	ON e.country = cbd.country
	AND e.`year` = 2020
LEFT JOIN lookup_table AS lt
	ON lt.country = cbd.country
	AND lt.province IS NULL -- cele soucty populace ve state
LEFT JOIN countries AS c
	ON c.country = cbd.country
LEFT JOIN ( -- gini agregace - nejaktualnejsi dostupny rok pro kazdou zemi
	SELECT 
		country,
		MAX(`year`) AS gini_year,
		gini
	FROM economies
	WHERE gini IS NOT NULL
	GROUP BY country
) AS ginitab
	ON cbd.country = ginitab.country
LEFT JOIN economies AS e2019
	ON e2019.country = cbd.country
	AND e2019.`year` = 2019
LEFT JOIN religions AS r
	ON r.country = cbd.country
	AND r.`year` = 2020
LEFT JOIN (
	SELECT 
		country,
		SUM(population) AS ssum
	FROM religions
	WHERE `year` = 2020
	GROUP BY country
) AS r_sum
	ON cbd.country = r_sum.country
LEFT JOIN life_expectancy AS le2015
	ON le2015.country = cbd.country
	AND le2015.`year` = 2015
LEFT JOIN life_expectancy AS le1965
	ON le1965.country = cbd.country
	AND le1965.`year` = 1965	
LEFT JOIN (
	SELECT
		country,
		`date`,
		ROUND(AVG(SUBSTRING_INDEX(temp, ' ', 1)),2) AS avg_daily_temp
	FROM t_michal_boucek_weather_projekt_sql_final
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
	FROM t_michal_boucek_weather_projekt_sql_final
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
	FROM t_michal_boucek_weather_projekt_sql_final
	GROUP BY country, `date`
) AS mgust
	ON mgust.country = cbd.country
	AND mgust.`date` = cbd.`date`
WHERE cbd.confirmed IS NOT NULL
	AND cbd.confirmed >= 0 -- vynechat nulove hodnoty
	AND cbd.country = 'Belgium' -- pouze pro vyvoj
	AND cbd.date = '2020-02-09' -- pouze pro vyvoj
ORDER BY cbd.country, cbd.`date`, r.religion
;