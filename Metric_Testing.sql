/* ------ Metrics ------------ */
/*
Metrics Outline:
1. [Average Ride Price by Weather Conditions: To analyze the relationship between weather conditions and 
                                              the average price of Uber and Lyft rides over a specified period.
2. [Ride Demand by Location]: To analyze and quantify the demand for Uber and Lyft rides in different locations, 
                              identifying popular areas and understanding variations in ride demand over time.
3. [Hourly Ride Demand Fluctuation]: To analyze the hourly variations in ride demand to understand peak hours 
                                     and identify potential opportunities for service optimization
*/ 
/*------- Queries ------------*/
/*[Average Ride Price by Weather Conditions]: To analyze the relationship between weather conditions and 
                                              the average price of Uber and Lyft rides over a specified period.*/
-- temperature
SELECT
    w.temp,
    AVG(cr.price) AS average_ride_price
FROM
    group22.Cab_Ride cr
    JOIN group22.Weather w ON cr.w_id = w.w_id
GROUP BY
    EXTRACT(MONTH FROM TO_TIMESTAMP(cr.time_stamp)::TIMESTAMP),
    w.temp
ORDER BY
    AVG(cr.price) desc;

-- rain	
SELECT
    w.rain,
    AVG(cr.price) AS average_ride_price
FROM
    group22.Cab_Ride cr
    JOIN group22.Weather w ON cr.w_id = w.w_id
GROUP BY
    EXTRACT(MONTH FROM TO_TIMESTAMP(cr.time_stamp)::TIMESTAMP),
    w.rain
ORDER BY
    avg(cr.price) desc;
	
	
/*[Ride Demand by Location]: To analyze and quantify the demand for Uber and Lyft rides in different locations, 
                              identifying popular areas and understanding variations in ride demand over time.*/

SELECT
    l.location_name,
    COUNT(cr.id) AS ride_demand
FROM
    group22.Cab_Ride cr
    JOIN group22.Location l ON cr.source_location_id = l.location_id
GROUP BY
    EXTRACT(MONTH FROM TO_TIMESTAMP(cr.time_stamp)::TIMESTAMP),
    l.location_name
ORDER BY
    ride_demand desc;


/*Hourly Ride Demand Fluctuation: To analyze the hourly variations in ride demand to understand peak hours 
                                  and identify potential opportunities for service optimization.*/
SELECT
    EXTRACT(HOUR FROM TO_TIMESTAMP(cr.time_stamp)::TIMESTAMP) AS hour_of_day,
    COUNT(cr.id) AS ride_demand
FROM
    group22.Cab_Ride cr
GROUP BY
    EXTRACT(HOUR FROM TO_TIMESTAMP(cr.time_stamp)::TIMESTAMP)
ORDER BY
    hour_of_day;