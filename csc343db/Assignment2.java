import java.sql.*;
// You should use this class so that you can represent SQL points as
// Java PGpoint objects.
import org.postgresql.geometric.PGpoint;

// If you are looking for Java data structures, these are highly useful.
// However, you can write the solution without them.  And remember
// that part of your mark is for doing as much in SQL (not Java) as you can.
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

public class Assignment2 {

   // A connection to the database
   Connection connection;

   Assignment2() throws SQLException {
      try {
         Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      }
   }

  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to uber.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {
      
      try {
        Class.forName("org.postgresql.Driver");
      }
      catch (ClassNotFoundException e) {
        System.out.println("Failed to find the JDBC driver");
      }
      
      try{
        connection = DriverManager.getConnection(URL, username, password);
        
        String queryString = "SET search_path TO uber";
        PreparedStatement pStatement = connection.prepareStatement(queryString);
        pStatement.execute();
        return true;
      }
      catch (SQLException se){
        System.err.println("SQL Exception." + "<Message>: " + se.getMessage()); 
      }
      
      return false;
   }

  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {
      
      try{
        connection.close();
        return true;
      }
      catch (Exception e){
        System.err.println(e.getMessage());
      }

      return false;
   }
   
   /* ======================= Driver-related methods ======================= */

   /**
    * Records the fact that a driver has declared that he or she is available 
    * to pick up a client.  
    *
    * Does so by inserting a row into the Available table.
    * 
    * @param  driverID  id of the driver
    * @param  when      the date and time when the driver became available
    * @param  location  the coordinates of the driver at the time when 
    *                   the driver became available
    * @return           true if the insertion was successful, false otherwise. 
    */
   public boolean available(int driverID, Timestamp when, PGpoint location) {
      
      try{
        String queryString = "INSERT INTO Available (driver_id, datetime, location) " + 
                              "VALUES (?, ?, ?);";
        PreparedStatement ps = connection.prepareStatement(queryString);
        ps.setInt(1, driverID);
        ps.setTimestamp(2, when);
        ps.setObject(3, location);   
        
        ps.execute();
        
        return true;                  
      }
      catch (SQLException se){
        System.err.println("SQL Exception." + "<Message>: " + se.getMessage()); 
      }


      return false;
   }
  
  
   /**
    * Records the fact that a driver has picked up a client.
    *
    * If the driver was dispatched to pick up the client and the corresponding
    * pick-up has not been recorded, records it by adding a row to the
    * Pickup table, and returns true.  Otherwise, returns false.
    * 
    * @param  driverID  id of the driver
    * @param  clientID  id of the client
    * @param  when      the date and time when the pick-up occurred
    * @return           true if the operation was successful, false otherwise
    */
   public boolean picked_up(int driverID, int clientID, Timestamp when) {
      
      
      try{
      
        // First check whether this entry has been registered in our database
        // same request id. driver, client and timestamp all match up
        String queryString = "SELECT Pickup.request_id " +
                              "FROM Request, Dispatch, Pickup " + 
                              "WHERE Dispatch.request_id=Pickup.request_id AND " +
                              "      Dispatch.request_id=Request.request_id AND " +
                              "      Dispatch.driver_id=? AND Request.client_id=? AND" + 
                              "      Pickup.datetime=?;";
        
        PreparedStatement ps = connection.prepareStatement(queryString);
        ps.setInt(1, driverID);
        ps.setInt(2, clientID);
        ps.setObject(3, when);
        ResultSet rs = ps.executeQuery();      
      
        if (rs.next()){   // If there is an item that is sent back, it means the
                          // pickup has already been recorded
          return false;
        }

        // Find all dispatches of this driver to this client
        queryString = "SELECT Request.request_id AS request_id, Dispatch.datetime AS dispatchTime " +
                      "FROM Request, Dispatch " + 
                      "WHERE Dispatch.request_id=Request.request_id AND " + 
                      "      Dispatch.driver_id= ? AND Request.client_id= ?;";
        
        ps = connection.prepareStatement(queryString);
        ps.setInt(1, driverID);
        ps.setInt(2, clientID);
        rs = ps.executeQuery();      
        
        if (rs.next()) {
          // Find the latest dispatch for this driver to this client. This must be the
          // one that is waiting for pickup (because we first checked if dispatch and
          // request match up)
          
          Timestamp latest = rs.getTimestamp("dispatchTime");
          int requestID = rs.getInt("request_id");
          
          System.out.println("Request id: " + requestID);
          
          while (rs.next()){
            Timestamp cur = rs.getTimestamp("dispatchTime");
            if (latest.compareTo(cur) > 0){
              latest = cur;
              requestID = rs.getInt("request_id");
            }
          }
          
          System.out.println("Latest: " + latest);
          
          // Now we have obtained the request_id, so we can execute the insert query
          queryString = "INSERT INTO Pickup (request_id, datetime) " + 
                                "VALUES (?, ?);";
          ps = connection.prepareStatement(queryString);
          ps.setInt(1, requestID);
          ps.setTimestamp(2, when);
          
          ps.execute();
          
          return true;     
        
        } else {
          return false;   // This pickup is invalid, no such driver client combo
        }
                
      }
      catch (SQLException se){
        System.err.println("SQL Exception." + "<Message>: " + se.getMessage()); 
      }

      return false;
   }
   
   /* ===================== Dispatcher-related methods ===================== */

   /**
    * Dispatches drivers to the clients who've requested rides in the area
    * bounded by NW and SE.
    * 
    * For all clients who have requested rides in this area (i.e., whose 
    * request has a source location in this area), dispatches drivers to them
    * one at a time, from the client with the highest total billings down
    * to the client with the lowest total billings, or until there are no
    * more drivers available.
    *
    * Only drivers who (a) have declared that they are available and have 
    * not since then been dispatched, and (b) whose location is in the area
    * bounded by NW and SE, are dispatched.  If there are several to choose
    * from, the one closest to the client's source location is chosen.
    * In the case of ties, any one of the tied drivers may be dispatched.
    *
    * Area boundaries are inclusive.  For example, the point (4.0, 10.0) 
    * is considered within the area defined by 
    *         NW = (1.0, 10.0) and SE = (25.0, 2.0) 
    * even though it is right at the upper boundary of the area.
    *
    * Dispatching a driver is accomplished by adding a row to the
    * Dispatch table.  All dispatching that results from a call to this
    * method is recorded to have happened at the same time, which is
    * passed through parameter 'when'.
    * 
    * @param  NW    x, y coordinates in the northwest corner of this area.
    * @param  SE    x, y coordinates in the southeast corner of this area.
    * @param  when  the date and time when the dispatching occurred
    */
   public void dispatch(PGpoint NW, PGpoint SE, Timestamp when) {
   
   
      try{
      
        // Requests that have not been picked up yet
        String queryString = "CREATE VIEW GoodReq AS ( " + 
                             "SELECT request_id " +
                             "FROM Request " + 
                             "EXCEPT " + 
                             "SELECT request_id "+
                             "FROM Pickup);"; 
        
        PreparedStatement ps = connection.prepareStatement(queryString);
        ps.execute();      
     	System.out.println("query1");
        // All clients ordered by bill amount
        queryString = "CREATE VIEW ClientBill AS ( " + 
                      "SELECT client.client_id, sum(Billed.amount) as billSum " +
                      "FROM Request, Client, Billed " + 
                      "WHERE Request.request_id=Billed.request_id AND "+
                      "      Request.client_id=Client.client_id "+
                      "GROUP BY Client.client_id); ";
        ps = connection.prepareStatement(queryString);
        ps.execute(); 
	System.out.println("query2");
      
        // Get all drivers who are available
        queryString = "SELECT DISTINCT Driver.driver_id as did, Available.location as location " +
                      "FROM Driver, Available " + 
                      "WHERE Driver.driver_id=Available.driver_id AND "+
                      "NOT EXISTS ( " + 
                      "SELECT * " +
                      "FROM Dispatch " + 
                      "WHERE Dispatch.datetime > Available.datetime AND "+
                      "Dispatch.driver_id=Driver.driver_id);";
	
        ps = connection.prepareStatement(queryString);
        ResultSet rs = ps.executeQuery(); 
	System.out.println("Query3 available drivers");
	        


        ArrayList<Integer> driverID = 
            new ArrayList<Integer>();
        ArrayList<PGpoint> driverLocation = 
            new ArrayList<PGpoint>();
        
        while (rs.next()){
          System.out.println("has result?");
          PGpoint temp = (PGpoint)rs.getObject("location");
          if (inbox(NW, SE, temp)){
			System.out.println("in box");
            driverID.add(rs.getInt("did"));
            driverLocation.add(temp);
          }
        
        }
		for(int i=0; i<driverID.size(); i++){
			System.out.println("driver id " + driverID.get(i));
		}

        
        // Get location of drivers 
        queryString = "SELECT GoodReq.request_id as rid, ClientBill.client_id as cid, Place.location as location" +
                      "FROM GoodReq, ClientBill, Request, Place " + 
                      "WHERE GoodReq.request_id=Request.requst_id AND "+
                      "      Request.client_id=ClientBill.client_id AND "+
                      "      Request.source=Place.name " +
                      "ORDER BY ClientBill.billSum; ";
        rs = ps.executeQuery();
        System.out.println("query4");
        
             
        ArrayList<Integer> requestID = 
            new ArrayList<Integer>();
        ArrayList<Integer> clientID = 
            new ArrayList<Integer>();
        ArrayList<PGpoint> clientLocation = 
            new ArrayList<PGpoint>();
        
        while (rs.next()){
        
          PGpoint temp = (PGpoint)rs.getObject("location");
          if (inbox(NW, SE, temp)){
            requestID.add(rs.getInt("rid"));
            clientID.add(rs.getInt("cid"));
            clientLocation.add((PGpoint)rs.getObject("location"));
          }

        }
        
        
        ArrayList<Integer> dpRid = new ArrayList<Integer>();
        ArrayList<Integer> dpDid = new ArrayList<Integer>();
        ArrayList<PGpoint> dpCarLoc = new ArrayList<PGpoint>();
        
        for (int i = 0; i < requestID.size(); i++){
          
          if (driverID.size() == 0){
            break;
          }
          
          double lowDist = Double.MAX_VALUE;
          int lowIndex = -1;
          for (int j = 0; j < driverID.size(); j++){
            double temp = getDist(clientLocation.get(i), driverLocation.get(j));
            if (temp < lowDist){
              lowDist = temp;
              lowIndex = j;
            }
          }
          
          // Add these information to a list of drivers who are about to
          // be dispatched
          dpDid.add(driverID.get(lowIndex));
          dpRid.add(requestID.get(i));
          dpCarLoc.add(driverLocation.get(lowIndex));
        }
                
        for (int i = 0; i < dpRid.size(); i++){	
	  System.out.println("here");
          queryString = "INSERT INTO Dispatch (request_id, driver_id, car_location, datetime) " + 
                        " VALUES(?, ?, ?, ?);";
          ps = connection.prepareStatement(queryString);
          ps.setInt(1, dpRid.get(i));
          ps.setInt(2, dpDid.get(i));
          ps.setObject(3, dpCarLoc.get(i));
          ps.setTimestamp(4, when);
          ps.execute(); 
              
        }
      
      }
      catch (SQLException se){
        System.err.println("SQL Exception." + "<Message>: " + se.getMessage()); 
      }
   }
   
   public boolean inbox (PGpoint tl, PGpoint br, PGpoint p){
   
    if (p.x >= tl.x && p.x <= br.x)
    {
      if (p.y >= tl.y && p.y <= br.y){
        return true;
      }
    }
    
    return false;
   } 
   
   public double getDist(PGpoint p1, PGpoint p2){
   
    double temp = (p1.x - p2.x) * (p1.x - p2.x) +  (p1.y - p2.y)* (p1.y - p2.y);
    return Math.sqrt(temp);
   }

   public static void main(String[] args) {
      // You can put testing code in here. It will not affect our autotester.
      System.out.println("Boo!");
   }



}
