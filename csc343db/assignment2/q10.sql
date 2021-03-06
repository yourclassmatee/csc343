-- Q10

SET search_path TO uber, public;

CREATE TABLE month12
(
  month integer
);

INSERT INTO month12 (month) VALUES (1);
INSERT INTO month12 (month) VALUES (2);
INSERT INTO month12 (month) VALUES (3);
INSERT INTO month12 (month) VALUES (4);
INSERT INTO month12 (month) VALUES (5);
INSERT INTO month12 (month) VALUES (6);
INSERT INTO month12 (month) VALUES (7);
INSERT INTO month12 (month) VALUES (8);
INSERT INTO month12 (month) VALUES (9);
INSERT INTO month12 (month) VALUES (10);
INSERT INTO month12 (month) VALUES (11);
INSERT INTO month12 (month) VALUES (12);


CREATE VIEW driverMonth AS 
(
  SELECT Driver.driver_id, month12.month
  FROM Driver, month12
);


CREATE VIEW fly4 AS
(
  SELECT Dispatch.driver_id, extract(month from Request.datetime) as month, 
          sum(begin.location <@> finish.location) as mileage, 
          sum(Billed.amount) as billing
  FROM Request, Place as begin, Place as finish,  Driver, Dispatch, Billed
  WHERE Request.request_id=Dispatch.request_id AND
        begin.name=Request.source AND finish.name=Request.destination AND
        Billed.request_id=Request.request_id AND
        Driver.driver_id=Dispatch.driver_id
  GROUP BY Dispatch.driver_id, extract(year from Request.datetime), 
          extract(month from Request.datetime)
  HAVING extract(year from Request.datetime)=2014

);

CREATE VIEW fly4Full AS
(
  SELECT driverMonth.driver_id, driverMonth.month, fly4.mileage, fly4.billing
  FROM driverMonth LEFT JOIN fly4
  ON driverMonth.driver_id=fly4.driver_id AND
      driverMonth.month=fly4.month
);

 

CREATE VIEW fly5 AS
(
  SELECT Dispatch.driver_id, extract(month from Request.datetime) as month, 
          sum(begin.location <@> finish.location) as mileage, 
          sum(Billed.amount) as billing
  FROM Request, Place as begin, Place as finish,  Driver, Dispatch, Billed
  WHERE Request.request_id=Dispatch.request_id AND
        begin.name=Request.source AND finish.name=Request.destination AND
        Billed.request_id=Request.request_id AND
        Driver.driver_id=Dispatch.driver_id
  GROUP BY Dispatch.driver_id, extract(year from Request.datetime), 
          extract(month from Request.datetime)
  HAVING extract(year from Request.datetime)=2015
);

CREATE VIEW fly5Full AS
(
  SELECT  driverMonth.driver_id, driverMonth.month, fly5.mileage, fly5.billing
  FROM driverMonth LEFT JOIN fly5
  ON driverMonth.driver_id=fly5.driver_id AND
      driverMonth.month=fly5.month
);

CREATE VIEW crow20142015 AS
(
  SELECT fly4Full.driver_id, fly4Full.month, fly4Full.mileage as m2014, 
          fly4Full.billing as b2014,
          fly5Full.mileage as m2015, fly5Full.billing as b2015
  FROM fly4Full, fly5Full
  WHERE fly4Full.driver_id=fly5Full.driver_id AND fly4Full.month=fly5Full.month
);



CREATE TABLE Result(
  driver_id integer,
  month integer,
  mileage_2014 real,
  billings_2014 real,
  mileage_2015 real,
  billings_2015 real,
  billings_increase real,
  mileage_increase real
);


INSERT INTO Result (driver_id, month, mileage_2014, 
                      billings_2014, mileage_2015, billings_2015)
  SELECT *
  FROM crow20142015;
  
UPDATE Result 
SET mileage_2014 = 0 WHERE mileage_2014 IS NULL;

UPDATE Result 
SET billings_2014 = 0 WHERE billings_2014 IS NULL;

UPDATE Result 
SET mileage_2015 = 0 WHERE mileage_2015 IS NULL;

UPDATE Result 
SET billings_2015 = 0 WHERE billings_2015 IS NULL;





UPDATE Result 
SET billings_increase=billings_2015 - billings_2014,
    mileage_increase=mileage_2015 - mileage_2014;
 
SELECT *
FROM Result
ORDER BY driver_id ASC, month ASC;
  


