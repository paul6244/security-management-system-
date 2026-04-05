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
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import config.SimpleDatabaseConfig;

@WebServlet("/FingerprintRegistration")
public class FingerprintRegistration extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Read fingerprint data from request
            String fingerprintData = request.getParameter("fingerprintData");
            String employeeId = request.getParameter("employeeId");
            
            if (fingerprintData == null || fingerprintData.trim().isEmpty()) {
                out.println("{\"success\": false, \"message\": \"Fingerprint data is required\"}");
                return;
            }
            
            if (employeeId == null || employeeId.trim().isEmpty()) {
                out.println("{\"success\": false, \"message\": \"Employee ID is required\"}");
                return;
            }
            
            // Validate fingerprint data (basic validation)
            if (!isValidFingerprintData(fingerprintData)) {
                out.println("{\"success\": false, \"message\": \"Invalid fingerprint data format\"}");
                return;
            }
            
            // Check if employee exists
            Connection con = SimpleDatabaseConfig.getSimpleConnection();
            String checkSql = "SELECT id FROM staff_registration WHERE employee_id = ?";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setString(1, employeeId);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (!checkRs.next()) {
                out.println("{\"success\": false, \"message\": \"Employee ID not found\"}");
                checkRs.close();
                checkPs.close();
                con.close();
                return;
            }
            
            // Check if fingerprint already exists for this employee
            String existingSql = "SELECT fingerprint_data FROM staff_registration WHERE employee_id = ?";
            PreparedStatement existingPs = con.prepareStatement(existingSql);
            existingPs.setString(1, employeeId);
            ResultSet existingRs = existingPs.executeQuery();
            
            if (existingRs.next() && existingRs.getString("fingerprint_data") != null) {
                out.println("{\"success\": false, \"message\": \"Fingerprint already registered for this employee\"}");
                existingRs.close();
                existingPs.close();
                checkRs.close();
                checkPs.close();
                con.close();
                return;
            }
            
            existingRs.close();
            existingPs.close();
            checkRs.close();
            checkPs.close();
            
            // Store fingerprint data
            String updateSql = "UPDATE staff_registration SET fingerprint_data = ? WHERE employee_id = ?";
            PreparedStatement updatePs = con.prepareStatement(updateSql);
            updatePs.setString(1, fingerprintData);
            updatePs.setString(2, employeeId);
            
            int rowsUpdated = updatePs.executeUpdate();
            updatePs.close();
            con.close();
            
            if (rowsUpdated > 0) {
                out.println("{\"success\": true, \"message\": \"Fingerprint registered successfully\"}");
            } else {
                out.println("{\"success\": false, \"message\": \"Failed to register fingerprint\"}");
            }
            
        } catch (Exception e) {
            out.println("{\"success\": false, \"message\": \"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
    
    // Basic validation for fingerprint data
    private boolean isValidFingerprintData(String data) {
        if (data == null || data.trim().isEmpty()) {
            return false;
        }
        
        // Check minimum length (fingerprint templates are typically long strings)
        if (data.length() < 50) {
            return false;
        }
        
        // Check for valid characters (base64-like or hex-like data)
        return data.matches("^[a-zA-Z0-9+/=]+$");
    }
    
    // Generate simulated fingerprint data for testing
    public static String generateSimulatedFingerprint(String employeeId) {
        // Generate a consistent but unique fingerprint template based on employee ID
        String baseData = "FP_" + employeeId + "_";
        StringBuilder fingerprint = new StringBuilder(baseData);
        
        // Add random-looking but deterministic data
        long hash = employeeId.hashCode();
        for (int i = 0; i < 100; i++) {
            fingerprint.append((char) ('A' + (Math.abs(hash + i) % 26)));
            fingerprint.append((char) ('0' + (Math.abs(hash * (i + 1)) % 10)));
        }
        
        return fingerprint.toString();
    }
}
