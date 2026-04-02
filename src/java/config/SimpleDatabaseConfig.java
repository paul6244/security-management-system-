package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.net.URI;

public class SimpleDatabaseConfig {
    
    public static Connection getSimpleConnection() throws SQLException {
        try {
            // Get database URL from environment
            String databaseUrl = System.getenv("DATABASE_URL");
            
            if (databaseUrl == null || databaseUrl.trim().isEmpty()) {
                throw new SQLException("DATABASE_URL environment variable not found");
            }
            
            System.out.println("SIMPLE DEBUG: DATABASE_URL = " + databaseUrl);
            
            if (!databaseUrl.startsWith("postgres://")) {
                throw new SQLException("Invalid DATABASE_URL format. Expected: postgres://user:pass@host:port/database");
            }
            
            // Parse DATABASE_URL
            URI uri = new URI(databaseUrl);
            String username = uri.getUserInfo().split(":")[0];
            String password = uri.getUserInfo().split(":")[1];
            String host = uri.getHost();
            int port = uri.getPort();
            String database = uri.getPath().substring(1);
            
            System.out.println("SIMPLE DEBUG: Host=" + host + ", Port=" + port + ", Database=" + database);
            
            // Load driver
            Class.forName("org.postgresql.Driver");
            
            // Try multiple connection approaches
            Connection conn = null;
            
            // Approach 1: Try with SSL (for AWS RDS)
            try {
                String jdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + database + "?ssl=true&sslmode=require";
                System.out.println("SIMPLE DEBUG: Trying SSL connection: " + jdbcUrl);
                conn = DriverManager.getConnection(jdbcUrl, username, password);
                System.out.println("SIMPLE DEBUG: SSL Connection successful!");
                return conn;
            } catch (Exception sslException) {
                System.out.println("SIMPLE DEBUG: SSL connection failed: " + sslException.getMessage());
                
                // Approach 2: Try without SSL (for local development)
                try {
                    String jdbcUrlNoSSL = "jdbc:postgresql://" + host + ":" + port + "/" + database;
                    System.out.println("SIMPLE DEBUG: Trying non-SSL connection: " + jdbcUrlNoSSL);
                    conn = DriverManager.getConnection(jdbcUrlNoSSL, username, password);
                    System.out.println("SIMPLE DEBUG: Non-SSL Connection successful!");
                    return conn;
                } catch (Exception noSSLException) {
                    System.out.println("SIMPLE DEBUG: Non-SSL connection also failed: " + noSSLException.getMessage());
                    
                    // Approach 3: Try with legacy SSL settings
                    try {
                        String jdbcUrlLegacy = "jdbc:postgresql://" + host + ":" + port + "/" + database + "?useSSL=true&ssl=true";
                        System.out.println("SIMPLE DEBUG: Trying legacy SSL connection: " + jdbcUrlLegacy);
                        conn = DriverManager.getConnection(jdbcUrlLegacy, username, password);
                        System.out.println("SIMPLE DEBUG: Legacy SSL Connection successful!");
                        return conn;
                    } catch (Exception legacyException) {
                        System.out.println("SIMPLE DEBUG: All connection attempts failed");
                        throw new SQLException("All database connection attempts failed. Last error: " + legacyException.getMessage(), legacyException);
                    }
                }
            }
            
        } catch (Exception e) {
            System.out.println("SIMPLE ERROR: " + e.getMessage());
            throw new SQLException("Simple database connection failed: " + e.getMessage(), e);
        }
    }
}
