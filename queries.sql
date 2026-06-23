-- _______________________Create Forestation View__________________________


CREATE VIEW
  forestation AS
SELECT
  f.country_code,
  f.country_name,
  f.year,
  f.forest_area_sqkm,
  l.total_area_sq_mi*2.59 AS total_area_sqkm,
  f.forest_area_sqkm/(l.total_area_sq_mi*2.59)*100 AS percentage_forest,
  r.region AS region,
  r.income_group
FROM
  forest_area f
  JOIN land_area l ON f.country_code=l.country_code
  AND f.year=l.year
  JOIN regions r ON f.country_code=r.country_code;




-- Global Situation


-- _______________________Forest area of the world in 1990________________________

SELECT forest_area_sqkm
  FROM forest_area
 WHERE country_name = 'World' AND year = 1990;



-- ________________________Forest area of world in 2016____________________________
SELECT forest_area_sqkm
  FROM forest_area
 WHERE country_name = 'World' AND year = 2016;






-- ________________Abs Change in forest area of world from 1990 to 2016_______________

SELECT (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 1990) -
       (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 2016) AS absolute_loss;



-- _________________ Change in forest area of world from 1990 to 2016_________________
SELECT ((SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 1990) -
       (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 2016)) /
        (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 1990) * 100 AS percent_loss



-- ________Country having total area close to amt of forest area lost in world____________

SELECT f.country_name, f.total_area_sqkm
FROM forestation AS f 
WHERE f.year ='2016' AND f.total_area_sqkm <= ((SELECT
((SELECT forest_area_sqkm AS forest_area_1990
FROM forestation
WHERE country_name = 'World' AND year='1990') -
(SELECT forest_area_sqkm as forest_area_2016
FROM forestation
WHERE country_name = 'World' AND year='2016')) AS forest))
ORDER BY f.total_area_sqkm DESC
LIMIT 1;





-- Regional Outlook



-- ____________________Create Region and their percent forest View___________________

SELECT year, region, ((SUM(forest_area_sqkm) / SUM(total_area_sqkm)) * 100) AS forest_percent
FROM forestation
WHERE year IN ('1990', '2016')
GROUP BY region, year
ORDER BY region, year;




-- __________________Percent forest of the entire world in 2016____________________

SELECT percentage_forest
FROM forestation AS f
WHERE f.country_name='World' AND f.year='2016'



-- _______________Region had the HIGHEST percent forest in 2016____________________

SELECT region, ((SUM(forest_area_sqkm) / SUM(total_area_sqkm)) * 100) AS net_forest_percent
FROM forestation
WHERE year IN ('2016')
GROUP BY region, year
ORDER BY net_forest_percent DESC
LIMIT 1;



-- _________________Region had the LOWEST percent forest in 2016___________________

SELECT region, ((SUM(forest_area_sqkm) / SUM(total_area_sqkm)) * 100) AS net_forest_percent
FROM forestation
WHERE year IN ('2016')
GROUP BY region, year
ORDER BY net_forest_percent ASC
LIMIT 1;


-- ____________________Percent forest of the entire world in 1990_____________________

SELECT percentage_forest
FROM forestation AS f
WHERE f.country_name='World' AND f.year='1990'



-- __________________Region had the HIGHEST percent forest in 1990_________________

SELECT region, ((SUM(forest_area_sqkm) / SUM(total_area_sqkm)) * 100) AS net_forest_percent
FROM forestation
WHERE year IN ('1990')
GROUP BY region, year
ORDER BY net_forest_percent DESC
LIMIT 1;




-- __________________Region had the LOWEST percent forest in 2016_________________

SELECT region, ((SUM(forest_area_sqkm) / SUM(total_area_sqkm)) * 100) AS net_forest_percent
FROM forestation
WHERE year IN ('1990')
GROUP BY region, year
ORDER BY net_forest_percent ASC
LIMIT 1;



-- ____________Regions of world DECREASED in forest area by 1990 to 2016____________

SELECT final.region FROM (SELECT t1990.region, t1990.net_forest_area1990, t2016.net_forest_area2016,
(t1990.net_forest_area1990-t2016.net_forest_area2016) as diff
FROM   
(SELECT year, region, (SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100) AS net_forest_area1990
FROM forestation
WHERE year IN ('1990')
GROUP BY region, year) AS t1990
JOIN
(SELECT year, region, (SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS net_forest_area2016
FROM forestation
WHERE year IN ('2016')
GROUP BY region, year) AS t2016
ON t1990.region=t2016.region
ORDER BY diff DESC
LIMIT 3) AS final



-- Country Level Detail



-- _____________________2 Countries that increased in forest Area__________________

SELECT final.country_name FROM (SELECT t1.country_name,
       t2.forest_area_2016 - t1.forest_area_1990 AS forest_increase
  FROM (SELECT country_name, forest_area_sqkm AS forest_area_1990
          FROM forest_area
         WHERE year = '1990') t1
  JOIN (SELECT country_name, forest_area_sqkm AS forest_area_2016
          FROM forest_area
         WHERE year = '2016') t2
    ON t1.country_name = t2.country_name
 WHERE t2.forest_area_2016 > t1.forest_area_1990
 ORDER BY forest_increase DESC
 LIMIT 2) AS final


-- _____________________China and Us increased by forest Area__________________

SELECT final.country_name FROM (SELECT t1.country_name,
       t2.forest_area_2016 - t1.forest_area_1990 AS forest_increase
  FROM (SELECT country_name, forest_area_sqkm AS forest_area_1990
          FROM forest_area
         WHERE year = '1990') t1
  JOIN (SELECT country_name, forest_area_sqkm AS forest_area_2016
          FROM forest_area
         WHERE year = '2016') t2
    ON t1.country_name = t2.country_name
 WHERE t2.forest_area_2016 > t1.forest_area_1990
 ORDER BY forest_increase DESC
 LIMIT 2) AS final

-- _____________________Countries that increased by percentage_____________________

SELECT t1.country_name,
       (t2.forest_area_2016 - t1.forest_area_1990) / t1.forest_area_1990 AS percent_forest_increase
  FROM (SELECT country_name, forest_area_sqkm AS forest_area_1990
          FROM forest_area
         WHERE year = '1990') t1
  JOIN (SELECT country_name, forest_area_sqkm AS forest_area_2016
          FROM forest_area
         WHERE year = '2016') t2
    ON t1.country_name = t2.country_name
 WHERE t2.forest_area_2016 > t1.forest_area_1990
 ORDER BY percent_forest_increase DESC
 LIMIT 5;




-- ______5 countries saw the largest amount decrease in forest area from 1990 to 2016____

SELECT final.country_name, final.region from (SELECT t1990.region, t1990.country_name AS country_name,t1990.forest_area_1990,t2016.forest_area_2016,
(t1990.forest_area_1990-t2016.forest_area_2016) AS forest_area_diff
FROM
(SELECT f.region, f.country_name, f.forest_area_sqkm AS forest_area_1990
FROM forestation AS f
WHERE year IN (1990)
ORDER BY  country_name) AS t1990
JOIN 
(SELECT f.region, f.country_name, f.forest_area_sqkm AS forest_area_2016
FROM forestation AS f
WHERE year IN (2016)
ORDER BY  country_name) AS t2016
ON t1990.country_name=t2016.country_name
WHERE (t1990.forest_area_1990-t2016.forest_area_2016) IS NOT NULL and
t1990.region != 'World'
ORDER BY forest_area_diff DESC
LIMIT 5) AS final



-- _____5 countries saw the largest percent decrease in forest area from 1990 to 2016_____

SELECT final.country_name, final.region FROM (SELECT t1990.region, t1990.country_name AS country_name,t1990.forest_area_1990,t2016.forest_area_2016,
(t1990.forest_area_1990-t2016.forest_area_2016) AS forest_area_diff,
((t1990.forest_area_1990 - t2016.forest_area_2016) / t1990.forest_area_1990) * 100 AS percentage_decrease
FROM
(SELECT f.region, f.country_name, f.forest_area_sqkm AS forest_area_1990
FROM forestation AS f
WHERE year IN (1990)
ORDER BY  country_name) AS t1990
JOIN
(SELECT f.region, f.country_name, f.forest_area_sqkm AS forest_area_2016
FROM forestation AS f
WHERE year IN (2016)
ORDER BY  country_name) AS t2016
ON t1990.country_name=t2016.country_name
WHERE (t1990.forest_area_1990-t2016.forest_area_2016) IS NOT NULL
ORDER BY percentage_decrease DESC
LIMIT 5) AS final





-- ___ If countries were grouped by percent forestation in quartiles, which group had the__ _________________________most countries in it in 2016___________________________

SELECT t1.quartile, COUNT(*) AS country
FROM (SELECT country_name, percentage_forest,
	   CASE WHEN percentage_forest < 25 THEN 1
            WHEN percentage_forest <= 50 THEN 2
            WHEN percentage_forest <= 75 THEN 3
            ELSE 4 END AS quartile
 FROM forestation
 WHERE year = '2016' AND percentage_forest IS NOT NULL) AS t1
 GROUP BY t1.quartile
 ORDER BY country DESC
 LIMIT 1;



-- _____ All of the countries and region that were in the 4th quartile (percent forest > 75%) in 2016.____

SELECT t1.quartile, t1.country_name,  t1.region
FROM (SELECT region, country_name, percentage_forest,
	  CASE WHEN percentage_forest < 25 THEN 1
               WHEN percentage_forest <= 50 THEN 2
            WHEN percentage_forest <= 75 THEN 3
            ELSE 4 END AS quartile
  FROM forestation
 WHERE YEAR = '2016' AND percentage_forest IS NOT NULL) AS t1
 WHERE t1.quartile='4'
 ORDER BY country_name;


-- _______Countries had a percent forestation higher than the United States in 2016_______

WITH t1 AS (
    SELECT percentage_forest
    FROM forestation 
    WHERE year = '2016' AND country_name = 'United States'
)
SELECT count(*)
FROM forestation
WHERE percentage_forest > (SELECT percentage_forest FROM t1) AND year ='2016'

