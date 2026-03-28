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
    <title>Settings Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>

<h1>Settings Page Test</h1>

<div class="test-section">
    <h2>Session Information</h2>
    <p><strong>Username:</strong> <%= username %></p>
    <p><strong>Session ID:</strong> <%= session.getId() %></p>
    <p><strong>Session Valid:</strong> <%= session.getAttribute("username") != null ? "Yes" : "No" %></p>
</div>

<div class="test-section">
    <h2>Database Connection Test</h2>
    <%
    Connection con = null;
    try {
        con = DatabaseConfig.getConnection();
        if (con == null) {
    %>
        <p class="error">❌ Database connection failed</p>
    <%
        } else {
    %>
        <p class="success">✅ Database connection successful</p>
        
        <%
        // Test personnel query
        String personnelSql = "SELECT sp.*, b.name as branch_name, u.email as user_email FROM security_personnel sp " +
                           "JOIN users u ON sp.user_id = u.id " +
                           "LEFT JOIN branches b ON sp.branch_id = b.id " +
                           "WHERE u.username = ?";
        PreparedStatement personnelPs = con.prepareStatement(personnelSql);
        personnelPs.setString(1, username);
        ResultSet personnelInfo = personnelPs.executeQuery();
        
        if(personnelInfo != null && personnelInfo.next()) {
            String personnelName = personnelInfo.getString("name");
            String personnelEmail = personnelInfo.getString("user_email");
            String personnelBranch = personnelInfo.getString("branch_name");
            String personnelShift = personnelInfo.getString("shift_time");
        %>
        <p class="success">✅ Personnel data found: <%= personnelName %> - <%= personnelEmail %> - <%= personnelBranch %></p>
        <%
        } else {
        %>
        <p class="error">❌ No personnel data found</p>
        <%
        }
        
        personnelInfo.close();
        personnelPs.close();
        con.close();
        }
    } catch(Exception e) {
    %>
        <p class="error">❌ Exception: <%= e.getMessage() %></p>
    <%
    }
    %>
</div>

<br><br>
<a href="securityOfficerSettings.jsp">← Go to Settings Page</a>
<a href="personnelDashboard.jsp">← Go to Dashboard</a>

</body>
</html>
