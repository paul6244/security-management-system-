<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="config.SimpleDatabaseConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>Fix Fingerprint Database</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .success { color: green; }
        .error { color: red; }
        .info { color: blue; }
    </style>
</head>
<body>
    <h1>Fingerprint Database Fix</h1>
    
    <%
    Connection con = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        con = SimpleDatabaseConfig.getSimpleConnection();
        stmt = con.createStatement();
        
        // Check if fingerprint_data column exists
        boolean columnExists = false;
        try {
            rs = stmt.executeQuery("SELECT fingerprint_data FROM staff_registration LIMIT 1");
            columnExists = true;
            rs.close();
        } catch (Exception e) {
            columnExists = false;
        }
        
        if (!columnExists) {
            // Add fingerprint_data column
            String alterSql = "ALTER TABLE staff_registration ADD COLUMN fingerprint_data TEXT";
            stmt.executeUpdate(alterSql);
            out.println("<p class='success'>✅ SUCCESS: Added fingerprint_data column to staff_registration table</p>");
        } else {
            out.println("<p class='info'>ℹ️ INFO: fingerprint_data column already exists</p>");
        }
        
        // Clear any existing fingerprint data
        int clearedRows = stmt.executeUpdate("UPDATE staff_registration SET fingerprint_data = NULL");
        out.println("<p class='success'>✅ Cleared fingerprint data from " + clearedRows + " staff records</p>");
        
        // Show current status
        rs = stmt.executeQuery("SELECT COUNT(*) as total, COUNT(fingerprint_data) as with_fp FROM staff_registration");
        if (rs.next()) {
            int total = rs.getInt("total");
            int withFp = rs.getInt("with_fp");
            out.println("<h2>Database Status:</h2>");
            out.println("<ul>");
            out.println("<li>Total staff records: " + total + "</li>");
            out.println("<li>With fingerprint data: " + withFp + "</li>");
            out.println("<li>Ready for fingerprint registration: " + (total - withFp) + "</li>");
            out.println("</ul>");
        }
        rs.close();
        
        out.println("<p class='success'>🎉 Database is now ready for fingerprint registration!</p>");
        
    } catch (Exception e) {
        out.println("<p class='error'>❌ ERROR: " + e.getMessage() + "</p>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (con != null) con.close();
        } catch (Exception e) {
            // Ignore
        }
    }
    %>
    
    <h2>Next Steps:</h2>
    <ol>
        <li><a href="staffRegistration.jsp">Go to Staff Registration</a></li>
        <li>Enter Employee ID (EM01 or EM04)</li>
        <li>Click "Register Fingerprint"</li>
        <li>Watch the animated scanner</li>
        <li>Test with "Test Fingerprint"</li>
    </ol>
    
    <p><a href="index.jsp">Return to Login</a></p>
</body>
</html>
