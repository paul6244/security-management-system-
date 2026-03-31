package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.net.URI;

public class SimpleDatabaseConfig {
    
    public static Connection getSimpleConnection() throws SQLException {
        try {
            String databaseUrl = System.getenv("DATABASE_URL");
            
            if (databaseUrl == null || databaseUrl.isEmpty()) {
                throw new SQLException("DATABASE_URL environment variable not found");
            }
            
            System.out.println("SIMPLE DEBUG: DATABASE_URL = " + databaseUrl.substring(0, Math.min(50, databaseUrl.length())) + "...");
            
            if (!databaseUrl.startsWith("postgres://")) {
                throw new SQLException("Invalid DATABASE_URL format");
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
            
            // Try the simplest possible connection
            String jdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + database;
            System.out.println("SIMPLE DEBUG: JDBC URL = " + jdbcUrl);
            
            Connection conn = DriverManager.getConnection(jdbcUrl, username, password);
            System.out.println("SIMPLE DEBUG: Connection successful!");
            
            return conn;
            
        } catch (Exception e) {
            System.out.println("SIMPLE ERROR: " + e.getMessage());
            throw new SQLException("Simple database connection failed: " + e.getMessage(), e);
        }
    }
}
