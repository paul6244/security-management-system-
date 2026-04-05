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

@WebServlet("/FingerprintVerification")
public class FingerprintVerification extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
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
            
            // Get stored fingerprint from database
            con = SimpleDatabaseConfig.getSimpleConnection();
            String sql = "SELECT fingerprint_data, first_name, last_name FROM staff_registration WHERE employee_id = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, employeeId);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                out.println("{\"success\": false, \"message\": \"Employee not found\"}");
                return;
            }
            
            String storedFingerprint = rs.getString("fingerprint_data");
            String firstName = rs.getString("first_name");
            String lastName = rs.getString("last_name");
            
            // Check if fingerprint is registered
            if (storedFingerprint == null || storedFingerprint.trim().isEmpty()) {
                out.println("{\"success\": false, \"message\": \"No fingerprint registered for this employee. Please register fingerprint first.\"}");
                return;
            }
            
            // Compare fingerprints
            boolean isMatch = compareFingerprints(fingerprintData, storedFingerprint);
            
            if (isMatch) {
                String fullName = firstName + " " + lastName;
                out.println("{\"success\": true, \"message\": \"Fingerprint verified successfully\", \"employeeName\": \"" + fullName + "\"}");
            } else {
                out.println("{\"success\": false, \"message\": \"Fingerprint does not match. Please try again.\"}");
            }
            
        } catch (Exception e) {
            out.println("{\"success\": false, \"message\": \"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            // Close all resources properly
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                // Log error if needed
            }
        }
    }
    
    // Compare fingerprint data (simulated comparison)
    private boolean compareFingerprints(String scannedFingerprint, String storedFingerprint) {
        if (scannedFingerprint == null || storedFingerprint == null) {
            return false;
        }
        
        // For simulation, we'll use exact matching
        // In a real system, this would use biometric comparison algorithms
        return scannedFingerprint.equals(storedFingerprint);
    }
    
    // Generate simulated fingerprint scan (for testing)
    public static String generateSimulatedScan(String employeeId) {
        // Generate the same fingerprint that would be stored
        return generateSimulatedFingerprint(employeeId);
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
