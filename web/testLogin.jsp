<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="config.DatabaseConfig" %>
<%@ page import="utility.universalManager" %>
<%@ page import="model.Mymodel" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Login</title>
</head>
<body>
    <h1>Test Login Process</h1>
    
    <%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    if (username != null && password != null) {
        out.println("<h2>Testing Login for: " + username + "</h2>");
        
        // Step 1: Check if user exists
        out.println("<h3>Step 1: Check if user exists</h3>");
        try {
            Connection conn = DatabaseConfig.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT username, password, role FROM users WHERE username = '" + username + "'");
            
            if (rs.next()) {
                String dbUsername = rs.getString("username");
                String dbPassword = rs.getString("password");
                String dbRole = rs.getString("role");
                
                out.println("<p style='color:green;'>✅ User found in database</p>");
                out.println("<p>Username: " + dbUsername + "</p>");
                out.println("<p>Role: " + dbRole + "</p>");
                out.println("<p>Stored Password Hash: " + dbPassword.substring(0, Math.min(10, dbPassword.length())) + "...</p>");
                
                // Step 2: Test password hashing
                out.println("<h3>Step 2: Test password hashing</h3>");
                String inputPasswordHash = universalManager.hashPassword(password);
                out.println("<p>Input Password: " + password + "</p>");
                out.println("<p>Input Password Hash: " + inputPasswordHash.substring(0, Math.min(10, inputPasswordHash.length())) + "...</p>");
                out.println("<p>Passwords match: " + dbPassword.equals(inputPasswordHash) + "</p>");
                
                // Step 3: Test Mymodel.getUserRole
                out.println("<h3>Step 3: Test Mymodel.getUserRole</h3>");
                String role = Mymodel.getUserRole(username, password);
                if (role != null) {
                    out.println("<p style='color:green;'>✅ Login successful! Role: " + role + "</p>");
                } else {
                    out.println("<p style='color:red;'>❌ Login failed - getUserRole returned null</p>");
                }
                
            } else {
                out.println("<p style='color:red;'>❌ User not found in database</p>");
            }
            
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (Exception e) {
            out.println("<p style='color:red;'>❌ Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
    } else {
        out.println("<p>Please provide username and password parameters</p>");
    }
    %>
    
    <br><br>
    <a href="testUsers.jsp">Back to Test Users</a> | 
    <a href="index.jsp">Back to Login</a>
    
</body>
</html>
