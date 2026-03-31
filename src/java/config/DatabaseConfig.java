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
                        
                        // Enhanced connection string with multiple SSL options for Heroku
                        String jdbcUrl = String.format("jdbc:postgresql://%s:%d/%s", host, port, database);
                        System.out.println("DEBUG: JDBC URL: " + jdbcUrl);
                        System.out.println("DEBUG: Username: " + username);
                        System.out.println("DEBUG: Host: " + host);
                        System.out.println("DEBUG: Port: " + port);
                        System.out.println("DEBUG: Database: " + database);
                        
                        // Load PostgreSQL driver
                        try {
                            Class.forName("org.postgresql.Driver");
                            System.out.println("DEBUG: PostgreSQL driver loaded successfully");
                            
                            // Try connection with enhanced retry logic and different SSL configurations
                            for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
                                try {
                                    // Set connection properties for Heroku with multiple SSL options
                                    java.util.Properties props = new java.util.Properties();
                                    props.setProperty("user", username);
                                    props.setProperty("password", password);
                                    props.setProperty("ssl", "true");
                                    props.setProperty("sslmode", "prefer");
                                    props.setProperty("connectTimeout", String.valueOf(CONNECTION_TIMEOUT * 1000));
                                    props.setProperty("socketTimeout", String.valueOf(CONNECTION_TIMEOUT * 1000));
                                    props.setProperty("tcpKeepAlive", "true");
                                    props.setProperty("reWriteBatchedInserts", "true");
                                    
                                    connection = DriverManager.getConnection(jdbcUrl, props);
                                    System.out.println("DEBUG: Database connection established successfully (attempt " + attempt + ")");
                                    break; // Success, exit retry loop
                                } catch (SQLException e) {
                                    System.out.println("ERROR: Connection attempt " + attempt + " failed: " + e.getMessage());
                                    System.out.println("ERROR: SQL State: " + e.getSQLState());
                                    System.out.println("ERROR: Error Code: " + e.getErrorCode());
                                    
                                    // Try alternative SSL mode on second attempt
                                    if (attempt == 2) {
                                        try {
                                            java.util.Properties props2 = new java.util.Properties();
                                            props2.setProperty("user", username);
                                            props2.setProperty("password", password);
                                            props2.setProperty("ssl", "false");
                                            props2.setProperty("connectTimeout", String.valueOf(CONNECTION_TIMEOUT * 1000));
                                            props2.setProperty("socketTimeout", String.valueOf(CONNECTION_TIMEOUT * 1000));
                                            
                                            connection = DriverManager.getConnection(jdbcUrl, props2);
                                            System.out.println("DEBUG: Database connection established without SSL (attempt " + attempt + ")");
                                            break;
                                        } catch (SQLException e2) {
                                            System.out.println("ERROR: Non-SSL connection also failed: " + e2.getMessage());
                                        }
                                    }
                                    
                                    if (attempt == MAX_RETRIES) {
                                        throw e; // Re-throw after final attempt
                                    }
                                    // Wait before retry
                                    try {
                                        Thread.sleep(3000); // 3 seconds
                                    } catch (InterruptedException ie) {
                                        Thread.currentThread().interrupt();
                                        throw new SQLException("Connection retry interrupted", ie);
                                    }
                                }
                            }
                        } catch (ClassNotFoundException e) {
                            throw new SQLException("PostgreSQL driver not found", e);
                        }
                    } else {
                        throw new SQLException("DATABASE_URL format not supported");
                    }
                } else {
                    throw new SQLException("DATABASE_URL environment variable not found or empty");
                }
            } catch (Exception e) {
                throw new SQLException("Failed to connect to database: " + e.getMessage(), e);
            }
        }
        return connection;
    }
    
    public static void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("DEBUG: Database connection closed");
            } catch (SQLException e) {
                System.out.println("ERROR: Failed to close database connection: " + e.getMessage());
            }
        }
    }
}
