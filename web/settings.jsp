<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - Security Management System</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        .settings-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .settings-section {
            background: white;
            padding: 25px;
            margin-bottom: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .settings-section h3 {
            color: #2c3e50;
            margin-bottom: 20px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .form-group textarea {
            height: 80px;
            resize: vertical;
        }
        .btn {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
        }
        .btn:hover {
            background: #2980b9;
        }
        .btn-danger {
            background: #e74c3c;
        }
        .btn-danger:hover {
            background: #c0392b;
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
        .user-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .user-info p {
            margin: 5px 0;
            color: #666;
        }
    </style>
</head>
<body>

<div class="container">
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="logo">Security System</div>
        <div class="nav">
            <a href="admin.jsp">Dashboard</a>
            <a href="userManagement.jsp">Users</a>
            <a href="reports.jsp">Reports</a>
            <a href="#" class="active">Settings</a>
        </div>
        <div class="logout">
            <a href="Logout">Logout</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="header">
            <div>
                <h1>Settings</h1>
                <p>Manage your account and system settings</p>
            </div>
        </div>

        <div class="settings-container">
            <!-- Display Messages -->
            <% 
            String success = (String) session.getAttribute("settingsSuccess");
            String error = (String) session.getAttribute("settingsError");
            
            if(success != null){
            %>
                <div class="success-msg"><%= success %></div>
            <%
                session.removeAttribute("settingsSuccess");
            }
            
            if(error != null){
            %>
                <div class="error-msg"><%= error %></div>
            <%
                session.removeAttribute("settingsError");
            }
            %>

            <!-- User Information Section -->
            <div class="settings-section">
                <h3>User Information</h3>
                <div class="user-info">
                    <p><strong>Username:</strong> <%= session.getAttribute("username") %></p>
                    <p><strong>Role:</strong> <%= session.getAttribute("role") %></p>
                    <p><strong>Account Status:</strong> <span style="color: #27ae60;">Active</span></p>
                </div>
            </div>

            <!-- Change Password Section -->
            <div class="settings-section">
                <h3>Change Password</h3>
                <form action="UpdatePassword" method="post">
                    <div class="form-group">
                        <label for="currentPassword">Current Password:</label>
                        <input type="password" id="currentPassword" name="currentPassword" required>
                    </div>
                    <div class="form-group">
                        <label for="newPassword">New Password:</label>
                        <input type="password" id="newPassword" name="newPassword" required minlength="6">
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password:</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required>
                    </div>
                    <button type="submit" class="btn">Update Password</button>
                </form>
            </div>

            <!-- System Settings Section (Admin Only) -->
            <% 
            String role = (String) session.getAttribute("role");
            if("admin".equals(role)){
            %>
            <div class="settings-section">
                <h3>System Settings</h3>
                <form action="UpdateSystemSettings" method="post">
                    <div class="form-group">
                        <label for="systemName">System Name:</label>
                        <input type="text" id="systemName" name="systemName" value="Security Management System">
                    </div>
                    <div class="form-group">
                        <label for="sessionTimeout">Session Timeout (minutes):</label>
                        <input type="number" id="sessionTimeout" name="sessionTimeout" value="30" min="5" max="240">
                    </div>
                    <div class="form-group">
                        <label for="maxLoginAttempts">Max Login Attempts:</label>
                        <input type="number" id="maxLoginAttempts" name="maxLoginAttempts" value="5" min="3" max="10">
                    </div>
                    <div class="form-group">
                        <label for="emailNotifications">Email Notifications:</label>
                        <select id="emailNotifications" name="emailNotifications">
                            <option value="enabled">Enabled</option>
                            <option value="disabled">Disabled</option>
                        </select>
                    </div>
                    <button type="submit" class="btn">Save System Settings</button>
                </form>
            </div>

            <!-- Database Backup Section (Admin Only) -->
            <div class="settings-section">
                <h3>Database Management</h3>
                <p>Create backup of the system database</p>
                <form action="BackupDatabase" method="post">
                    <button type="submit" class="btn">Create Database Backup</button>
                </form>
                
                <h4 style="margin-top: 20px; color: #e74c3c;">Danger Zone</h4>
                <p style="color: #666; font-size: 14px;">Reset all shift data and reports. This action cannot be undone.</p>
                <form action="ResetSystemData" method="post" onsubmit="return confirm('Are you sure you want to reset all system data? This cannot be undone.')">
                    <button type="submit" class="btn btn-danger">Reset System Data</button>
                </form>
            </div>
            <% 
            }
            %>

            <!-- About Section -->
            <div class="settings-section">
                <h3>About</h3>
                <p><strong>Security Management System</strong></p>
                <p>Version: 1.0.0</p>
                <p>A comprehensive security personnel management system for tracking shifts, reports, and incidents across multiple branches.</p>
                <p style="margin-top: 15px;">
                    <strong>Features:</strong><br>
                    • User authentication and role-based access<br>
                    • Shift management and tracking<br>
                    • Incident reporting and analytics<br>
                    • Real-time dashboard with charts<br>
                    • Multi-branch support
                </p>
            </div>
        </div>
    </div>
</div>

<script>
// Password confirmation validation
document.querySelector('form[action="UpdatePassword"]').addEventListener('submit', function(e) {
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    if(newPassword !== confirmPassword) {
        e.preventDefault();
        alert('New password and confirm password do not match!');
        return false;
    }
    
    if(newPassword.length < 6) {
        e.preventDefault();
        alert('Password must be at least 6 characters long!');
        return false;
    }
});

// System settings validation
document.querySelector('form[action="UpdateSystemSettings"]').addEventListener('submit', function(e) {
    const sessionTimeout = document.getElementById('sessionTimeout').value;
    const maxAttempts = document.getElementById('maxLoginAttempts').value;
    
    if(sessionTimeout < 5 || sessionTimeout > 240) {
        e.preventDefault();
        alert('Session timeout must be between 5 and 240 minutes!');
        return false;
    }
    
    if(maxAttempts < 3 || maxAttempts > 10) {
        e.preventDefault();
        alert('Max login attempts must be between 3 and 10!');
        return false;
    }
});
</script>

</body>
</html>
