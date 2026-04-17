<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login</title>
        <link rel="stylesheet" type="text/css" href="css/form.css">
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
        <a href="personnelDashboard.jsp">Dashboard</a>
        <a href="staffRegistrationIntegrated.jsp">Attendance</a>
        <a href="viewAttendance.jsp">QR Code</a>
        <a href="staffRegistration.jsp">Staff Registration</a>
        </div>
    </body>

</html>
