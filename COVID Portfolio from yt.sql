select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by  1,2

--Looking at Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%indo%'
and continent is not null
order by  1,2

-- Looking at Total Cases vs Populaton
-- Show what percentage of populatin got covid
select location, date, population, total_cases, (total_deaths/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths
where Location like '%indo%'
order by  1,2

--Looking at countries with Highest Infection Rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where Location like '%indo%'
group by location, population
order by  PercentagePopulationInfected desc

-- Showing Countries with highest DeathCount per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like '%indo%'
where continent is not null
group by location
order by  TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
-- Showing continents with thew highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like '%indo%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where Location like '%indo%'
where continent is not null
--group by date
order by  1,2


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as rollingPeopleVaccinated,
--	(rollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as rollingPeopleVaccinated
--	,(rollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100
from PopvsVac



-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as rollingPeopleVaccinated
--	,(rollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated






--Creating view to share data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as rollingPeopleVaccinated
--	,(rollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3




select *
from PercentPopulationVaccinated