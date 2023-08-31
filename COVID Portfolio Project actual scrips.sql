select *
from Portfolio_Project..CovidDeaths$
where continent is not null
order by 3,4

select *
from Portfolio_Project..CovidVaccinations$
order by 3,4

---- select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you could die in India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths$
where location like '%India%'
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as Percentage_Population_Infected
from Portfolio_Project..CovidDeaths$
-- where location like '%India%'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as Highest_Infection_Count,
	max((total_cases/population))*100 as Percent_Population_Infected
from Portfolio_Project..CovidDeaths$
-- where location like '%India%'
group by location, population
order by Percent_Population_Infected desc

-- Showing Countires with Highest Death Count per Population

select location, max(total_deaths) as Total_Death_Count
from Portfolio_Project..CovidDeaths$
-- where location like '%India%'
where continent is not null
group by location
order by Total_Death_Count desc

-- LET'S BREAK THIS DOWN BY CONTINENT
-- Showing continents with highest death count per population

select continent, max(total_deaths) as Total_Death_Count
from Portfolio_Project..CovidDeaths$
-- where location like '%India%'
where continent is not null
group by continent
order by Total_Death_Count desc


-- Global Numbers

select sum(new_cases), sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as
	Death_Percentage
from CovidDeaths$
where continent is not null
-- where location like '%India%'
-- group by date
order by 1,2

-- Looking at Total Population va Vaccinations

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as Rolling_people_Vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE

with PopvsVac(continent, location, date, population, new_vaccinations, Rolling_people_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as Rolling_people_Vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_people_Vaccinated/population)*100
from PopvsVac





-- Temp table

drop table if exists #PercentPopulationVacation
create table #PercentPopulationVacation
(
continent nvarchar(255),
lovation nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_Vaccinated numeric
)
insert into #PercentPopulationVacation
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as Rolling_people_Vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (Rolling_people_Vaccinated/population)*100
from #PercentPopulationVacation



-- creating view to store data for later vizualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as Rolling_people_Vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated