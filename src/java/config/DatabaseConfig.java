package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.net.URI;

public class DatabaseConfig {
    
    private static Connection connection;
    private static final int MAX_RETRIES = 1;
    private static final int CONNECTION_TIMEOUT = 10; // 10 seconds timeout
    
    public static Connection getConnection() throws SQLException, InterruptedException {
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
                        System.out.println("DEBUG: Full DATABASE_URL: " + databaseUrl);
                        
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
                                    props.setProperty("prepareThreshold", "0");
                                    props.setProperty("preparedStatementCacheQueries", "0");
                                    props.setProperty("preparedStatementCacheSizeMiB", "5");
                                    
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
                                            props2.setProperty("tcpKeepAlive", "true");
                                            
                                            connection = DriverManager.getConnection(jdbcUrl, props2);
                                            System.out.println("DEBUG: Database connection established without SSL (attempt " + attempt + ")");
                                            break;
                                        } catch (SQLException e2) {
                                            System.out.println("ERROR: Non-SSL connection also failed: " + e2.getMessage());
                                        }
                                    }
                                    
                                    // Try URL-based connection on third attempt
                                    if (attempt == 3) {
                                        try {
                                            String urlWithParams = jdbcUrl + "?user=" + username + "&password=" + password + "&ssl=false";
                                            connection = DriverManager.getConnection(urlWithParams);
                                            System.out.println("DEBUG: Database connection established via URL (attempt " + attempt + ")");
                                            break;
                                        } catch (SQLException e3) {
                                            System.out.println("ERROR: URL-based connection also failed: " + e3.getMessage());
                                        }
                                    }
                                    
                                    if (attempt == MAX_RETRIES) {
                                        throw e; // Re-throw after final attempt
                                    }
                                } catch (InterruptedException ie) {
                                    Thread.currentThread().interrupt();
                                    throw new SQLException("Connection retry interrupted", ie);
                                } catch (Exception ie) {
                                    throw new SQLException("Connection retry error: " + ie.getMessage(), ie);
                                }
                            }
                        } catch (ClassNotFoundException e) {
                            throw new SQLException("PostgreSQL driver not found", e);
                        }
                    } else {
                        throw new SQLException("DATABASE_URL format not supported");
                    }
                } else {
                    // Fallback to MySQL for local development
                    System.out.println("DEBUG: DATABASE_URL not found, using MySQL fallback");
                    try {
                        // Load MySQL driver
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        System.out.println("DEBUG: MySQL driver loaded successfully");
                        
                        // MySQL connection parameters
                        String mysqlUrl = "jdbc:mysql://localhost:3306/security_management?useSSL=false&serverTimezone=UTC";
                        String mysqlUser = "root";
                        String mysqlPassword = "";
                        
                        // Set connection properties for MySQL
                        java.util.Properties props = new java.util.Properties();
                        props.setProperty("user", mysqlUser);
                        props.setProperty("password", mysqlPassword);
                        props.setProperty("connectTimeout", String.valueOf(CONNECTION_TIMEOUT * 1000));
                        props.setProperty("socketTimeout", String.valueOf(CONNECTION_TIMEOUT * 1000));
                        props.setProperty("autoReconnect", "true");
                        props.setProperty("useSSL", "false");
                        props.setProperty("serverTimezone", "UTC");
                        
                        connection = DriverManager.getConnection(mysqlUrl, props);
                        System.out.println("DEBUG: MySQL database connection established successfully");
                        
                    } catch (ClassNotFoundException e) {
                        throw new SQLException("MySQL driver not found", e);
                    } catch (SQLException e) {
                        System.out.println("ERROR: MySQL connection failed: " + e.getMessage());
                        throw new SQLException("Failed to connect to MySQL: " + e.getMessage(), e);
                    }
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
