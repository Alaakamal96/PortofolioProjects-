/****** Script for SelectTopNRows command from SSMS  ******/

SELECT *
FROM dbo.CovidDeaths
Where continent is not null 
Order by 3,4 
  

--SELECT *
--FROM dbo.CovidVaccinations
--Order by 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population  
FROM master.dbo.CovidDeaths
Where continent is not null 
Order by 1,2 

-- Lokking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contact covid in Australia 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage 
FROM master.dbo.CovidDeaths
Where location like '%Australia%'
and continent is not null 
Order by 1,2 


-- Looking at Total Cases vs Population 
-- what percentage of population got covid 

SELECT Location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected 
FROM master.dbo.CovidDeaths
Where location like '%Australia%'
and continent is not null 
Order by 1,2

-- Looking at Countries Withe Highest Infection Rate Compared to Population 

SELECT Location, population, MAX(total_cases) as HighesrInfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
FROM master.dbo.CovidDeaths
Where continent is not null 
Group by Location, population
Order by 4 Desc --PercentPopulationInfected

-- Showing Countries with Higest Death count Per Population 

SELECT Location, MAX(cast(Total_deaths as int)) As totalDeathCount
FROM master.dbo.CovidDeaths
Where continent is not null 
Group by Location
Order by totalDeathCount Desc  

-- Showing continent with the higest death count per population 


SELECT Continent, MAX(cast(Total_deaths as int)) As totalDeathCount
FROM master.dbo.CovidDeaths
Where continent is not null 
Group by Continent
Order by totalDeathCount Desc 

-- Global Numbers 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM master.dbo.CovidDeaths
Where continent is not null 
Order by 1,2


-- Looking at Total population vs vaccinations 
-- USE CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From master.dbo.CovidDeaths As dea 
Join master.dbo.CovidVaccinations As vac 
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
)

Select * , (RollingPeopleVaccinated/POPULATION)*100
From PopvsVac


-- TEMP TEBLE 

Drop table if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinationns numeric, 
RollingPeopleVaccinated numeric 
)
Insert into #PercentPopulationVaccinated  
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From master.dbo.CovidDeaths As dea 
Join master.dbo.CovidVaccinations As vac 
	On dea.location = vac.location 
	and dea.date = vac.date 
--Where dea.continent is not null

Select * , (RollingPeopleVaccinated/POPULATION)*100
From #PercentPopulationVaccinated  

-- Creating vieew to store data for later visulaization 

Create view PercentPopulationVaccinated as   
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From master.dbo.CovidDeaths As dea 
Join master.dbo.CovidVaccinations As vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null 



-- Work table 
Select * 
From PercentPopulationVaccinated