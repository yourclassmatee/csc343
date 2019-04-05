-- Q6
SET search_path TO uber, public;

CREATE VIEW ClientRides AS
(
    SELECT Client.client_id, extract(year FROM Request.datetime) AS year, count(Request.request_id) AS numRides
    FROM Client,  Request
    WHERE Request.client_id=Client.client_id
    GROUP BY Client.client_id, extract(year FROM Request.datetime)
);

CREATE VIEW Garbage AS
(
  SELECT Client.client_id, extract(year FROM Request.datetime) AS year
  FROM Client, Request
);

CREATE VIEW NewClientRides AS
(
  SELECT Garbage.client_id, Garbage.year, ClientRides.numRides
  FROM Garbage LEFT JOIN ClientRides
  ON Garbage.client_id=ClientRides.client_id AND Garbage.year=ClientRides.year
);


CREATE VIEW Top AS
(
    SELECT client_id, year, numRides, 
            DENSE_RANK() OVER(ORDER BY numRides ASC) AS rk
    FROM NewClientRides
    GROUP BY client_id, year, numRides
);


CREATE VIEW Bottom AS
(
    SELECT client_id, year, numRides, 
            DENSE_RANK() OVER(ORDER BY numRides DESC) AS rk
    FROM NewClientRides
    GROUP BY client_id, year, numRides
);

CREATE TABLE Combined(
    client_id integer,
    year integer,
    rides integer
); 

INSERT INTO Combined (client_id, year, rides)
    SELECT client_id, year, numRides
    FROM Top
    WHERE rk = 1 or rk = 2 or rk = 3;

INSERT INTO Combined (client_id, year, rides)
    SELECT client_id, year, numRides
    FROM Bottom
    WHERE rk = 1 or rk = 2 or rk = 3;

UPDATE Combined 
SET rides=0 
WHERE rides is null;

SELECT DISTINCT *
FROM Combined
ORDER BY rides DESC, year ASC, client_id ASC;
