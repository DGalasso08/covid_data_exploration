-- COVID 19 DATA EXPLORATION PROJECT

USE Projects;


-- The big picture view of data
SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM covid_death
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking at total_cases vs total_deaths by country: whatÕs the likelihood of dying if infected in your country (US)
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases) *100 AS percent_deaths
FROM covid_death
WHERE location LIKE '%states'
AND continent IS NOT NULL
ORDER BY 1,2;


-- Total_cases vs population: what percentage of population has contracted covid
SELECT
    location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 AS percent_pop_infected
FROM covid_death
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Highest infection rate compared to population
SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population)*100) AS highest_infection_rate
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY 1, 2
ORDER BY 4 DESC;


-- Countries with highest death count per population
-- Using Cast Function
SELECT
    location,
    MAX(CAST(total_deaths AS double)) AS highest_death_count
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- Highest Death Rate Per Population
SELECT
    location,
    population,
    MAX(CAST(total_deaths AS double)) AS highest_death_count,
    MAX((total_deaths/population)*100) AS highest_death_rate
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY 1, 2
ORDER BY 4 DESC;


-- Breaking Down By Continent

-- Continents with highest death count per population
SELECT
    continent,
    MAX(CAST(total_deaths AS double)) AS highest_death_count
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;



-- GLOBAL NUMBERS


SELECT	
    SUM(new_cases) AS global_new_cases,
    SUM(new_deaths) AS global_new_deaths,
    (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
FROM covid_death
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Joining 2 tables
SELECT *
FROM covid_death AS dea
	JOIN covid_vacc AS vac
		ON dea.location = vac.location
        AND dea.date = vac.date;
        
-- Total population vs total vaccinations: shows percent of population with at least one vaccination
-- Rolling count using Partion By
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS double)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM covid_death AS dea
	JOIN covid_vacc AS vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform calculation on previous on the Partion By clause in previous query

WITH pop_vs_vacc (continent, location, date, population, new_vaccinations, rolling_people_vacc)
AS
(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS double)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM covid_death AS dea
	JOIN covid_vacc AS vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)
SELECT 
    *,
    (rolling_people_vacc/population)*100 AS rolling_percent_vacc
FROM pop_vs_vacc;

-- Using Temp Table instead of CTE on same query
DROP TABLE IF EXISTS percent_pop_vaxxed;
CREATE TEMPORARY TABLE percent_pop_vaxxed
(
continent varchar(500),
location varchar(500),
date datetime,
population int,
new_vaccinations int,
rolling_people_vacc bigint
);

-- USING TEMP TABLE
INSERT INTO percent_pop_vaxxed(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS double)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM covid_death AS dea
	JOIN covid_vacc AS vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
);

SELECT 
	*,
    (rolling_people_vacc/population)*100 AS rolling_percent_vacc
FROM percent_pop_vaxxed;

-- Creating Views to store data for later visualizations

-- This is percent of population vaccinated
CREATE VIEW percent_pop_vaxxed AS 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS double)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM covid_death AS dea
	JOIN covid_vacc AS vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- this is new cases and deaths by day globally
CREATE VIEW daily_global_new_cases_deaths AS
SELECT
    date,
    SUM(new_cases) AS global_new_cases,
    SUM(new_deaths) AS global_new_deaths
FROM covid_death
WHERE continent IS NOT NULL;

-- new vaccinations by day
CREATE VIEW new_vacc_by_day AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
FROM covid_death AS dea
	JOIN covid_vacc AS vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;  

-- global death percent by day
CREATE VIEW global_daily_death_rate AS
SELECT
    date,
    SUM(new_cases) AS global_new_cases,
    SUM(new_deaths) AS global_new_deaths,
    (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
FROM covid_death
WHERE continent IS NOT NULL;

-- death rate by continent
CREATE VIEW death_rate_by_continent AS
SELECT
    location,
    MAX(CAST(total_deaths AS double)) AS highest_death_count
FROM covid_death
WHERE continent IS NULL;

-- infection rate by country
CREATE VIEW max_inf_rate AS
SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population)*100) AS highest_infection_rate
FROM covid_death;



  


