import java.sql.*;
import config.DatabaseConfig;

public class setup_database {
    public static void main(String[] args) {
        try {
            Connection conn = DatabaseConfig.getConnection();
            System.out.println("Database connected successfully!");
            
            // Check if tables exist
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet rs = meta.getTables(null, null, "users", null);
            if (rs.next()) {
                System.out.println("Users table exists");
            } else {
                System.out.println("Users table does not exist - creating it...");
                createUsersTable(conn);
            }
            
            rs.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private static void createUsersTable(Connection conn) throws SQLException {
        String sql = "CREATE TABLE users (" +
                     "id SERIAL PRIMARY KEY, " +
                     "username VARCHAR(50) UNIQUE NOT NULL, " +
                     "email VARCHAR(100) UNIQUE NOT NULL, " +
                     "password VARCHAR(255) NOT NULL, " +
                     "role VARCHAR(50) NOT NULL" +
                     ")";
        Statement stmt = conn.createStatement();
        stmt.executeUpdate(sql);
        System.out.println("Users table created successfully!");
        stmt.close();
    }
}
