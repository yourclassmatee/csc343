
SET search_path TO uber, public;

CREATE VIEW ResultQ1 AS (
  SELECT tempFrom.client_id as client_id, tempFrom.email as email, 
          sum(CASE WHEN tempCount!=0 THEN 1 ELSE 0 END ) AS months
  FROM(
    SELECT Client.client_id, Client.email, 
            count(Request.request_id) AS tempCount
    FROM Client LEFT JOIN Request
    ON CLient.client_id=Request.client_id
    GROUP BY Client.client_id, to_char(extract(month from datetime),'99')
                                ||to_char(extract(year from datetime), '9999')
    ) tempFrom
  GROUP BY tempFrom.client_id, tempFrom.email
  ORDER BY months DESC
);

SELECT DISTINCT *
FROM ResultQ1;





