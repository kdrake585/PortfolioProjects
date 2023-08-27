
 SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is not null
 ORDER BY 1,2

 -- Looking at Total Cases vs Total Deaths

 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is not null
 --and location = 'United States'
 ORDER BY 1,2

 -- Looking at total cases vs population

 SELECT continent, location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentInfected
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE location = 'United States'
 and continent is not null
 ORDER BY 1,2

 -- What countries have the highest infection rates?

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY population, location
Order By PopulationPercentInfected DESC

-- What countries have the most deaths from COVID?

 SELECT location, MAX(total_deaths) as TotalDeathCount
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is not null
 GROUP BY location
 Order By TotalDeathCount DESC

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is null
and location not in ('world', 'european union', 'international')
and location not like '%income'
GROUP BY location
Order By TotalDeathCount DESC

 -- What countries have the highest death rate?

 SELECT location, population, MAX(total_deaths), MAX((total_deaths/population))*100 as DeathRate
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is not null
 GROUP BY population, location
 Order By DeathRate DESC

-- Let's take a look at them grouped by continent
--Showing the continents with the highest death counts per pop.
 SELECT location, MAX(total_deaths) as TotalDeathCount
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is null 
 and location not like '%income'
 GROUP BY location
 Order By TotalDeathCount DESC

 --Running tally of infection rate
 SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 GROUP BY location, population, date
 ORDER BY PercentPopulationInfected desc

 -- Global Numbers

 SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is not null
 ORDER BY 1,2

 --Cases, deaths, mortality rate by country
 SELECT SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is not null
 and new_deaths > '0'
 and new_cases > '0'
 --and location not like '%income'
 --and location not like 'European Union'
 --GROUP BY location
 ORDER BY 1,2

--Cases, deaths, mortality rate by region
 SELECT location, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is null
 and new_deaths > '0'
 and new_cases > '0'
 and location not like '%income'
 --and location not like 'European Union'
 GROUP BY location
 ORDER BY 1,2

 --Cases, deaths, mortality rate by income level
  SELECT location, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is null
 and new_deaths > '0'
 and new_cases > '0'
 and location like '%income'
 --and location not like 'European Union'
 GROUP BY location
 ORDER BY 1,2

--Cases, deaths, mortality rate global total
 SELECT location, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
 FROM [PortfolioProject].[dbo].[CovidDeaths]
 WHERE continent is null
 and new_deaths > '0'
 and new_cases > '0'
 and location = 'World'
 --and location not like 'European Union'
 GROUP BY location
 ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccRunningTotal
FROM [PortfolioProject].[dbo].[CovidDeaths] as dea
Join [PortfolioProject].[dbo].[CovidVaccinations] as vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVacc (Continent, Location, Date, Population, New_vaccinations, VaccRunningTotal)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(convert(int, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccRunningTotal
FROM [PortfolioProject].[dbo].[CovidDeaths] as dea
Join [PortfolioProject].[dbo].[CovidVaccinations] as vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (VaccRunningTotal/Population)*100 as PercentPopVacc
FROM PopvsVacc
WHERE LOCATION = 'United States'

--TEMP TABLE to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccRunningTotal numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccRunningTotal
FROM [PortfolioProject].[dbo].[CovidDeaths] as dea
Join [PortfolioProject].[dbo].[CovidVaccinations] as vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (VaccRunningTotal/Population)*100
FROM #PercentPopulationVaccinated

--Creating Views

--View for Percent of the Population Vaccinated as a running total 
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(convert(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccRunningTotal
FROM [PortfolioProject].[dbo].[CovidDeaths] as dea
Join [PortfolioProject].[dbo].[CovidVaccinations] as vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3

--View for Perecent of the population infected as of 8/11/2023
CREATE VIEW PercentPopInfection as
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY population, location
--Order By PopulationPercentInfected DESC

--View for Cases, deaths, mortality rate by country
CREATE VIEW MortalitybyCountry as
SELECT Location, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
and new_deaths > '0'
and new_cases > '0'
--and location not like '%income'
--and location not like 'European Union'
GROUP BY location


--View for Cases, deaths, mortality rate by region
CREATE VIEW MortalitybyRegion as
SELECT location, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is null
and new_deaths > '0'
and new_cases > '0'
and location not like '%income'
--and location not like 'European Union'
GROUP BY location

--Cases, deaths, mortality rate by income level
CREATE VIEW MortalitybyIncome as
SELECT location, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is null
and new_deaths > '0'
and new_cases > '0'
and location like '%income'
--and location not like 'European Union'
GROUP BY location

--Cases, deaths, mortality rate global total
CREATE VIEW MortalityWorldTotal as
SELECT location, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is null
and new_deaths > '0'
and new_cases > '0'
and location = 'World'
--and location not like 'European Union'
GROUP BY location

SELECT *
FROM PercentPopInfection
ORDER BY PopulationPercentInfected DESC






