<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Login Credentials</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border: 1px solid #ddd; border-collapse: collapse; width: 100%; }
        th, td { padding: 12px; text-align: left; border: 1px solid #ddd; }
        th { background-color: #f2f2f2; font-weight: bold; }
        .correct { color: green; font-weight: bold; }
        .test-link { padding: 5px 10px; background: #007bff; color: white; text-decoration: none; border-radius: 3px; }
        .test-link:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>🔑 Login Credentials Cheat Sheet</h1>
    <p><strong>Use these EXACT credentials to login:</strong></p>
    
    <table>
        <tr>
            <th>Username</th>
            <th>Password</th>
            <th>Role</th>
            <th>Test Login</th>
        </tr>
        <tr>
            <td><strong>Pg123</strong></td>
            <td><span class="correct">admin123</span></td>
            <td>Admin</td>
            <td><a href="testLogin.jsp?username=Pg123&password=admin123" class="test-link" target="_blank">Test Login</a></td>
        </tr>
        <tr>
            <td><strong>PK</strong></td>
            <td><span class="correct">PK123</span></td>
            <td>Security Officer</td>
            <td><a href="testLogin.jsp?username=PK&password=PK123" class="test-link" target="_blank">Test Login</a></td>
        </tr>
        <tr>
            <td><strong>ok</strong></td>
            <td><span class="correct">ok123</span></td>
            <td>Security Officer</td>
            <td><a href="testLogin.jsp?username=ok&password=ok123" class="test-link" target="_blank">Test Login</a></td>
        </tr>
        <tr>
            <td><strong>Banard</strong></td>
            <td><span class="correct">Banard123</span></td>
            <td>Security Officer</td>
            <td><a href="testLogin.jsp?username=Banard&password=Banard123" class="test-link" target="_blank">Test Login</a></td>
        </tr>
        <tr>
            <td><strong>kumii2010</strong></td>
            <td><span class="correct">kumii123</span></td>
            <td>Security Officer</td>
            <td><a href="testLogin.jsp?username=kumii2010&password=kumii123" class="test-link" target="_blank">Test Login</a></td>
        </tr>
    </table>
    
    <br><br>
    <h3>🚀 Quick Links:</h3>
    <p><a href="index.jsp">🏠 Main Login Page</a></p>
    <p><a href="testUsers.jsp">👥 Test Users Database</a></p>
    <p><a href="personnelDashboard.jsp">🎛 Personnel Dashboard</a></p>
    <p><a href="admin.jsp">⚙️ Admin Dashboard</a></p>
    
</body>
</html>
