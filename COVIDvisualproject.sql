SELECT *
FROM PortfolioCovid..CovidVaccinations
ORDER BY 3,4

SELECT *
FROM PortfolioCovid..CovidDeaths
ORDER BY 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioCovid..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths VS Death Percentage 
-- Shows likelihood of dying if you contract COVID 

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentFatal
From PortfolioCovid..CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- looking at total_cases VS the Population
SELECT Location, Date, total_cases, population, (total_cases/population)*100 as PercentPopInfected
From PortfolioCovid..CovidDeaths
Where location like '%australia%'
ORDER BY 1,2

-- looking at countries with highest infection rates 

SELECT location, population, MAX(total_cases) as HighInfectionCount, MAX(total_cases/population)*100 as PercentPopInfected
From PortfolioCovid..CovidDeaths
GROUP BY location, population
ORDER BY 4 desc

--showing countries with the highest death percentage

SELECT location, population, MAX(total_deaths) as DeathCount, MAX(total_deaths/population)*100 as PercentPopDead
From PortfolioCovid..CovidDeaths
Where continent is not null
GROUP BY location, population
ORDER BY 3 desc

-- breakdown by continent

SELECT location, MAX(total_deaths) as DeathCount, MAX(total_deaths/population)*100 as PercentPopDead
From PortfolioCovid..CovidDeaths
WHERE continent IS NULL AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY 3 desc

-- Global numbers

SELECT Date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioCovid..CovidDeaths
Where continent is not null
AND new_cases > 0
GROUP BY date
ORDER BY 1,2


-- Looking at total population VS vaccination
With PopVSVac (Continent, Location, Date, Population, New_vaccinations, VaccinationsToDate)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, COALESCE(SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date), 0) AS VaccinationsToDate
FROM PortfolioCovid..CovidVaccinations vac
JOIN PortfolioCovid..CovidDeaths dea
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
)
Select * , (VaccinationsToDate/Population)*100
From PopVSVac
order by 2,3

-- Temp Table

DROP Table if exists #PercentPopulationVacccinated
Create Table #PercentPopulationVacccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
VaccinationsToDate numeric
)

Insert Into #PercentPopulationVacccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, COALESCE(SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date), 0) AS VaccinationsToDate
FROM PortfolioCovid..CovidVaccinations vac
JOIN PortfolioCovid..CovidDeaths dea
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null

Select * , (VaccinationsToDate/Population)*100
From #PercentPopulationVacccinated

-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, COALESCE(SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date), 0) AS VaccinationsToDate
FROM PortfolioCovid..CovidVaccinations vac
JOIN PortfolioCovid..CovidDeaths dea
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

