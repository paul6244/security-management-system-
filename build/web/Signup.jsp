<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sign Up</title>
<link rel="stylesheet" type="text/css" href="css/form.css">
</head>

<body background="image/download.jpg">
<div class="container">

<h1>Sign Up</h1>

<%-- Display error message --%>
<%
String error = (String) session.getAttribute("signupError");
if(error != null){
%>
<p style="color:red;"><%= error %></p>
<%
    session.removeAttribute("signupError");
}
%>

<%-- Display success message --%>
<%
String success = (String) session.getAttribute("signupSuccess");
if(success != null){
%>
<p style="color:rgb(9, 209, 42);"><%= success %></p>
<%
    session.removeAttribute("signupSuccess");
}
%>

<form action="Signup" method="post">
    <label for="username">Username:</label>
    <input type="text" id="username" name="username" autocomplete="username" required>

    <label for="email">Email:</label>
    <input type="email" id="email" name="email" autocomplete="email" required>

    <label for="role">Role:</label>
    <select id="role" name="role" autocomplete="organization-title" required>
        <option value="">Select Role</option>
        <option value="security_officer">Security Officer</option>
        <option value="admin">Admin</option>
    </select>

    <div id="securityFields" style="display:none; margin-top:10px;">
        <label for="branch_id">Branch:</label>
      <select id="branch_id" name="branch_id" autocomplete="organization">
    <option value="">Select Branch</option>

         <%
             ResultSet rsBranches = Mymodel.getBranches();
             while(rsBranches != null && rsBranches.next()){
        %>
            <option value="<%= rsBranches.getInt("id") %>">
                 <%= rsBranches.getString("name") %>
            </option>
        <%
        }
            if(rsBranches != null) rsBranches.close();
        %>
    </select>

        <label for="shift_time" id="shift_label">Shift Time:</label>
        <input type="text" id="shift_time" name="shift_time" autocomplete="organization" placeholder="Enter shift time">
    </div>

    <label for="password">Password:</label>
    <input type="password" id="password" name="password" autocomplete="new-password" required>

    <label for="confirm_password">Confirm Password:</label>
    <input type="password" id="confirm_password" name="confirmPassword" autocomplete="new-password" required>

    <input type="submit" value="Signup">
    <input type="reset" value="Clear">
</form>

<p>Already have an account? <a href="index.jsp">Login here</a></p>

</div>

<script>
// Toggle Security Officer fields & dynamically require branch/shift
const roleSelect = document.getElementById("role");
const securityDiv = document.getElementById("securityFields");
const branchSelect = document.getElementById("branch_id");
const shiftInput = document.getElementById("shift_time");

roleSelect.addEventListener("change", function() {
    if(this.value === "security_officer") {
        securityDiv.style.display = "block";
        branchSelect.setAttribute("required", "required");
        shiftInput.setAttribute("required", "required");
    } else {
        securityDiv.style.display = "none";
        branchSelect.removeAttribute("required");
        shiftInput.removeAttribute("required");
    }
});
</script>

</body>
</html>