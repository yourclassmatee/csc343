-- Q5


SET search_path TO uber, public;



CREATE VIEW ClientTotal AS
(
  SELECT extract(year from Request.datetime) || ' ' || 
  extract(month from Request.datetime) AS month, 
        sum(Billed.amount) AS clientSum,
        Client.client_id
  FROM  Client, Request, Billed
  WHERE Request.request_id = Billed.request_id AND 
        Request.client_id = Client.client_id
  GROUP BY extract(year from Request.datetime), 
            extract(month from Request.datetime), 
            Client.client_id
);

CREATE VIEW MonthAvg AS
(
  SELECT month, 
        avg(clientSum) AS average
  FROM ClientTotal
  GROUP BY month
);

CREATE VIEW totalList AS
(
  SELECT Client.client_id, 
          ClientTotal.month
  FROM Client, ClientTotal
);


CREATE VIEW garbage as
(
  SELECT totalList.client_id, totalList.month, ClientTotal.clientSum
  FROM totalList left join ClientTotal
  ON totalList.client_id=ClientTotal.client_id
  AND totalList.month=ClientTotal.month
);


CREATE VIEW JointAvg AS
(
  SELECT garbage.client_id as client_id, 
        MonthAvg.month,
        MonthAvg.average, garbage.clientSum 
  FROM MonthAvg, garbage
  WHERE MonthAvg.month = garbage.month
);

  
CREATE TABLE Result (
  client_id integer,
  month varchar(7),
  clientSum real,
  comparison varchar(12)
) ;


CREATE VIEW Below AS
(
  SELECT client_id, month,
        average, clientSum
  FROM JointAvg
  WHERE clientSum < average or clientSum is null
);

CREATE VIEW AtAbove AS
(
  SELECT client_id, month,
        average, clientSum 
  FROM JointAvg
  WHERE clientSum >= average
);

CREATE TABLE Combined(
    client_id integer,
    month varchar(12),
    average real,
    clientSum real,
    comparison varchar(12)
);

INSERT INTO Combined(client_id, month, average, clientSum)
    SELECT *
    FROM Below;
    
INSERT INTO Combined(client_id, month, average, clientSum)
    SELECT *
    FROM AtAbove;

UPDATE Combined SET comparison='below' 
WHERE clientSum < average or clientSum is null;

UPDATE Combined SET comparison='at or above' WHERE clientSum >= average;

UPDATE Combined SET clientSum=0 WHERE clientSum is null;

CREATE VIEW resultQ5 as 
(
SELECT DISTINCT client_id, month, 
                clientSum AS total, comparison
FROM Combined
ORDER BY month, total asc, client_id asc
);


SELECT * 
FROM resultQ5;

