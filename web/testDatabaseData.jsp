<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%@page import="model.Mymodel" %>
<%@page import="config.DatabaseConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>Database Data Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .section h2 { color: #2c3e50; }
        table { border: 1px solid #ddd; border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { padding: 10px; text-align: left; border: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        .empty { color: #e74c3c; font-style: italic; }
        .success { color: #27ae60; }
        .action-btn { padding: 10px 20px; margin: 10px; background: #3498db; color: white; border: none; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <h1>🔍 Database Data Test</h1>
    
    <div class="section">
        <h2>Security Personnel Table</h2>
        <%
            try {
                ResultSet rs = Mymodel.getAllPersonnel();
                if (rs != null && rs.isBeforeFirst()) {
                    out.println("<table>");
                    out.println("<tr><th>ID</th><th>Name</th><th>Email</th><th>Shift Time</th><th>Branch</th></tr>");
                    while (rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getInt("id") + "</td>");
                        out.println("<td>" + rs.getString("name") + "</td>");
                        out.println("<td>" + (rs.getString("email") != null ? rs.getString("email") : "N/A") + "</td>");
                        out.println("<td>" + rs.getString("shift_time") + "</td>");
                        out.println("<td>" + rs.getString("branch_name") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                    rs.close();
                } else {
                    out.println("<p class='empty'>❌ No personnel records found in database.</p>");
                }
            } catch (Exception e) {
                out.println("<p class='empty'>❌ Error: " + e.getMessage() + "</p>");
            }
        %>
    </div>
    
    <div class="section">
        <h2>Users Table</h2>
        <%
            try {
                Connection conn = DatabaseConfig.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT id, username, email, role FROM users");
                
                if (rs != null && rs.isBeforeFirst()) {
                    out.println("<table>");
                    out.println("<tr><th>ID</th><th>Username</th><th>Email</th><th>Role</th></tr>");
                    while (rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getInt("id") + "</td>");
                        out.println("<td>" + rs.getString("username") + "</td>");
                        out.println("<td>" + (rs.getString("email") != null ? rs.getString("email") : "N/A") + "</td>");
                        out.println("<td>" + rs.getString("role") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                    rs.close();
                } else {
                    out.println("<p class='empty'>❌ No user records found in database.</p>");
                }
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<p class='empty'>❌ Error: " + e.getMessage() + "</p>");
            }
        %>
    </div>
    
    <div class="section">
        <h2>Branches Table</h2>
        <%
            try {
                Connection conn = DatabaseConfig.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT id, name FROM branches");
                
                if (rs != null && rs.isBeforeFirst()) {
                    out.println("<table>");
                    out.println("<tr><th>ID</th><th>Name</th></tr>");
                    while (rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getInt("id") + "</td>");
                        out.println("<td>" + rs.getString("name") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                    rs.close();
                } else {
                    out.println("<p class='empty'>❌ No branch records found in database.</p>");
                }
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<p class='empty'>❌ Error: " + e.getMessage() + "</p>");
            }
        %>
    </div>
    
    <div class="section">
        <h2>Shift Checks Table</h2>
        <%
            try {
                Connection conn = DatabaseConfig.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT id, check_date, status, branch_id FROM shift_checks LIMIT 5");
                
                if (rs != null && rs.isBeforeFirst()) {
                    out.println("<table>");
                    out.println("<tr><th>ID</th><th>Check Date</th><th>Status</th><th>Branch ID</th></tr>");
                    while (rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getInt("id") + "</td>");
                        out.println("<td>" + rs.getString("check_date") + "</td>");
                        out.println("<td>" + rs.getString("status") + "</td>");
                        out.println("<td>" + rs.getInt("branch_id") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                    rs.close();
                } else {
                    out.println("<p class='empty'>❌ No shift check records found in database.</p>");
                }
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<p class='empty'>❌ Error: " + e.getMessage() + "</p>");
            }
        %>
    </div>
    
    <br><br>
    <a href="index.jsp" class="action-btn">🏠 Back to Login</a>
    <a href="admin.jsp" class="action-btn">⚙️ Admin Dashboard</a>
    
</body>
</html>
