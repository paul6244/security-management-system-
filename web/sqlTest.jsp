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
    <title>SQL Test - Security Management System</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .success { color: #155724; background: #d4edda; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { color: #721c24; background: #f8d7da; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .sql-test { background: #e9ecef; padding: 15px; margin: 10px 0; border-radius: 4px; font-family: monospace; }
        .result { margin: 10px 0; }
    </style>
</head>
<body>

<h1>SQL Function Test</h1>

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
                <p>Connected to database successfully</p>
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
    }
    %>
</div>

<div class="test-section">
    <h2>MySQL Function Tests</h2>
    
    <div class="sql-test">
        <h3>Test 1: CURDATE() Function</h3>
        <%
        try {
            if(con != null) {
                String testSql = "SELECT CURDATE() as today_date";
                PreparedStatement testPs = con.prepareStatement(testSql);
                ResultSet testRs = testPs.executeQuery();
                
                if(testRs.next()) {
                    String today = testRs.getString("today_date");
        %>
                    <div class="result">
                        <strong>✅ CURDATE() works:</strong> <%= today %>
                    </div>
        <%
                }
                testRs.close();
                testPs.close();
            }
        } catch(Exception e) {
        %>
            <div class="error">
                <strong>❌ CURDATE() Error:</strong> <%= e.getMessage() %>
            </div>
        <%
        }
        %>
    </div>
    
    <div class="sql-test">
        <h3>Test 2: NOW() Function</h3>
        <%
        try {
            if(con != null) {
                String testSql = "SELECT NOW() as current_time";
                PreparedStatement testPs = con.prepareStatement(testSql);
                ResultSet testRs = testPs.executeQuery();
                
                if(testRs.next()) {
                    String now = testRs.getString("current_time");
        %>
                    <div class="result">
                        <strong>✅ NOW() works:</strong> <%= now %>
                    </div>
        <%
                }
                testRs.close();
                testPs.close();
            }
        } catch(Exception e) {
        %>
            <div class="error">
                <strong>❌ NOW() Error:</strong> <%= e.getMessage() %>
            </div>
        <%
        }
        %>
    </div>
    
    <div class="sql-test">
        <h3>Test 3: Simple Query</h3>
        <%
        try {
            if(con != null) {
                String testSql = "SELECT 'Hello World' as test_value";
                PreparedStatement testPs = con.prepareStatement(testSql);
                ResultSet testRs = testPs.executeQuery();
                
                if(testRs.next()) {
                    String testValue = testRs.getString("test_value");
        %>
                    <div class="result">
                        <strong>✅ Simple Query works:</strong> <%= testValue %>
                    </div>
        <%
                }
                testRs.close();
                testPs.close();
            }
        } catch(Exception e) {
        %>
            <div class="error">
                <strong>❌ Simple Query Error:</strong> <%= e.getMessage() %>
            </div>
        <%
        }
        %>
    </div>
    
    <%
    if(con != null) {
        try {
            con.close();
        } catch(Exception e) {
            // Ignore close errors
        }
    }
    }
    %>
</div>

<div class="test-section">
    <h2>Troubleshooting</h2>
    <p><strong>If SQL functions don't work:</strong></p>
    <ul>
        <li>Check if database is MySQL (not PostgreSQL or other)</li>
        <li>Verify database connection is working properly</li>
        <li>Check if user has proper database permissions</li>
        <li>Try replacing CURDATE() with NOW() or CURRENT_DATE</li>
        <li>Check database version compatibility</li>
    </ul>
</div>

</body>
</html>
