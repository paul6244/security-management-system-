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
                    System.out.println("DEBUG: DATABASE_URL found: " + databaseUrl.substring(0, Math.min(50, databaseUrl.length())) + "...");
                    
                    // Parse Heroku DATABASE_URL: postgres://username:password@host:port/database
                    if (databaseUrl.startsWith("postgres://")) {
                        // Convert to JDBC format
                        String jdbcUrl = databaseUrl.replace("postgres://", "jdbc:postgresql://");
                        System.out.println("DEBUG: Converted to JDBC URL: " + jdbcUrl.substring(0, Math.min(50, jdbcUrl.length())) + "...");
                        
                        // Load PostgreSQL driver
                        try {
                            Class.forName("org.postgresql.Driver");
                            System.out.println("DEBUG: PostgreSQL driver loaded successfully");
                        } catch (ClassNotFoundException e) {
                            System.out.println("ERROR: PostgreSQL driver not found: " + e.getMessage());
                            throw new SQLException("PostgreSQL driver not found", e);
                        }
                        
                        // Use full connection string (JDBC will parse it)
                        try {
                            connection = DriverManager.getConnection(jdbcUrl);
                            System.out.println("DEBUG: Database connection established successfully");
                        } catch (SQLException e) {
                            System.out.println("ERROR: Failed to connect to database: " + e.getMessage());
                            throw e;
                        }
                    } else {
                        connection = DriverManager.getConnection(databaseUrl);
                    }
                } else {
                    System.out.println("DEBUG: No DATABASE_URL found, using local MySQL");
                    // Local MySQL connection
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/securitymanagementsystem", 
                        "root", 
                        ""
                    );
                }
            } catch (ClassNotFoundException e) {
                System.out.println("ERROR: Database driver not found: " + e.getMessage());
                throw new SQLException("Database driver not found", e);
            } catch (SQLException e) {
                System.out.println("ERROR: SQL Exception: " + e.getMessage());
                throw e;
            } catch (Exception e) {
                System.out.println("ERROR: General Exception: " + e.getMessage());
                throw new SQLException("Database connection failed", e);
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
