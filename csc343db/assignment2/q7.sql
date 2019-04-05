-- Q7

SET search_path TO uber, public;


CREATE VIEW DriverRatingMe AS
(
  SELECT Driver.driver_id as driver_id, 
         sum(CASE WHEN DriverRating.rating=5 THEN 1 ELSE 0 END ) AS r5,
         sum(CASE WHEN DriverRating.rating=4 THEN 1 ELSE 0 END ) AS r4,
         sum(CASE WHEN DriverRating.rating=3 THEN 1 ELSE 0 END ) AS r3,
         sum(CASE WHEN DriverRating.rating=2 THEN 1 ELSE 0 END ) AS r2,
         sum(CASE WHEN DriverRating.rating=1 THEN 1 ELSE 0 END ) AS r1
  FROM Driver, Dispatch, DriverRating
  WHERE DriverRating.request_id = Dispatch.request_id AND
       Dispatch.driver_id = Driver.driver_id
  Group By Driver.driver_id
);

CREATE VIEW DriverWithNull AS
(
  SELECT Driver.driver_id, r5, r4, r3, r2, r1
  FROM Driver LEFT JOIN DriverRatingMe
  ON Driver.driver_id=DriverRatingMe.driver_id
);

CREATE TABLE DriverHistTable
(
  driver_id integer,
  r5 integer,
  r4 integer,
  r3 integer,
  r2 integer,
  r1 integer
);

INSERT INTO DriverHistTable
  SELECT *
  FROM DriverWithNull;


UPDATE DriverHistTable SET r5=null WHERE r5=0;
UPDATE DriverHistTable SET r4=null WHERE r4=0;
UPDATE DriverHistTable SET r3=null WHERE r3=0;
UPDATE DriverHistTable SET r2=null WHERE r2=0;
UPDATE DriverHistTable SET r1=null WHERE r1=0;

SELECT *
FROM DriverHistTable
ORDER BY r5 DESC, r4 DESC, r3 DESC, r2 DESC, r1 DESC, driver_id DESC;
