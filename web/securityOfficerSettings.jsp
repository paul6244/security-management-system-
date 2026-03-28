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
        
        /* Tab Navigation */
        .tab-nav {
            display: flex;
            border-bottom: 2px solid #e0e0e0;
            margin-bottom: 20px;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }
        
        .tab-btn {
            background: none;
            border: none;
            padding: 12px 20px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            color: #666;
            border-bottom: 3px solid transparent;
            transition: all 0.3s ease;
            white-space: nowrap;
            min-width: 120px;
        }
        
        .tab-btn.active {
            color: #3498db;
            border-bottom-color: #3498db;
        }
        
        .tab-btn:hover {
            background: #f8f9fa;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        /* User Info Section */
        .user-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            border-left: 4px solid #3498db;
        }
        
        .user-info h4 {
            margin: 0 0 15px 0;
            color: #2c3e50;
            font-size: 16px;
        }
        
        .user-info p {
            margin: 5px 0;
            color: #555;
            font-size: 14px;
        }
        
        .user-info strong {
            color: #2c3e50;
        }
        
        /* Two-column layout for forms */
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 15px;
        }
        
        .form-col {
            flex: 1;
            min-width: 0;
        }
        
        /* Success/Error Messages */
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #c3e6cb;
            font-size: 14px;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
            font-size: 14px;
        }
        
        .success-msg {
            color: #27ae60;
            padding: 10px;
            background: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 5px;
            margin-bottom: 15px;
        }
        
        .error-msg {
            color: #e74c3c;
            padding: 10px;
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 5px;
            margin-bottom: 15px;
        }
        
        /* Mobile Responsive Design */
        @media (max-width: 768px) {
            .settings-container {
                padding: 10px;
            }
            
            .settings-section {
                padding: 15px;
                margin-bottom: 15px;
            }
            
            .form-row {
                flex-direction: column;
                gap: 0;
            }
            
            .tab-nav {
                flex-wrap: wrap;
                gap: 5px;
            }
            
            .tab-btn {
                flex: 1;
                min-width: 100px;
                padding: 10px 15px;
                font-size: 13px;
            }
            
            .btn {
                width: 100%;
                margin-right: 0;
                padding: 15px;
                font-size: 16px;
            }
            
            .user-info {
                padding: 15px;
            }
            
            .form-group input, .form-group select, .form-group textarea {
                font-size: 16px; /* Prevents zoom on iOS */
            }
        }
        
        @media (max-width: 480px) {
            .settings-container {
                padding: 5px;
            }
            
            .settings-section {
                padding: 10px;
            }
            
            .settings-section h3 {
                font-size: 16px;
            }
            
            .tab-btn {
                font-size: 12px;
                padding: 8px 12px;
                min-width: 80px;
            }
            
            .user-info h4 {
                font-size: 14px;
            }
            
            .user-info p {
                font-size: 13px;
            }
        }
        
        /* Touch-friendly improvements */
        @media (hover: none) and (pointer: coarse) {
            .btn, .tab-btn {
                min-height: 44px;
                min-width: 44px;
            }
            
            .form-group input, .form-group select, .form-group textarea {
                min-height: 44px;
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
            <a href="reports.jsp">Reports</a>
            <a href="securityOfficerSettings.jsp" class="active">Settings</a>
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
                <a href="Logout">Logout</a>
            </div>
        </div>

        <!-- USER INFORMATION -->
        <div class="user-info">
            <h3>User Information</h3>
            <p><strong>Username:</strong> <%= username %></p>
            <p><strong>Role:</strong> <%= userRole %></p>
            <p><strong>Account Status:</strong> <%= userStatus %></p>
            <% if(!userEmail.isEmpty()) { %>
            <p><strong>Email:</strong> <%= userEmail %></p>
            <% } %>
        </div>

        <!-- SETTINGS TABS -->
        <div class="tabs">
            <div class="tab active" onclick="showTab('user-settings')">User Settings</div>
            <div class="tab" onclick="showTab('system-settings')">System Settings</div>
        </div>

        <!-- USER SETTINGS TAB -->
        <div id="user-settings" class="tab-content active">
            <div class="settings-section">
                <h3>Change Password</h3>
                <form action="UpdateSecuritySettings" method="post">
                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                    
                    <div class="form-group">
                        <label for="currentPassword">Current Password</label>
                        <input type="password" id="currentPassword" name="currentPassword" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="newPassword">New Password</label>
                        <input type="password" id="newPassword" name="newPassword">
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <input type="password" id="confirmPassword" name="confirmPassword">
                    </div>
                    
                    <button type="submit" class="btn">Update Password</button>
                </form>
            </div>

            <div class="settings-section">
                <h3>Profile Information</h3>
                <form action="UpdateSecurityOfficerSettings" method="post">
                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                    
                    <div class="two-column">
                        <div>
                            <div class="form-group">
                                <label for="fullName">Full Name</label>
                                <input type="text" id="fullName" name="fullName" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email Address</label>
                                <input type="email" id="email" name="email" required>
                            </div>
                        </div>
                        
                        <div>
                            <div class="form-group">
                                <label for="phone">Phone Number</label>
                                <input type="tel" id="phone" name="phone" placeholder="+1234567890">
                            </div>
                            
                            <div class="form-group">
                                <label for="emergencyContact">Emergency Contact</label>
                                <input type="text" id="emergencyContact" name="emergencyContact" placeholder="Emergency contact name and number">
                            </div>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn">Save Profile</button>
                </form>
            </div>
        </div>

        <!-- SYSTEM SETTINGS TAB -->
        <div id="system-settings" class="tab-content">
            <div class="settings-section">
                <h3>System Settings</h3>
                <form action="UpdateSystemSettings" method="post">
                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                    
                    <div class="form-group">
                        <label for="systemName">System Name</label>
                        <input type="text" id="systemName" name="systemName" value="Security Management System" required>
                    </div>
                    
                    <div class="two-column">
                        <div>
                            <div class="form-group">
                                <label for="sessionTimeout">Session Timeout (minutes)</label>
                                <input type="number" id="sessionTimeout" name="sessionTimeout" value="30" min="5" max="120" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="maxLoginAttempts">Max Login Attempts</label>
                                <input type="number" id="maxLoginAttempts" name="maxLoginAttempts" value="5" min="3" max="10" required>
                            </div>
                        </div>
                        
                        <div>
                            <div class="form-group">
                                <label for="emailNotifications">
                                    <input type="checkbox" name="emailNotifications" checked> Email Notifications
                                </label>
                            </div>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn">Save System Settings</button>
                </form>
            </div>
        </div>

        <!-- SUCCESS/ERROR MESSAGES -->
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            String message = request.getParameter("message");
        %>
        
        <% if(successMsg != null) { %>
            <div class="success-msg">
                <strong>✅ Success:</strong> <%= message %>
            </div>
        <% } %>
        
        <% if(errorMsg != null) { %>
            <div class="error-msg">
                <strong>❌ Error:</strong> <%= message %>
            </div>
        <% } %>
    </div>
</div>

<script>
function showTab(tabName) {
    // Hide all tab contents
    const tabContents = document.querySelectorAll('.tab-content');
    tabContents.forEach(content => content.classList.remove('active'));
    
    // Remove active class from all tabs
    const tabs = document.querySelectorAll('.tab');
    tabs.forEach(tab => tab.classList.remove('active'));
    
    // Show selected tab content
    document.getElementById(tabName).classList.add('active');
    
    // Add active class to clicked tab
    event.target.classList.add('active');
}
</script>

</body>
</html>
