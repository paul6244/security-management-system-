<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<!DOCTYPE html>
<html>
<head>
    <title>Clear Staff Data</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; 
        }
        .container { 
            max-width: 600px; 
            margin: 0 auto; 
            background: rgba(255,255,255,0.1); 
            padding: 30px; 
            border-radius: 15px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .section { 
            margin: 20px 0; 
            padding: 20px; 
            background: rgba(255,255,255,0.05); 
            border-radius: 10px; 
        }
        .success { 
            background: #27ae60; 
            padding: 15px; 
            margin: 10px 0; 
            border-radius: 5px;
            color: white;
        }
        .warning { 
            background: #e74c3c; 
            padding: 15px; 
            margin: 10px 0; 
            border-radius: 5px;
            color: white;
        }
        .btn { 
            background: #667eea; 
            color: white; 
            padding: 12px 20px; 
            border: none; 
            border-radius: 5px; 
            cursor: pointer; 
            margin: 10px 5px; 
            text-decoration: none;
            display: inline-block;
        }
        .btn:hover { 
            background: #546e7a; 
        }
        .btn-danger { 
            background: #e74c3c; 
        }
        .btn-danger:hover { 
            background: #c0392b; 
        }
        h1, h2 { color: #667eea; margin-bottom: 20px; }
        h3 { color: white; margin-bottom: 15px; }
        p { margin: 10px 0; line-height: 1.5; }
        .stats {
            background: #2c3e50;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🗑️ Clear Staff Data</h1>
        
        <div class="section">
            <h3>Database Operations</h3>
            
            <%
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                con = SimpleDatabaseConfig.getSimpleConnection();
                stmt = con.createStatement();
                
                // Count total staff records
                rs = stmt.executeQuery("SELECT COUNT(*) as total FROM staff_registration");
                int totalStaff = 0;
                if (rs.next()) {
                    totalStaff = rs.getInt("total");
                }
                rs.close();
                
                // Count records with fingerprints
                rs = stmt.executeQuery("SELECT COUNT(*) as with_fingerprint FROM staff_registration WHERE fingerprint_data IS NOT NULL AND fingerprint_data != ''");
                int withFingerprints = 0;
                if (rs.next()) {
                    withFingerprints = rs.getInt("with_fingerprint");
                }
                rs.close();
                
                // Count records with QR codes
                rs = stmt.executeQuery("SELECT COUNT(*) as with_qr FROM staff_registration WHERE qr_code IS NOT NULL AND qr_code != ''");
                int withQRCodes = 0;
                if (rs.next()) {
                    withQRCodes = rs.getInt("with_qr");
                }
                rs.close();
                
                out.println("<div class='stats'>");
                out.println("<h3>Current Database Status:</h3>");
                out.println("<p><strong>Total Staff Records:</strong> " + totalStaff + "</p>");
                out.println("<p><strong>With Fingerprints:</strong> " + withFingerprints + "</p>");
                out.println("<p><strong>With QR Codes:</strong> " + withQRCodes + "</p>");
                out.println("<p><strong>Ready for Fresh Registration:</strong> " + (totalStaff - withFingerprints) + "</p>");
                out.println("</div>");
                
            } catch(SQLException e) {
                out.println("<div class='warning'>");
                out.println("<h3>Database Error</h3>");
                out.println("<p>Error: " + e.getMessage() + "</p>");
                out.println("</div>");
            } catch(Exception e) {
                out.println("<div class='warning'>");
                out.println("<h3>System Error</h3>");
                out.println("<p>Error: " + e.getMessage() + "</p>");
                out.println("</div>");
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (con != null) con.close();
                } catch(Exception e) {
                    // Ignore connection close error
                }
            }
            %>
        </div>
        
        <div class="section">
            <h3>Clear Operations</h3>
            <p>This will completely remove all staff data, fingerprints, and QR codes to start fresh.</p>
            
            <form method="post">
                <button type="submit" name="action" value="clear_fingerprints" class="btn">🗑️ Clear Fingerprints Only</button>
                <button type="submit" name="action" value="clear_qr" class="btn">🗑️ Clear QR Codes Only</button>
                <button type="submit" name="action" value="clear_all" class="btn btn-danger">🗑️ Clear ALL Staff Data</button>
            </form>
        </div>
        
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("action");
                Connection con2 = null;
                Statement stmt2 = null;
                
                try {
                    con2 = SimpleDatabaseConfig.getSimpleConnection();
                    stmt2 = con2.createStatement();
                    
                    int cleared = 0;
                    
                    if ("clear_fingerprints".equals(action)) {
                        cleared = stmt2.executeUpdate("UPDATE staff_registration SET fingerprint_data = NULL WHERE fingerprint_data IS NOT NULL");
                        out.println("<div class='success'>");
                        out.println("<h3>✅ Fingerprints Cleared!</h3>");
                        out.println("<p>Cleared fingerprint data from " + cleared + " staff records.</p>");
                        out.println("<p>Ready for fresh fingerprint registration.</p>");
                        out.println("</div>");
                        
                    } else if ("clear_qr".equals(action)) {
                        cleared = stmt2.executeUpdate("UPDATE staff_registration SET qr_code = NULL WHERE qr_code IS NOT NULL");
                        out.println("<div class='success'>");
                        out.println("<h3>✅ QR Codes Cleared!</h3>");
                        out.println("<p>Cleared QR codes from " + cleared + " staff records.</p>");
                        out.println("<p>Ready for fresh QR code generation.</p>");
                        out.println("</div>");
                        
                    } else if ("clear_all".equals(action)) {
                        // Delete all staff records
                        cleared = stmt2.executeUpdate("DELETE FROM staff_registration");
                        out.println("<div class='success'>");
                        out.println("<h3>✅ All Staff Data Cleared!</h3>");
                        out.println("<p>Deleted " + cleared + " staff records.</p>");
                        out.println("<p>Database is now completely empty.</p>");
                        out.println("<p>Ready for fresh staff registration with fingerprints.</p>");
                        out.println("</div>");
                    }
                    
                } catch(SQLException e) {
                    out.println("<div class='warning'>");
                    out.println("<h3>❌ Operation Failed</h3>");
                    out.println("<p>Error: " + e.getMessage() + "</p>");
                    out.println("</div>");
                } catch(Exception e) {
                    out.println("<div class='warning'>");
                    out.println("<h3>❌ System Error</h3>");
                    out.println("<p>Error: " + e.getMessage() + "</p>");
                    out.println("</div>");
                } finally {
                    try {
                        if (stmt2 != null) stmt2.close();
                        if (con2 != null) con2.close();
                    } catch(Exception e) {
                        // Ignore connection close error
                    }
                }
            }
        %>
        
        <div class="section">
            <h3>🔗 Navigation</h3>
            <p><a href="staffRegistration.jsp" class="btn">📝 Staff Registration</a></p>
            <p><a href="index.jsp" class="btn">🏠 Login</a></p>
            <p><a href="fingerprintAttendance.jsp" class="btn">👆 Fingerprint Attendance</a></p>
        </div>
    </div>
</body>
</html>
