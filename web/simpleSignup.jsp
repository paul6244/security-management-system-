<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Simple Signup (No DB)</title>
<style>
    body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
    .container { 
        max-width: 400px; 
        margin: 0 auto; 
        background: white; 
        padding: 40px; 
        border-radius: 10px; 
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        width: 90%;
    }
    h1 { 
        color: #333; 
        text-align: center; 
        margin-bottom: 30px;
        font-size: 24px;
    }
    .form-group { 
        margin-bottom: 20px; 
    }
    label { 
        display: block; 
        margin-bottom: 8px; 
        font-weight: bold; 
        color: #555;
        font-size: 14px;
    }
    input, select { 
        width: 100%; 
        padding: 15px; 
        border: 2px solid #ddd; 
        border-radius: 8px; 
        box-sizing: border-box; 
        font-size: 16px;
        min-height: 44px;
    }
    input:focus, select:focus {
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
        min-height: 44px;
        min-width: 44px;
    }
    input[type="submit"]:hover { 
        transform: translateY(-2px);
    }
    .success { 
        color: #27ae60; 
        margin-bottom: 15px; 
        text-align: center; 
        padding: 10px;
        background: #f2fdf5;
        border-radius: 5px;
        border: 1px solid #27ae60;
        font-size: 14px;
    }
    .back-link { 
        text-align: center; 
        margin-top: 20px; 
    }
    .back-link a { 
        color: #667eea; 
        text-decoration: none; 
        font-weight: bold;
        font-size: 14px;
    }
    .back-link a:hover { 
        text-decoration: underline; 
    }
    
    /* Mobile Responsive Design */
    @media (max-width: 768px) {
        .container {
            width: 95%;
            padding: 30px;
            margin: 10px auto;
        }
        
        h1 {
            font-size: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        label {
            font-size: 16px;
            margin-bottom: 6px;
        }
        
        input, select {
            font-size: 16px;
            padding: 12px;
        }
        
        input[type="submit"] {
            width: 100%;
            padding: 18px;
            font-size: 16px;
            margin-top: 15px;
        }
        
        .success {
            font-size: 16px;
            padding: 12px;
            margin-bottom: 10px;
        }
        
        .back-link {
            margin-top: 15px;
        }
        
        .back-link a {
            font-size: 16px;
        }
    }
    
    @media (max-width: 480px) {
        .container {
            width: 98%;
            padding: 20px;
            margin: 5px auto;
        }
        
        h1 {
            font-size: 18px;
            margin-bottom: 15px;
        }
        
        .form-group {
            margin-bottom: 12px;
        }
        
        label {
            font-size: 14px;
            margin-bottom: 5px;
        }
        
        input, select {
            font-size: 16px;
            padding: 12px;
        }
        
        input[type="submit"] {
            padding: 15px;
            font-size: 14px;
            margin-top: 10px;
        }
        
        .success {
            font-size: 14px;
            padding: 10px;
            margin-bottom: 8px;
        }
        
        .back-link a {
            font-size: 14px;
        }
    }
    
    /* Touch-friendly improvements */
    @media (hover: none) and (pointer: coarse) {
        input, select {
            min-height: 44px;
        }
        
        input[type="submit"] {
            min-height: 44px;
            min-width: 44px;
        }
        
        .back-link a {
            min-height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
    }
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
