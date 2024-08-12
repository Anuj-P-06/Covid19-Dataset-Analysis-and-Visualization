---------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------COVID DATASET----------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- Queries Performed-> Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Exploring Data
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Total Cases vs Total Deaths
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Total Cases vs Population
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BREAKING THINGS DOWN BY CONTINENT
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(int,vac.new_vaccinations)) 
           OVER (Partition by dea.Location 
                 Order by CAST(dea.location AS VARCHAR(255)), dea.Date) as RollingPeopleVaccinated
    From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
    where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Using Temp Table to perform Calculation on PartitionBy in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),Location nvarchar(255),Date datetime,Population numeric,New_vaccinations numeric,RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
       OVER (Partition by dea.Location 
             Order by CAST(dea.location AS VARCHAR(255)), dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating View to store data for later visualizations
CREATE VIEW 
PercentageofPopulationVaccinatedd AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.Location Order by CAST(dea.location AS VARCHAR(255)), dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;

select * from PercentageofPopulationVaccinatedd

--------------------------------------------------------------------------------------------------------------------------------------------------------------
x----------x----------x----------x----------x----------x----------x----------x----------x----------x----------x----------x-----------x-----------x-----------x
