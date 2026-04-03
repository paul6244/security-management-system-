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
            
            // Try connection with different SSL settings
            String[] jdbcUrls = {
                "jdbc:postgresql://" + host + ":" + port + "/" + database + "?ssl=true&sslmode=require",
                "jdbc:postgresql://" + host + ":" + port + "/" + database,
                "jdbc:postgresql://" + host + ":" + port + "/" + database + "?useSSL=true&ssl=true"
            };
            
            for (int i = 0; i < jdbcUrls.length; i++) {
                try {
                    System.out.println("SIMPLE DEBUG: Attempt " + (i+1) + ": " + jdbcUrls[i]);
                    Connection conn = DriverManager.getConnection(jdbcUrls[i], username, password);
                    System.out.println("SIMPLE DEBUG: Connection successful with attempt " + (i+1));
                    return conn;
                } catch (Exception e) {
                    System.out.println("SIMPLE DEBUG: Attempt " + (i+1) + " failed: " + e.getMessage());
                    if (i == jdbcUrls.length - 1) {
                        // Last attempt failed, throw the exception
                        throw new SQLException("All database connection attempts failed. Last error: " + e.getMessage(), e);
                    }
                }
            }
            
            throw new SQLException("Unexpected error in database connection");
            
        } catch (Exception e) {
            System.out.println("SIMPLE ERROR: " + e.getMessage());
            throw new SQLException("Simple database connection failed: " + e.getMessage(), e);
        }
    }
}
