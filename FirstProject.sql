SELECT * FROM PortfolioProject.coviddeaths;


USE PortfolioProject;

SHOW tables;

UPDATE coviddeaths
SET continent = null
WHERE location = "Africa";


SELECT * FROM coviddeaths 
ORDER BY 3,4,2;

SELECT * FROM coviddeaths
WHERE location = "High Income" AND continent = '';

DELETE FROM coviddeaths
WHERE location = "High Income";

SELECT * FROM coviddeaths;


-- SELECT * FROM covidvaccinations order by 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;


-- Looking at total cases vs Total Deaths
-- Shows probability of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeaths
WHERE location LIKE '%India%'
ORDER BY 1,3;


-- Looking at Total Cases vs Population
-- Shows the percentage of population that got infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 As Covid_Infected_Population
FROM coviddeaths
-- WHERE location LIKE '%India%'
ORDER BY 1,5;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, 
		(MAX(total_cases/population))*100 AS Covid_Infected_Population
FROM coviddeaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths AS UNSIGNED)) AS Total_Death_Count
FROM coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC; 

-- Let's break things down by continent

-- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths AS UNSIGNED)) AS Total_Death_Count
FROM coviddeaths
WHERE continent IS NOT NULL	
GROUP BY continent
ORDER BY 2 DESC;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_cases)/SUM(new_deaths)*100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY DATE(1),2 ;


-- Looking at total population VS vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- CTE

With PopVsVac(continent, location, dates, population, vaccinations, RollingPeopleVaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS RellingPeopleVaccinated_Per FROM PopVsVac;


CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL;
    


