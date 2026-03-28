<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="config.DatabaseConfig" %>

<%
    if(session.getAttribute("username") == null){
        response.sendRedirect("index.jsp");
    }
    
    String username = session.getAttribute("username") != null ? session.getAttribute("username").toString() : "";
    
    // Simple role check - for security officers, we'll assume they have the right role
    // In a real app, you'd store the role in session during login
    String userRole = "security_officer"; // Simplified for now
%>

<!DOCTYPE html>
<html>
<head>
    <title>Security Officer Settings - Security System</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .settings-container {
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .settings-section {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .settings-header {
            background: #3498db;
            color: white;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #2c3e50;
        }
        
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .form-group textarea {
            height: 100px;
            resize: vertical;
        }
        
        .btn {
            background-color: #3498db;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .btn:hover {
            background-color: #2980b9;
        }
        
        .btn-danger {
            background-color: #e74c3c;
        }
        
        .btn-danger:hover {
            background-color: #c0392b;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        .profile-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .shift-info {
            background: #e8f5e8;
            color: #856404;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
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
            <a href="securityOfficerSettings.jsp" class="active">Settings</a>
            <a href="Logout">Logout</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="settings-container">
            <!-- Success/Error Messages -->
            <%
            String message = "";
            String messageType = "";
            String successParam = request.getParameter("success");
            String errorParam = request.getParameter("error");
            
            if(successParam != null && successParam.equals("1")) {
                message = request.getParameter("message");
                messageType = "success";
            } else if(errorParam != null && errorParam.equals("1")) {
                message = request.getParameter("message");
                messageType = "error";
            }
            
            if(!message.isEmpty()) {
            %>
            <div class="alert alert-<%= messageType %>" style="padding: 15px; margin-bottom: 20px; border-radius: 4px;">
                <%= message %>
            </div>
            <%
            }
            %>
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
                con = DatabaseConfig.getConnection();
                
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
                <% if(personnelName.isEmpty()) { %>
                <div class="profile-info">
                    <strong>Name:</strong> <%= personnelName %><br>
                    <strong>Email:</strong> <%= personnelEmail %><br>
                    <strong>Branch:</strong> <%= personnelBranch %><br>
                    <strong>Shift Time:</strong> <%= personnelShift %><br>
                    <strong>Employee ID:</strong> SEC-<%= String.format("%04d", personnelId) %>
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
                    
                    <div class="form-group">
                        <label for="twoFactor">Two-Factor Authentication</label>
                        <select id="twoFactor" name="twoFactor">
                            <option value="disabled">Disabled</option>
                            <option value="email">Email Based</option>
                            <option value="app">Authenticator App</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn">Update Security</button>
                </form>
            </div>

            <!-- SHIFT PREFERENCES -->
            <div class="settings-section">
                <h2>Shift Preferences</h2>
                <form action="UpdateShiftPreferences" method="post">
                    <div class="form-group">
                        <label for="preferredBranch">Preferred Branch</label>
                        <select id="preferredBranch" name="preferredBranch">
                            <% 
                            try {
                                Connection branchCon = DatabaseConfig.getConnection();
                                String branchSql = "SELECT id, name FROM branches";
                                PreparedStatement branchPs = branchCon.prepareStatement(branchSql);
                                ResultSet branches = branchPs.executeQuery();
                                
                                while(branches != null && branches.next()) {
                            %>
                            <option value="<%= branches.getInt("id") %>" <%= branches.getInt("id") == personnelBranchId ? "selected" : "" %>><%= branches.getString("name") %></option>
                            <% 
                                }
                                if(branches != null) branches.close();
                                if(branchPs != null) branchPs.close();
                                if(branchCon != null) branchCon.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="preferredShift">Preferred Shift Time</label>
                        <select id="preferredShift" name="preferredShift">
                            <option value="08:00-16:00" <%= "08:00-16:00".equals(personnelShift) ? "selected" : "" %>>Day Shift (8AM-4PM)</option>
                            <option value="16:00-00:00" <%= "16:00-00:00".equals(personnelShift) ? "selected" : "" %>>Evening Shift (4PM-12AM)</option>
                            <option value="00:00-08:00" <%= "00:00-08:00".equals(personnelShift) ? "selected" : "" %>>Night Shift (12AM-8AM)</option>
                            <option value="flexible">Flexible</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="autoCheckin">Automatic Check-in</label>
                        <select id="autoCheckin" name="autoCheckin">
                            <option value="enabled">Enabled</option>
                            <option value="disabled">Disabled</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn">Save Shift Preferences</button>
                </form>
            </div>

            <!-- NOTIFICATION SETTINGS -->
            <div class="settings-section">
                <h2>Notification Settings</h2>
                <form action="UpdateNotificationSettings" method="post">
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="emailAlerts" checked> Email Alerts for Incidents
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="shiftReminders" checked> Shift Start/End Reminders
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="reportUpdates" checked> Daily Report Summary
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="systemUpdates"> System Maintenance Updates
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label for="reportFrequency">Report Frequency</label>
                        <select id="reportFrequency" name="reportFrequency">
                            <option value="daily">Daily</option>
                            <option value="weekly">Weekly</option>
                            <option value="monthly">Monthly</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn">Save Notification Settings</button>
                </form>
            </div>

            <!-- DASHBOARD SETTINGS -->
            <div class="settings-section">
                <h2>Dashboard Preferences</h2>
                <form action="UpdateDashboardSettings" method="post">
                    <div class="form-group">
                        <label for="dashboardTheme">Dashboard Theme</label>
                        <select id="dashboardTheme" name="dashboardTheme">
                            <option value="default">Default Blue</option>
                            <option value="dark">Dark Mode</option>
                            <option value="light">Light Mode</option>
                            <option value="high-contrast">High Contrast</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="refreshRate">Auto Refresh Rate</label>
                        <select id="refreshRate" name="refreshRate">
                            <option value="30">30 seconds</option>
                            <option value="60">1 minute</option>
                            <option value="300">5 minutes</option>
                            <option value="disabled">Disabled</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="showCharts" checked> Show Charts on Dashboard
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="checkbox" name="showNotifications" checked> Show Real-time Notifications
                        </label>
                    </div>
                    
                    <button type="submit" class="btn">Save Dashboard Settings</button>
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
            newPassword.addEventListener('input', function() {
                const strength = checkPasswordStrength(this.value);
                updatePasswordStrength(strength);
            });
            
            confirmPassword.addEventListener('input', function() {
                if(this.value !== newPassword.value) {
                    this.setCustomValidity('Passwords do not match');
                } else {
                    this.setCustomValidity('');
                }
            });
        }
        
        // Auto-save functionality
        let autoSaveTimer;
        const inputs = document.querySelectorAll('input, select, textarea');
        
        inputs.forEach(input => {
            input.addEventListener('change', function() {
                clearTimeout(autoSaveTimer);
                autoSaveTimer = setTimeout(() => {
                    // Auto-save draft settings
                    console.log('Auto-saving settings...');
                }, 2000);
            });
        });
        
        // Settings tabs for better organization
        createSettingsTabs();
    });
    
    function checkPasswordStrength(password) {
        let strength = 0;
        if(password.length >= 8) strength++;
        if(password.match(/[a-z]+/)) strength++;
        if(password.match(/[A-Z]+/)) strength++;
        if(password.match(/[0-9]+/)) strength++;
        if(password.match(/[^a-zA-Z0-9]+/)) strength++;
        return strength;
    }
    
    function updatePasswordStrength(strength) {
        const strengthIndicator = document.createElement('div');
        strengthIndicator.style.marginTop = '5px';
        strengthIndicator.style.fontSize = '12px';
        
        if(strength < 2) {
            strengthIndicator.textContent = 'Weak password';
            strengthIndicator.style.color = '#e74c3c';
        } else if(strength < 4) {
            strengthIndicator.textContent = 'Medium strength';
            strengthIndicator.style.color = '#f39c12';
        } else {
            strengthIndicator.textContent = 'Strong password';
            strengthIndicator.style.color = '#27ae60';
        }
        
        const newPassword = document.getElementById('newPassword');
        if(newPassword && newPassword.parentNode) {
            newPassword.parentNode.appendChild(strengthIndicator);
        }
    }
    
    function createSettingsTabs() {
        const sections = document.querySelectorAll('.settings-section');
        const tabContainer = document.createElement('div');
        tabContainer.style.marginBottom = '20px';
        tabContainer.style.textAlign = 'center';
        
        const tabs = ['Profile', 'Security', 'Shift', 'Notifications', 'Dashboard'];
        tabs.forEach((tab, index) => {
            const button = document.createElement('button');
            button.textContent = tab;
            button.style.margin = '0 5px';
            button.style.padding = '8px 16px';
            button.style.border = '1px solid #ddd';
            button.style.background = '#f8f9fa';
            button.style.cursor = 'pointer';
            
            button.addEventListener('click', () => {
                sections.forEach(section => section.style.display = 'none');
                sections[index].style.display = 'block';
                
                // Update button styles
                tabContainer.querySelectorAll('button').forEach(btn => {
                    btn.style.background = '#f8f9fa';
                    btn.style.color = '#333';
                });
                button.style.background = '#3498db';
                button.style.color = 'white';
            });
            
            tabContainer.appendChild(button);
        });
        
        // Insert tabs before first section
        const firstSection = document.querySelector('.settings-section');
        if(firstSection) {
            firstSection.parentNode.insertBefore(tabContainer, firstSection);
        }
        
        // Show first tab by default
        sections.forEach(section => section.style.display = 'none');
        if(sections[0]) sections[0].style.display = 'block';
        if(tabContainer.children[0]) {
            tabContainer.children[0].style.background = '#3498db';
            tabContainer.children[0].style.color = 'white';
        }
    }
</script>

</body>
</html>
