<%@ page import="java.sql.*" %>
<%@ page import="config.DatabaseConfig" %>
<%@ page import="model.Mymodel" %>

<%
if(session.getAttribute("username") != null){
    response.sendRedirect("personnelDashboard.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Login Diagnosis - Security Management System</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .success { color: #155724; background: #d4edda; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { color: #721c24; background: #f8d7da; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .info { background: #e9ecef; padding: 15px; margin: 10px 0; border-radius: 4px; }
        .test-button { background: #28a745; color: white; padding: 10px 20px; text-decoration: none; border: none; border-radius: 4px; cursor: pointer; margin: 10px 5px; display: inline-block; }
        .test-button:hover { background: #218838; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
    </style>
</head>
<body>

<h1>Login System Diagnosis</h1>

<div class="test-section">
    <h2>Database Connection Test</h2>
    <%
    Connection con = null;
    try {
        con = DatabaseConfig.getConnection();
        if(con != null && !con.isClosed()) {
    %>
            <div class="success">
                <h3>✅ Database Connection Successful</h3>
                <p>Database connection established successfully</p>
            </div>
    <%
        } else {
    %>
            <div class="error">
                <h3>❌ Database Connection Failed</h3>
                <p>Could not establish database connection</p>
            </div>
    <%
        }
    } catch(Exception e) {
    %>
        <div class="error">
            <h3>❌ Database Connection Error</h3>
            <p><strong>Error:</strong> <%= e.getMessage() %></p>
        </div>
    <%
    } finally {
        try {
            if(con != null) con.close();
        } catch(Exception e) {
            // Ignore close errors
        }
    }
    %>
</div>

<div class="test-section">
    <h2>User Authentication Test</h2>
    
    <div class="info">
        <h3>Test Login Functionality</h3>
        <p>Use this form to test the login system with known credentials:</p>
    </div>
    
    <form action="SimpleLogin" method="post">
        <div class="form-group">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" required>
        </div>
        
        <div class="form-group">
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
        </div>
        
        <div class="form-group">
            <input type="submit" value="Test Login" class="test-button">
        </div>
    </form>
    
    <div class="info">
        <h3>Expected Results:</h3>
        <ul>
            <li><strong>Valid Credentials:</strong> Should redirect to appropriate dashboard</li>
            <li><strong>Invalid Credentials:</strong> Should show "Invalid username or password" error</li>
            <li><strong>Database Issues:</strong> Should show database connection errors</li>
            <li><strong>Connection Problems:</strong> Should show connection timeout errors</li>
        </ul>
    </div>
</div>

<div class="test-section">
    <h2>Troubleshooting Steps</h2>
    <ol>
        <li><strong>Test Database Connection:</strong> Check if database is accessible</li>
        <li><strong>Verify Credentials:</strong> Ensure username and password are correct</li>
        <li><strong>Check User Table:</strong> Verify users table exists and has data</li>
        <li><strong>Password Hashing:</strong> Ensure password hashing is working correctly</li>
        <li><strong>Session Management:</strong> Check if sessions are being created properly</li>
        <li><strong>Network Issues:</strong> Verify Heroku database connectivity</li>
    </ol>
    
    <div class="info">
        <h3>Common Issues:</h3>
        <ul>
            <li><strong>"Invalid username or password":</strong> Either credentials are wrong or database query failed</li>
            <li><strong>Database connection errors:</strong> Database is down or connection string is wrong</li>
            <li><strong>Connection timeouts:</strong> Network issues or database server problems</li>
            <li><strong>Session issues:</strong> Session management problems</li>
        </ul>
    </div>
</div>

<div class="test-section">
    <h2>Quick Links</h2>
    <a href="simpleLogin.jsp" class="test-button">🔐 Main Login Page</a>
    <a href="simpleSignup.jsp" class="test-button">👤 Sign Up Page</a>
    <a href="index.jsp" class="test-button">🏠 Home Page</a>
    <a href="sqlTest.jsp" class="test-button">🔍 SQL Function Test</a>
</div>

</body>
</html>
