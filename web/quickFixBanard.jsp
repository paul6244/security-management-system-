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
<title>Quick Fix - Banard User ID</title>
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
.btn-danger { background: #e74c3c; }
.btn-danger:hover { background: #c0392b; }
</style>
</head>
<body>

<h1>Quick Fix - Banard User ID Issue</h1>

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
        
        // Get Banard's actual user_id from users table
        String getUserSql = "SELECT id, username FROM users WHERE username = ?";
        PreparedStatement getUserPs = con.prepareStatement(getUserSql);
        getUserPs.setString(1, "Banard");
        ResultSet userRs = getUserPs.executeQuery();
        
        int actualUserId = 0;
        if(userRs.next()) {
            actualUserId = userRs.getInt("id");
        }
        userRs.close();
        getUserPs.close();
        
        // Get Banard's current security_personnel record
        String getPersonnelSql = "SELECT id, name, user_id FROM security_personnel WHERE name = ?";
        PreparedStatement getPersonnelPs = con.prepareStatement(getPersonnelSql);
        getPersonnelPs.setString(1, "Banard");
        ResultSet personnelRs = getPersonnelPs.executeQuery();
        
        int personnelId = 0;
        int currentUserId = 0;
        if(personnelRs.next()) {
            personnelId = personnelRs.getInt("id");
            currentUserId = personnelRs.getInt("user_id");
        }
        personnelRs.close();
        getPersonnelPs.close();
        
        %>
        <div class="fix-section">
            <h3>Current State Analysis</h3>
            <table>
                <tr><th>Table</th><th>ID</th><th>Name/Username</th><th>Status</th></tr>
                <tr>
                    <td>Users</td>
                    <td><%= actualUserId %></td>
                    <td>Banard</td>
                    <td><%= actualUserId > 0 ? "✅ Found" : "❌ Not Found" %></td>
                </tr>
                <tr>
                    <td>Security Personnel</td>
                    <td><%= personnelId %></td>
                    <td>Banard</td>
                    <td>user_id = <%= currentUserId %></td>
                </tr>
            </table>
            
            <% if(actualUserId > 0 && currentUserId != actualUserId) { %>
                <p style="color: red; font-weight: bold;">
                    ❌ MISMATCH DETECTED: Banard has user_id <%= actualUserId %> in users table but <%= currentUserId %> in security_personnel table!
                </p>
                
                <button class="btn" onclick="fixBanardUserId()">Fix User ID Mismatch</button>
            <% } else if(actualUserId > 0 && currentUserId == actualUserId) { %>
                <p style="color: green; font-weight: bold;">
                    ✅ User IDs match correctly! No fix needed.
                </p>
            <% } else { %>
                <p style="color: red; font-weight: bold;">
                    ❌ ERROR: Cannot determine correct user_id mapping
                </p>
            <% } %>
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
function fixBanardUserId() {
    // Get the actual user_id for Banard from the table above
    const actualUserId = <%= actualUserId %>;
    const personnelId = <%= personnelId %>;
    
    if (confirm('Update Banard security_personnel record to use correct user_id ' + actualUserId + '?')) {
        fetch('FixUserIdMismatch?personnelId=' + personnelId + '&correctUserId=' + actualUserId)
            .then(response => response.text())
            .then(result => {
                if (result.includes('success')) {
                    alert('Banard user ID fixed successfully!');
                    window.location.href = 'securityOfficerSettings.jsp';
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
<a href="personnelDashboard.jsp">← Back to Dashboard</a>

</body>
</html>
