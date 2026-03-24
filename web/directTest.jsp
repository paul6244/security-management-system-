<%@ page import="java.sql.*" %>
<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Direct Database Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .test-container { background: #f8f9fa; padding: 20px; border-radius: 8px; max-width: 600px; }
        .result { margin: 15px 0; padding: 10px; border-radius: 4px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
    </style>
</head>
<body>
    <div class="test-container">
        <h1>🗄️ Direct Database Test</h1>
        
        <%
        String action = request.getParameter("action");
        
        if("test".equals(action)) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
                
                String username = session.getAttribute("username").toString();
                
                // Get user ID
                String userSql = "SELECT id FROM users WHERE username = ?";
                PreparedStatement userPs = con.prepareStatement(userSql);
                userPs.setString(1, username);
                ResultSet userRs = userPs.executeQuery();
                
                if(userRs.next()) {
                    int userId = userRs.getInt("id");
                    
                    // Get personnel ID
                    String personnelSql = "SELECT id FROM security_personnel WHERE user_id = ?";
                    PreparedStatement personnelPs = con.prepareStatement(personnelSql);
                    personnelPs.setInt(1, userId);
                    ResultSet personnelRs = personnelPs.executeQuery();
                    
                    if(personnelRs.next()) {
                        int personnelId = personnelRs.getInt("id");
                        
                        // Create a test shift
                        String createShiftSql = "INSERT INTO shifts(user_id, start_time, end_time) VALUES(?, NOW(), NOW())";
                        PreparedStatement createShiftPs = con.prepareStatement(createShiftSql, PreparedStatement.RETURN_GENERATED_KEYS);
                        createShiftPs.setInt(1, userId);
                        createShiftPs.executeUpdate();
                        
                        ResultSet shiftKeys = createShiftPs.getGeneratedKeys();
                        int shiftId = 0;
                        if(shiftKeys.next()) {
                            shiftId = shiftKeys.getInt(1);
                        }
                        createShiftPs.close();
                        
                        // Insert test record
                        String insertSql = "INSERT INTO shift_checks(shift_id,personnel_id,item_id,status,reason,check_time) VALUES(?,?,?,?,?,NOW())";
                        PreparedStatement insertPs = con.prepareStatement(insertSql);
                        insertPs.setInt(1, shiftId);
                        insertPs.setInt(2, personnelId);
                        insertPs.setInt(3, 1); // item_id = 1
                        insertPs.setString(4, "OK");
                        insertPs.setString(5, "");
                        insertPs.executeUpdate();
                        insertPs.close();
                        
                        out.println("<div class='result success'>✅ SUCCESS: Direct database insert worked! Shift ID: " + shiftId + ", Personnel ID: " + personnelId + "</div>");
                        
                    } else {
                        out.println("<div class='result error'>❌ Personnel not found for user: " + username + "</div>");
                    }
                    personnelRs.close();
                    personnelPs.close();
                } else {
                    out.println("<div class='result error'>❌ User not found: " + username + "</div>");
                }
                userRs.close();
                userPs.close();
                con.close();
                
            } catch(Exception e) {
                out.println("<div class='result error'>❌ Error: " + e.getMessage() + "</div>");
            }
        }
        %>
        
        <h3>Test Direct Database Insert</h3>
        <p>This bypasses all forms and servlets - tests direct database operations.</p>
        
        <form method="get">
            <input type="hidden" name="action" value="test">
            <button type="submit">🧪 Test Direct Database Insert</button>
        </form>
        
        <hr>
        
        <h3>What This Tests:</h3>
        <ul>
            <li>✅ Database connection</li>
            <li>✅ User/personnel lookup</li>
            <li>✅ Shift creation</li>
            <li>✅ Direct shift_checks insert</li>
            <li>✅ Table structure compatibility</li>
        </ul>
        
        <p><strong>If this test works, the issue is in the servlet logic, not the database.</strong></p>
        
        <div style="margin-top: 20px;">
            <a href="personnelDashboard.jsp" style="text-decoration: none;">
                <button type="button">🏠 Back to Dashboard</button>
            </a>
        </div>
    </div>
</body>
</html>
