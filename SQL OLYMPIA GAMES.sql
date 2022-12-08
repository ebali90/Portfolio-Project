-- Dataset used for this is from 2016 and prior

-- 51 Olympics have been held so far until year 2016
USE OlympicPractice
Go

Select distinct games
from dbo.Events
Order by games desc


Select count(distinct games) #ofOlympicsHeld
from dbo.Events

---------------------------------------------------------------------------------------------------

-- List of all Olympics games held so far

Select distinct year, Season, City
from dbo.Events
order by year

---------------------------------------------------------------------------------------------------

-- The total number of nations who participated in each olympics game

Select distinct 
	games,
	year, 
	count(distinct NOC) #ofNationsParticipated
From DBO.Events
group by
	games,
	year
order by year

---------------------------------------------------------------------------------------------------
-- Years that saw the highest and lowest no of countries participating in olympics


WITH CTE as (
	Select distinct 
		games,
		year, 
		count(distinct NOC) as #ofNationsParticipated
	From DBO.Events
	group by
		games,
		year
)


Select TOP 1 MIN(#ofNationsParticipated) as Lowest_And_Highest#Countries_Participating, MIN(year) as Year
From CTE
UNION
Select TOP 1 Max(#ofNationsParticipated), MAX(year)
From CTE

---------------------------------------------------------------------------------------------------
-- 4 nations have participated in all of the olympic games

Select *
From DBO.Events

With #ofCountries as (
Select distinct games, noc
From DBO.Events
group by games, noc
)

Select c.noc, count(c.noc) numbers, r.region
From #ofCountries c
join noc_regions r on r.noc = c.noc
group by c.noc, r.region
having count(c.noc) = 51
order by numbers desc

---------------------------------------------------------------------------------------------------

--  sports that were played in all summer olympics

Select 
	count(distinct year) NumberOfYearsPlayed,
	season, 
	sport
from 
	events
group by 
	season, 
	sport
having 
	season = 'Summer'
order by
	NumberOfYearsPlayed desc


-- OR

With CountSport as (
	Select distinct 
		sport, 
		season, 
		year
	from 
		Events
	group by 
		sport, 
		season, 
		year
	having 
		Season = 'summer'
)

Select 
	sport, 
	count(sport) as count, 
	season
From 
	CountSport
group by 
	sport, season
order by 
	count desc

------------------------------------------------------------------------------------------

-- Sports that were just played only once in the Olympics

Select 
	count(distinct year) NumberOfYearsPlayed,
	season, 
	sport
from 
	events
group by 
	season, 
	sport
having 
	count(distinct year) < 2
order by
	NumberOfYearsPlayed desc

---------------------------------------------------------------------------------------------------

-- Total number of sports played in each olympic games.

Select distinct games, count(distinct Sport)
from OlympicPractice.dbo.Events
group by games
order by games

---------------------------------------------------------------------------------------------------

-- Oldest athletes to win a gold medal

Select TOP 10 
	Name, 
	Sex, 
	Age, 
	Team, 
	City, 
	year, 
	season, 
	games, 
	event
From Events
Where Medal = 'Gold' and age <> 'NA'
Order by Age desc

---------------------------------------------------------------------------------------------------

-- Ratio of Female to Male Athletes

With CTEsex as (
Select distinct Name, sex, Age
From Events
)

Select distinct 
	(select count(sex) from CTEsex where Sex = 'F') #of_FemaleAthletes,
	(select count(sex) from CTEsex where Sex = 'M') #of_MaleAthletes,
	(select cast(count(sex) as float) from CTEsex where Sex = 'F') / (select cast(count(sex) as float) from CTEsex where Sex = 'M') * 100 ratio
from CTEsex

-- OR


Select Distinct
	(select count(sex) from OlympicPractice.DBO.Events where Sex = 'F') as FemaleAthletes,
	(select count(sex) from OlympicPractice.DBO.Events where Sex = 'M') as MaleAthletes,
	(select cast(count(sex) as float) from OlympicPractice.DBO.Events where Sex = 'F') / 
	(select cast(count(sex) as float) from OlympicPractice.DBO.Events where Sex = 'M') * 100 as RatioFemale2Male
from OlympicPractice.DBO.Events

---------------------------------------------------------------------------------------------------
-- Top 5 athletes who have won the most gold medals

Select top 5
	name, 
	team, 
	count(medal) as #ofGoldMedals
from 
	Events
where 
	medal = 'Gold'
group by 
	name, team
order by 
	#ofGoldMedals desc

---------------------------------------------------------------------------------------------------

-- top 5 athletes who have won the most medals (gold/silver/bronze)

Select top 5
	name, 
	team, 
	count(medal) as #ofGoldMedals
from 
	Events
where 
	medal = 'Gold' or medal =  'Silver' or medal = 'Bronze'
group by 
	name, team
order by 
	#ofGoldMedals desc


--------------------------------------------------------------------------------------------------

-- top 5 most successful countries in olympics. Success is defined by no of medals won.

Select distinct top 5 
	r.region, 
	count(e.Medal) as medals, 
	RANK() over (order by count(e.Medal) DESC) as rank
From 
	Events E
join noc_regions R
on E.noc = R.noc
Where 
	Medal = 'Gold' or Medal = 'Silver' or Medal = 'Bronze'
group by 
	r.region
order by 
	medals desc

---------------------------------------------------------------------------------------------------

-- Total gold, silver and bronze medals won by each country


select 
	r.region, 
	sum(case when e.Medal = 'Gold' then 1 else 0 end) as Gold,
	sum(case when e.Medal = 'silver' then 1 else 0 end) as Silver,
	sum(case when e.Medal = 'bronze' then 1 else 0 end) as Bronze
from 
	olympicpractice.dbo.events E
join 
	olympicpractice.dbo.noc_regions R
	on E.noc = R.noc
group by 
	r.region
order by
	gold desc, silver desc, bronze desc

---------------------------------------------------------------------------------------------------

-- Total gold, silver and bronze medals won by each country corresponding to each olympic games

select 
	games,
	r.region, 
	sum(case when e.Medal = 'Gold' then 1 else 0 end) as Gold,
	sum(case when e.Medal = 'silver' then 1 else 0 end) as Silver,
	sum(case when e.Medal = 'bronze' then 1 else 0 end) as Bronze
from 
	olympicpractice.dbo.events E
join 
	olympicpractice.dbo.noc_regions R
	on E.noc = R.noc
group by 
	games, r.region
order by
	games

---------------------------------------------------------------------------------------------------

-- Countries won the most gold, most silver and most bronze medals in each olympic games.


with final_t as(
	select 
		noc,
		games,
		sum(case when medal='Gold' then 1 else 0 end) as Gold,
		sum(case when medal='Silver' then 1 else 0 end) as Silver,
		sum(case when medal='Bronze' then 1 else 0 end) as Bronze
		from 
			Events
		group by 
			noc,games
	),

t1 as(
	select 
		games, 
		max(gold) g, 
		max(silver) s, 
		max(bronze) b
	from 
		final_t
	group by 
		games
),

gold as
	(select 
		t.games, 
		concat(t.g, '-',f.noc) as Gold_Max
	from 
		final_t f, 
		t1 t
	where 
		f.gold= t.g and f.games = t.games ),

silver as 
	(select 
		t.games,
		concat(t.s,'-',f.noc) as Silver_Max
	from 
		final_t f , t1 t
	where 
		f.silver= t.s and f.games=t.games ),

bronze as 
	(select t.games, concat(t.b,'-',f.noc) as Bronze_Max
	from 
		final_t f , t1 t
	where 
		f.bronze = t.b and f.games = t.games )

select 
	gl.games,
	Gold_Max, 
	Silver_max,
	Bronze_max
from 
	gold gl, 
	silver sl,
	bronze bl
where 
	gl.games=sl.games and sl.games=bl.games and bl.games= gl.games
order by 
	gl.games


	-- OR

With T1 As(
	select games, region,
		sum(case when Medal='Gold' then 1 else 0 end) as Gold,
		sum(case when Medal= 'Silver' then 1 else 0 end) as Silver,
		sum(case when Medal= 'Bronze' then 1 else 0 end) as Bronze
	from Events o join noc_regions oh on
		o.NOC=oh.NOC
	group by games,region)

	Select Distinct
		games,
		Concat((FIRST_VALUE(region) Over(partition by games order by Gold desc)),'-',(FIRST_VALUE(Gold) Over(partition by games order by Gold desc))) As Max_Gold,
		Concat((FIRST_VALUE(region) Over(partition by games order by Silver desc)),'-',(FIRST_VALUE(Silver) Over(partition by games order by Silver desc))) As Max_Silver,
		Concat((FIRST_VALUE(region) Over(partition by games order by Bronze desc)),'-',(FIRST_VALUE(Bronze) Over(partition by games order by Bronze desc))) As Max_Bronze
	From T1
	Order By Games


---------------------------------------------------------------------------------------------------

-- countries have never won gold medal but have won silver/bronze medals?


Select r.region,
	sum(case when Medal = 'Gold' then 1 else 0 end) as Gold,
	sum(case when Medal = 'silver' then 1 else 0 end) as Silver,
	sum(case when Medal = 'bronze' then 1 else 0 end) as Bronze
from 
	olympicpractice.dbo.events E
join 
	olympicpractice.dbo.noc_regions R
	on E.noc = R.noc 
where medal <> 'NA'
group by r.region
having sum(case when Medal = 'Gold' then 1 else 0 end) = 0
order by gold, silver desc, bronze desc

---------------------------------------------------------------------------------------------------

-- Sport/event, United States has won highest medals

Select Top 1 
	noc, 
	sport, 
	count(sport) as #ofMedals
from 
	Events
where 
	NOC = 'USA' and Medal <> 'NA'
group by 
	noc, sport
order by 
	#ofMedals desc

---------------------------------------------------------------------------------------------------

-- All olympic games where U.S won medal for Athletics and how many medals in each olympic games

Select distinct noc, games, sport, count(medal) #ofMedals
From Events
Where NOC = 'USA' and sport = 'Athletics' and Medal <> 'NA'
group by noc, games, sport
order by count(medal) desc