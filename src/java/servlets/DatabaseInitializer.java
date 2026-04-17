package servlets;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Database initializer for QR attendance system
 */
@WebListener
public class DatabaseInitializer implements ServletContextListener {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/security_management";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    // For Heroku PostgreSQL
    private static final String HEROKU_DB_URL = System.getenv("DATABASE_URL");
    private static final String HEROKU_DB_USER = System.getenv("DB_USERNAME");
    private static final String HEROKU_DB_PASSWORD = System.getenv("DB_PASSWORD");

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        initializeDatabase();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if needed
    }

    public static void initializeDatabase() {
        String createTableSQL = """
            CREATE TABLE IF NOT EXISTS qr_attendance (
                id INT AUTO_INCREMENT PRIMARY KEY,
                class_id VARCHAR(50) NOT NULL,
                date DATE NOT NULL,
                student_id VARCHAR(50) NOT NULL,
                marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status VARCHAR(20) DEFAULT 'PRESENT',
                UNIQUE KEY unique_attendance (class_id, date, student_id),
                INDEX idx_class_date (class_id, date),
                INDEX idx_student (student_id)
            )
            """;
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(createTableSQL)) {
            
            stmt.executeUpdate();
            System.out.println("QR attendance table initialized successfully");
            
        } catch (SQLException e) {
            System.err.println("Error initializing QR attendance table: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static Connection getConnection() throws SQLException {
        try {
            // Try Heroku PostgreSQL first
            if (HEROKU_DB_URL != null && !HEROKU_DB_URL.isEmpty()) {
                return DriverManager.getConnection(HEROKU_DB_URL, HEROKU_DB_USER, HEROKU_DB_PASSWORD);
            }
        } catch (SQLException e) {
            // Fallback to local MySQL
        }
        
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
}
