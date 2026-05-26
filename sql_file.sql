ALTER TABLE competitions
ADD COLUMN wgs_long DOUBLE;

UPDATE competitions
SET wgs_long = longitude_microdegrees / 1000000.0;

ALTER TABLE competitions
ADD COLUMN wgs_lat DOUBLE;

UPDATE competitions
SET wgs_lat = latitude_microdegrees / 1000000.0;

create table championships_coordinates as
select ch.competition_id, ch.championship_type, co.* from championships as ch 
left join competitions as co
on ch.competition_id = co.id


create table ranks_singles_persons as
select * from ranks_single as rs 
left join persons as p
on rs.person_id = p.wca_id

-- country results per events
create table country_speed_records as 
SELECT
  rsp.country_id,
  c.iso2,
  MIN(CASE WHEN rsp.event_id = '333' THEN rsp.best END) AS e_333,
  MIN(CASE WHEN rsp.event_id = '333bf' THEN rsp.best END) AS e_333bf,
  MIN(CASE WHEN rsp.event_id = '444' THEN rsp.best END) AS e_444,
  MIN(CASE WHEN rsp.event_id = 'minx' THEN rsp.best END) AS e_minx,
  MIN(CASE WHEN rsp.event_id = 'sq1' THEN rsp.best END) AS e_sq1
FROM ranks_singles_persons as rsp 
join countries as c on rsp.country_id=c.id
GROUP BY rsp.country_id order by e_333bf;

create table country_speed_record_positions as 
SELECT
    country_id,
    iso2,
    RANK() OVER (ORDER BY e_333 ASC NULLS LAST) AS rank_333,
    RANK() OVER (ORDER BY e_333bf ASC NULLS LAST) AS rank_333bf,
    RANK() OVER (ORDER BY e_444 ASC NULLS LAST) AS rank_444,
    RANK() OVER (ORDER BY e_minx ASC NULLS LAST) AS rank_minx,
    RANK() OVER (ORDER BY e_sq1 ASC NULLS LAST) AS rank_sq1
FROM country_speed_records

-- count of people per events
SELECT
  rsp.country_id,
  c.iso2,
  COUNT(CASE WHEN event_id = '333' AND world_rank < 1000 THEN 1 END) AS e_333,
  COUNT(CASE WHEN event_id = '333bf' AND world_rank < 1000 THEN 1 END) AS e_333bf,
  COUNT(CASE WHEN event_id = '444' AND world_rank < 1000 THEN 1 END) AS e_444,
  COUNT(CASE WHEN event_id = 'minx' AND world_rank < 1000 THEN 1 END) AS e_minx,
  COUNT(CASE WHEN event_id = 'sq1' AND world_rank < 1000 THEN 1 END) AS e_sq1
FROM ranks_singles_persons as rsp 
join countries as c on rsp.country_id=c.id
GROUP BY rsp.country_id;

create table competition_year_continent as
select comp.name, comp.year, coun.id as country, coun.continent_id as continent from competitions as comp
join countries as coun on comp.country_id = coun.id

create table person_year_continent as
select comp.wca_id, coun.continent_id as continent from persons as comp
join countries as coun on comp.country_id = coun.id order by comp.wca_id

create table best_dates as
select r.best, r.event_id, c.year, c.month, c.day  from results as r
join competitions as c on c.id=r.competition_id
where r.regional_single_record = "WR"

create table competitions_second_mapa_data4 as
SELECT 
    c.id, c.name, c.country_id, date(
    c.year || '-' ||
    printf('%02d', c.month) || '-' ||
    printf('%02d', c.day)
) AS full_date, c.year, c.month, c.day, c.wgs_long, c.wgs_lat, ch.championship_type,
    CASE 
        WHEN ch.competition_id IS NOT NULL THEN 1
        ELSE 0
    END AS is_championship
FROM competitions c
LEFT JOIN championships ch 
    ON c.id = ch.competition_id;

create table main_map_data as
select top.*, pos.rank_333, pos.rank_333bf, pos.rank_444, pos.rank_minx, pos.rank_sq1 from country_records_in_top1000 as top
join country_speed_record_positions as pos on top.iso2 = pos.iso2 order by pos.rank_333

create table external_relations_map3 as
select count(*) as result_count, c_comp.id as comp_country, c_comp.iso2 as comp_iso, 
c_person.id as person_country, c_person.iso2 as person_iso from results as r 
join competitions as c on c.id=r.competition_id 
join countries as c_person on c_person.id=r.person_country_id 
join countries as c_comp on c_comp.id=c.country_id 
where comp_iso != person_iso and c_comp.continent_id="_Europe" and c_person.continent_id="_Europe"
group by comp_iso, person_iso order by result_count desc

create table external_relations_map3_coor as 
select e.*, cp.LABEL_X as X_person, cp.LABEL_Y as Y_person, cc.LABEL_X as X_comp, cc.LABEL_Y as Y_comp, cc.populace from external_relations_map3 as e 
join country_coordinates as cp on cp.ISO_A2_EH=e.person_iso
join country_coordinates as cc on cc.ISO_A2_EH=e.comp_iso