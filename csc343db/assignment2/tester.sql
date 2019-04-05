SELECT Driver.firstname || ' ' || Driver.surname AS names
FROM Client, Driver, Request, Dispatch
WHERE Client.client_id=Request.client_id AND
        Request.request_id=Dispatch.request_id AND 
        Dispatch.driver_id=Driver.driver_id AND 
        Client.firstname || ' ' || Client.surname= 'Daisy Mason';
