package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet to mark attendance from QR code scan
 */
@WebServlet("/MarkAttendance")
public class MarkAttendanceServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/security_management";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    // For Heroku PostgreSQL
    private static final String HEROKU_DB_URL = System.getenv("DATABASE_URL");
    private static final String HEROKU_DB_USER = System.getenv("DB_USERNAME");
    private static final String HEROKU_DB_PASSWORD = System.getenv("DB_PASSWORD");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String staffId = request.getParameter("staffId");
        String date = request.getParameter("date");
        String employeeId = request.getParameter("employeeId");
        
        // Validate required parameters
        if (staffId == null || staffId.trim().isEmpty() || 
            date == null || date.trim().isEmpty() || 
            employeeId == null || employeeId.trim().isEmpty()) {
            
            request.setAttribute("message", "Missing required parameters. Please scan the QR code again.");
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("attendanceResult.jsp").forward(request, response);
            return;
        }
        
        try {
            // Check if attendance is already marked
            if (isAttendanceAlreadyMarked(staffId, date, employeeId)) {
                request.setAttribute("message", "Attendance already marked for this session.");
                request.setAttribute("messageType", "warning");
            } else {
                // Mark attendance
                if (markAttendance(staffId, date, employeeId)) {
                    request.setAttribute("message", "Attendance marked successfully!");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "Failed to mark attendance. Please try again.");
                    request.setAttribute("messageType", "error");
                }
            }
            
            // Set additional attributes for display
            request.setAttribute("staffId", staffId);
            request.setAttribute("date", date);
            request.setAttribute("employeeId", employeeId);
            request.setAttribute("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            
            request.getRequestDispatcher("attendanceResult.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Database error: " + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("attendanceResult.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    private Connection getConnection() throws SQLException {
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
    
    private boolean isAttendanceAlreadyMarked(String staffId, String date, String employeeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM staff_attendance WHERE staff_id = ? AND date = ? AND employee_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, staffId);
            stmt.setString(2, date);
            stmt.setString(3, employeeId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        
        return false;
    }
    
    private boolean markAttendance(String staffId, String date, String employeeId) throws SQLException {
        String sql = "INSERT INTO staff_attendance (staff_id, date, employee_id, marked_at, status) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, staffId);
            stmt.setString(2, date);
            stmt.setString(3, employeeId);
            stmt.setString(4, LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            stmt.setString(5, "PRESENT");
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Initialize database table if it doesn't exist
     */
    public static void initializeDatabase() {
        String createTableSQL = "CREATE TABLE IF NOT EXISTS staff_attendance (" +
            "id INT AUTO_INCREMENT PRIMARY KEY," +
            "staff_id VARCHAR(50) NOT NULL," +
            "date DATE NOT NULL," +
            "employee_id VARCHAR(50) NOT NULL," +
            "marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "status VARCHAR(20) DEFAULT 'PRESENT'," +
            "UNIQUE KEY unique_attendance (staff_id, date, employee_id)," +
            "INDEX idx_staff_date (staff_id, date)," +
            "INDEX idx_employee (employee_id)" +
            ")";
        
        try (Connection conn = DriverManager.getConnection(
                System.getenv("DATABASE_URL") != null ? System.getenv("DATABASE_URL") : "jdbc:mysql://localhost:3306/security_management",
                System.getenv("DB_USERNAME") != null ? System.getenv("DB_USERNAME") : "root",
                System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "");
             PreparedStatement stmt = conn.prepareStatement(createTableSQL)) {
            
            stmt.executeUpdate();
            System.out.println("QR attendance table initialized successfully");
            
        } catch (SQLException e) {
            System.err.println("Error initializing QR attendance table: " + e.getMessage());
        }
    }
}
