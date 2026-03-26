package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {
    
    private static Connection connection;
    
    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                String databaseUrl = System.getenv("DATABASE_URL");
                
                if (databaseUrl != null && !databaseUrl.isEmpty()) {
                    // Parse Heroku DATABASE_URL: postgres://username:password@host:port/database
                    if (databaseUrl.startsWith("postgres://")) {
                        // Convert to JDBC format
                        String jdbcUrl = databaseUrl.replace("postgres://", "jdbc:postgresql://");
                        
                        // Load PostgreSQL driver
                        Class.forName("org.postgresql.Driver");
                        
                        // Use full connection string (JDBC will parse it)
                        connection = DriverManager.getConnection(jdbcUrl);
                    } else {
                        connection = DriverManager.getConnection(databaseUrl);
                    }
                } else {
                    // Local MySQL connection
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/securitymanagementsystem", 
                        "root", 
                        ""
                    );
                }
            } catch (ClassNotFoundException e) {
                throw new SQLException("Database driver not found", e);
            }
        }
        return connection;
    }
    
    public static void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
