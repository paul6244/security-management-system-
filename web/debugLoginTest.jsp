<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Debug Login Test</title>
<style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .form-group { margin-bottom: 15px; }
    label { display: block; margin-bottom: 5px; font-weight: bold; }
    input { width: 300px; padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
    input[type="submit"] { background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
    input[type="submit"]:hover { background-color: #0056b3; }
</style>
</head>

<body>
    <h1>Debug Login Test</h1>
    <p>This will show exactly what happens during login.</p>
    
    <form action="DebugLogin" method="post">
        <div class="form-group">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" required>
        </div>
        
        <div class="form-group">
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
        </div>
        
        <div class="form-group">
            <input type="submit" value="Debug Login">
        </div>
    </form>
    
    <p><a href="index.jsp">← Back to Original Login</a></p>
</body>
</html>
