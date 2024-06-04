SELECT DISTINCT TOP 10 continent FROM CovidDeaths

SELECT DISTINCT iso_code, location FROM CovidVaccinations
WHERE iso_code = 'OWID_AFR'
ORDER BY 1

SELECT *
FROM CovidDeaths
WHERE CONTINENT IS  not NULL

--- 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS  not NULL
ORDER BY 1,2

--- Looking at Total Cases vs Total Deaths 



SELECT location, date, total_cases, total_deaths, ROUND ((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Costa Rica'
ORDER BY 1,2 
GO


--- Looking at Total Cases vs Population 
--- Shows the percentage of the population infected with covid



SELECT location, date, population, total_cases, ROUND ((total_cases/population)*100, 2) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Costa Rica'
ORDER BY 1,2 
GO



---Looking at countries with highest infection rate compared to population



SELECT location, population, MAX (total_cases) AS HighestInfectionCount
, ROUND ( MAX ((total_cases/population))*100, 2) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS  not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 
GO



---Showing countries with highest death count per Population



SELECT location, population, MAX (Cast (total_deaths as INT)) AS TotalDeathCount
, ROUND ( MAX ((total_deaths/population))*100, 2) AS DeceasedPercentage
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS  not NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC
GO



---BREAKING THING DOWN TO CONTINENTS
--- Showing the continents with the highest death count



SELECT location, MAX (Cast (total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
GO


---GLOBAL NUMBERS

SELECT SUM (new_cases) AS TotalNewCases ,SUM (CAST (new_deaths AS int)) AS TotalNewDeaths,
SUM (CAST(new_deaths as int)) / SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1
GO

---TOTAL POPULATION VS VACCINATIONS


SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM (CONVERT (INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as
RollingPeopleVaccinated
FROM CovidVaccinations vac
JOIN CovidDeaths dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null
ORDER BY 2,3




----- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM (CONVERT (INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as
RollingPeopleVaccinated
FROM CovidVaccinations vac
JOIN CovidDeaths dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, Round ((RollingPeopleVaccinated / population)*100,2) as PopulationVaccinationPercentage
FROM PopvsVac
ORDER BY 2,3


---Creating view for future visualization

CREATE VIEW PercentPopulationVaccinated 
as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM (CONVERT (INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as
RollingPeopleVaccinated
FROM CovidVaccinations vac
JOIN CovidDeaths dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null
--ORDER BY 2,3


