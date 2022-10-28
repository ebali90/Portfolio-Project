-- Data taken from https://ourworldindata.org/covid-deaths


-- COVID19 numbers

Select *
From Project..CovidDeaths
Order by 3,4


Select *
From Project..CovidVaccines
Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs. Total Deaths, and death percentage 
-- In United States

Select Location, date, total_cases, total_deaths, round(((total_deaths/total_cases)*100),2) as DeathPercentage
From Project..CovidDeaths
Where total_cases is not null and total_deaths is not null and location like '%united states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of pupulation got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From Project..CovidDeaths
Where total_cases is not null and total_deaths is not null and location like '%united states%'
Order by 1,2

-- Looking at top 10 countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as CovidPercentage
From Project..CovidDeaths
Where continent is not null
Group by Location, population
Order by HighestInfectionCount DESC
	OFFSET 0 ROWS
	FETCH NEXT 10 ROWS ONLY;

-- Showing countries with the highest death count per population :(

Select Location, MAX(cast(total_deaths as int)) TotalDeathCount
From Project..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount DESC

-- Continents with highest deaths :( !

Select Location, MAX(cast(total_deaths as int)) TotalDeathCount
From Project..CovidDeaths
Where continent is null and location not in ('World', 'High income', 'Low income', 'International', 'Lower middle income', 'Upper middle income')
Group by Location
Order by TotalDeathCount DESC

-- Global Numbers 

Select  
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	CONCAT(round((sum(cast(new_deaths as int)) / sum(new_cases) *100), 2), '%') as DeathPercentage
From Project..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Population vs Vaccination

With PopVsVac (continent, location, date, population, new_vaccionations, vaccinatedppl)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccinatedPPL
From Project..CovidDeaths dea
join Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
)

Select *, (vaccinatedppl/population)*100 as VaccinatedPercentage
From PopVsVac
Order by 1,2

-- Temp Table

DROP TABLE IF EXISTS #VaccinatedPercentage
CREATE TABLE #VaccinatedPercentage
(
Continent varchar(255),
Location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinatedppl numeric, 
)

INSERT INTO #VaccinatedPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccinatedPPL
From Project..CovidDeaths dea
join Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null

-- Create View

Create View VaccinatedPercentage as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccinatedPPL
From Project..CovidDeaths dea
join Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
