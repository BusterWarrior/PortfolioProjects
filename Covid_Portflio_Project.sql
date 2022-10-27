select * from 
Protfolio_Project..CovidVaccinations$
where continent is not null
order by 3,4

--select * from 
--Protfolio_Project..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Protfolio_Project..CovidDeaths$
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM Protfolio_Project..CovidDeaths$
where continent is not null and location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of population got covid

SELECT location, date,  population, total_cases, (total_cases / population) * 100 AS Percentage_Population_Infected
FROM Protfolio_Project..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compare to Population

SELECT location,  population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases / population)) * 100 AS Percentage_Population_Infected
FROM Protfolio_Project..CovidDeaths$
where continent is not null
GROUP BY  location, population
ORDER BY Percentage_Population_Infected DESC


-- Showing Countries with Highest Death Count Per Population

SELECT location,  MAX(CAST((total_deaths) as INT)) as Total_Death_Count
FROM Protfolio_Project..CovidDeaths$
where continent is not null
GROUP BY  location
ORDER BY Total_Death_Count DESC

-- Let's Break Things down by continent

SELECT location,  MAX(CAST((total_deaths) as INT)) as Total_Death_Count
FROM Protfolio_Project..CovidDeaths$
where continent is null
GROUP BY  location
ORDER BY Total_Death_Count DESC


-- Global Numbers

SELECT  date, SUM(new_cases) AS Global_New_Infection_Case, SUM(CAST(new_deaths as INT)) as Global_New_Death_Case, (SUM(CAST(new_deaths as INT)) / SUM(new_cases)) * 100 as DeathPercentage
FROM Protfolio_Project..CovidDeaths$
where continent is not null 
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as Daily_Vaccination_Case,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM Protfolio_Project..CovidDeaths$ dea
JOIN Protfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date	= vac.date
where dea.continent is not null 
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as Daily_Vaccination_Case,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated 
FROM Protfolio_Project..CovidDeaths$ dea
JOIN Protfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date	= vac.date
where dea.continent is not null 

)
SELECT *, (Rolling_People_Vaccinated / Population) * 100
FROM PopvsVac


--USE TEMP TABLE

DROP TABLE IF exists #Percent_Population_Vaccinated

CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)


INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as Daily_Vaccination_Case,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated 
FROM Protfolio_Project..CovidDeaths$ dea
JOIN Protfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date	= vac.date
--where dea.continent is not null 

SELECT *, (Rolling_People_Vaccinated / Population) * 100
FROM #Percent_Population_Vaccinated


-- Creating View to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as Daily_Vaccination_Case,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated 
FROM Protfolio_Project..CovidDeaths$ dea
JOIN Protfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date	= vac.date
where dea.continent is not null 


SELECT *
FROM Percent_Population_Vaccinated