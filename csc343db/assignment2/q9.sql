-- Q9
SET search_path TO uber, public;

CREATE VIEW AllPairs AS
(
    SELECT DISTINCT Request.client_id, Dispatch.driver_id
    FROM Request, Dispatch
    WHERE Request.request_id=Dispatch.request_id
);


CREATE VIEW ActualPairs AS
(
    SELECT DISTINCT Request.client_id, Dispatch.driver_id
    FROM Request, Dispatch, DriverRating
    WHERE Request.request_id=Dispatch.request_id AND
            DriverRating.request_id=Request.request_id
);

CREATE VIEW NotWantedClients AS
(
    SELECT *
    FROM AllPairs
    
    EXCEPT
    
    SELECT *
    FROM ActualPairs
);


CREATE VIEW WantedClients AS
(
    SELECT client_id
    FROM Client
    
    EXCEPT

    SELECT client_id
    FROM NotWantedClients
);

CREATE VIEW resultQ9 AS
(
  SELECT DISTINCT Client.client_id, Client.email
  FROM Client, WantedClients
  WHERE Client.client_id=WantedClients.client_id
  ORDER BY Client.email
);

SELECT *
FROM resultQ9
ORDER BY email ASC, client_id ASC;


