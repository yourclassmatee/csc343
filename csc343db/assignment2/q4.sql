-- Q4
-- LIMIT 10 AND 5 !!!


SET search_path TO uber, public;

CREATE VIEW Driver10 AS
(
  SELECT Dispatch.driver_id
  FROM Request, Dispatch
  WHERE Request.request_id = Dispatch.request_id
  GROUP BY Dispatch.driver_id
  HAVING count(date_trunc('day', Request.datetime)) >= 10
);


CREATE VIEW Day10 AS
(
  SELECT d1.driver_id, date_trunc('day', d1.datetime) AS days
  FROM Dispatch d1
  WHERE 
   (
    SELECT count(*)
    FROM Dispatch d2
    WHERE d2.driver_id=d1.driver_id
    AND d2.datetime < d1.datetime
  ) > 4
);



CREATE VIEW Day5 AS
(
  SELECT d1.driver_id, date_trunc('day', d1.datetime) AS days
  FROM Dispatch d1
  WHERE 
   (
    SELECT count(*)
    FROM Dispatch d2
    WHERE d2.driver_id=d1.driver_id
    AND d2.datetime < d1.datetime
  ) < 5
);



CREATE VIEW RideRating5 AS
(
  SELECT Day5.driver_id, avg(cast(DriverRating.rating as real)) AS rating
  FROM Day5, Driver10, DriverRating, Dispatch
  WHERE Day5.driver_id = Driver10.driver_id AND 
        Day5.driver_id = Dispatch.driver_id AND
        Dispatch.request_id = DriverRating.request_id AND
        Day5.days = date_trunc('day', Dispatch.datetime)
  GROUP BY Day5.driver_id
);


CREATE VIEW RideRatingLast5 AS
(
  SELECT Day10.driver_id, avg(cast(DriverRating.rating as real)) AS rating
  FROM Day10, Driver10, DriverRating, Dispatch
  WHERE Day10.driver_id = Driver10.driver_id AND 
        Day10.driver_id = Dispatch.driver_id AND
        Dispatch.request_id = DriverRating.request_id AND
        Day10.days = date_trunc('day', Dispatch.datetime)
  GROUP BY Day10.driver_id
);



CREATE VIEW resultQ4 AS
(
SELECT  Driver.trained AS type, count(Driver.driver_id) AS number,
        avg(RideRating5.rating) AS early, avg(RideRatingLast5.rating) AS late
FROM Driver, RideRatingLast5, RideRating5
WHERE Driver.driver_id = RideRatingLast5.driver_id AND
      Driver.driver_id = RideRating5.driver_id
GROUP BY Driver.trained
ORDER BY type
);


CREATE TABLE resultQ41
(
type VARCHAR(30),
type_bool BOOLEAN default false,
number integer,
early real,
late real
);


INSERT INTO resultq41 (type_bool, number, early, late)
(
  SELECT * FROM resultq4
);





UPDATE resultQ41
SET type='trained' WHERE type_bool = true;

UPDATE resultQ41
SET type='untrained' WHERE type_bool = false;

CREATE VIEW resultq42 as
(
SELECT type, number, early, late FROM
resultQ41
);

SELECT * FROM
resultq42;






