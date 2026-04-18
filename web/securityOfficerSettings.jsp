<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="config.DatabaseConfig" %>

<%
if(session.getAttribute("username") == null){
    response.sendRedirect("index.jsp");
}

String username = session.getAttribute("username") != null ? session.getAttribute("username").toString() : "";
String userRole = "security_officer";

// Generate CSRF token
String csrfToken = session.getId() + System.currentTimeMillis();
session.setAttribute("csrfToken", csrfToken);

// Get user information
String userEmail = "";
String userStatus = "Active";
try {
    Connection con = DatabaseConfig.getConnection();
    String userSql = "SELECT email, role FROM users WHERE username = ?";
    PreparedStatement userPs = con.prepareStatement(userSql);
    userPs.setString(1, username);
    ResultSet userRs = userPs.executeQuery();
    
    if(userRs.next()) {
        userEmail = userRs.getString("email");
        userRole = userRs.getString("role");
        userStatus = "Active";
    }
    
    userRs.close();
    userPs.close();
    con.close();
} catch(Exception e) {
    userStatus = "Error retrieving user info";
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - Security Management System</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        /* Mobile-First Responsive Design */
        .settings-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 15px;
        }
        
        .settings-section {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .settings-section h3 {
            color: #2c3e50;
            margin-bottom: 20px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
            font-size: 18px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
            font-size: 14px;
        }
        
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
        }
        
        .form-group textarea {
            height: 80px;
            resize: vertical;
        }
        
        .btn {
            background: #3498db;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
            margin-bottom: 10px;
            font-size: 14px;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        
        .btn:hover {
            background: #2980b9;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
        }
        
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
        }
        
        .profile-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        @media (max-width: 768px) {
            .settings-container {
                padding: 10px;
            }
            
            .settings-section {
                padding: 15px;
                margin-bottom: 15px;
            }
            
            .btn {
                width: 100%;
                margin-right: 0;
                padding: 15px;
                font-size: 16px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="logo">Security System</div>
        <div class="nav">
            <a href="personnelDashboard.jsp">Dashboard</a>
            <a href="attendance.jsp">Attendance</a>
            <a href="staffRegistration.jsp">Staff Registration</a>
            <a href="securityOfficerReports.jsp">Reports</a>
            <a href="securityOfficerSettings.jsp" class="active">Settings</a>
            <a href="Logout">Logout</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">

        <!-- HEADER -->
        <div class="header">
            <div>
                <h1>Settings</h1>
                <p>Manage your account and system settings</p>
            </div>
            <div class="logout">
                <span>Welcome, <%= username %></span>
                <a href="Logout" class="btn">Logout</a>
            </div>
        </div>

        <div class="settings-container">
            <!-- Success/Error Messages -->
            <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            String messageParam = request.getParameter("message");
            %>
            
            <% if(successMsg != null) { %>
                <div class="alert-success">
                    <strong>Success:</strong> <%= messageParam %>
                </div>
            <% } %>
            
            <% if(errorMsg != null) { %>
                <div class="alert-error">
                    <strong>Error:</strong> <%= messageParam %>
                </div>
            <% } %>

            <!-- HEADER -->
            <div class="settings-header">
                <h1>Security Officer Settings</h1>
                <p>Manage your personal account and preferences</p>
            </div>

            <%
            // Get personnel information
            ResultSet personnelInfo = null;
            Connection con = null;
            String personnelName = "";
            String personnelEmail = "";
            String personnelBranch = "";
            String personnelShift = "";
            int personnelId = 0;
            int personnelBranchId = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
                
                String personnelSql = "SELECT sp.*, b.name as branch_name, u.email as user_email FROM security_personnel sp " +
                                   "JOIN users u ON sp.user_id = u.id " +
                                   "LEFT JOIN branches b ON sp.branch_id = b.id " +
                                   "WHERE u.username = ?";
                PreparedStatement personnelPs = con.prepareStatement(personnelSql);
                personnelPs.setString(1, username);
                personnelInfo = personnelPs.executeQuery();
                
                // Store personnel data in variables
                if(personnelInfo != null && personnelInfo.next()) {
                    personnelName = personnelInfo.getString("name");
                    personnelEmail = personnelInfo.getString("user_email");
                    personnelBranch = personnelInfo.getString("branch_name");
                    personnelShift = personnelInfo.getString("shift_time");
                    personnelId = personnelInfo.getInt("id");
                    personnelBranchId = personnelInfo.getInt("branch_id");
                }
            } catch(Exception e) {
                e.printStackTrace();
            }
            %>

            <!-- PROFILE INFORMATION -->
            <div class="settings-section">
                <h2>Profile Information</h2>
                <% if(!personnelName.isEmpty()) { %>
                <div class="profile-info">
                    <strong>Name:</strong> <%= personnelName %><br>
                    <strong>Email:</strong> <%= personnelEmail %><br>
                    <strong>Branch:</strong> <%= personnelBranch %><br>
                    <strong>Shift Time:</strong> <%= personnelShift %><br>
                    <strong>Student ID:</strong> STU-<%= String.format("%04d", personnelId) %>
                </div>
                <% } else { %>
                <div class="profile-info">
                    <em>No personnel information found. Please contact administrator.</em>
                </div>
                <% } %>
            </div>

            <!-- PERSONAL SETTINGS -->
            <div class="settings-section">
                <h2>Personal Settings</h2>
                <form action="UpdateSecurityOfficerSettings" method="post">
                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" value="<%= personnelName %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" value="<%= personnelEmail %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" placeholder="+1234567890">
                    </div>
                    
                    <div class="form-group">
                        <label for="emergencyContact">Emergency Contact</label>
                        <input type="text" id="emergencyContact" name="emergencyContact" placeholder="Emergency contact name and number">
                    </div>
                    
                    <div class="form-group">
                        <label for="notifications">Email Notifications</label>
                        <select id="notifications" name="notifications">
                            <option value="all">All Notifications</option>
                            <option value="important">Important Only</option>
                            <option value="none">None</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn">Save Personal Settings</button>
                </form>
            </div>

            <!-- SECURITY SETTINGS -->
            <div class="settings-section">
                <h2>Security Settings</h2>
                <form action="UpdateSecuritySettings" method="post">
                    <div class="form-group">
                        <label for="currentPassword">Current Password</label>
                        <input type="password" id="currentPassword" name="currentPassword" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="newPassword">New Password</label>
                        <input type="password" id="newPassword" name="newPassword" placeholder="Leave blank to keep current">
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <input type="password" id="confirmPassword" name="confirmPassword">
                    </div>
                    
                    <button type="submit" class="btn">Update Password</button>
                </form>
            </div>

            <%
            if(personnelInfo != null) personnelInfo.close();
            if(con != null) con.close();
            %>
        </div>

    </div>
</div>

<script>
    // Form validation and user experience enhancements
    document.addEventListener('DOMContentLoaded', function() {
        // Password strength validation
        const newPassword = document.getElementById('newPassword');
        const confirmPassword = document.getElementById('confirmPassword');
        
        if(newPassword && confirmPassword) {
            confirmPassword.addEventListener('input', function() {
                if(this.value !== newPassword.value) {
                    this.setCustomValidity('Passwords do not match');
                } else {
                    this.setCustomValidity('');
                }
            });
        }
    });
</script>

</body>
</html>
