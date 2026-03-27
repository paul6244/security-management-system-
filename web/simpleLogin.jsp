<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Simple Login</title>
<style>
    body { 
        font-family: Arial, sans-serif; 
        margin: 0; 
        padding: 20px; 
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .container { 
        max-width: 400px; 
        margin: 0 auto; 
        background: white; 
        padding: 40px; 
        border-radius: 10px; 
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
    }
    h1 { 
        color: #333; 
        text-align: center; 
        margin-bottom: 30px;
        font-size: 28px;
    }
    .form-group { 
        margin-bottom: 20px; 
    }
    label { 
        display: block; 
        margin-bottom: 8px; 
        font-weight: bold; 
        color: #555;
    }
    input { 
        width: 100%; 
        padding: 15px; 
        border: 2px solid #ddd; 
        border-radius: 8px; 
        box-sizing: border-box; 
        font-size: 16px;
        transition: border-color 0.3s;
    }
    input:focus {
        outline: none;
        border-color: #667eea;
    }
    input[type="submit"] { 
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; 
        padding: 15px; 
        border: none; 
        border-radius: 8px; 
        cursor: pointer; 
        font-size: 18px;
        font-weight: bold;
        margin-top: 10px;
        transition: transform 0.2s;
    }
    input[type="submit"]:hover { 
        transform: translateY(-2px);
    }
    .error { 
        color: #e74c3c; 
        margin-bottom: 15px; 
        text-align: center; 
        padding: 10px;
        background: #fdf2f2;
        border-radius: 5px;
        border: 1px solid #e74c3c;
    }
    .success { 
        color: #27ae60; 
        margin-bottom: 15px; 
        text-align: center; 
        padding: 10px;
        background: #f2fdf5;
        border-radius: 5px;
        border: 1px solid #27ae60;
    }
    .back-link { 
        text-align: center; 
        margin-top: 20px; 
    }
    .back-link a { 
        color: #667eea; 
        text-decoration: none; 
        font-weight: bold;
    }
    .back-link a:hover { 
        text-decoration: underline; 
    }
    .links {
        text-align: center;
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px solid #eee;
    }
    .links a {
        display: block;
        margin: 10px 0;
        color: #667eea;
        text-decoration: none;
    }
    .links a:hover {
        text-decoration: underline;
    }
</style>
</head>

<body>
    <div class="container">
        <h1>Simple Login</h1>
        
        <%-- Display error message --%>
        <%
        String error = (String) session.getAttribute("loginError");
        if(error != null){
        %>
        <p class="error"><%= error %></p>
        <%
            session.removeAttribute("loginError");
        }
        %>

        <%-- Display success message --%>
        <%
        String success = (String) session.getAttribute("loginSuccess");
        if(success != null){
        %>
        <p class="success"><%= success %></p>
        <%
            session.removeAttribute("loginSuccess");
        }
        %>  

        <form action="SimpleLogin" method="post">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" autocomplete="username" required>
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" autocomplete="current-password" required>
            </div>

            <div class="form-group">
                <input type="submit" value="Login">
            </div>
        </form>

        <div class="links">
            <a href="simpleSignup.jsp">Don't have an account? Sign up here</a>
            <a href="index.jsp">← Back to Original Login</a>
            <a href="debugLoginTest.jsp">Debug Login Test</a>
        </div>
    </div>
</body>
</html>
