<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
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
<title>Settings Debug - Security System</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
.debug-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
.error { color: red; }
.success { color: green; }
table { border-collapse: collapse; width: 100%; margin: 20px 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
</style>
</head>
<body>

<h1>Security Officer Settings Debug</h1>

<div class="debug-section">
    <h2>Session Information</h2>
    <p><strong>Username:</strong> <%= username %></p>
    <p><strong>Session ID:</strong> <%= session.getId() %></p>
    <p><strong>Session Valid:</strong> <%= session.getAttribute("username") != null ? "Yes" : "No" %></p>
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
        <div class="debug-section error">
            <h3>Database Connection Error</h3>
            <p>Database connection is null</p>
        </div>
        <%
    } else {
        %>
        <div class="debug-section success">
            <h3>Database Connection Success</h3>
            <p>Database connection established successfully</p>
        </div>
        <%
        
        String personnelSql = "SELECT sp.*, b.name as branch_name, u.email as user_email FROM security_personnel sp " +
                           "JOIN users u ON sp.user_id = u.id " +
                           "LEFT JOIN branches b ON sp.branch_id = b.id " +
                           "WHERE u.username = ?";
        
        %>
        <div class="debug-section">
            <h3>SQL Query</h3>
            <p><strong>Query:</strong> <%= personnelSql %></p>
            <p><strong>Parameter:</strong> <%= username %></p>
        </div>
        <%
        
        PreparedStatement personnelPs = con.prepareStatement(personnelSql);
        personnelPs.setString(1, username);
        personnelInfo = personnelPs.executeQuery();
        
        %>
        <div class="debug-section">
            <h3>Query Execution</h3>
            <p><strong>ResultSet:</strong> <%= personnelInfo != null ? "Not null" : "Null" %></p>
            <p><strong>Has Next:</strong> <%= personnelInfo != null && personnelInfo.next() ? "Yes" : "No" %></p>
        </div>
        <%
        
        if(personnelInfo != null && personnelInfo.next()) {
            personnelName = personnelInfo.getString("name");
            personnelEmail = personnelInfo.getString("user_email");
            personnelBranch = personnelInfo.getString("branch_name");
            personnelShift = personnelInfo.getString("shift_time");
            personnelId = personnelInfo.getInt("id");
            personnelBranchId = personnelInfo.getInt("branch_id");
            
            %>
            <div class="debug-section success">
                <h3>Personnel Data Found</h3>
                <table>
                    <tr><th>Field</th><th>Value</th></tr>
                    <tr><td>Name</td><td><%= personnelName %></td></tr>
                    <tr><td>Email</td><td><%= personnelEmail %></td></tr>
                    <tr><td>Branch</td><td><%= personnelBranch %></td></tr>
                    <tr><td>Shift</td><td><%= personnelShift %></td></tr>
                    <tr><td>ID</td><td><%= personnelId %></td></tr>
                    <tr><td>Branch ID</td><td><%= personnelBranchId %></td></tr>
                </table>
            </div>
            <%
        } else {
            %>
            <div class="debug-section error">
                <h3>No Personnel Data Found</h3>
                <p>No personnel information found for username: <%= username %></p>
            </div>
            <%
        }
        
        personnelPs.close();
        con.close();
    }
    
} catch(Exception e) {
    %>
    <div class="debug-section error">
        <h3>Exception Occurred</h3>
        <p><strong>Error:</strong> <%= e.getMessage() %></p>
        <pre><%= e.getStackTrace()[0].toString() %></pre>
    </div>
    <%
}
%>

<br><br>
<a href="securityOfficerSettings.jsp">← Back to Settings</a>
<a href="personnelDashboard.jsp">← Back to Dashboard</a>

</body>
</html>
