
SELECT
	location,date,total_cases,new_cases, total_deaths, population
FROM 
	PortfolioProject..CovidDeaths$
ORDER BY
	1,2

-- Looking at Total cases vs total deaths

SELECT
	location,date,total_cases,new_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths$
WHERE
	location = 'United States'
ORDER BY
	1,2

-- Looking at Total cases vs Population

SELECT
	location, date, total_cases, new_cases, population, (total_cases/population)* 100 AS InfectionRate
FROM 
	PortfolioProject..CovidDeaths$
WHERE
	location = 'United States'
ORDER BY
	1,2;
	-- Looking at the Top 10 Countries with Highset Infection Rate compared to Population

CREATE OR ALTER VIEW
Top10InfectionRate AS
SELECT
	Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)* 100 AS InfectionRate
FROM 
	PortfolioProject..CovidDeaths$

GROUP BY
	Location,
	Population
ORDER BY
	InfectionRate desc
	OFFSET 0 ROWS
	FETCH NEXT 10 ROWS ONLY

	

	-- Showing Countries with the Highest Death Count per population

SELECT
	location, MAX(cast(total_deaths AS int)) AS DeathCount
FROM 
	PortfolioProject..CovidDeaths$
WHERE
	continent is not null
GROUP BY
	Location
ORDER BY
	DeathCount desc

	-- Breaking things down by continent

SELECT
	location, MAX(cast(total_deaths AS int)) AS DeathCount
FROM 
	PortfolioProject..CovidDeaths$
WHERE
	continent is null
GROUP BY
	Location
ORDER BY
	DeathCount desc

-- Looking at Total Population vs Vaccinations
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM
	PortfolioProject..CovidDeaths$ dea
	JOIN
	PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY
	2,3

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE
	#PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	INSERT INTO #PercentPopulationVaccinated
	SELECT
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea. location, 
		dea.Date) AS RollingPeopleVaccinated
	FROM
	PortfolioProject..CovidDeaths$ dea
	JOIN
	PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
SELECT
	*, (RollingPeoplevaccinated/Population)*100
FROM
	#PercentPopulationVaccinated

SELECT 
	*
FROM
	Top10InfectionRate