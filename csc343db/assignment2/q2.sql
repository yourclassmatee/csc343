
SET search_path TO uber, public;

CREATE VIEW Spend500 AS (
  SELECT Request.client_id, sum(Billed.amount) AS sum2014
  FROM Request NATURAL JOIN Billed
  WHERE extract(year from datetime) < 2014
  GROUP BY Request.client_id
);

CREATE VIEW Ride2014 AS (
  SELECT Request.client_id, count(Request.request_id) AS rideNum
  FROM Request 
  WHERE extract(year from datetime) = 2014
  GROUP BY Request.client_id
  HAVING count(Request.request_id) > 1 AND count(Request.request_id) < 10
);

CREATE VIEW Ride2015 AS (
  SELECT Request.client_id, count(Request.request_id) AS rideNum
  FROM Request 
  WHERE extract(year from datetime) = 2015
  GROUP BY Request.client_id
);

CREATE VIEW ResultQ2 AS
(
SELECT Client.client_id AS client_id, 
        (Client.firstname || ' ' || Client.surname) AS name,
        Client.email as email,
        Spend500.sum2014 AS billed, 
        Ride2014.rideNum - Ride2015.rideNum AS decline
FROM Client, Spend500, Ride2014, Ride2015
WHERE Client.client_id = Spend500.client_id AND 
      Client.client_id = Ride2014.client_id AND 
      Client.client_id = Ride2015.client_id AND
      Ride2014.rideNum > Ride2015.rideNum
);

SELECT DISTINCT *
FROM ResultQ2
ORDER BY billed DESC;
