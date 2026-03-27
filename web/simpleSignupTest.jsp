<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Simple Signup Test</title>
<style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .form-group { margin-bottom: 15px; }
    label { display: block; margin-bottom: 5px; font-weight: bold; }
    input, select { width: 300px; padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
    input[type="submit"] { background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
    input[type="submit"]:hover { background-color: #0056b3; }
</style>
</head>

<body>
    <h1>Simple Signup Test</h1>
    <p>This is a debug version of signup to identify the exact issue.</p>
    
    <form action="SimpleSignup" method="post">
        <div class="form-group">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" required>
        </div>
        
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
        </div>
        
        <div class="form-group">
            <label for="role">Role:</label>
            <select id="role" name="role" required>
                <option value="">Select Role</option>
                <option value="admin">Admin</option>
                <option value="security_officer">Security Officer</option>
            </select>
        </div>
        
        <div class="form-group">
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
        </div>
        
        <div class="form-group">
            <input type="submit" value="Test Signup">
        </div>
    </form>
    
    <p><a href="Signup.jsp">← Back to Original Signup</a></p>
</body>
</html>
