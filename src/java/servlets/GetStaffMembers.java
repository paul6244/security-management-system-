package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/GetStaffMembers")
public class GetStaffMembers extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Gson gson = new Gson();
        
        try {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = config.SimpleDatabaseConfig.getSimpleConnection();
                
                // Get all staff members with QR codes
                pstmt = conn.prepareStatement(
                    "SELECT id, employee_id, first_name, last_name, department, qr_code " +
                    "FROM staff_registration " +
                    "ORDER BY first_name, last_name"
                );
                
                rs = pstmt.executeQuery();
                
                List<StaffMember> staffList = new ArrayList<>();
                
                while (rs.next()) {
                    StaffMember member = new StaffMember();
                    member.setId(rs.getInt("id"));
                    member.setEmployeeId(rs.getString("employee_id"));
                    member.setFirstName(rs.getString("first_name"));
                    member.setLastName(rs.getString("last_name"));
                    member.setDepartment(rs.getString("department"));
                    member.setQrCode(rs.getString("qr_code"));
                    staffList.add(member);
                }
                
                String jsonResponse = gson.toJson(staffList);
                out.print(jsonResponse);
                
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
        private List<StaffMember> staff;
        
        public Response(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
        
        public Response(boolean success, String message, List<StaffMember> staff) {
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
        
        public List<StaffMember> getStaff() {
            return staff;
        }
    }
    
    // StaffMember class for JSON response
    public class StaffMember {
        private int id;
        private String employeeId;
        private String firstName;
        private String lastName;
        private String department;
        private String qrCode;
        
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
        
        public void setQrCode(String qrCode) {
            this.qrCode = qrCode;
        }
    }
}
