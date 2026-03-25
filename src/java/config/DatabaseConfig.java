package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {
    
    private static Connection connection;
    
    // Database configuration
    private static String getDatabaseUrl() {
        // Check for Heroku DATABASE_URL environment variable
        String databaseUrl = System.getenv("DATABASE_URL");
        
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // Heroku PostgreSQL connection
            return databaseUrl;
        } else {
            // Local MySQL connection (fallback)
            return "jdbc:mysql://localhost:3306/securitymanagementsystem";
        }
    }
    
    private static String getDatabaseUser() {
        String databaseUrl = System.getenv("DATABASE_URL");
        
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // Extract username from Heroku DATABASE_URL
            // Format: postgres://username:password@host:port/database
            return databaseUrl.split("//")[1].split(":")[0];
        } else {
            // Local MySQL user
            return "root";
        }
    }
    
    private static String getDatabasePassword() {
        String databaseUrl = System.getenv("DATABASE_URL");
        
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // Extract password from Heroku DATABASE_URL
            String[] parts = databaseUrl.split("//")[1].split("@")[0].split(":");
            return parts.length > 1 ? parts[1] : "";
        } else {
            // Local MySQL password
            return "";
        }
    }
    
    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                String url = getDatabaseUrl();
                String user = getDatabaseUser();
                String password = getDatabasePassword();
                
                // Handle different database types
                if (url.startsWith("jdbc:postgresql://")) {
                    // PostgreSQL for Heroku
                    Class.forName("org.postgresql.Driver");
                } else {
                    // MySQL for local development
                    Class.forName("com.mysql.cj.jdbc.Driver");
                }
                
                connection = DriverManager.getConnection(url, user, password);
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
