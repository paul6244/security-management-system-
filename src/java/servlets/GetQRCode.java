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
import config.SimpleDatabaseConfig;

@WebServlet("/GetQRCode")
public class GetQRCode extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        String staffId = request.getParameter("staffId");
        
        if (staffId == null || staffId.trim().isEmpty()) {
            String jsonResponse = gson.toJson(new Response(false, "Staff ID is required"));
            out.print(jsonResponse);
            return;
        }
        
        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            con = SimpleDatabaseConfig.getSimpleConnection();
            stmt = con.prepareStatement(
                "SELECT id, employee_id, first_name, last_name, qr_code FROM staff_registration WHERE employee_id = ?"
            );
            stmt.setString(1, staffId);
            
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                int id = rs.getInt("id");
                String employeeId = rs.getString("employee_id");
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                String qrCode = rs.getString("qr_code");
                
                if (qrCode != null && !qrCode.trim().isEmpty()) {
                    String jsonResponse = gson.toJson(new QRResponse(true, "QR code found", id, employeeId, firstName, lastName, qrCode));
                    out.print(jsonResponse);
                } else {
                    String jsonResponse = gson.toJson(new Response(false, "No QR code found for this staff member"));
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
    
    // Response class for regular operations
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
    
    // Response class for QR code operations
    private class QRResponse {
        private boolean success;
        private String message;
        private Integer id;
        private String employeeId;
        private String firstName;
        private String lastName;
        private String qrCode;
        
        public QRResponse(boolean success, String message, Integer id, String employeeId, String firstName, String lastName, String qrCode) {
            this.success = success;
            this.message = message;
            this.id = id;
            this.employeeId = employeeId;
            this.firstName = firstName;
            this.lastName = lastName;
            this.qrCode = qrCode;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public String getMessage() {
            return message;
        }
        
        public Integer getId() {
            return id;
        }
        
        public String getEmployeeId() {
            return employeeId;
        }
        
        public String getFirstName() {
            return firstName;
        }
        
        public String getLastName() {
            return lastName;
        }
        
        public String getQRCode() {
            return qrCode;
        }
    }
}
