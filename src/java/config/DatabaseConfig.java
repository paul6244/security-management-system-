package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.net.URI;

public class DatabaseConfig {
    
    private static Connection connection;
    private static final int MAX_RETRIES = 3;
    private static final int CONNECTION_TIMEOUT = 30; // 30 seconds timeout
    
    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                String databaseUrl = System.getenv("DATABASE_URL");
                
                if (databaseUrl != null && !databaseUrl.isEmpty()) {
                    System.out.println("DEBUG: DATABASE_URL found: " + databaseUrl.substring(0, Math.min(50, databaseUrl.length())) + "...");
                    
                    // Parse Heroku DATABASE_URL: postgres://username:password@host:port/database
                    if (databaseUrl.startsWith("postgres://")) {
                        // Properly parse DATABASE_URL
                        URI uri = new URI(databaseUrl);
                        
                        String username = uri.getUserInfo().split(":")[0];
                        String password = uri.getUserInfo().split(":")[1];
                        String host = uri.getHost();
                        int port = uri.getPort();
                        String database = uri.getPath().substring(1); // Remove leading slash
                        
                        // Enhanced connection string with timeout and SSL
                        String jdbcUrl = String.format("jdbc:postgresql://%s:%d/%s?ssl=true&connectTimeout=%d", host, port, database, CONNECTION_TIMEOUT);
                        System.out.println("DEBUG: Enhanced JDBC URL: " + jdbcUrl);
                        System.out.println("DEBUG: Username: " + username);
                        System.out.println("DEBUG: Host: " + host);
                        System.out.println("DEBUG: Port: " + port);
                        System.out.println("DEBUG: Database: " + database);
                        
                        // Load PostgreSQL driver
                        try {
                            Class.forName("org.postgresql.Driver");
                            System.out.println("DEBUG: PostgreSQL driver loaded successfully");
                            
                            // Try connection with retry logic
                            for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
                                try {
                                    connection = DriverManager.getConnection(jdbcUrl, username, password);
                                    System.out.println("DEBUG: Database connection established successfully (attempt " + attempt + ")");
                                    break; // Success, exit retry loop
                                } catch (SQLException e) {
                                    System.out.println("ERROR: Connection attempt " + attempt + " failed: " + e.getMessage());
                                    if (attempt == MAX_RETRIES) {
                                        throw new SQLException("Failed to connect to database after " + MAX_RETRIES + " attempts", e);
                                    }
                                    // Wait before retry
                                    if (attempt < MAX_RETRIES) {
                                        try {
                                            Thread.sleep(2000); // Wait 2 seconds
                                        } catch (InterruptedException ie) {
                                            Thread.currentThread().interrupt();
                                        }
                                    }
                                }
                            }
                        } catch (ClassNotFoundException e) {
                            System.out.println("ERROR: PostgreSQL driver not found: " + e.getMessage());
                            throw new SQLException("PostgreSQL driver not found", e);
                        }
                    } else {
                        System.out.println("DEBUG: No DATABASE_URL found, using local MySQL");
                        // Local MySQL connection with timeout
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        String localJdbcUrl = "jdbc:mysql://localhost:3306/securitymanagementsystem?connectTimeout=" + CONNECTION_TIMEOUT;
                        connection = DriverManager.getConnection(localJdbcUrl, "root", "");
                    }
                } else {
                    throw new SQLException("DATABASE_URL environment variable not set");
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
