SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations$
--ORDER by 3,4


SELECT location, date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--looking at total cases vs total deaths

--Shows likelihood of dying if you contract covid 19 in a specific country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
where location LIKE '%kenya%'
ORDER BY 1,2

--Total cases vs population
--shows what the percentage of the population contracted covid 19
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infection_percentage
FROM PortfolioProject..CovidDeaths
where location LIKE '%Kingdom%' AND total_cases IS NOT NULL and  continent is not null
ORDER BY 1,2

--Shows what country has the highest infection rate compared to population

SELECT location, population, max(total_cases)AS highestInfectionCount, MAX((total_cases/population))*100 AS Infection_percentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group BY population, location 
ORDER BY Infection_percentage desc


--Shows what country has the highest death rate due to covid compared to population

SELECT location, population, max(cast(total_deaths as int))AS DeathCount, MAX((total_deaths/population))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group BY population, location 
ORDER BY DeathCount desc

--LETS BREAK IT DOWN BY CONTINENT

-- showing the continents with the highest death count
SELECT continent, max(cast(total_deaths as int))AS DeathCount, MAX((total_deaths/population))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group BY continent 
ORDER BY DeathCount desc

--GLOBAL NUMBERS

--Death percentage worldwide
SELECT  SUM(new_cases) as total_cases ,  SUM(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int)) / SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
--where location LIKE '%kenya%'
where continent is not null
ORDER BY 1,2

--death percentage every day around the world
SELECT  date,SUM(new_cases) as total_cases ,  SUM(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int)) / SUM(New_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
--where location LIKE '%kenya%'
where continent is not null 
group by date
having SUM(New_cases) >0
ORDER BY 1,2


SELECT *
from PortfolioProject..CovidVaccinations
where new_tests is not null



--Total population vs vaccinations

--Number of people vaccinated by country
SELECT  dth.location, dth.population,sum(convert(float,vacc. new_vaccinations)) AS NumberOftotalVaccinantions
FROM PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dth
	ON vacc.location = dth.location
	and vacc.date = dth.date
where   dth.continent is not null
group by dth.location, dth.population

--Number of poeple vaccinated every day by country
SELECT dth.continent, dth.location, dth.date, dth.population, vacc. new_vaccinations--, dth.population / vacc. total_vaccinations *100
FROM PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dth
	ON vacc.location = dth.location
	and vacc.date = dth.date
where   dth.continent is not null and new_vaccinations is not null
order by  2, 3


SELECT dth.continent, dth.location, dth.date, dth.population, vacc. new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER(partition by dth.location order by dth.location , dth.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dth
	ON vacc.location = dth.location
	and vacc.date = dth.date
where   dth.continent is not null and new_vaccinations is not null
order by  2, 3


--USE CTE

with PopvsVac (Continent, location,Date ,population,new_vaccinations ,RollingPeoplevaccinated)
as
(
SELECT dth.continent, dth.location, dth.date, dth.population, vacc. new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER(partition by dth.location order by dth.location , dth.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dth
	ON vacc.location = dth.location
	and vacc.date = dth.date
where   dth.continent is not null and new_vaccinations is not null
--order by  2, 3
)

SELECT * ,(RollingPeoplevaccinated/population)*100 FROM PopvsVac




--USING temp table
DROP TABLE if EXISTS #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
SELECT dth.continent, dth.location, dth.date, dth.population, vacc. new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER(partition by dth.location order by dth.location , dth.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dth
	ON vacc.location = dth.location
	and vacc.date = dth.date
where   dth.continent is not null and new_vaccinations is not null
--order by  2, 3

SELECT * ,(RollingPeoplevaccinated/population)*100
FROM #PercentPeopleVaccinated

--Creating views

CREATE view PercentPeopleVaccinated as
SELECT dth.continent, dth.location, dth.date, dth.population, vacc. new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER(partition by dth.location order by dth.location , dth.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dth
	ON vacc.location = dth.location
	and vacc.date = dth.date
where   dth.continent is not null and new_vaccinations is not null
--order by  2, 3