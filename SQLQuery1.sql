select * from project1.dbo.Data1;

select * from project1.dbo.data2;

-- number of rows into our dataset--

select count(*) from project1.dbo.data1;

select count(*) from project1.dbo.data2;

---- dataset for Jharkhand and bihar---

select * from project1..data1 where state in ('Jharkhand','Bihar');

-- population of  india--

select sum(Population) from project1.dbo.data2;

--- avg growth---

select state, avg(growth)*100 from project1..data1 group by state;

-----avg sex ratio----

select state, round(avg(sex_ratio),0) as avg_sex_ratio from project1..data1 group by state order by avg_sex_ratio desc; 

--- avg literacy_rate
select state, round(avg(literacy),0) as avg_literacy_ratio from project1..data1 group by state having round(avg(literacy),0)>90  order by avg_literacy_ratio desc;


---- top 3 states showing highest growth ratio---

select top 3 state, avg(growth)*100 avg_growth from project1..data1 group by state order by avg_growth desc;


---- bottom  3 states showing highest growth ratio---

select top 3 state, round(avg(sex_ratio),0) avg_sex_ratio from project1..data1 group by state order by avg_sex_ratio asc;


-- top and bottom 3 states in the literacy state

drop table if exists #topstates

create table #topstates
( state nvarchar(255),
topstates float
)

insert into #topstates
select state, round(avg(literacy),0) avg_literacy_ratio from project1..data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstates desc;

drop table if exists #bottomstates

create table #bottomstates
( state nvarchar(255),
bottomstates float
)

insert into #bottomstates
select state, round(avg(literacy),0) avg_literacy_ratio from project1..data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstates asc;

----- union all


select * from (
select top 3 * from #topstates order by #topstates.topstates desc) a
union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc) b;

--- states atrting with letter a 

select distinct state from project1..data1 where lower(state) like 'a%';

--- states atrting with letter a and end with letter d

select distinct state from project1..data1 where lower(state) like 'J%' and lower(state) like '%d';

--- Joining both table

select d.state, sum(d.males) total_males, sum(d.females) total_females from
(select c.district, c.state, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio +1),0) females from
(select a.district,a.state,a.sex_ratio,b.population from project1..data1 a inner join project1..data2 b on a.district = b.district) c ) d
group by d.state;

--- total literacy rate
select c.state, sum(literate_people) total_literate_people, sum(illiterate_people) total_illiterate_people from
(select d.district,d.state, round(d.literacy_ratio*d.population,0) literate_people, round((1-d.literacy_ratio)*d.population,0) illiterate_people from
(select a.district,a.state, a.literacy/100 literacy_ratio,b.population from project1..data1 a inner join project1..data2 b on a.district = b.district) d) c group by c.state;

---- population in previous census
select sum(m.total_previous_census_population) total_previous_census_population, sum(m.total_current_census_population) total_current_census_population from (
select e.state, sum(e.previous_census_population) total_previous_census_population, sum(e.current_census_population) total_current_census_population from 
(select d.district, d.state, round(d.population/(1+d.growth),0) previous_census_population, d.population current_census_population  from 
(select a.district, a.state, a.growth growth, b.population from project1..data1 a inner join project1..data2 b on a.district = b.district) d) e 
group by e.state)m


---population vs Area-----


select (g.total_area/g.total_previous_census_population) total_previous_census_population_vs_area, (g.total_area/g.total_current_census_population) total_current_census_population_vs_area from 
(select q.*, r.total_area from (

select '1' as keyy, n.* from
(select sum(m.total_previous_census_population) total_previous_census_population, sum(m.total_current_census_population) total_current_census_population from (
select e.state, sum(e.previous_census_population) total_previous_census_population, sum(e.current_census_population) total_current_census_population from 
(select d.district, d.state, round(d.population/(1+d.growth),0) previous_census_population, d.population current_census_population  from 
(select a.district, a.state, a.growth growth, b.population from project1..data1 a inner join project1..data2 b on a.district = b.district) d) e 
group by e.state)m) n ) q inner join (


select '1' as keyy, z.* from (
select sum(area_km2) total_area from project1..data2)z )r on q.keyy = r.keyy) g


-----  window ---

---Output top 3 district from each state with highest literacy rate--

select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) rnk from project1..data1) a

where a.rnk in(1,2,3) order by state;
















 




