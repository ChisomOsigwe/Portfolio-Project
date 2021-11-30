select *
from PortfolioProject..covid19_deaths$
order by 3,4

--select *
--from PortfolioProject..covid19_vaccination$
--order by 3,4

--selecting data to be used
select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..covid19_deaths$
order by 1,2

--total cases/total deaths
select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage, population
from PortfolioProject..covid19_deaths$
where location like '%states%'
order by 1,2

--total cases vs population
select location, population,total_cases,(total_cases/population)*100 as population_percentage 
from PortfolioProject..covid19_deaths$
order by 1,2

--countries with highest infection rate compared to population
select location, population,max(total_cases) as higheset_infection_count,max((total_cases/population))*100 as percentage_population_infected 
from PortfolioProject..covid19_deaths$
group by location, population
order by percentage_population_infected desc

--countries with highest death count per population
select location,max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..covid19_deaths$
group by location
order by highest_death_count desc

---highest death count by continent
select continent,max(cast(total_deaths as int)) as higheset_death_count
from PortfolioProject..covid19_deaths$
where continent is not null
group by continent
order by higheset_death_count desc

--Global
select date, sum(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/SUM(new_cases)*100 as TotalNewDeathsPercentage
from PortfolioProject..covid19_deaths$
where continent is not null
group by date
order by 1,2 

--total global
select sum(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/SUM(new_cases)*100 as TotalNewDeathsPercentage
from PortfolioProject..covid19_deaths$
where continent is not null
--group by date
order by 1,2 

--joining the two tables
select *
from PortfolioProject..covid19_deaths$ dea
join PortfolioProject..covid19_vaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date

----Total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid19_deaths$ dea
join PortfolioProject..covid19_vaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, 
RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(ROllingPeopleVaccinated/population)*100
from PortfolioProject..covid19_deaths$ dea
join PortfolioProject..covid19_vaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
--drop table if exists 
create table #percentPopulationVaccinated
(
continent nvarchar (120),
location nvarchar (120),
date datetime ,
population numeric,
new_vacciations numeric,
RollingPeopleVaccinated numeric)
insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(ROllingPeopleVaccinated/population)*100
from PortfolioProject..covid19_deaths$ dea
join PortfolioProject..covid19_vaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated

--creating view to store data for visalization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(ROllingPeopleVaccinated/population)*100
from PortfolioProject..covid19_deaths$ dea
join PortfolioProject..covid19_vaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

