SELECT *
FROM portfolioproject..covideath
Where continent is not NULL
ORDER BY 3,4


--SELECT *
--FROM portfolioproject..covideath
--ORDER BY 3,4


-- selecting the data we need 
Select Location, date, total_cases, new_cases,total_deaths,population
FROM portfolioproject..covideath
Where continent is not NULL
ORDER BY 1,2

---looking at total cases vs total deaths at percentage
-- showing the likelihood of dying if you get covid in Nigeria
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_percentage
FROM portfolioproject..covideath
WHERE location like '%NIGERI%'
and continent is not NULL
ORDER BY 1,2


--lokking at total_cases vs population in percentage
-- showing what percentage of population got covid
Select Location, date,population,total_cases, (total_cases/population) *100 AS Death_percentage
FROM portfolioproject..covideath
--WHERE location like '%IGERIA%'
ORDER BY 1,2

--looking at countries with highest infection rate compared to populations
Select Location,population, MAX(total_cases) AS highest_INFCOUNT,MAX((total_cases/population))*100 AS InfPop_percentage
FROM portfolioproject..covideath
--WHERE location like '%IGERIA%'
GROUP BY Location,population
ORDER BY InfPop_percentage DESC

-- showing countries with highest death count per population
Select Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM portfolioproject..covideath
--WHERE location like '%IGERIA%'
Where continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


--- LETS BREAK THINGS DOWN BY CONTINENT 

Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM portfolioproject..covideath
--WHERE location like '%IGERIA%'
Where continent is NOT  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--- showing continent with highest death count per population
Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM portfolioproject..covideath
--WHERE location like '%IGERIA%'
Where continent is NOT  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


----- Global numbers


Select date, SUM(New_cases) As totalcases,SUM(CAST(New_deaths as int)) as totalDeaths,sum(CAST(new_deaths AS int))/SUM(New_cases)*100 AS Death_percentage
FROM portfolioproject..covideath
--WHERE location like '%NIGERI%'
Where continent is not NULL
Group By Date
ORDER BY 1,2


Select  SUM(New_cases) As totalcases,SUM(CAST(New_deaths as int)) as totalDeaths,sum(CAST(new_deaths AS int))/SUM(New_cases)*100 AS Death_percentage
FROM portfolioproject..covideath
--WHERE location like '%NIGERI%'
Where continent is not NULL
--Group By Date
ORDER BY 1,2

--JOINING THE TWO TABLES 
SELECT *
FROM Portfolioproject..COVIDEATH as dea
JOIN Portfolioproject..Covidvaccination as vac
ON dea.location = vac.location
AND dea.Date = vac.date
and dea.iso_code = vac.iso_code

--- LOOKING at TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolioproject..COVIDEATH as dea
JOIN Portfolioproject..Covidvaccination as vac
ON dea.location = vac.location
AND dea.Date = vac.date
and dea.iso_code = vac.iso_code
Where dea.continent is not NULL
ORDER BY 2,3

----- looking at the sum of new vaccinations across countries 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM Portfolioproject..COVIDEATH as dea
JOIN Portfolioproject..Covidvaccination as vac
ON dea.location = vac.location
AND dea.Date = vac.date
Where dea.continent is not NULL
ORDER BY 2,3


----- including Summation Agregate function on population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolioproject..COVIDEATH as dea
JOIN Portfolioproject..Covidvaccination as vac
  ON dea.location = vac.location
  AND dea.Date = vac.date
Where dea.continent is not NULL
ORDER BY 2,3

--- USE CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolioproject..COVIDEATH as dea
JOIN Portfolioproject..Covidvaccination as vac
   ON dea.location = vac.location
   AND dea.Date = vac.date
Where dea.continent is not NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



---	Temp table
Drop Table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert Into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolioproject..COVIDEATH as dea
JOIN Portfolioproject..Covidvaccination as vac
   ON dea.location = vac.location
   AND dea.Date = vac.date
--Where dea.continent is not NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #percentpopulationvaccinated

---Creating view to stor data for later visualizations

Create view percentpopulationvaccinated  as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolioproject..COVIDEATH as dea
JOIN Portfolioproject..Covidvaccination as vac
   ON dea.location = vac.location
   AND dea.Date = vac.date
Where dea.continent is not NULL
--ORDER BY 2,3