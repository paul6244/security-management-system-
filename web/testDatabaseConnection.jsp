<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="config.DatabaseConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>Database Connection Test</title>
</head>
<body>
    <h1>Database Connection Test</h1>
    
    <%
    try {
        Connection conn = DatabaseConfig.getConnection();
        out.println("<p style='color:green;'>✅ Database connected successfully!</p>");
        
        // Test basic query
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT version()");
            if (rs.next()) {
                out.println("<p>PostgreSQL Version: " + rs.getString(1) + "</p>");
            }
            rs.close();
            stmt.close();
            
            // Check if users table exists
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet tables = meta.getTables(null, null, "users", null);
            if (tables.next()) {
                out.println("<p style='color:green;'>✅ Users table exists</p>");
                
                // Count users
                ResultSet countRs = stmt.executeQuery("SELECT COUNT(*) FROM users");
                if (countRs.next()) {
                    int userCount = countRs.getInt(1);
                    out.println("<p>Number of users: " + userCount + "</p>");
                }
                countRs.close();
            } else {
                out.println("<p style='color:red;'>❌ Users table does not exist</p>");
                
                // Create users table
                out.println("<p>Creating users table...</p>");
                String createTableSQL = "CREATE TABLE users (" +
                                      "id SERIAL PRIMARY KEY, " +
                                      "username VARCHAR(50) UNIQUE NOT NULL, " +
                                      "email VARCHAR(100) UNIQUE NOT NULL, " +
                                      "password VARCHAR(255) NOT NULL, " +
                                      "role VARCHAR(50) NOT NULL" +
                                      ")";
                stmt.executeUpdate(createTableSQL);
                out.println("<p style='color:green;'>✅ Users table created successfully!</p>");
            }
            tables.close();
            
            // Check if branches table exists
            tables = meta.getTables(null, null, "branches", null);
            if (tables.next()) {
                out.println("<p style='color:green;'>✅ Branches table exists</p>");
                
                // Count branches
                ResultSet countRs = stmt.executeQuery("SELECT COUNT(*) FROM branches");
                if (countRs.next()) {
                    int branchCount = countRs.getInt(1);
                    out.println("<p>Number of branches: " + branchCount + "</p>");
                }
                countRs.close();
            } else {
                out.println("<p style='color:red;'>❌ Branches table does not exist</p>");
                
                // Create branches table
                out.println("<p>Creating branches table...</p>");
                String createTableSQL = "CREATE TABLE branches (" +
                                      "id SERIAL PRIMARY KEY, " +
                                      "name VARCHAR(100) NOT NULL" +
                                      ")";
                stmt.executeUpdate(createTableSQL);
                out.println("<p style='color:green;'>✅ Branches table created successfully!</p>");
                
                // Insert sample branches
                String[] branchNames = {"Main Campus", "Science Block", "Engineering Block", "Library", "Administration", "Sports Complex", "Hostel A", "Hostel B", "Cafeteria", "Health Center", "Research Lab", "Computer Center", "Auditorium"};
                for (String branchName : branchNames) {
                    stmt.executeUpdate("INSERT INTO branches (name) VALUES ('" + branchName + "')");
                }
                out.println("<p style='color:green;'>✅ Sample branches inserted!</p>");
            }
            tables.close();
            
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
    <a href="index.jsp">Back to Login</a>
    
</body>
</html>
