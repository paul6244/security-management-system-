
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login</title>
        <link rel="stylesheet" type="text/css" href="css/form.css">
        <style>
            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .container {
                width: 350px;
                margin: 0;
                padding: 30px;
                background: rgba(255, 255, 255, 0.95);
                border-radius: 15px;
                box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255, 255, 255, 0.2);
            }
            h1 {
                text-align: center;
                margin-bottom: 30px;
                color: #2c3e50;
                font-size: 28px;
                font-weight: 600;
            }
            label {
                display: block;
                margin-bottom: 8px;
                color: #34495e;
                font-weight: 500;
            }
            input[type="text"],
            input[type="password"] {
                width: 100%;
                padding: 12px;
                margin-bottom: 20px;
                border: 2px solid #e1e8ed;
                border-radius: 8px;
                font-size: 14px;
                transition: border-color 0.3s ease;
                box-sizing: border-box;
            }
            input[type="text"]:focus,
            input[type="password"]:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }
            input[type="submit"] {
                width: 100%;
                padding: 12px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            input[type="submit"]:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
            }
            .signup-link {
                text-align: center;
                margin-top: 20px;
                color: #7f8c8d;
            }
            .signup-link a {
                color: #667eea;
                text-decoration: none;
                font-weight: 500;
            }
            .signup-link a:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body background="image/download.jpg">
        <div class="container">
        <h1>Log In</h1>
        <%-- Display error message --%>
        <%
        String error = (String) session.getAttribute("loginError");
        if(error != null){
        %>
        <p style="color:red;"><%= error %></p>
        <%
            session.removeAttribute("loginError");
        }
        %>
         <%-- Display success message --%>
        <%
        String success = (String) session.getAttribute("loginSuccess");
        if(success != null){
        %>
        <p style="color:rgb(9, 209, 42);"><%= success %></p>
        <%
            session.removeAttribute("loginSuccess");
        }
        %>  
        <form action="Login" method="post">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" autocomplete="username" required><br><br>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" autocomplete="current-password" required><br><br>
            <input type="submit" value="Login">
        </form>
        <p>Don't have an account? <a href="Signup.jsp">Register here</a></p>
        </div>
    </body>

</html>
