-- Select all the data in table 'CovidDeaths'
SELECT *
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
ORDER BY 2,3,4

-- Select all the data that are going to be used
SELECT location, date, total_cases, total_deaths, population
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
ORDER BY 1,2

-- Total deaths / Total cases (Case Fatality Rate)
-- Shows likelihood of dying if someone got infected by Covid
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/CAST(total_cases AS float))*100, 2) AS case_fatality_rate
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
ORDER BY 1,2

-- Total cases / Population (Attack Rate)
-- Total deaths / Population (Mortality Rate)
SELECT location, date, total_cases, total_deaths, population, 
	ROUND((CAST(total_cases AS float)/CAST(population AS float))*100, 3) AS attack_rate,
	ROUND((CAST(total_deaths AS float)/CAST(population AS float))*100, 3) AS mortality_rate
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
ORDER BY 1,2

-- Countries with the highest attack rate from 01-01-2020 to 30-04-2021
SELECT location, population, 
	MAX(CAST(total_cases AS float)) AS total_cases, 
	MAX(ROUND((CAST(total_cases AS float)/CAST(population AS float))*100, 3)) AS attack_rate
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
GROUP BY location, population
ORDER BY attack_rate DESC

-- Countries with the highest mortality rate from 01-01-2020 to 30-04-2021
SELECT location, population, 
	MAX(CAST(total_deaths AS float)) AS total_deaths, 
	MAX(ROUND((CAST(total_deaths AS float)/CAST(population AS float))*100, 3)) AS mortality_rate
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
GROUP BY location, population
ORDER BY mortality_rate DESC

-- Continents with the highest attack rate from 01-01-2020 to 30-04-2021
SELECT continent, SUM(CAST (population AS float)) AS population, SUM(CAST (total_cases AS float)) AS total_cases, 
	ROUND((SUM(CAST (total_cases AS float))/SUM(CAST (population AS float)))*100, 3) AS attack_rate
FROM
(
SELECT continent, location, population, MAX(CAST(total_cases AS float)) AS total_cases
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
GROUP BY location, population, continent
) AS subquery
GROUP BY continent
ORDER BY attack_rate DESC

-- Continents with the highest mortality rate from 01-01-2020 to 30-04-2021
SELECT continent, SUM(CAST (population AS float)) AS population, SUM(CAST (total_deaths AS float)) AS total_deaths, 
	ROUND((SUM(CAST (total_deaths AS float))/SUM(CAST (population AS float)))*100, 3) AS mortality_rate
FROM
(
SELECT continent, location, population, MAX(CAST(total_deaths AS float)) AS total_deaths
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
GROUP BY location, population, continent
) AS subquery
GROUP BY continent
ORDER BY mortality_rate DESC

-- Total cases, total deaths, population in the whole world each day day from 01-01-2020 to 30-04-2021
SELECT date, SUM(CAST (population AS float)) AS population, SUM(CAST (total_cases AS float)) AS total_cases, 
	SUM(CAST (total_deaths AS float)) AS total_deaths
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
GROUP BY date
ORDER BY date

-- Global Number of total deaths, total cases, and population from 01-01-2020 to 30-04-2021
SELECT SUM(CAST (population AS float)) AS population, SUM(CAST (total_deaths AS float)) AS total_deaths, 
	SUM(CAST (total_cases AS float)) AS total_cases
FROM
(
SELECT continent, location, population, MAX(CAST(total_deaths AS float)) AS total_deaths, MAX(CAST(total_cases AS float)) AS total_cases
FROM PortofolioProject..Death
WHERE location != 'World' and continent is not NULL
GROUP BY location, population, continent
) AS subquery

-- Select all the data in table 'Vaccination' to get an overview of the data
SELECT * 
FROM PortofolioProject..Vaccination
WHERE location != 'World' and continent is not NULL
ORDER BY 2,3,4

-- Total_vaccination / Population
-- Shows percentage of population that has received at least one vaccine
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, v.total_vaccinations,
	ROUND((CAST(v.total_vaccinations AS float)/d.population)*100, 2) AS vaccination_rate
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL
ORDER BY d.continent, d.location, d.date

-- All people in each country who were fully vaccinated rate from 01-01-2020 to 30-04-2021
SELECT d.location, d.population, MAX(CAST(v.people_fully_vaccinated AS float)) AS people_vaccinated, 
	ROUND((MAX(CAST(v.people_fully_vaccinated AS float))/d.population)*100, 3) AS fully_vaccination_rate
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
WHERE d.location != 'World' and d.continent is not NULL
GROUP BY d.location, d.population
ORDER BY fully_vaccination_rate DESC

-- All people in each continent who were fully vaccinated rate from 01-01-2020 to 30-04-2021
SELECT continent,
	SUM(CAST(population AS float)) AS total_population,
	SUM(CAST(people_vaccinated AS float)) AS total_people_vaccinated,
	ROUND((SUM(CAST(people_vaccinated AS float))/SUM(CAST(population AS float)))*100, 3) AS fully_vaccination_rate
FROM
(
SELECT d.continent, d.location, d.population, MAX(CAST(v.people_fully_vaccinated AS float)) AS people_vaccinated, 
	ROUND((MAX(CAST(v.people_fully_vaccinated AS float))/d.population)*100, 3) AS fully_vaccination_rate
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL
GROUP BY d.location, d.population, d.continent
) As subquery
GROUP BY continent
ORDER BY fully_vaccination_rate DESC

-- Total people get vaccinated in the whole world every single day from 01-01-2020 to 30-04-2021
SELECT d.date, 
	SUM(CAST(d.population AS float)) AS world_population,
	SUM(CAST(v.total_vaccinations AS float)) AS total_vaccinations,
	ROUND((SUM(CAST(v.total_vaccinations AS float))/SUM(CAST(d.population AS float)))*100, 3) AS vaccination_rate
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL
GROUP BY d.date
ORDER by d.date

-- All data (Population, total vaccination, total cases, total deaths) in the whole world day by day from 01-01-2020 to 30-04-2021
SELECT d.date, 
	SUM(CAST(d.population AS float)) AS world_population,
	SUM(CAST (d.total_cases AS float)) AS total_cases, 
	SUM(CAST (d.total_deaths AS float)) AS total_deaths,
	SUM(CAST(v.total_vaccinations AS float)) AS total_vaccinations,
	ROUND((SUM(CAST (d.total_cases AS float))/SUM(CAST(d.population AS float)))*100, 3) AS cases_rate,
	ROUND((SUM(CAST (d.total_deaths AS float))/SUM(CAST(d.population AS float)))*100, 3) AS death_rate,
	ROUND((SUM(CAST(v.total_vaccinations AS float))/SUM(CAST(d.population AS float)))*100, 3) AS vaccination_rate
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL
GROUP BY d.date
ORDER by d.date

-- Global Number of total deaths, cases, vaccinations, people fully vaccinated and population from 01-01-2020 to 30-04-2021
SELECT SUM(CAST(population AS float)) AS population,
	SUM(CAST (total_cases AS float)) AS total_cases, 
	SUM(CAST (total_deaths AS float)) AS total_deaths,
	SUM(CAST(total_vaccinations AS float)) AS total_vaccinations,
	SUM(CAST(people_fully_vaccinated AS float)) AS people_fully_vaccinated
FROM
(
SELECT d.continent, d.location, 
	MAX(CAST(d.total_deaths AS float)) AS total_deaths,
	MAX(CAST(d.total_cases AS float)) AS total_cases,
	MAX(CAST(d.population AS float)) AS population,
	MAX(CAST(v.total_vaccinations AS float)) AS total_vaccinations,
	MAX(CAST(v.people_fully_vaccinated AS float)) AS people_fully_vaccinated
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL
GROUP BY d.location, d.continent, d.population
) AS subquery

-- Using CTE in global Number of total deaths, cases, vaccinations, people fully vaccinated and population from 01-01-2020 to 30-04-2021
WITH global_number
AS
(
SELECT d.continent, d.location, 
	MAX(CAST(d.total_deaths AS float)) AS total_deaths,
	MAX(CAST(d.total_cases AS float)) AS total_cases,
	MAX(CAST(d.population AS float)) AS population,
	MAX(CAST(v.total_vaccinations AS float)) AS total_vaccinations,
	MAX(CAST(v.people_fully_vaccinated AS float)) AS people_fully_vaccinated
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL
GROUP BY d.location, d.continent, d.population
)
SELECT SUM(CAST(population AS float)) AS population,
	SUM(CAST (total_cases AS float)) AS total_cases, 
	SUM(CAST (total_deaths AS float)) AS total_deaths,
	SUM(CAST(total_vaccinations AS float)) AS total_vaccinations,
	SUM(CAST(people_fully_vaccinated AS float)) AS people_fully_vaccinated
FROM global_number

-- Using temporary table to perform calculation in above query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric,
vaccination_rate numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, v.total_vaccinations,
	ROUND((CAST(v.total_vaccinations AS float)/d.population)*100, 2) AS vaccination_rate
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, v.total_vaccinations,
	ROUND((CAST(v.total_vaccinations AS float)/d.population)*100, 2) AS vaccination_rate
FROM PortofolioProject..Death d
JOIN PortofolioProject..Vaccination v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location != 'World' and d.continent is not NULL