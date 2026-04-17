package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import config.DatabaseConfig;

@WebServlet("/EnhancedAttendance")
public class EnhancedAttendance extends HttpServlet {

    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Map<String, Object> jsonResponse = new HashMap<>();
        
        try {
            if ("diagnostic".equals(action)) {
                jsonResponse = runDiagnostics();
            } else if ("loadAttendance".equals(action)) {
                jsonResponse = loadTodayAttendance();
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Unknown action: " + action);
            }
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Map<String, Object> jsonResponse = new HashMap<>();
        
        try {
            if ("markAttendance".equals(action)) {
                jsonResponse = markAttendance(request);
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Unknown action: " + action);
            }
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }

    private Map<String, Object> runDiagnostics() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            Connection conn = DatabaseConfig.getConnection();
            
            if (conn != null && !conn.isClosed()) {
                // Check database connection
                result.put("success", true);
                
                // Check if required tables exist
                DatabaseMetaData meta = conn.getMetaData();
                
                // Check users table
                ResultSet usersTable = meta.getTables(null, null, "users", null);
                boolean usersExists = usersTable.next();
                usersTable.close();
                
                // Check attendance table
                ResultSet attendanceTable = meta.getTables(null, null, "attendance", null);
                boolean attendanceExists = attendanceTable.next();
                attendanceTable.close();
                
                // Check staff_registration table
                ResultSet staffTable = meta.getTables(null, null, "staff_registration", null);
                boolean staffExists = staffTable.next();
                staffTable.close();
                
                result.put("tables", Map.of(
                    "users", usersExists,
                    "attendance", attendanceExists,
                    "staff_registration", staffExists
                ));
                
                conn.close();
            } else {
                result.put("success", false);
                result.put("message", "Database connection failed");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Diagnostic error: " + e.getMessage());
        }
        
        return result;
    }

    private Map<String, Object> loadTodayAttendance() {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> attendanceList = new ArrayList<>();
        
        try {
            Connection conn = DatabaseConfig.getConnection();
            
            String sql = "SELECT a.id, a.staff_id, a.first_name, a.last_name, a.check_in_time, a.selfie_path " +
                        "FROM attendance a " +
                        "WHERE DATE(a.check_in_time) = CURRENT_DATE " +
                        "ORDER BY a.check_in_time DESC";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> attendance = new HashMap<>();
                attendance.put("id", rs.getInt("id"));
                attendance.put("staffId", rs.getString("staff_id"));
                attendance.put("name", rs.getString("first_name") + " " + rs.getString("last_name"));
                attendance.put("checkInTime", rs.getTimestamp("check_in_time").toString());
                attendance.put("photo", rs.getString("selfie_path"));
                attendanceList.add(attendance);
            }
            
            rs.close();
            ps.close();
            conn.close();
            
            result.put("success", true);
            result.put("attendance", attendanceList);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Error loading attendance: " + e.getMessage());
        }
        
        return result;
    }

    private Map<String, Object> markAttendance(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // Read JSON data from request
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            
            Map<String, Object> attendanceData = gson.fromJson(sb.toString(), Map.class);
            
            String staffId = (String) attendanceData.get("staffId");
            String method = (String) attendanceData.get("method");
            String photoData = (String) attendanceData.get("photo");
            
            // Get staff information
            Connection conn = DatabaseConfig.getConnection();
            
            String staffSql = "SELECT first_name, last_name, email, phone FROM staff_registration WHERE employee_id = ?";
            PreparedStatement staffPs = conn.prepareStatement(staffSql);
            staffPs.setString(1, staffId);
            ResultSet staffRs = staffPs.executeQuery();
            
            if (staffRs.next()) {
                // Insert attendance record
                String insertSql = "INSERT INTO attendance (staff_id, first_name, last_name, email, phone, " +
                                 "check_in_time, selfie_path, attendance_type) " +
                                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                
                PreparedStatement insertPs = conn.prepareStatement(insertSql);
                insertPs.setString(1, staffId);
                insertPs.setString(2, staffRs.getString("first_name"));
                insertPs.setString(3, staffRs.getString("last_name"));
                insertPs.setString(4, staffRs.getString("email"));
                insertPs.setString(5, staffRs.getString("phone"));
                insertPs.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
                insertPs.setString(7, photoData);
                insertPs.setString(8, method);
                
                int rowsAffected = insertPs.executeUpdate();
                insertPs.close();
                
                if (rowsAffected > 0) {
                    result.put("success", true);
                    result.put("message", "Attendance marked successfully");
                } else {
                    result.put("success", false);
                    result.put("message", "Failed to mark attendance");
                }
            } else {
                result.put("success", false);
                result.put("message", "Staff ID not found: " + staffId);
            }
            
            staffRs.close();
            staffPs.close();
            conn.close();
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Error marking attendance: " + e.getMessage());
        }
        
        return result;
    }
}
