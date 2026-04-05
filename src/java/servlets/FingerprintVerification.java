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
            Connection con = SimpleDatabaseConfig.getSimpleConnection();
            String sql = "SELECT fingerprint_data, first_name, last_name FROM staff_registration WHERE employee_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, employeeId);
            ResultSet rs = ps.executeQuery();
            
            if (!rs.next()) {
                out.println("{\"success\": false, \"message\": \"Employee not found\"}");
                rs.close();
                ps.close();
                con.close();
                return;
            }
            
            String storedFingerprint = rs.getString("fingerprint_data");
            String firstName = rs.getString("first_name");
            String lastName = rs.getString("last_name");
            
            rs.close();
            ps.close();
            con.close();
            
            // Check if fingerprint is registered
            if (storedFingerprint == null || storedFingerprint.trim().isEmpty()) {
                out.println("{\"success\": false, \"message\": \"No fingerprint registered for this employee\"}");
                return;
            }
            
            // Compare fingerprints
            boolean isMatch = compareFingerprints(fingerprintData, storedFingerprint);
            
            if (isMatch) {
                String fullName = firstName + " " + lastName;
                out.println("{\"success\": true, \"message\": \"Fingerprint verified successfully\", \"employeeName\": \"" + fullName + "\"}");
            } else {
                out.println("{\"success\": false, \"message\": \"Fingerprint does not match\"}");
            }
            
        } catch (Exception e) {
            out.println("{\"success\": false, \"message\": \"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
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
        return FingerprintRegistration.generateSimulatedFingerprint(employeeId);
    }
}
