package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import config.SimpleDatabaseConfig;

@WebServlet("/SendVerificationCode")
public class SendVerificationCode extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String employeeId = request.getParameter("employeeId");
        String action = request.getParameter("action"); // "checkin" or "checkout"
        
        try {
            Connection con = SimpleDatabaseConfig.getSimpleConnection();
            
            // Get staff phone number
            String sql = "SELECT phone, first_name, last_name FROM staff_registration WHERE employee_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, employeeId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                String phoneNumber = rs.getString("phone");
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                String fullName = firstName + " " + lastName;
                
                // Ensure phone number has country code for SMS
                if (!phoneNumber.startsWith("+")) {
                    phoneNumber = "+233" + phoneNumber; // Add Ghana country code
                }
                
                // Generate 6-digit verification code
                Random random = new Random();
                String verificationCode = String.format("%06d", random.nextInt(999999));
                
                // Store verification code in session or database (for demo, we'll simulate)
                request.getSession().setAttribute("verificationCode", verificationCode);
                request.getSession().setAttribute("verifiedEmployeeId", employeeId);
                request.getSession().setAttribute("verificationAction", action);
                
                // Simulate SMS sending (in production, use Twilio or similar service)
                boolean smsSent = simulateSMSSending(phoneNumber, verificationCode, fullName, action);
                
                if (smsSent) {
                    String maskedPhone = maskPhoneNumber(phoneNumber);
                    String message = "Verification code sent to " + maskedPhone;
                    out.println("{\"success\": true, \"message\": \"" + message.replace("\"", "\\\"") + "\", \"code\": \"" + verificationCode + "\"}");
                } else {
                    out.println("{\"success\": false, \"message\": \"Failed to send verification code\"}");
                }
            } else {
                out.println("{\"success\": false, \"message\": \"Staff member not found\"}");
            }
            
            rs.close();
            ps.close();
            con.close();
            
        } catch (Exception e) {
            String errorMessage = e.getMessage().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
            out.println("{\"success\": false, \"message\": \"Error: " + errorMessage + "\"}");
        }
    }
    
    private boolean simulateSMSSending(String phoneNumber, String code, String fullName, String action) {
        // Simulate SMS sending - in production, integrate with Twilio, AWS SNS, etc.
        System.out.println("SMS SIMULATION: Sending verification code " + code + " to " + phoneNumber + " for " + action);
        System.out.println("SMS MESSAGE: Hi " + fullName + ", your verification code for " + action + " is: " + code);
        
        // For testing purposes, we'll store the code in session so it can be displayed
        // In production, this would be replaced with actual SMS sending
        try {
            // Store code in session for debugging (remove in production)
            HttpServletRequest request = null; // This would be passed as parameter in real implementation
            // For now, just log the code prominently
            System.out.println("=================================================");
            System.out.println("IMPORTANT: Your verification code is: " + code);
            System.out.println("=================================================");
        } catch (Exception e) {
            System.out.println("Session storage error: " + e.getMessage());
        }
        
        return true; // Simulate success
    }
    
    private String maskPhoneNumber(String phone) {
        if (phone == null || phone.length() < 4) return phone;
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 2);
    }
}
