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
	ROUND((r.population/r_sum.ssum)*100,2) AS percent_religion
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
WHERE cbd.confirmed IS NOT NULL
	AND cbd.confirmed >= 0 -- vynechat nulove hodnoty
	AND cbd.country = 'Albania' -- pouze pro vyvoj
	#AND cbd.date = '2020-01-23' -- pouze pro vyvoj
# ORDER BY cbd.country, cbd.`date`, r.religion -- vypnuto pro vyvoj, zpomaluje
;