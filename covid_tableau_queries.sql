
/*
Queries Used for Tableau Viz
*/

-- COVID DASHBOARD QUERIES

-- 1.
-- Shows total of new cases, new deaths and the death percentage
SELECT 
    SUM(new_cases) AS total_new_cases,
    SUM(new_deaths) AS total_new_deaths,
    (SUM(new_deaths)/SUM(new_cases))*100 AS percent_deaths
FROM covid_death
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- 2.
-- Shows the total deaths by continent, excluding those which are other groupings
SELECT 
    location,
    SUM(new_deaths) AS total_deaths
FROM covid_death
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income','Lower middle income', 'Low income')
GROUP BY 1
ORDER BY 2 DESC;


-- 3.
-- Shows the highest percent of population infected by country descending
SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    (MAX(total_cases)/population)*100 AS percent_population_infected
FROM covid_death
GROUP BY 1,2
ORDER BY 4 DESC;


-- 4.
-- Shows highest percent of countries by date
SELECT
    location,
    population,
    date,
    MAX(total_cases) AS highest_infection_count,
    (MAX(total_cases)/population)*100 AS percent_population_infected
FROM covid_death
GROUP BY 1,2,3
ORDER BY 5 DESC;



-- COVID VACCINATIONS DASHBOARD QUERIES

-- 5.
-- total maximum people vaccinated by country
SELECT 
    dea.continent,
    dea.location,
    dea.population,
    MAX(CAST(vac.people_vaccinated AS double)) AS max_people_vaccinated,
    (MAX(CAST(vac.people_vaccinated AS double))/dea.population)*100 AS highest_percent_vaccinated
FROM covid_death AS dea
	JOIN covid_vacc AS vac
	    ON dea.location = vac.location
            AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY 1,2,3
ORDER BY 5 DESC;


-- 6.
-- Shows vaccinations over time by country
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    MAX(CAST(vac.people_vaccinated AS double)) AS max_people_vaccinated
FROM covid_death AS dea
	JOIN covid_vacc AS vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY 1,2
ORDER BY 1;


-- 7. 
-- Global Total Vaccinations and Percent of Population
SELECT 
    dea.population,
    MAX(CAST(vac.people_vaccinated AS double)) AS max_people_vaccinated,
    (MAX(CAST(vac.people_vaccinated AS double))/dea.population)*100 AS world_pop_vaccinated
FROM covid_death AS dea
	JOIN covid_vacc AS vac
	    ON dea.location = vac.location
            AND dea.date = vac.date
WHERE dea.location = 'World'
GROUP BY 1
ORDER BY 3 DESC;


-- 8. 
-- Total Vaccinations by Continent
SELECT 
	dea.location,
    MAX(CAST(vac.people_vaccinated AS double)) AS total_vaccinations
FROM covid_death AS dea
	INNER JOIN covid_vacc AS vac
	    ON dea.date = vac.date
            AND dea.location = vac.location
WHERE dea.continent IS NULL
AND dea.location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income','Lower middle income', 'Low income')
GROUP BY 1
ORDER BY 2 DESC;




