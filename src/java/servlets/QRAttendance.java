package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Map;
import java.util.HashMap;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

@WebServlet("/QRAttendance")
public class QRAttendance extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Gson gson = new Gson();
        
        try {
            String qrCode = request.getParameter("qrCode");
            String method = request.getParameter("method");
            
            if (qrCode == null || qrCode.trim().isEmpty()) {
                String jsonResponse = gson.toJson(new Response(false, "QR Code is required"));
                out.print(jsonResponse);
                return;
            }
            
            if (method == null || method.trim().isEmpty()) {
                method = "qr";
            }
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = config.SimpleDatabaseConfig.getSimpleConnection();
                
                // Extract staff ID from QR code
                String staffId = extractStaffIdFromQR(qrCode);
                
                if (staffId == null) {
                    String jsonResponse = gson.toJson(new Response(false, "Invalid QR code format"));
                    out.print(jsonResponse);
                    return;
                }
                
                // Get staff information
                pstmt = conn.prepareStatement(
                    "SELECT id, first_name, last_name, employee_id, department, selfie_path " +
                    "FROM staff_registration WHERE employee_id = ? OR id = ?"
                );
                pstmt.setString(1, staffId);
                pstmt.setString(2, staffId);
                
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    int staffDbId = rs.getInt("id");
                    String firstName = rs.getString("first_name");
                    String lastName = rs.getString("last_name");
                    String employeeId = rs.getString("employee_id");
                    String department = rs.getString("department");
                    String selfiePath = rs.getString("selfie_path");
                    
                    // Check if attendance already marked today
                    if (pstmt != null) pstmt.close();
                    if (rs != null) rs.close();
                    
                    pstmt = conn.prepareStatement(
                        "SELECT COUNT(*) as attendance_count FROM attendance " +
                        "WHERE staff_id = ? AND DATE(check_in_time) = CURDATE()"
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
                            "INSERT INTO attendance (staff_id, employee_id, first_name, last_name, " +
                            "department, latitude, longitude, check_in_time, attendance_type, " +
                            "verification_method, face_verified, selfie_path, verification_data) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?, ?, ?, ?)"
                        );
                        
                        pstmt.setInt(1, staffDbId);
                        pstmt.setString(2, employeeId);
                        pstmt.setString(3, firstName);
                        pstmt.setString(4, lastName);
                        pstmt.setString(5, department);
                        pstmt.setString(6, "0.0"); // Default latitude
                        pstmt.setString(7, "0.0"); // Default longitude
                        pstmt.setString(8, method);
                        pstmt.setString(9, "QR Code");
                        pstmt.setBoolean(10, false);
                        pstmt.setString(11, selfiePath);
                        pstmt.setString(12, qrCode);
                        
                        int rowsAffected = pstmt.executeUpdate();
                        
                        if (rowsAffected > 0) {
                            // Create attendance record for response
                            AttendanceRecord record = new AttendanceRecord();
                            record.setId(staffDbId);
                            record.setStaffId(staffDbId);
                            record.setEmployeeId(employeeId);
                            record.setFirstName(firstName);
                            record.setLastName(lastName);
                            record.setDepartment(department);
                            record.setLatitude(0.0);
                            record.setLongitude(0.0);
                            record.setCheckInTime(new Timestamp(System.currentTimeMillis()));
                            record.setAttendanceType(method);
                            record.setVerificationMethod("QR Code");
                            record.setFaceVerified(false);
                            record.setSelfiePath(selfiePath);
                            record.setVerificationData(qrCode);
                            
                            String jsonResponse = gson.toJson(new Response(true, "Attendance marked successfully", record));
                            out.print(jsonResponse);
                        } else {
                            String jsonResponse = gson.toJson(new Response(false, "Failed to mark attendance"));
                            out.print(jsonResponse);
                        }
                        
                    } else {
                        String jsonResponse = gson.toJson(new Response(false, "Attendance already marked for today"));
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
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Gson gson = new Gson();
        
        try {
            String staffId = request.getParameter("staffId");
            
            if (staffId == null || staffId.trim().isEmpty()) {
                String jsonResponse = gson.toJson(new Response(false, "Staff ID is required"));
                out.print(jsonResponse);
                return;
            }
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = config.SimpleDatabaseConfig.getSimpleConnection();
                
                // Get today's attendance for staff member
                pstmt = conn.prepareStatement(
                    "SELECT id, staff_id, employee_id, first_name, last_name, " +
                    "department, latitude, longitude, check_in_time, attendance_type, " +
                    "verification_method, face_verified, selfie_path " +
                    "FROM attendance " +
                    "WHERE staff_id = (SELECT id FROM staff_registration WHERE employee_id = ? OR id = ? LIMIT 1) " +
                    "AND DATE(check_in_time) = CURDATE() " +
                    "ORDER BY check_in_time DESC"
                );
                pstmt.setString(1, staffId);
                pstmt.setString(2, staffId);
                
                rs = pstmt.executeQuery();
                
                java.util.List<AttendanceRecord> attendanceList = new java.util.ArrayList<>();
                
                while (rs.next()) {
                    AttendanceRecord record = new AttendanceRecord();
                    record.setId(rs.getInt("id"));
                    record.setStaffId(rs.getInt("staff_id"));
                    record.setEmployeeId(rs.getString("employee_id"));
                    record.setFirstName(rs.getString("first_name"));
                    record.setLastName(rs.getString("last_name"));
                    record.setDepartment(rs.getString("department"));
                    record.setLatitude(rs.getDouble("latitude"));
                    record.setLongitude(rs.getDouble("longitude"));
                    record.setCheckInTime(rs.getTimestamp("check_in_time"));
                    record.setAttendanceType(rs.getString("attendance_type"));
                    record.setVerificationMethod(rs.getString("verification_method"));
                    record.setFaceVerified(rs.getBoolean("face_verified"));
                    record.setSelfiePath(rs.getString("selfie_path"));
                    attendanceList.add(record);
                }
                
                // Create response with attendance data
                Map<String, Object> responseData = new java.util.HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Attendance records retrieved successfully");
                responseData.put("attendance", attendanceList);
                
                String jsonResponse = gson.toJson(responseData);
                out.print(jsonResponse);
                
            } catch (Exception e) {
                e.printStackTrace();
                String jsonResponse = gson.toJson(new Response(false, "Database error: " + e.getMessage()));
                out.print(jsonResponse);
            } finally {
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
    
    // Helper methods
    private String extractStaffIdFromQR(String qrCode) {
        // Simple QR code parsing for demo
        if (qrCode.startsWith("STAFF_")) {
            String[] parts = qrCode.split("_");
            if (parts.length >= 3) {
                return parts[2]; // Return staff ID part
            }
        }
        return null;
    }
    
    // Response class for JSON
    private class Response {
        private boolean success;
        private String message;
        private Object data;
        
        public Response(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
        
        public Response(boolean success, String message, Object data) {
            this.success = success;
            this.message = message;
            this.data = data;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public String getMessage() {
            return message;
        }
        
        public Object getData() {
            return data;
        }
    }
    
    // AttendanceRecord class for JSON response
    public class AttendanceRecord {
        private int id;
        private int staffId;
        private String employeeId;
        private String firstName;
        private String lastName;
        private String department;
        private double latitude;
        private double longitude;
        private Timestamp checkInTime;
        private String attendanceType;
        private String verificationMethod;
        private boolean faceVerified;
        private String selfiePath;
        private String verificationData;
        
        // Getters and setters
        public void setId(int id) { this.id = id; }
        public void setStaffId(int staffId) { this.staffId = staffId; }
        public void setEmployeeId(String employeeId) { this.employeeId = employeeId; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        public void setDepartment(String department) { this.department = department; }
        public void setLatitude(double latitude) { this.latitude = latitude; }
        public void setLongitude(double longitude) { this.longitude = longitude; }
        public void setCheckInTime(Timestamp checkInTime) { this.checkInTime = checkInTime; }
        public void setAttendanceType(String attendanceType) { this.attendanceType = attendanceType; }
        public void setVerificationMethod(String verificationMethod) { this.verificationMethod = verificationMethod; }
        public void setFaceVerified(boolean faceVerified) { this.faceVerified = faceVerified; }
        public void setSelfiePath(String selfiePath) { this.selfiePath = selfiePath; }
        public void setVerificationData(String verificationData) { this.verificationData = verificationData; }
    }
}
