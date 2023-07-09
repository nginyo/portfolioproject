--select *
--from ['COVID VACCINATIONS$']
--order by 3,4


select *
from ['COVID DEATHS$']
where continent is not Null
order by 3,4

--select data that were going to use

select Location,date,total_cases,new_cases,total_deaths,population
from ['COVID DEATHS$']
order by 1,2

--looking at total cases and total deaths
--shows the likelihood of dying if you contract covid in your country.
select Location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as DeathPercentage
from ['COVID DEATHS$']
where location like '%kenya%'
order by 1,2


--looking at total cases vs population
--shows percentage of population got covid
select Location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationwithcovid
from ['COVID DEATHS$']
where location like '%kenya%'
order by 1,2

--looking at countries with highest infection rate compared to population	
select Location,population,max(total_cases) as Highestinfectioncount,max(total_cases/population)*100 as PercentagePopulationwithcovid
from ['COVID DEATHS$']
--where location like '%kenya%'
where continent is not Null
group by location,population
order by 4 desc

--shows Countris with the highest death count per population
select Location,population,max(total_deaths) as Highestdeaths,max(total_deaths/population)*100 as PercentagePopulationwithcovid
from ['COVID DEATHS$']
--where location like '%kenya%'
--where continent is not Null
group by location,population
order by 4 desc


--lets break things down by continent with highest death counts
select continent, max(total_deaths) as TotalDeaths
from ['COVID DEATHS$']
where continent is not null	
group by continent

--select location, MAX(total_deaths) as TotalDeaths
--from ['COVID DEATHS$']
--where continent is null
--Group by location
--order by TotalDeaths desc

--Global Numbers
select sum(new_cases),sum(new_deaths),(sum(new_deaths)/sum(new_cases))*100 as newdeathpercentage  
from ['COVID DEATHS$']
--where location like '%kenya%'
where continent is not Null and new_cases>0

order by 1

--Looking at total population vs vaccinations
Select deaths.continent,deaths.location, deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(cast (vaccinations.new_vaccinations as float)) OVER (PARTITION BY deaths.location order by deaths.location,deaths.date) as VaccinationCountbyCountry
from ['COVID DEATHS$'] as deaths
join ['COVID VACCINATIONS$'] as vaccinations
on deaths.location=vaccinations.location
and deaths.date=vaccinations.date
where deaths.continent is not null and deaths.location Like '%Kenya%'
order by 2,3


--use CTE
with popvsvac (continent,location,Date,Population,new_vaccinations,VaccinationCountbyCountry)
as
(
Select deaths.continent,deaths.location, deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(cast (vaccinations.new_vaccinations as float)) OVER (PARTITION BY deaths.location order by deaths.location,deaths.date) as VaccinationCountbyCountry
from ['COVID DEATHS$'] as deaths
join ['COVID VACCINATIONS$'] as vaccinations
on deaths.location=vaccinations.location
and deaths.date=vaccinations.date
where deaths.continent is not null 

)
select *,(VaccinationCountbyCountry/Population)*100 as PERCENTAGEVAC CINATED
from popvsvac

--TEMP  TABLE
DROP TABLE IF EXISTS  #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(continent  varchar(255),
location varchar(255),
Date datetime,
population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PERCENTPOPULATIONVACCINATED
Select deaths.continent,deaths.location, deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(cast (vaccinations.new_vaccinations as float)) OVER (PARTITION BY deaths.location order by deaths.location,deaths.date) as VaccinationCountbyCountry
from ['COVID DEATHS$'] as deaths
join ['COVID VACCINATIONS$'] as vaccinations
on deaths.location=vaccinations.location
and deaths.date=vaccinations.date
where deaths.continent is not null 

select *
from #PERCENTPOPULATIONVACCINATED
ORDER BY date


--create view to store data  for later visualisation
create view PERCENTPOPULATIONVACCINATED as
Select deaths.continent,deaths.location, deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(cast (vaccinations.new_vaccinations as float)) OVER (PARTITION BY deaths.location order by deaths.location,deaths.date) as VaccinationCountbyCountry
from ['COVID DEATHS$'] as deaths
join ['COVID VACCINATIONS$'] as vaccinations
on deaths.location=vaccinations.location
and deaths.date=vaccinations.date
where deaths.continent is not null 




