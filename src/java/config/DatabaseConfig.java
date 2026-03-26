package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.net.URI;

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
                        // Properly parse the DATABASE_URL
                        URI uri = new URI(databaseUrl);
                        
                        String username = uri.getUserInfo().split(":")[0];
                        String password = uri.getUserInfo().split(":")[1];
                        String host = uri.getHost();
                        int port = uri.getPort();
                        String database = uri.getPath().substring(1); // Remove leading slash
                        
                        String jdbcUrl = String.format("jdbc:postgresql://%s:%d/%s", host, port, database);
                        System.out.println("DEBUG: Converted to JDBC URL: " + jdbcUrl);
                        System.out.println("DEBUG: Username: " + username);
                        System.out.println("DEBUG: Host: " + host);
                        System.out.println("DEBUG: Port: " + port);
                        System.out.println("DEBUG: Database: " + database);
                        
                        // Load PostgreSQL driver
                        try {
                            Class.forName("org.postgresql.Driver");
                            System.out.println("DEBUG: PostgreSQL driver loaded successfully");
                        } catch (ClassNotFoundException e) {
                            System.out.println("ERROR: PostgreSQL driver not found: " + e.getMessage());
                            throw new SQLException("PostgreSQL driver not found", e);
                        }
                        
                        // Use parsed connection details
                        try {
                            connection = DriverManager.getConnection(jdbcUrl, username, password);
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
