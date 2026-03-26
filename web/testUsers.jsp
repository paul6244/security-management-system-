<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="config.DatabaseConfig" %>
<%@ page import="utility.universalManager" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Users</title>
</head>
<body>
    <h1>Test Users in Database</h1>
    
    <%
    try {
        Connection conn = DatabaseConfig.getConnection();
        out.println("<p style='color:green;'>✅ Database connected successfully!</p>");
        
        // Check if users table exists and has data
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT id, username, email, role FROM users");
            
            if (!rs.isBeforeFirst()) {
                out.println("<p style='color:red;'>❌ No users found in database. Creating test users...</p>");
                
                // Create test users
                String[] testUsers = {
                    "INSERT INTO users(username, email, password, role) VALUES('Pg123', 'admin@example.com', '" + universalManager.hashPassword("admin123") + "', 'admin')",
                    "INSERT INTO users(username, email, password, role) VALUES('PK', 'security1@example.com', '" + universalManager.hashPassword("security123") + "', 'security_officer')",
                    "INSERT INTO users(username, email, password, role) VALUES('ok', 'security2@example.com', '" + universalManager.hashPassword("security123") + "', 'security_officer')",
                    "INSERT INTO users(username, email, password, role) VALUES('Banard', 'security3@example.com', '" + universalManager.hashPassword("security123") + "', 'security_officer')",
                    "INSERT INTO users(username, email, password, role) VALUES('kumii2010', 'security4@example.com', '" + universalManager.hashPassword("security123") + "', 'security_officer')"
                };
                
                for (String userSql : testUsers) {
                    try {
                        stmt.executeUpdate(userSql);
                        out.println("<p style='color:green;'>✅ Created test user</p>");
                    } catch (SQLException e) {
                        out.println("<p style='color:orange;'>⚠️ User might already exist: " + e.getMessage() + "</p>");
                    }
                }
                
                // Query users again
                rs = stmt.executeQuery("SELECT id, username, email, role FROM users");
            }
            
            out.println("<h2>Current Users in Database:</h2>");
            out.println("<table border='1'>");
            out.println("<tr><th>ID</th><th>Username</th><th>Email</th><th>Role</th><th>Test Login</th></tr>");
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String username = rs.getString("username");
                String email = rs.getString("email");
                String role = rs.getString("role");
                
                out.println("<tr>");
                out.println("<td>" + id + "</td>");
                out.println("<td>" + username + "</td>");
                out.println("<td>" + email + "</td>");
                out.println("<td>" + role + "</td>");
                out.println("<td><a href='testLogin.jsp?username=" + username + "&password=admin123' target='_blank'>Test Login</a></td>");
                out.println("</tr>");
            }
            
            out.println("</table>");
            
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (SQLException e) {
            out.println("<p style='color:red;'>❌ Database query error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>❌ Database connection failed: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
    %>
    
    <br><br>
    <a href="index.jsp">Back to Login</a> | 
    <a href="testLogin.jsp">Test Login Page</a>
    
</body>
</html>
