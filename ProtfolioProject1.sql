Select *
From ProtfolioProject..CovidDeaths
Where Continent is not null
Order by 3,4

Select *
From ProtfolioProject..CovidVaccination
Order by 3,4

--using this table
Select Location, Date, total_cases, new_cases, total_deaths, population
From ProtfolioProject1..CovidDeaths
Where Continent is not null
Order by 1, 2

--looking at total cases vs total deaths
--Likelihood of dying due to Covid in your country
Select Location, date, total_cases, total_deaths, Cast((total_deaths/ total_cases)*100 as Decimal(10,4)) as DeathPercentage
From ProtfolioProject1..CovidDeaths
Where location = 'India'
and Continent is not null
Order by 1, 2

--Looking at total cases vs Population
--Percentage of population got Covid
Select location, date, total_cases, population, Cast((total_cases/population)*100 as Decimal(10,4)) as InfectionRate
From ProtfolioProject1..CovidDeaths
Where Continent is not null
--Where location = 'India'
Order by 1, 2

--Countries with Highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From ProtfolioProject1..CovidDeaths
Where Continent is not null
Group by Location, population
Order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From ProtfolioProject1..CovidDeaths
Where Continent is not null
Group by Location
Order by TotalDeathCount desc

--Break things by Continent
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From ProtfolioProject1..CovidDeaths
Where Continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From ProtfolioProject..CovidDeaths
Where Continent is not null


Select *
From ProtfolioProject1..CovidVaccinations

--Looking at total population vs vaccination
--Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProtfolioProject1..CovidDeaths dea
Join ProtfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/ Population)*100
From PopvsVac


--TEMP TABLE
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProtfolioProject1..CovidDeaths dea
Join ProtfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

Select *, (RollingPeopleVaccinated / Population) * 100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization
Create VIEW PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProtfolioProject1..CovidDeaths dea
Join ProtfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

