package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;
import config.SimpleDatabaseConfig;
import config.SMSConfig;
import java.util.Random;
import java.net.URI;
import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Account;
import com.twilio.rest.api.v2010.account.MessageCreator;
import com.twilio.type.PhoneNumber;
import com.twilio.type.api.v2010.account.Message;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
                
                // Send verification code (real SMS or simulation)
                boolean smsSent = false;
                if (SMSConfig.isRealSMSEnabled()) {
                    smsSent = sendRealSMS(phoneNumber, verificationCode, fullName, action);
                } else {
                    smsSent = simulateSMSSending(phoneNumber, verificationCode, fullName, action);
                }
                
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
    
    private boolean sendRealSMS(String phoneNumber, String code, String fullName, String action) {
        try {
            // Initialize Twilio client
            Twilio twilio = new Twilio(SMSConfig.getAccountSid(), SMSConfig.getAuthToken());
            
            PhoneNumber to = new PhoneNumber(phoneNumber);
            PhoneNumber from = new PhoneNumber(SMSConfig.getTwilioNumber());
            
            // Create SMS message
            String message = String.format("Hi %s, your verification code for %s is: %s", fullName, action, code);
            
            // Send SMS
            MessageCreator creator = Message.creator(
                to,
                from
            ).setBody(message);
            
            Message smsMessage = creator.create();
            
            System.out.println("REAL SMS SENT: " + message + " to " + phoneNumber);
            return true;
            
        } catch (Exception e) {
            System.out.println("SMS sending failed: " + e.getMessage());
            e.printStackTrace();
            return false;
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
