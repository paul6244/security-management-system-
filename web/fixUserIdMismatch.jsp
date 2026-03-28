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
<title>Fix User ID Mismatch</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
.fix-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
.error { color: red; }
.success { color: green; }
table { border-collapse: collapse; width: 100%; margin: 20px 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
.btn { background: #3498db; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
.btn:hover { background: #2980b9; }
</style>
</head>
<body>

<h1>Fix User ID Mismatch in Database</h1>

<%
Connection con = null;
try {
    con = DatabaseConfig.getConnection();
    
    if (con == null) {
        %>
        <div class="fix-section error">
            <h3>Database Connection Error</h3>
            <p>Database connection is null</p>
        </div>
        <%
    } else {
        
        // Show current mismatched data
        String checkSql = "SELECT sp.id as sp_id, sp.name as sp_name, sp.user_id as sp_user_id, u.id as u_id, u.username as u_username " +
                       "FROM security_personnel sp " +
                       "LEFT JOIN users u ON sp.user_id = u.id " +
                       "ORDER BY sp.id";
        PreparedStatement checkPs = con.prepareStatement(checkSql);
        ResultSet checkRs = checkPs.executeQuery();
        
        %>
        <div class="fix-section">
            <h3>Current User ID Mismatches</h3>
            <table>
                <tr><th>Personnel ID</th><th>Personnel Name</th><th>Current user_id</th><th>Users Table ID</th><th>Username</th><th>Status</th></tr>
                <%
                while(checkRs.next()) {
                    String status = checkRs.getInt("u_id") > 0 ? "✅ Match" : "❌ Mismatch";
                    %>
                    <tr>
                        <td><%= checkRs.getInt("sp_id") %></td>
                        <td><%= checkRs.getString("sp_name") %></td>
                        <td><%= checkRs.getInt("sp_user_id") %></td>
                        <td><%= checkRs.getInt("u_id") %></td>
                        <td><%= checkRs.getString("u_username") %></td>
                        <td><%= status %></td>
                    </tr>
                    <%
                }
                %>
            </table>
        </div>
        <%
        
        checkRs.close();
        checkPs.close();
        
        // Fix the mismatches
        %>
        <div class="fix-section">
            <h3>Fix User ID Mismatches</h3>
            <p>Click the buttons below to fix the user_id references in security_personnel table:</p>
            
            <button class="btn" onclick="fixUserId(8, 13)">Fix 'ok' (user_id 13)</button>
            <button class="btn" onclick="fixUserId(9, 12)">Fix 'Banard' (user_id 12)</button>
            <button class="btn" onclick="fixUserId(10, 12)">Fix 'kumii2010' (user_id 12)</button>
        </div>
        <%
        
        con.close();
    }
    
} catch(Exception e) {
    %>
    <div class="fix-section error">
        <h3>Exception Occurred</h3>
        <p><strong>Error:</strong> <%= e.getMessage() %></p>
    </div>
    <%
}
%>

<script>
function fixUserId(personnelId, correctUserId) {
    if (confirm('Update personnel ID ' + personnelId + ' to use correct user_id ' + correctUserId + '?')) {
        fetch('FixUserIdMismatch?personnelId=' + personnelId + '&correctUserId=' + correctUserId)
            .then(response => response.text())
            .then(result => {
                if (result.includes('success')) {
                    alert('User ID mismatch fixed successfully!');
                    location.reload();
                } else {
                    alert('Error: ' + result);
                }
            })
            .catch(error => {
                alert('Error: ' + error);
            });
    }
}
</script>

<br><br>
<a href="securityOfficerSettings.jsp">← Back to Settings</a>
<a href="settingsDebug.jsp">← Debug Settings</a>

</body>
</html>
