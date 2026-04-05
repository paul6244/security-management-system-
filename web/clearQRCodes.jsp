<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="config.SimpleDatabaseConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>Clear QR Codes</title>
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
        .error { 
            background: #c0392b; 
            padding: 15px; 
            margin: 10px 0; 
            border-radius: 5px;
            color: white;
        }
        .btn { 
            background: #667eea; 
            color: white; 
            padding: 10px 20px; 
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
        a { color: #667eea; text-decoration: none; }
        a:hover { text-decoration: underline; }
        h1, h2 { color: #667eea; margin-bottom: 20px; }
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
        <h1>🗑️ Clear QR Codes</h1>
        
        <div class="section">
            <h2>Database Operations</h2>
            
            <%
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                con = SimpleDatabaseConfig.getSimpleConnection();
                stmt = con.createStatement();
                
                // Check if qr_code column exists
                boolean qrColumnExists = false;
                try {
                    rs = stmt.executeQuery("SELECT qr_code FROM staff_registration LIMIT 1");
                    qrColumnExists = true;
                    rs.close();
                } catch (Exception e) {
                    qrColumnExists = false;
                }
                
                // Add qr_code column if it doesn't exist
                if (!qrColumnExists) {
                    stmt.executeUpdate("ALTER TABLE staff_registration ADD COLUMN qr_code VARCHAR(255)");
                    out.println("<div class='success'>");
                    out.println("<h3>✅ Added QR Code Column!</h3>");
                    out.println("<p>Successfully added qr_code column to staff_registration table.</p>");
                    out.println("</div>");
                }
                
                // Count total staff records
                rs = stmt.executeQuery("SELECT COUNT(*) as total FROM staff_registration");
                int totalStaff = 0;
                if (rs.next()) {
                    totalStaff = rs.getInt("total");
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
                out.println("<p><strong>With QR Codes:</strong> " + withQRCodes + "</p>");
                out.println("<p><strong>Without QR Codes:</strong> " + (totalStaff - withQRCodes) + "</p>");
                out.println("</div>");
                
            } catch (Exception e) {
                out.println("<div class='error'>");
                out.println("<h3>Database Error:</h3>");
                out.println("<p>Error: " + e.getMessage() + "</p>");
                out.println("</div>");
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
        </div>
        
        <div class="section">
            <h2>Clear QR Codes</h2>
            <p>This will remove all QR codes from staff records and set qr_code to NULL.</p>
            
            <form method="post">
                <button type="submit" name="action" value="clear_qr" class="btn">🗑️ Clear All QR Codes</button>
                <button type="submit" name="action" value="clear_all" class="btn" style="background: #e74c3c;">🗑️ Clear All Data (Reset)</button>
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
                    
                    if ("clear_qr".equals(action)) {
                        // Clear only QR codes
                        int cleared = stmt2.executeUpdate("UPDATE staff_registration SET qr_code = NULL WHERE qr_code IS NOT NULL");
                        out.println("<div class='success'>");
                        out.println("<h3>✅ QR Codes Cleared!</h3>");
                        out.println("<p>Cleared QR codes from " + cleared + " staff records.</p>");
                        out.println("<p>All staff records now have no QR codes.</p>");
                        out.println("</div>");
                        
                    } else if ("clear_all".equals(action)) {
                        // Clear all data (complete reset)
                        int cleared = stmt2.executeUpdate("UPDATE staff_registration SET qr_code = NULL, fingerprint_data = NULL");
                        out.println("<div class='warning'>");
                        out.println("<h3>⚠️ Complete Database Reset!</h3>");
                        out.println("<p>Cleared ALL QR codes and fingerprint data from " + cleared + " staff records.</p>");
                        out.println("<p>Database has been completely reset.</p>");
                        out.println("</div>");
                    }
                    
                } catch (Exception e) {
                    out.println("<div class='error'>");
                    out.println("<h3>❌ Operation Failed:</h3>");
                    out.println("<p>Error: " + e.getMessage() + "</p>");
                    out.println("</div>");
                } finally {
                    try {
                        if (stmt2 != null) stmt2.close();
                        if (con2 != null) con2.close();
                    } catch (Exception e) {
                        // Ignore
                    }
                }
            }
        %>
        
        <div class="section">
            <h2>🔗 Navigation</h2>
            <p><a href="staffRegistration.jsp" class="btn">📝 Staff Registration</a></p>
            <p><a href="index.jsp" class="btn">🏠 Login</a></p>
            <p><a href="fingerprintAttendance.jsp" class="btn">👆 Fingerprint Attendance</a></p>
        </div>
    </div>
</body>
</html>
