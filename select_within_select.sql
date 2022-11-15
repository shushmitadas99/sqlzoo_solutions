-- SELECT WITHIN SELECT TUTORIAL

-- 1: List each country name where the population is larger than that of 'Russia'.
SELECT name FROM world
  WHERE population >
     (SELECT population FROM world
      WHERE name='Russia');
-- **Note: The nested SELECT subquery must return only ONE column/value**

-- 2: Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.
-- Per capita = gdp/population
SELECT name 
  FROM world 
  WHERE continent = 'Europe' 
    AND gdp/population > (
      SELECT gdp/population
        FROM world
        WHERE name = 'United Kingdom'
  );


-- 3: List the name and continent of countries in the continents containing either Argentina 
-- or Australia. Order by name of the country.
SELECT name, continent
  FROM world
  WHERE continent IN (
    SELECT continent
      FROM world
      WHERE name LIKE 'Argentina'
      OR name LIKE 'Australia'
  );


  -- 4: Which country has a population that is more than United Kingdom but less than Germany? 
  -- Show the name and the population.
  SELECT name, population
    FROM world
    WHERE population > (
        SELECT population FROM world
        WHERE name = 'United Kingdom')
    AND population < (
        SELECT population FROM world
        WHERE name = 'Germany'
    );


-- 5: Germany (population 80 million) has the largest population of the countries in Europe. 
-- Austria (population 8.5 million) has 11% of the population of Germany.
-- Decimal places: You can use the function ROUND to remove the decimal places.
-- Percent symbol %: You can use the function CONCAT to add the percentage symbol.
-- Show the name and the population of each country in Europe. Show the population as a percentage 
-- of the population of Germany.
SELECT name, 
       CONCAT(ROUND(100*population/(SELECT population
                               FROM world
                               WHERE name = 'Germany'), 0), '%')
  AS percentage
  FROM world
  WHERE continent = 'Europe';


-- Tutorial: We can use the word ALL to allow >= or > or < or <=to act over a list. For example, you 
-- can find the largest country in the world, by population with this query:
SELECT name
  FROM world
 WHERE population >= ALL(SELECT population
                           FROM world
                           WHERE population>0);


-- 6: Which countries have a GDP greater than every country in Europe? [Give the name only.] 
-- (Some countries may have NULL gdp values)
SELECT name
  FROM world
  WHERE gdp > ALL(SELECT gdp
                    FROM world
                    WHERE gdp>0 AND continent='Europe');


-- 7: Find the largest country (by area) in each continent, show the continent, the name and the area:
-- The below example is known as a correlated or synchronized sub-query.
-- A correlated subquery works like a nested loop: the subquery only has access to rows related to a single 
-- record at a time in the outer query. The technique relies on table aliases to identify two different uses of 
-- the same table, one in the outer query and the other in the subquery.
-- One way to interpret the line in the WHERE clause that references the two table is “… where the correlated values are the same”.
-- In the example provided, you would say:

-- “select the country details from world where the population is greater than or equal to the 
-- population of all countries where the continent is the same”.
SELECT continent, name, area 
  FROM world x
  WHERE area >= ALL(
    SELECT area FROM world y 
    WHERE x.continent = y.continent AND y.area>0
  );


-- 8: List each continent and the name of the country that comes first alphabetically.
SELECT continent, name 
FROM world x 
WHERE name <= ALL(
  SELECT name FROM world y WHERE x.continent = y.continent
);

----------------------------Difficult Questions That Utilize Techniques Not Covered In Prior Sections-------------------------------

-- 9: Find the continents where all countries have a population <= 25000000. Then find the names of the countries associated with these continents. 
-- Show name, continent and population.
SELECT name, continent, population 
FROM world WHERE continent IN (
  SELECT continent FROM world  x WHERE 25000000 >= (SELECT MAX(population) FROM world y WHERE x.continent = y.continent)
);
-- or
SELECT y.name, y.continent, y.population
FROM world AS y
JOIN
(SELECT continent, max(population) as max_population
FROM world
GROUP BY continent
HAVING max(population) <= 25000000) AS x
ON y.continent = x.continent


--10: Some countries have populations more than three times that of all of their neighbours (in the same continent). Give the countries and continents.
SELECT name, continent FROM world x
WHERE population > ALL(
  SELECT population*3 FROM world y
  WHERE y.continent = x.continent AND x.name <> y.name
);