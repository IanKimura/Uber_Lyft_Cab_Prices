-- CREATE database to house the schemas
CREATE DATABASE group_project;


-- CREATE schema for importing data from Kaggle
CREATE SCHEMA datasets;


-- CREATE tables to house the data

-- cab_rides table
CREATE TABLE datasets.cab_rides(
	distance NUMERIC, 
	cab_type VARCHAR(250), 
	time_stamp BIGINT, 
	destination VARCHAR(250), 
	source VARCHAR(500), 
	price NUMERIC,
	surge_multiplier NUMERIC,
	id uuid,
	product_id VARCHAR(250),
	name VARCHAR(250)
);


-- Round time to allow for better joining
UPDATE datasets.cab_rides
SET time_stamp = EXTRACT(EPOCH FROM DATE_TRUNC('hour', to_timestamp(time_stamp / 1000)))::BIGINT;

-- Check to see if it works
select *
from datasets.cab_rides
limit 50;


-- Weather Table
CREATE TABLE datasets.weather(
	temp VARCHAR(250),
	location VARCHAR(250),
	clouds NUMERIC,
	pressure NUMERIC,
	rain NUMERIC,
	time_stamp BIGINT,
	humidity NUMERIC,
	wind NUMERIC
);


-- round for better joining
UPDATE datasets.weather
SET time_stamp = EXTRACT(EPOCH FROM DATE_TRUNC('hour', to_timestamp(time_stamp)))::BIGINT;


-- check to see if it works
SELECT *
FROM datasets.weather
LIMIT 10;

-- sample join just to see if this is possible to join with updated times

select *
from datasets.cab_rides c
     left join datasets.weather w on w.location = c.source and w.time_stamp = c.time_stamp
limit 10;




-- CREATE schema for the ERD tables
CREATE SCHEMA group22;




--  WEATHER entity

CREATE TABLE group22.Weather(
	w_id UUID PRIMARY KEY,
	temp VARCHAR(250),
	clouds NUMERIC,
	pressure NUMERIC,
	rain NUMERIC,
	humidity NUMERIC,
	wind NUMERIC
);
CREATE TEMP TABLE w_tmp AS (
	SELECT DISTINCT
           temp,clouds,pressure,rain,humidity,wind
    FROM datasets.weather

);

INSERT INTO group22.weather(
	SELECT gen_random_uuid(), * 
	FROM w_tmp

);

SELECT *
FROM group22.weather
limit 10;




-- LOCATION ENTITY

CREATE TABLE group22.Location(
	location_id UUID PRIMARY KEY,
	location_name VARCHAR(250) 
);

CREATE TEMP TABLE loc_tmp AS (
SELECT DISTINCT location FROM  datasets.weather
);


INSERT INTO group22.Location (
	SELECT gen_random_uuid(), * 
	FROM loc_tmp);
	
SELECT *
FROM group22.location
LIMIT 10;


-- CAB entity

CREATE TABLE group22.cab(
	cab_id uuid PRIMARY KEY,
	time_stamp BIGINT,
	cab_type VARCHAR(250),
	product_id VARCHAR(250),
	name VARCHAR(250)
);



CREATE TEMP TABLE c_tmp as (
SELECT DISTINCT 
	cab_type,
	time_stamp,
	product_id,
	name 
FROM datasets.cab_rides
);


INSERT INTO group22.cab (
  cab_id,
  time_stamp,
  cab_type,
  product_id,
  name
)
SELECT 
  gen_random_uuid() AS cab_id,
  time_stamp :: BIGINT,
  cab_type,
  product_id,
  name 
FROM c_tmp;

select *
from group22.cab
limit 10;


-- CAB_RIDE entity

CREATE TABLE group22.Cab_Ride(
	id UUID PRIMARY KEY,
	w_id UUID,
	cab_id UUID,
	source_location_id UUID,
	destination_location_id UUID,
	time_stamp BIGINT,
	distance NUMERIC,
	price NUMERIC,
	surge_multiplier NUMERIC
	
);

ALTER TABLE group22.Cab_Ride
ADD CONSTRAINT fk_w_id FOREIGN KEY (w_id) REFERENCES group22.weather(w_id);

ALTER TABLE group22.Cab_Ride
ADD CONSTRAINT fk_cab_id FOREIGN KEY (cab_id) REFERENCES group22.cab(cab_id);

ALTER TABLE group22.Cab_Ride
ADD CONSTRAINT fk_source_location_id FOREIGN KEY (source_location_id) REFERENCES group22.location(location_id);

ALTER TABLE group22.Cab_Ride
ADD CONSTRAINT fk_destination_location_id FOREIGN KEY (destination_location_id) REFERENCES group22.location(location_id);




CREATE TEMP TABLE cabride_tmp AS (
	SELECT DISTINCT on (r.id) r.id, gw.w_id as weather_id
		,c.cab_id, sl.location_id as source_location_id
		,dl.location_id as destination_location_id, r.time_stamp,
	    r.distance, r.price, r.surge_multiplier
	FROM datasets.cab_rides r
		LEFT JOIN datasets.weather w ON r.source = w.location
			AND r.time_stamp = w.time_stamp
		LEFT JOIN group22.cab c ON c.cab_type=r.cab_type
	              and c.name = r.name
	              and c.time_stamp = r.time_stamp
	              and c.product_id = r.product_id
		LEFT JOIN group22.weather gw ON w.temp = gw.temp
	              and w.pressure = gw.pressure
	              and w.rain = gw.rain
	              and w.humidity = gw.humidity
	              and w.clouds = gw.clouds
		LEFT JOIN group22.location sl ON sl.location_name=r.source
		LEFT JOIN group22.location dl ON dl.location_name=r.destination

);


INSERT INTO group22.Cab_Ride (
    id,
    w_id,
    cab_id,
    source_location_id,
    destination_location_id,
    time_stamp,
    distance,
    price,
    surge_multiplier
)
SELECT
    DISTINCT id,
    weather_id,
    cab_id,
    source_location_id,
    destination_location_id,
    time_stamp,
    distance,
    price,
    surge_multiplier
FROM cabride_tmp;


select *
from group22.cab_ride
limit 10;



-- weather_location entity


CREATE TABLE group22.weather_location(
	wloc_id UUID PRIMARY KEY,
	location_id UUID,
	w_id UUID,
	time_stamp BIGINT
);

ALTER TABLE group22.weather_location
ADD CONSTRAINT fk_location_id FOREIGN KEY (location_id) REFERENCES group22.location(location_id);

ALTER TABLE group22.weather_location
ADD CONSTRAINT fk_w_id FOREIGN KEY (w_id) REFERENCES group22.weather(w_id);

CREATE TEMP TABLE weatherloc_tmp AS (
	SELECT l.location_id, gw.w_id, r.time_stamp
	FROM datasets.cab_rides r
		LEFT JOIN datasets.weather w ON r.source = w.location
			AND r.time_stamp = w.time_stamp
	    LEFT JOIN group22.weather gw ON w.temp = gw.temp
	              and w.pressure = gw.pressure
	              and w.rain = gw.rain
	              and w.humidity = gw.humidity
	              and w.clouds = gw.clouds
	    LEFT JOIN group22.location l on r.source = l.location_name
	
);

INSERT INTO group22.weather_location(
    SELECT gen_random_uuid() as wloc_id, *
	FROM weatherloc_tmp
);


select *
from group22.weather_location 
limit 10;



-- SELECT statements for each table

SELECT *
FROM group22.cab
LIMIT 10;

SELECT *
FROM group22.cab_ride
LIMIT 10;

SELECT *
FROM group22.location
LIMIT 10;

select *
from group22.weather
limit 10;

select *
from group22.weather_location
limit 10;







