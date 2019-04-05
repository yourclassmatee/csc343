SET search_path TO uber, public;

CREATE VIEW DriverDuration AS (
  SELECT  Dispatch.driver_id, 
          date_trunc('day', min(Pickup.datetime)) AS durationDay, 
          sum(Dropoff.datetime - Pickup.datetime) AS Duration
  FROM Dispatch, Pickup, Dropoff
  WHERE Dispatch.request_id = Pickup.request_id AND
        Dispatch.request_id = Dropoff.request_id
  GROUP BY Dispatch.driver_id, 
            date_trunc('day', Pickup.datetime) 
);


CREATE VIEW DriverBreak AS (
  SELECT Dp1.driver_id, date_trunc('day', min(Pickup.datetime)) AS breakDay, 
        sum (
              (
              SELECT Dropoff.datetime
              FROM Dropoff, Dispatch AS Dp2
              WHERE Dropoff.datetime > Pickup.datetime AND
                    Dropoff.request_id = Dp2.request_id AND
                    Dp1.driver_id = Dp2.driver_id
              ORDER BY Dropoff.datetime 
              )
              - Pickup.datetime
            ) AS breakDuration
  FROM Dispatch AS Dp1, Pickup
  WHERE Dp1.request_id = Pickup.request_id
  GROUP BY Dp1.driver_id, 
    date_trunc('day', Pickup.datetime) 
);
    
    

CREATE VIEW DriverBreak15 AS (
  SELECT DISTINCT Dp1.driver_id, date_trunc('day', min(Pickup.datetime)) AS breakDay
  FROM Dispatch AS Dp1, Pickup
  WHERE Dp1.request_id = Pickup.request_id AND
        EXTRACT(EPOCH FROM (
          SELECT Dropoff.datetime
          FROM Dropoff, Dispatch AS Dp2
          WHERE Dropoff.datetime > Pickup.datetime AND
                Dropoff.request_id = Dp2.request_id AND
                Dp1.driver_id = Dp2.driver_id
          ORDER BY Dropoff.datetime 
        )) 
        - EXTRACT(EPOCH FROM Pickup.datetime) > 900
  GROUP BY Dp1.driver_id, 
    date_trunc('day', Pickup.datetime) 
);


SELECT DD1.driver_id AS driver,
       to_char(extract(year from DD1.durationDay), '9999') ||
       to_char(extract(month from DD1.durationDay),'99')   ||
       to_char(extract(day from DD1.durationDay),'99') AS start,
       DD1.Duration + DD2.Duration + DD3.Duration AS driving, 
       DB1.breakDuration + DB2.breakDuration + DB3.breakDuration AS breaks
FROM DriverDuration AS DD1, DriverDuration AS DD2, DriverDuration AS DD3,
     DriverBreak AS DB1, DriverBreak AS DB2, DriverBreak AS DB3, 
     DriverBreak15 AS DB15
WHERE 
       DD1.durationDay = DB1.breakDay AND
       DD2.durationDay = DB2.breakDay AND
       DD3.durationDay = DB3.breakDay AND
        (DB1.breakDay = DB15.breakDay OR
         DB2.breakDay = DB15.breakDay OR
         DB3.breakDay = DB15.breakDay) AND
       EXTRACT(EPOCH FROM DD1.Duration) > 43200 AND
       EXTRACT(EPOCH FROM DD2.Duration) > 43200 AND
       EXTRACT(EPOCH FROM DD3.Duration) > 43200 AND
      (EXTRACT(EPOCH FROM DD2.durationDay) - EXTRACT(EPOCH FROM DD1.durationDay) = 86400) AND
      (EXTRACT(EPOCH FROM DD3.durationDay) - EXTRACT(EPOCH FROM DD2.durationDay) = 86400)
       ;
