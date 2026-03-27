<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Simple Signup (No DB)</title>
<style>
    body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
    .container { max-width: 500px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    h1 { color: #333; text-align: center; margin-bottom: 30px; }
    .form-group { margin-bottom: 20px; }
    label { display: block; margin-bottom: 8px; font-weight: bold; color: #555; }
    input, select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; font-size: 14px; }
    input[type="submit"] { background-color: #007bff; color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%; }
    input[type="submit"]:hover { background-color: #0056b3; }
    input[type="reset"] { background-color: #6c757d; color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%; margin-top: 10px; }
    .error { color: red; margin-bottom: 15px; text-align: center; }
    .success { color: green; margin-bottom: 15px; text-align: center; }
    .back-link { text-align: center; margin-top: 20px; }
    .back-link a { color: #007bff; text-decoration: none; }
    .back-link a:hover { text-decoration: underline; }
</style>
</head>

<body>
    <div class="container">
        <h1>Simple Signup</h1>
        
        <%-- Display error message --%>
        <%
        String error = (String) session.getAttribute("signupError");
        if(error != null){
        %>
        <p class="error"><%= error %></p>
        <%
            session.removeAttribute("signupError");
        }
        %>

        <%-- Display success message --%>
        <%
        String success = (String) session.getAttribute("signupSuccess");
        if(success != null){
        %>
        <p class="success"><%= success %></p>
        <%
            session.removeAttribute("signupSuccess");
        }
        %>

        <form action="Signup" method="post">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" autocomplete="username" required>
            </div>

            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" autocomplete="email" required>
            </div>

            <div class="form-group">
                <label for="role">Role:</label>
                <select id="role" name="role" autocomplete="organization-title" required>
                    <option value="">Select Role</option>
                    <option value="security_officer">Security Officer</option>
                    <option value="admin">Admin</option>
                </select>
            </div>

            <div class="form-group">
                <label for="branch_id">Branch:</label>
                <select id="branch_id" name="branch_id" autocomplete="organization">
                    <option value="">Select Branch</option>
                    <option value="1">Main Branch</option>
                    <option value="2">North Branch</option>
                    <option value="3">South Branch</option>
                    <option value="4">East Branch</option>
                    <option value="5">West Branch</option>
                </select>
            </div>

            <div class="form-group">
                <label for="shift_time">Shift Time:</label>
                <input type="text" id="shift_time" name="shift_time" autocomplete="organization" placeholder="Enter shift time (e.g., Morning, Afternoon, Night)">
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" autocomplete="new-password" required>
            </div>

            <div class="form-group">
                <label for="confirm_password">Confirm Password:</label>
                <input type="password" id="confirm_password" name="confirmPassword" autocomplete="new-password" required>
            </div>

            <div class="form-group">
                <input type="submit" value="Sign Up">
            </div>

            <div class="form-group">
                <input type="reset" value="Clear Form">
            </div>
        </form>

        <div class="back-link">
            <p>Already have an account? <a href="index.jsp">Login here</a></p>
        </div>
    </div>

    <script>
    // Toggle Security Officer fields
    const roleSelect = document.getElementById("role");
    const branchSelect = document.getElementById("branch_id");
    const shiftInput = document.getElementById("shift_time");

    roleSelect.addEventListener("change", function() {
        if(this.value === "security_officer") {
            branchSelect.setAttribute("required", "required");
            shiftInput.setAttribute("required", "required");
        } else {
            branchSelect.removeAttribute("required");
            shiftInput.removeAttribute("required");
        }
    });
    </script>
</body>
</html>
