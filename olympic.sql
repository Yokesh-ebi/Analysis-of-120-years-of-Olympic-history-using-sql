select * from OLYMPICS_HISTORY
select * from OLYMPICS_HISTORY_NOC_REGIONS

--How many olympics games have been held?
select count(distinct games) from OLYMPICS_HISTORY

--List down all Olympics games held so far.
select year,games,city from OLYMPICS_HISTORY
group by year,games,city
order by year

--Mention the total no of nations who participated in each olympics game?
select games,count( distinct noc) total_no_nations from OLYMPICS_HISTORY
group by games
order by games

--Which year saw the highest and lowest no of countries participating in olympics?
with t1 as(
select games,count(distinct ohr.region) as country from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS ohr
on oh.noc=ohr.noc
group by games)

select distinct concat(FIRST_VALUE(games) over(order by t1.country),
'-',FIRST_VALUE(country) over(order by t1.country)) as lowest_countries,

concat(FIRST_VALUE(games) over(order by t1.country desc),
'-',FIRST_VALUE(country) over(order by t1.country desc)) as highest_countries
from t1

--5. Which nation has participated in all of the olympic games
declare @totalgames int
set @totalgames= (select count(distinct games) from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS ohr
on oh.noc=ohr.noc)

select region,count(distinct games) total_participated_games from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS ohr
on oh.noc=ohr.noc
group by region
having count(distinct games)=@totalgames

--6. Identify the sport which was played in all summer olympics.

with t1 as(
	select count(distinct games) as [total summer games] 
	from OLYMPICS_HISTORY
	where Season='summer'),t2 as(
	select distinct sport,games from OLYMPICS_HISTORY
	where Season='summer'),t3 as(
	select distinct sport, count(games)as count_of_sport from t2
	group by sport)
select * from t3
join t1 on t1.[total summer games]=t3.count_of_sport

--7. Which Sports were just played only once in the olympics.

with t1 as(
	select distinct sport,games from OLYMPICS_HISTORY
	
), t2 as(
	select sport,count(sport) [No of Games] from t1
	group by sport
)
select t2.*,t1.games from t2
join t1 on t1.sport=t2.sport
where t2.[No of Games]=1
order by t2.sport

--8. Fetch the total no of sports played in each olympic games.
with t1 as(
	select distinct sport,games from OLYMPICS_HISTORY
	
), t2 as(
	select games,count(sport) [No of Games] from t1
	group by games
)
select * from t2
order by games

--9. Fetch oldest athletes to win a gold medal
with t1 as (
	select * from OLYMPICS_HISTORY
	where age !='NA' and medal ='gold'
	),t2 as (
	select *,rank() over(order by age desc) as rnk
	from t1
	)
select * from t2
where rnk=1

--10.Fetch the top 5 athletes who have won the most gold medals.
with t1 as(
	select name,team,count(medal)as cnt_of_gold_medal from OLYMPICS_HISTORY
	where medal='gold'
	group by name,team
	),
	t2 as(
	select *,dense_rank() over(order by cnt_of_gold_medal desc) rnk from
	t1
	)
	select name,team,cnt_of_gold_medal from t2
	where rnk <6
--11.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
with t1 as(
	select name,team,count(medal)as cnt_of_medal from OLYMPICS_HISTORY
	where medal in ('Gold', 'Silver', 'Bronze')
	group by name,team
	),
	t2 as(
	select *,dense_rank() over(order by cnt_of_medal desc) rnk from
	t1
	)
	select name,team,cnt_of_medal from t2
	where rnk <6

--12.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
with t1 as(
	select region,count(medal) as total_medal from OLYMPICS_HISTORY oh
	join OLYMPICS_HISTORY_NOC_REGIONS ohr on ohr.noc=oh.noc
	where medal in ('Gold', 'Silver', 'Bronze')
	group by region
),t2 as(
	select * ,DENSE_RANK() over(order by total_medal desc) as rnk from t1
)
select * from t2
where rnk <6

--13.In which Sport/event, India has won highest medals.
	with t1 as(
	select region,sport,count(medal) as total_medal from OLYMPICS_HISTORY oh
	join OLYMPICS_HISTORY_NOC_REGIONS ohr on ohr.noc=oh.noc
	where medal in ('Gold', 'Silver', 'Bronze') and region ='india'
	group by region,sport
)
	select top 1* from t1 order by total_medal desc

--14. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
	select region,sport,games,count(medal) as total_medal from OLYMPICS_HISTORY oh
	join OLYMPICS_HISTORY_NOC_REGIONS ohr on ohr.noc=oh.noc
	where medal in ('Gold', 'Silver', 'Bronze') and region ='india' and sport='hockey'
	group by region,sport,games
	order by total_medal desc