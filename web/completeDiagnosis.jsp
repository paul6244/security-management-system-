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
    <title>Complete Settings Diagnosis</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .diagnostic-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #007bff; }
        .success { color: #155724; background: #d4edda; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { color: #721c24; background: #f8d7da; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .warning { color: #856404; background: #fff3cd; padding: 10px; margin: 10px 0; border-radius: 4px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .debug-info { background: #e9ecef; padding: 15px; margin: 10px 0; border-radius: 4px; }
        .fix-button { background: #28a745; color: white; padding: 10px 20px; text-decoration: none; border: none; border-radius: 4px; cursor: pointer; margin: 10px 0; display: inline-block; }
        .fix-button:hover { background: #218838; }
    </style>
</head>
<body>

<h1>Complete Settings Diagnosis</h1>

<div class="diagnostic-section">
    <h2>Session Information</h2>
    <table>
        <tr><th>Property</th><th>Value</th></tr>
        <tr><td>Username</td><td><%= username %></td></tr>
        <tr><td>Session ID</td><td><%= session.getId() %></td></tr>
        <tr><td>Session Valid</td><td><%= session.getAttribute("username") != null ? "✅ YES" : "❌ NO" %></td></tr>
    </table>
</div>

<%
Connection con = null;
ResultSet personnelInfo = null;
String personnelName = "";
String personnelEmail = "";
String personnelBranch = "";
String personnelShift = "";
int personnelId = 0;
int personnelBranchId = 0;

try {
    con = DatabaseConfig.getConnection();
    
    if (con == null) {
        %>
        <div class="diagnostic-section error">
            <h3>❌ Database Connection Failed</h3>
            <p>DatabaseConfig.getConnection() returned null</p>
        </div>
        <%
    } else {
        %>
        <div class="diagnostic-section success">
            <h3>✅ Database Connection Successful</h3>
            <p>Database connection established successfully</p>
        </div>
        <%
        
        // Test the exact query from securityOfficerSettings.jsp
        String personnelSql = "SELECT sp.*, b.name as branch_name, u.email as user_email FROM security_personnel sp " +
                           "JOIN users u ON sp.user_id = u.id " +
                           "LEFT JOIN branches b ON sp.branch_id = b.id " +
                           "WHERE u.username = ?";
        
        PreparedStatement personnelPs = con.prepareStatement(personnelSql);
        personnelPs.setString(1, username);
        personnelInfo = personnelPs.executeQuery();
        
        %>
        <div class="diagnostic-section">
            <h2>Personnel Query Analysis</h2>
            <table>
                <tr><th>Query</th><th>Result</th></tr>
                <tr><td><%= personnelSql %></td><td>Executed</td></tr>
                <tr><td>Parameter</td><td><%= username %></td></tr>
                <tr><td>ResultSet</td><td><%= personnelInfo != null ? "Not null" : "Null" %></td></tr>
                <tr><td>Has Next</td><td><%= personnelInfo != null && personnelInfo.next() ? "YES" : "NO" %></td></tr>
            </table>
        </div>
        <%
        
        if(personnelInfo != null && personnelInfo.next()) {
            personnelName = personnelInfo.getString("name");
            personnelEmail = personnelInfo.getString("user_email");
            personnelBranch = personnelInfo.getString("branch_name");
            personnelShift = personnelInfo.getString("shift_time");
            personnelId = personnelInfo.getInt("id");
            personnelBranchId = personnelInfo.getInt("branch_id");
        }
        
        personnelPs.close();
        con.close();
        
    } catch(Exception e) {
        %>
        <div class="diagnostic-section error">
            <h3>❌ Database Query Failed</h3>
            <p><strong>Error:</strong> <%= e.getMessage() %></p>
            <p><strong>SQL State:</strong> Database connection issue</p>
        </div>
        <%
    }
%>

<% if(!personnelName.isEmpty()) { %>
    <div class="diagnostic-section success">
        <h2>✅ Personnel Data Found</h2>
        <table>
            <tr><th>Field</th><th>Value</th></tr>
            <tr><td>Name</td><td><%= personnelName %></td></tr>
            <tr><td>Email</td><td><%= personnelEmail %></td></tr>
            <tr><td>Branch</td><td><%= personnelBranch %></td></tr>
            <tr><td>Shift</td><td><%= personnelShift %></td></tr>
            <tr><td>Personnel ID</td><td><%= personnelId %></td></tr>
            <tr><td>Branch ID</td><td><%= personnelBranchId %></td></tr>
        </table>
        
        <div class="debug-info">
            <h3>🔧 Settings Page Should Work Now</h3>
            <p>Personnel data found successfully! The securityOfficerSettings.jsp page should now display your information correctly.</p>
        </div>
        
        <div class="debug-info">
            <h3>📋 Next Steps</h3>
            <ol>
                <li>Return to <a href="securityOfficerSettings.jsp">securityOfficerSettings.jsp</a></li>
                <li>Check if your profile information is displayed</li>
                <li>Test all save buttons (Personal, Security, Shift, Notifications, Dashboard)</li>
                <li>If issues persist, contact administrator with this diagnostic information</li>
            </ol>
        </div>
        
        <div style="text-align: center; margin-top: 30px;">
            <a href="securityOfficerSettings.jsp" class="fix-button">🔧 Go Back to Settings</a>
        </div>
    </div>
    
<% } else { %>
    <div class="diagnostic-section error">
        <h2>❌ No Personnel Data Found</h2>
        <table>
            <tr><th>Issue</th><th>Details</th></tr>
            <tr><td>Username</td><td><%= username %></td></tr>
            <tr><td>Database</td><td>Connected ✅</td></tr>
            <tr><td>Query Result</td><td>No records returned</td></tr>
        </table>
        
        <div class="debug-info">
            <h3>🔍 Root Cause Analysis</h3>
            <p><strong>Possible Issues:</strong></p>
            <ul>
                <li><strong>User ID Mismatch:</strong> Your user_id in security_personnel table doesn't match your users table ID</li>
                <li><strong>Missing Personnel Record:</strong> No security_personnel record exists for your username</li>
                <li><strong>Database Inconsistency:</strong> Tables are not properly linked</li>
            </ul>
        </div>
        
        <div class="debug-info">
            <h3>🛠️ Recommended Solutions</h3>
            <ol>
                <li><strong>Fix User ID Mismatch:</strong> Use the <a href="fixUserIdMismatch.jsp">User ID Mismatch Fix Tool</a></li>
                <li><strong>Create Personnel Record:</strong> Contact administrator to create security_personnel record</li>
                <li><strong>Database Check:</strong> Verify database integrity</li>
            </ol>
        </div>
        
        <div style="text-align: center; margin-top: 30px;">
            <a href="fixUserIdMismatch.jsp" class="fix-button">🔧 Fix User ID Mismatch</a>
        </div>
    </div>
<% } %>

<br><br>
<div style="text-align: center; margin-top: 20px; padding: 20px; background: #f8f9fa; border-radius: 8px;">
    <p><strong>🔍 If you're still seeing "No personnel information found" on the settings page, this diagnostic tool will help identify the exact cause.</strong></p>
    <p><strong>📋 Most Common Issue:</strong> User ID mismatch between users and security_personnel tables.</p>
    <p><strong>🛠️ Quick Fix Available:</strong> <a href="fixUserIdMismatch.jsp" style="color: #007bff; text-decoration: none;">Click here to fix User ID mismatch</a></p>
</div>

</body>
</html>
