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

@WebServlet("/StaffRegistrationWithFingerprint")
public class StaffRegistrationWithFingerprint extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Gson gson = new Gson();
        
        try {
            // Get form parameters
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String department = request.getParameter("department");
            String position = request.getParameter("position");
            String employeeId = request.getParameter("employeeId");
            String officeLocation = request.getParameter("officeLocation");
            String address = request.getParameter("address");
            String fingerprintData = request.getParameter("fingerprintData");
            
            // Validate required fields
            if (firstName == null || firstName.trim().isEmpty() ||
                lastName == null || lastName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                department == null || department.trim().isEmpty() ||
                position == null || position.trim().isEmpty() ||
                employeeId == null || employeeId.trim().isEmpty()) {
                
                String jsonResponse = gson.toJson(new Response(false, "All required fields must be filled"));
                out.print(jsonResponse);
                return;
            }
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = SimpleDatabaseConfig.getSimpleConnection();
                
                // Check if employee ID already exists
                pstmt = conn.prepareStatement("SELECT id FROM staff_registration WHERE employee_id = ?");
                pstmt.setString(1, employeeId);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    String jsonResponse = gson.toJson(new Response(false, "Employee ID already exists"));
                    out.print(jsonResponse);
                    return;
                }
                
                // Close previous statement
                if (pstmt != null) pstmt.close();
                if (rs != null) rs.close();
                
                // Insert staff record
                String sql = "INSERT INTO staff_registration " +
                           "(first_name, last_name, email, phone, department, position, " +
                           "employee_id, office_location, address, registration_date, fingerprint_data) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, firstName.trim());
                pstmt.setString(2, lastName.trim());
                pstmt.setString(3, email.trim());
                pstmt.setString(4, phone.trim());
                pstmt.setString(5, department.trim());
                pstmt.setString(6, position.trim());
                pstmt.setString(7, employeeId.trim());
                pstmt.setString(8, officeLocation != null ? officeLocation.trim() : "");
                pstmt.setString(9, address != null ? address.trim() : "");
                pstmt.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
                
                if (fingerprintData != null && !fingerprintData.trim().isEmpty()) {
                    pstmt.setString(11, fingerprintData.trim());
                } else {
                    pstmt.setNull(11, java.sql.Types.VARCHAR);
                }
                
                int result = pstmt.executeUpdate();
                
                if (result > 0) {
                    String jsonResponse = gson.toJson(new Response(true, 
                        "Staff member registered successfully" + 
                        (fingerprintData != null ? " with fingerprint" : " without fingerprint")));
                    out.print(jsonResponse);
                } else {
                    String jsonResponse = gson.toJson(new Response(false, "Registration failed"));
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
