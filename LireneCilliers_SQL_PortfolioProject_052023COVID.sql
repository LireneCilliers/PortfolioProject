SELECT *
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    ORDER BY 3,4

SELECT *
    FROM PortfolioProject.dbo.CovidVaccinations
    ORDER BY 3,4

SELECT [location], [date], total_cases, new_cases, total_deaths, population
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract COVID in Cambodia
SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE LOCATION LIKE '%CAMBODIA%'
    ORDER BY 1,2

--Looking at total cases vs total population
SELECT [location], [date], population, total_cases, (total_cases/population)*100 AS PercentageOfPopulationGotCOVID
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE LOCATION LIKE '%CAMBODIA%'
    ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentOfPopulationInfected
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY location, population
    ORDER BY PercentOfPopulationInfected DESC

--Looking at countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY TotalDeathCount DESC

--Cases by continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY continent
    ORDER BY TotalDeathCount DESC

--Global cases, deaths, and death% overall
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    ORDER BY 1,2

--Global cases, deaths, and death% per day 
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY date
    ORDER BY 1,2

--CTE
WITH PopulationVSVaccination (continent, location, date, population, new_vaccinations, PeopleVaccinatedRolling)
AS
(
--Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRolling
    FROM PortfolioProject.dbo.CovidDeaths dea
    JOIN PortfolioProject.dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (PeopleVaccinatedRolling/Population)*100
    FROM PopulationVSVaccination

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    PeopleVaccinatedRolling NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRolling
    FROM PortfolioProject.dbo.CovidDeaths dea
    JOIN PortfolioProject.dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date

SELECT *, (PeopleVaccinatedRolling/Population)*100
    FROM #PercentPopulationVaccinated

--Creating view to store dataa for later visualisation 
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRolling
    FROM PortfolioProject.dbo.CovidDeaths dea
    JOIN PortfolioProject.dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated