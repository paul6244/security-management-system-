<%@ page import="java.sql.*" %>
<%@ page import="config.DatabaseConfig" %>

<%
if(session.getAttribute("username") == null){
    response.sendRedirect("index.jsp");
}

String username = session.getAttribute("username") != null ? session.getAttribute("username").toString() : "";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Simple Settings Diagnosis</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .success { color: #155724; background: #d4edda; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { color: #721c24; background: #f8d7da; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .info { background: #e9ecef; padding: 15px; margin: 10px 0; border-radius: 4px; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .btn { background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border: none; border-radius: 4px; cursor: pointer; margin: 10px 0; display: inline-block; }
    </style>
</head>
<body>

<h1>Settings Diagnosis</h1>

<div class="section">
    <h2>Session Information</h2>
    <table>
        <tr><th>Property</th><th>Value</th></tr>
        <tr><td>Username</td><td><%= username %></td></tr>
        <tr><td>Session Valid</td><td><%= session.getAttribute("username") != null ? "✅ YES" : "❌ NO" %></td></tr>
    </table>
</div>

<%
Connection con = null;
boolean hasPersonnel = false;
String errorMsg = "";

try {
    con = DatabaseConfig.getConnection();
    
    if (con == null) {
        errorMsg = "Database connection failed";
    } else {
        // Test personnel query
        String personnelSql = "SELECT sp.*, b.name as branch_name, u.email as user_email FROM security_personnel sp " +
                           "JOIN users u ON sp.user_id = u.id " +
                           "LEFT JOIN branches b ON sp.branch_id = b.id " +
                           "WHERE u.username = ?";
        
        PreparedStatement personnelPs = con.prepareStatement(personnelSql);
        personnelPs.setString(1, username);
        ResultSet personnelInfo = personnelPs.executeQuery();
        
        if(personnelInfo != null && personnelInfo.next()) {
            hasPersonnel = true;
        }
        
        personnelInfo.close();
        personnelPs.close();
        con.close();
    }
} catch(Exception e) {
    errorMsg = e.getMessage();
}
%>

<div class="section">
    <h2>Database Test Results</h2>
    <% if (!errorMsg.isEmpty()) { %>
        <div class="success">
            <h3>✅ Database Connection Successful</h3>
            <p>Database connection established successfully</p>
        </div>
    <% } else { %>
        <div class="error">
            <h3>❌ Database Error</h3>
            <p><strong>Error:</strong> <%= errorMsg %></p>
        </div>
    <% } %>
</div>

<div class="section">
    <h2>Personnel Data Test</h2>
    <% if (hasPersonnel) { %>
        <div class="success">
            <h3>✅ Personnel Data Found</h3>
            <p>Personnel record exists for username: <%= username %></p>
            <p><strong>Settings page should work now!</strong></p>
        </div>
    <% } else { %>
        <div class="error">
            <h3>❌ No Personnel Data Found</h3>
            <p><strong>Username:</strong> <%= username %></p>
            <p><strong>Issue:</strong> Personnel record not found in database</p>
            <p><strong>Most likely cause:</strong> User ID mismatch between users and security_personnel tables</p>
        </div>
    <% } %>
</div>

<div class="section">
    <h2>Recommended Actions</h2>
    <% if (hasPersonnel) { %>
        <div class="info">
            <h3>🎯 Next Steps</h3>
            <ol>
                <li>Return to <a href="securityOfficerSettings.jsp">securityOfficerSettings.jsp</a></li>
                <li>Check if your profile information is displayed</li>
                <li>Test all save buttons</li>
            </ol>
        </div>
    <% } else { %>
        <div class="info">
            <h3>🛠️ Recommended Solutions</h3>
            <ol>
                <li><strong>Fix User ID Mismatch:</strong> Use the <a href="fixUserIdMismatch.jsp">User ID Mismatch Fix Tool</a></li>
                <li><strong>Check Database:</strong> Verify database integrity</li>
                <li><strong>Contact Admin:</strong> Request personnel record creation</li>
            </ol>
            
            <div style="text-align: center; margin-top: 20px;">
                <a href="fixUserIdMismatch.jsp" class="btn">🔧 Fix User ID Mismatch</a>
            </div>
        </div>
    <% } %>
</div>

<br><br>
<div style="text-align: center; margin-top: 20px; padding: 20px; background: #f8f9fa; border-radius: 8px;">
    <p><strong>🔍 This simple diagnostic tool will help identify the exact issue with your settings page.</strong></p>
    <p><strong>📋 Most Common Issue:</strong> User ID mismatch between users and security_personnel tables.</p>
</div>

</body>
</html>
