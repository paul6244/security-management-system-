package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import config.SimpleDatabaseConfig;

@WebServlet("/MarkAttendance")
public class MarkAttendance extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        String staffId = request.getParameter("staffId");
        String staffName = request.getParameter("staffName");
        
        if (staffId == null || staffId.trim().isEmpty() || 
            staffName == null || staffName.trim().isEmpty()) {
            String jsonResponse = gson.toJson(new Response(false, "Staff ID and name are required"));
            out.print(jsonResponse);
            return;
        }
        
        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            con = SimpleDatabaseConfig.getSimpleConnection();
            stmt = con.prepareStatement(
                "SELECT id FROM staff_registration WHERE employee_id = ?"
            );
            stmt.setString(1, staffId);
            
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                int staffDbId = rs.getInt("id");
                
                // Check if QR code exists for this staff member
                PreparedStatement checkStmt = con.prepareStatement(
                    "SELECT qr_code FROM staff_registration WHERE id = ?"
                );
                checkStmt.setInt(1, staffDbId);
                ResultSet checkRs = checkStmt.executeQuery();
                
                boolean hasQRCode = false;
                if (checkRs.next()) {
                    hasQRCode = checkRs.getString("qr_code") != null && 
                            !checkRs.getString("qr_code").trim().isEmpty();
                }
                checkRs.close();
                checkStmt.close();
                
                if (!hasQRCode) {
                    String jsonResponse = gson.toJson(new Response(false, "No QR code found for this staff member"));
                    out.print(jsonResponse);
                    return;
                }
                
                // Mark attendance
                PreparedStatement insertStmt = con.prepareStatement(
                    "INSERT INTO attendance (staff_id, employee_id, staff_name, check_in_time, check_in_type, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)"
                );
                
                insertStmt.setInt(1, staffDbId);
                insertStmt.setString(2, staffId);
                insertStmt.setString(3, staffName);
                insertStmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
                insertStmt.setString(5, "qr_code");
                insertStmt.setString(6, "present");
                
                int result = insertStmt.executeUpdate();
                insertStmt.close();
                
                if (result > 0) {
                    String jsonResponse = gson.toJson(new Response(true, 
                        "Attendance marked successfully for " + staffName + " using QR code"));
                    out.print(jsonResponse);
                } else {
                    String jsonResponse = gson.toJson(new Response(false, "Failed to mark attendance"));
                    out.print(jsonResponse);
                }
                
            } else {
                String jsonResponse = gson.toJson(new Response(false, "Staff member not found"));
                out.print(jsonResponse);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            String jsonResponse = gson.toJson(new Response(false, "Database error: " + e.getMessage()));
            out.print(jsonResponse);
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (Exception e) {
                // Ignore cleanup errors
            }
        }
    }
    
    // Response class
    private class Response {
        private boolean success;
        private String message;
        
        public Response(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public String getMessage() {
            return message;
        }
    }
}
