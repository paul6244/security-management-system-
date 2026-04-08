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

@WebServlet("/QRCodeAttendance")
public class QRCodeAttendance extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Gson gson = new Gson();
        
        try {
            String staffId = request.getParameter("staffId");
            String qrData = request.getParameter("qrData");
            
            if (staffId == null || staffId.trim().isEmpty()) {
                String jsonResponse = gson.toJson(new Response(false, "Staff ID is required"));
                out.print(jsonResponse);
                return;
            }
            
            if (qrData == null || qrData.trim().isEmpty()) {
                String jsonResponse = gson.toJson(new Response(false, "QR code data is required"));
                out.print(jsonResponse);
                return;
            }
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = config.SimpleDatabaseConfig.getSimpleConnection();
                
                // Validate QR code against database
                pstmt = conn.prepareStatement(
                    "SELECT id, employee_id, first_name, last_name, department FROM staff_registration " +
                    "WHERE employee_id = ? AND qr_code = ?"
                );
                pstmt.setString(1, staffId);
                pstmt.setString(2, qrData);
                
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    // Valid QR code - mark attendance
                    int staffDbId = rs.getInt("id");
                    String firstName = rs.getString("first_name");
                    String lastName = rs.getString("last_name");
                    String department = rs.getString("department");
                    
                    // Close previous statement
                    if (pstmt != null) pstmt.close();
                    if (rs != null) rs.close();
                    
                    // Check if attendance already marked today
                    pstmt = conn.prepareStatement(
                        "SELECT COUNT(*) as attendance_count FROM attendance " +
                        "WHERE staff_id = ? AND DATE(check_in_time) = CURRENT_DATE"
                    );
                    pstmt.setInt(1, staffDbId);
                    
                    ResultSet attendanceRs = pstmt.executeQuery();
                    boolean alreadyMarked = false;
                    
                    if (attendanceRs.next()) {
                        alreadyMarked = attendanceRs.getInt("attendance_count") > 0;
                    }
                    attendanceRs.close();
                    
                    if (!alreadyMarked) {
                        // Mark attendance
                        if (pstmt != null) pstmt.close();
                        
                        pstmt = conn.prepareStatement(
                            "INSERT INTO attendance (staff_id, check_in_time, check_in_method, status) " +
                            "VALUES (?, CURRENT_TIMESTAMP, 'qr_code', 'present')"
                        );
                        pstmt.setInt(1, staffDbId);
                        pstmt.executeUpdate();
                        
                        // Create staff object for response
                        Staff staff = new Staff();
                        staff.setId(staffDbId);
                        staff.setEmployeeId(staffId);
                        staff.setFirstName(firstName);
                        staff.setLastName(lastName);
                        staff.setDepartment(department);
                        
                        String jsonResponse = gson.toJson(new Response(true, "Attendance marked successfully", staff));
                        out.print(jsonResponse);
                        
                    } else {
                        String jsonResponse = gson.toJson(new Response(false, "Attendance already marked for today"));
                        out.print(jsonResponse);
                    }
                    
                } else {
                    String jsonResponse = gson.toJson(new Response(false, "Invalid QR code or staff not found"));
                    out.print(jsonResponse);
                }
                
            } catch (Exception e) {
                e.printStackTrace();
                String jsonResponse = gson.toJson(new Response(false, "Database error: " + e.getMessage()));
                out.print(jsonResponse);
            } finally {
                // Close resources
                try {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            String jsonResponse = gson.toJson(new Response(false, "System error: " + e.getMessage()));
            out.print(jsonResponse);
        }
    }
    
    // Response class for JSON
    private class Response {
        private boolean success;
        private String message;
        private Staff staff;
        
        public Response(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
        
        public Response(boolean success, String message, Staff staff) {
            this.success = success;
            this.message = message;
            this.staff = staff;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public String getMessage() {
            return message;
        }
        
        public Staff getStaff() {
            return staff;
        }
    }
    
    // Staff class for JSON response
    private class Staff {
        private int id;
        private String employeeId;
        private String firstName;
        private String lastName;
        private String department;
        
        public void setId(int id) {
            this.id = id;
        }
        
        public void setEmployeeId(String employeeId) {
            this.employeeId = employeeId;
        }
        
        public void setFirstName(String firstName) {
            this.firstName = firstName;
        }
        
        public void setLastName(String lastName) {
            this.lastName = lastName;
        }
        
        public void setDepartment(String department) {
            this.department = department;
        }
    }
}
