
-- Evolution over time of population death rate in Brazil

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	population, 
	(CAST (total_deaths as decimal)/CAST (population as decimal))*100 as PopDeathPerc
FROM PortfólioCOVID19..fCovidDeaths
WHERE location like '%brazil%'
ORDER BY 1,2;


-- Which countries had it worse? Comparison of % Population Infected, % Population Dead, and Mortality Rates

SELECT 
	location, 
	population, 
	MAX(cast(total_Cases as float)) as InfectionCount, 
	MAX(cast(total_deaths as float)) as DeathCount, 
	MAX(cast(TOTAL_cases as float)/cast(population as float))*100 as PopInfectionPerc, -- % of population infected
	MAX(cast(total_deaths as float)/cast(population as float))*100 as PopDeathPerc, -- % of population that died of COVID-19
	(Max(cast(total_deaths as float))/MAX(cast(total_cases as float)))*100 as MortalityRate -- chance of dying if you contract COVID-19
FROM PortfólioCOVID19..fCovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopDeathPerc DESC


-- Global Numbers Timeline

SELECT 
	date, 
	SUM(CAST(new_cases as float)) as TotalCases,
	SUM(CAST(new_deaths as float)) as TotalDeaths
FROM PortfólioCOVID19..fCovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY TotalCases


-- Vaccination Timeline

SELECT 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinations,
	people_vaccinated,
	CAST(people_vaccinated as float)/CAST(population as float)*100 as PercPopVaccinated
FROM PortfólioCOVID19..fCovidDeaths dea
LEFT JOIN PortfólioCOVID19..fCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
	AND dea.location like '%brazil%'
ORDER BY 2, 3



-- Doses per people vaccinated - Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations, people_vaccinated, PercPopVaccinated)
as
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinations,
	people_vaccinated,
	CAST(people_vaccinated as float)/CAST(population as float)*100 as PercPopVaccinated
FROM PortfólioCOVID19..fCovidDeaths dea
LEFT JOIN PortfólioCOVID19..fCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,
	RollingVaccinations/people_vaccinated AS DosesPerPerson
FROM PopvsVac
WHERE people_vaccinated is not null AND location like '%brazil%'








-- Doses per people vaccinated - using temp table

DROP TABLE if exists #VaccinationsPerPeople
CREATE TABLE #VaccinationsPerPeople
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinations numeric,
people_vaccinated numeric,
percpopvaccinated numeric
)

Insert Into #VaccinationsPerPeople
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinations,
	people_vaccinated,
	CAST(people_vaccinated as float)/CAST(population as float)*100 as PercPopVaccinated
FROM PortfólioCOVID19..fCovidDeaths dea
LEFT JOIN PortfólioCOVID19..fCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *,
	RollingVaccinations/people_vaccinated AS DosesPerPerson
FROM #VaccinationsPerPeople
WHERE people_vaccinated is not null AND location like '%brazil%'


-- Create view to store data for later visualizations

CREATE VIEW CovidBrazil as
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	population, 
	(CAST (total_deaths as decimal)/CAST (population as decimal))*100 as PopDeathPerc
FROM PortfólioCOVID19..fCovidDeaths
WHERE location like '%brazil%'



-- Create view 02

CREATE VIEW VaccinationsView as
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinations,
	people_vaccinated,
	CAST(people_vaccinated as float)/CAST(population as float)*100 as PercPopVaccinated
FROM PortfólioCOVID19..fCovidDeaths dea
LEFT JOIN PortfólioCOVID19..fCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM VaccinationsView