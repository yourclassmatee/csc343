import java.sql.*;
import org.postgresql.geometric.PGpoint;

class SelfTest {

  Assignment2 a2;
  SelfTest(){
    try {
            a2 = new Assignment2();
    } catch(Exception e){
            System.out.println("Error importing A2!");
    }
  }

  public static void main(String args[]){
  
    SelfTest st = new SelfTest();
    String dbname = args[0];
    String url = "jdbc:postgresql:" + dbname;
    String username = args[1];
    String password = "";
    
    java.sql.Timestamp now = new Timestamp(new Long(1457676102));
    org.postgresql.geometric.PGpoint location = new org.postgresql.geometric.PGpoint(new Double(1), new Double(1));

	org.postgresql.geometric.PGpoint topleft = new org.postgresql.geometric.PGpoint(0,0);
	org.postgresql.geometric.PGpoint bottomright = new org.postgresql.geometric.PGpoint(100,100);
    Integer ret = 0;
    
    if(st.a2.connectDB(url,username,password)) {
    
      System.out.println("==========\nJDBC CONNECT\n==========\n\tSuccessfully connected to DB");
		
	
      System.out.println(st.a2.available(22222, now, location));
      System.out.println("*****************************************");
      System.out.println(st.a2.picked_up(33333, 100, now));


	  System.out.println("********************dispatch*********************");
	  System.out.println(topleft.x + "   " + topleft.y);
	  System.out.println(bottomright.x + "   " + bottomright.y);

      st.a2.dispatch(topleft, bottomright, now);


      ret += 1;
      if (st.a2.disconnectDB()) {
        System.out.println("==========\nJDBC DISCONNECT\n==========\n\tSuccessfully disconnected from DB");
        ret += 4;
      } else {
        System.out.println("==========\nJDBC DISCONNECT\n==========\n\tFailed to disconnect from DB");
      }
      
    } else {
      System.out.println("==========\nJDBC CONNECT\n==========\n\tFailed to connect to DB");
    }
    
    System.exit(ret);
    
  }
}
