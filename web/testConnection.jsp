<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%@page import="config.DatabaseConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>Database Connection Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .status { padding: 20px; border-radius: 5px; margin: 10px 0; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .test-btn { padding: 10px 20px; margin: 10px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <h1>🔍 Database Connection Test</h1>
    
    <div class="status info">
        <h3>Database URL Test</h3>
        <%
            String dbUrl = System.getenv("DATABASE_URL");
            if (dbUrl != null && !dbUrl.isEmpty()) {
                out.println("<p><strong>DATABASE_URL found:</strong> " + dbUrl.substring(0, Math.min(50, dbUrl.length())) + "...</p>");
            } else {
                out.println("<p><strong>DATABASE_URL:</strong> Not found (using local MySQL)</p>");
            }
        %>
    </div>
    
    <div class="status">
        <h3>Connection Test</h3>
        <%
            try {
                out.println("<p>Attempting database connection...</p>");
                Connection conn = DatabaseConfig.getConnection();
                
                if (conn != null && !conn.isClosed()) {
                    out.println("<p class='success'>✅ Database connection successful!</p>");
                    
                    // Test a simple query
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM users");
                    
                    if (rs.next()) {
                        int userCount = rs.getInt("total");
                        out.println("<p class='success'>✅ Query successful! Found " + userCount + " users in database.</p>");
                    }
                    
                    rs.close();
                    stmt.close();
                    conn.close();
                    
                    out.println("<p class='success'>✅ Connection closed successfully.</p>");
                } else {
                    out.println("<p class='error'>❌ Failed to establish database connection.</p>");
                }
                
            } catch (SQLException e) {
                out.println("<p class='error'>❌ SQL Error: " + e.getMessage() + "</p>");
                out.println("<p class='error'>❌ SQL State: " + e.getSQLState() + "</p>");
                out.println("<p class='error'>❌ Error Code: " + e.getErrorCode() + "</p>");
            } catch (Exception e) {
                out.println("<p class='error'>❌ General Error: " + e.getMessage() + "</p>");
                e.printStackTrace();
            }
        %>
    </div>
    
    <div class="status">
        <h3>Environment Variables</h3>
        <p><strong>Heroku Environment:</strong> <%= System.getProperty("java.vendor") %></p>
        <p><strong>Java Version:</strong> <%= System.getProperty("java.version") %></p>
        <p><strong>OS:</strong> <%= System.getProperty("os.name") %></p>
    </div>
    
    <br>
    <a href="index.jsp" class="test-btn">🏠 Back to Login</a>
    <a href="admin.jsp" class="test-btn">⚙️ Admin Dashboard</a>
    
</body>
</html>
