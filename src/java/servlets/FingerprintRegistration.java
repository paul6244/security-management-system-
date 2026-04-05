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
import config.SimpleDatabaseConfig;

@WebServlet("/FingerprintRegistration")
public class FingerprintRegistration extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Connection con = null;
        PreparedStatement checkPs = null;
        PreparedStatement existingPs = null;
        PreparedStatement updatePs = null;
        ResultSet checkRs = null;
        ResultSet existingRs = null;
        
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
            con = SimpleDatabaseConfig.getSimpleConnection();
            String checkSql = "SELECT id FROM staff_registration WHERE employee_id = ?";
            checkPs = con.prepareStatement(checkSql);
            checkPs.setString(1, employeeId);
            checkRs = checkPs.executeQuery();
            
            if (!checkRs.next()) {
                out.println("{\"success\": false, \"message\": \"Employee ID not found\"}");
                return;
            }
            
            // Check if fingerprint already exists for this employee
            String existingSql = "SELECT fingerprint_data FROM staff_registration WHERE employee_id = ?";
            existingPs = con.prepareStatement(existingSql);
            existingPs.setString(1, employeeId);
            existingRs = existingPs.executeQuery();
            
            if (existingRs.next() && existingRs.getString("fingerprint_data") != null && 
                !existingRs.getString("fingerprint_data").trim().isEmpty()) {
                out.println("{\"success\": false, \"message\": \"Fingerprint already registered for this employee\"}");
                return;
            }
            
            // Store fingerprint data
            String updateSql = "UPDATE staff_registration SET fingerprint_data = ? WHERE employee_id = ?";
            updatePs = con.prepareStatement(updateSql);
            updatePs.setString(1, fingerprintData);
            updatePs.setString(2, employeeId);
            
            int rowsUpdated = updatePs.executeUpdate();
            
            if (rowsUpdated > 0) {
                out.println("{\"success\": true, \"message\": \"Fingerprint registered successfully\"}");
            } else {
                out.println("{\"success\": false, \"message\": \"Failed to register fingerprint\"}");
            }
            
        } catch (Exception e) {
            String errorMessage = e.getMessage();
            if (errorMessage == null) {
                errorMessage = "Unknown error occurred";
            }
            // Proper JSON escaping
            String jsonMessage = errorMessage.replace("\\", "\\\\")
                                          .replace("\"", "\\\"")
                                          .replace("\n", "\\n")
                                          .replace("\r", "\\r")
                                          .replace("\t", "\\t");
            out.println("{\"success\": false, \"message\": \"Error: " + jsonMessage + "\"}");
        } finally {
            // Close all resources properly
            try {
                if (checkRs != null) checkRs.close();
                if (existingRs != null) existingRs.close();
                if (checkPs != null) checkPs.close();
                if (existingPs != null) existingPs.close();
                if (updatePs != null) updatePs.close();
                if (con != null) con.close();
            } catch (Exception e) {
                // Log error if needed
            }
        }
    }
    
    // Basic validation for fingerprint data
    private boolean isValidFingerprintData(String data) {
        if (data == null || data.trim().isEmpty()) {
            return false;
        }
        
        // Check minimum length (fingerprint templates are typically long strings)
        if (data.length() < 20) {
            return false;
        }
        
        // Check for valid characters (allow letters, numbers, underscores, and basic symbols)
        return data.matches("^[a-zA-Z0-9_+=]+$");
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
