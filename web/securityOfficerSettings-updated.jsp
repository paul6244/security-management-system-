<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="config.DatabaseConfig" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Settings Dashboard</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="css/shared-ui.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="navbar">
    <div class="navbar-header">
        <h2>Security Management System</h2>
        <div class="navbar-user">
            <span>Admin</span>
        </div>
    </div>
    <nav class="navbar-nav">
        <a href="personnelDashboard.jsp" class="nav-link">
            <i class="nav-icon">📊</i>
            <span class="nav-text">Dashboard</span>
        </a>
        <a href="checklistDashboard.jsp" class="nav-link">
            <i class="nav-icon">✓</i>
            <span class="nav-text">Checklist</span>
        </a>
        <a href="qrCodeDashboard.jsp" class="nav-link">
            <i class="nav-icon">📱</i>
            <span class="nav-text">QR Code</span>
        </a>
        <a href="staffRegistration.jsp" class="nav-link">
            <i class="nav-icon">👥</i>
            <span class="nav-text">Staff Registration</span>
        </a>
        <a href="securityOfficerReports.jsp" class="nav-link">
            <i class="nav-icon">📈</i>
            <span class="nav-text">Reports</span>
        </a>
        <a href="securityOfficerSettings.jsp" class="nav-link active">
            <i class="nav-icon">⚙️</i>
            <span class="nav-text">Settings</span>
        </a>
        <a href="Logout" class="nav-link">
            <i class="nav-icon">🚪</i>
            <span class="nav-text">Logout</span>
        </a>
    </nav>
</div>

<div class="container">

<!-- MAIN CONTENT -->
<div class="main">

<!-- SETTINGS OVERVIEW -->
<div class="card">
    <div class="card-header">
        <h3>System Settings</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="backupSettings()">Backup Settings</button>
            <button class="btn btn-secondary" onclick="restoreSettings()">Restore Settings</button>
        </div>
    </div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card">
                <h4>System Status</h4>
                <div class="stat-number" id="systemStatus">Online</div>
                <div class="stat-label">Current Status</div>
            </div>
            
            <div class="stat-card">
                <h4>Database</h4>
                <div class="stat-number" id="dbStatus">Connected</div>
                <div class="stat-label">Database Status</div>
            </div>
            
            <div class="stat-card">
                <h4>Active Users</h4>
                <div class="stat-number" id="activeUsers">Loading...</div>
                <div class="stat-label">Currently Active</div>
            </div>
            
            <div class="stat-card">
                <h4>Last Backup</h4>
                <div class="stat-number" id="lastBackup">Loading...</div>
                <div class="stat-label">Backup Status</div>
            </div>
        </div>
    </div>
</div>

<!-- USER PROFILE SETTINGS -->
<div class="card">
    <div class="card-header">
        <h3>User Profile Settings</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="saveProfileSettings()">Save Changes</button>
        </div>
    </div>
    <div class="card-body">
        <form id="profileForm" class="form-section">
            <div class="form-group">
                <label for="userFirstName">First Name</label>
                <input type="text" id="userFirstName" name="userFirstName" class="form-control" placeholder="Enter first name">
            </div>
            
            <div class="form-group">
                <label for="userLastName">Last Name</label>
                <input type="text" id="userLastName" name="userLastName" class="form-control" placeholder="Enter last name">
            </div>
            
            <div class="form-group">
                <label for="userEmail">Email Address</label>
                <input type="email" id="userEmail" name="userEmail" class="form-control" placeholder="Enter email address">
            </div>
            
            <div class="form-group">
                <label for="userPhone">Phone Number</label>
                <input type="tel" id="userPhone" name="userPhone" class="form-control" placeholder="Enter phone number">
            </div>
            
            <div class="form-group">
                <label for="userBio">Bio</label>
                <textarea id="userBio" name="userBio" class="form-control" rows="3" placeholder="Enter your bio"></textarea>
            </div>
        </form>
    </div>
</div>

<!-- SECURITY SETTINGS -->
<div class="card">
    <div class="card-header">
        <h3>Security Settings</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="saveSecuritySettings()">Save Changes</button>
        </div>
    </div>
    <div class="card-body">
        <form id="securityForm" class="form-section">
            <div class="form-group">
                <label for="currentPassword">Current Password</label>
                <input type="password" id="currentPassword" name="currentPassword" class="form-control" placeholder="Enter current password">
            </div>
            
            <div class="form-group">
                <label for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" class="form-control" placeholder="Enter new password">
            </div>
            
            <div class="form-group">
                <label for="confirmNewPassword">Confirm New Password</label>
                <input type="password" id="confirmNewPassword" name="confirmNewPassword" class="form-control" placeholder="Confirm new password">
            </div>
            
            <div class="form-group">
                <label for="twoFactorAuth">Two-Factor Authentication</label>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="twoFactorAuth" id="twoFactorAuth"> Enable two-factor authentication
                    </label>
                    <label>
                        <input type="checkbox" name="emailNotifications" id="emailNotifications" checked> Email notifications for login attempts
                    </label>
                    <label>
                        <input type="checkbox" name="sessionTimeout" id="sessionTimeout" checked> Auto-logout after inactivity
                    </label>
                </div>
            </div>
            
            <div class="form-group">
                <label for="sessionTimeoutMinutes">Session Timeout (minutes)</label>
                <input type="number" id="sessionTimeoutMinutes" name="sessionTimeoutMinutes" class="form-control" value="30" min="5" max="480">
            </div>
        </form>
    </div>
</div>

<!-- NOTIFICATION SETTINGS -->
<div class="card">
    <div class="card-header">
        <h3>Notification Settings</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="saveNotificationSettings()">Save Changes</button>
        </div>
    </div>
    <div class="card-body">
        <form id="notificationForm" class="form-section">
            <div class="form-group">
                <label>Email Notifications</label>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="emailChecklist" id="emailChecklist" checked> Checklist completion reminders
                    </label>
                    <label>
                        <input type="checkbox" name="emailAttendance" id="emailAttendance" checked> Daily attendance summaries
                    </label>
                    <label>
                        <input type="checkbox" name="emailIncidents" id="emailIncidents" checked> Incident alerts
                    </label>
                    <label>
                        <input type="checkbox" name="emailReports" id="emailReports" checked> Weekly reports
                    </label>
                </div>
            </div>
            
            <div class="form-group">
                <label>SMS Notifications</label>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="smsEmergency" id="smsEmergency" checked> Emergency alerts only
                    </label>
                    <label>
                        <input type="checkbox" name="smsAttendance" id="smsAttendance"> Attendance notifications
                    </label>
                    <label>
                        <input type="checkbox" name="smsShift" id="smsShift"> Shift reminders
                    </label>
                </div>
            </div>
            
            <div class="form-group">
                <label for="notificationFrequency">Notification Frequency</label>
                <select id="notificationFrequency" name="notificationFrequency" class="form-control">
                    <option value="realtime">Real-time</option>
                    <option value="hourly">Hourly</option>
                    <option value="daily" selected>Daily</option>
                    <option value="weekly">Weekly</option>
                </select>
            </div>
        </form>
    </div>
</div>

<!-- SYSTEM CONFIGURATION -->
<div class="card">
    <div class="card-header">
        <h3>System Configuration</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="saveSystemSettings()">Save Changes</button>
        </div>
    </div>
    <div class="card-body">
        <form id="systemForm" class="form-section">
            <div class="form-group">
                <label for="companyName">Company Name</label>
                <input type="text" id="companyName" name="companyName" class="form-control" placeholder="Enter company name">
            </div>
            
            <div class="form-group">
                <label for="companyAddress">Company Address</label>
                <textarea id="companyAddress" name="companyAddress" class="form-control" rows="3" placeholder="Enter company address"></textarea>
            </div>
            
            <div class="form-group">
                <label for="companyPhone">Company Phone</label>
                <input type="tel" id="companyPhone" name="companyPhone" class="form-control" placeholder="Enter company phone">
            </div>
            
            <div class="form-group">
                <label for="companyEmail">Company Email</label>
                <input type="email" id="companyEmail" name="companyEmail" class="form-control" placeholder="Enter company email">
            </div>
            
            <div class="form-group">
                <label for="timezone">Timezone</label>
                <select id="timezone" name="timezone" class="form-control">
                    <option value="UTC">UTC</option>
                    <option value="America/New_York">Eastern Time</option>
                    <option value="America/Chicago">Central Time</option>
                    <option value="America/Denver">Mountain Time</option>
                    <option value="America/Los_Angeles">Pacific Time</option>
                    <option value="Europe/London">London</option>
                    <option value="Europe/Paris">Paris</option>
                    <option value="Asia/Tokyo">Tokyo</option>
                    <option value="Asia/Shanghai">Shanghai</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="dateFormat">Date Format</label>
                <select id="dateFormat" name="dateFormat" class="form-control">
                    <option value="MM/DD/YYYY">MM/DD/YYYY</option>
                    <option value="DD/MM/YYYY">DD/MM/YYYY</option>
                    <option value="YYYY-MM-DD">YYYY-MM-DD</option>
                    <option value="DD-MM-YYYY">DD-MM-YYYY</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>System Features</label>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="enableQR" id="enableQR" checked> Enable QR Code System
                    </label>
                    <label>
                        <input type="checkbox" name="enableChecklist" id="enableChecklist" checked> Enable Checklist System
                    </label>
                    <label>
                        <input type="checkbox" name="enableReports" id="enableReports" checked> Enable Reports System
                    </label>
                    <label>
                        <input type="checkbox" name="enableNotifications" id="enableNotifications" checked> Enable Notifications
                    </label>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- DATA MANAGEMENT -->
<div class="card">
    <div class="card-header">
        <h3>Data Management</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="exportData()">Export Data</button>
            <button class="btn btn-secondary" onclick="importData()">Import Data</button>
        </div>
    </div>
    <div class="card-body">
        <div class="form-section">
            <div class="form-group">
                <label>Export Options</label>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="exportStaff" id="exportStaff" checked> Staff Data
                    </label>
                    <label>
                        <input type="checkbox" name="exportAttendance" id="exportAttendance" checked> Attendance Records
                    </label>
                    <label>
                        <input type="checkbox" name="exportChecklist" id="exportChecklist" checked> Checklist Data
                    </label>
                    <label>
                        <input type="checkbox" name="exportReports" id="exportReports" checked> Reports
                    </label>
                </div>
            </div>
            
            <div class="form-group">
                <label for="exportFormat">Export Format</label>
                <select id="exportFormat" name="exportFormat" class="form-control">
                    <option value="csv">CSV</option>
                    <option value="excel">Excel</option>
                    <option value="json">JSON</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button class="btn btn-primary" onclick="exportData()">Export Selected Data</button>
                <button class="btn btn-warning" onclick="clearOldData()">Clear Old Data</button>
            </div>
        </div>
    </div>
</div>

<!-- SYSTEM LOGS -->
<div class="card">
    <div class="card-header">
        <h3>System Logs</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="refreshLogs()">Refresh</button>
            <button class="btn btn-secondary" onclick="clearLogs()">Clear Logs</button>
        </div>
    </div>
    <div class="card-body">
        <div class="form-group">
            <label for="logLevel">Log Level</label>
            <select id="logLevel" name="logLevel" class="form-control" onchange="filterLogs()">
                <option value="all">All Logs</option>
                <option value="error">Errors Only</option>
                <option value="warning">Warnings Only</option>
                <option value="info">Info Only</option>
            </select>
        </div>
        
        <div class="table-container">
            <table id="logsTable" class="table">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Level</th>
                        <th>User</th>
                        <th>Message</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="logsTableBody">
                    <!-- Logs will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

</div>

<script>
// Load user profile
function loadUserProfile() {
    fetch('GetUserProfile')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const profile = data.profile;
                document.getElementById('userFirstName').value = profile.firstName || '';
                document.getElementById('userLastName').value = profile.lastName || '';
                document.getElementById('userEmail').value = profile.email || '';
                document.getElementById('userPhone').value = profile.phone || '';
                document.getElementById('userBio').value = profile.bio || '';
            }
        })
        .catch(error => {
            console.error('Error loading user profile:', error);
        });
}

// Load system settings
function loadSystemSettings() {
    fetch('GetSystemSettings')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const settings = data.settings;
                document.getElementById('companyName').value = settings.companyName || '';
                document.getElementById('companyAddress').value = settings.companyAddress || '';
                document.getElementById('companyPhone').value = settings.companyPhone || '';
                document.getElementById('companyEmail').value = settings.companyEmail || '';
                document.getElementById('timezone').value = settings.timezone || 'UTC';
                document.getElementById('dateFormat').value = settings.dateFormat || 'MM/DD/YYYY';
                
                // Set checkboxes
                document.getElementById('enableQR').checked = settings.enableQR !== false;
                document.getElementById('enableChecklist').checked = settings.enableChecklist !== false;
                document.getElementById('enableReports').checked = settings.enableReports !== false;
                document.getElementById('enableNotifications').checked = settings.enableNotifications !== false;
            }
        })
        .catch(error => {
            console.error('Error loading system settings:', error);
        });
}

// Load system stats
function loadSystemStats() {
    fetch('GetSystemStats')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const stats = data.stats;
                document.getElementById('activeUsers').textContent = stats.activeUsers || '0';
                document.getElementById('lastBackup').textContent = stats.lastBackup || 'Never';
                document.getElementById('systemStatus').textContent = stats.systemStatus || 'Unknown';
                document.getElementById('dbStatus').textContent = stats.dbStatus || 'Unknown';
            }
        })
        .catch(error => {
            console.error('Error loading system stats:', error);
        });
}

// Load system logs
function loadSystemLogs() {
    fetch('GetSystemLogs')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const tbody = document.getElementById('logsTableBody');
                tbody.innerHTML = '';
                
                data.logs.forEach(log => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${log.timestamp}</td>
                        <td><span class="badge badge-${log.level}">${log.level}</span></td>
                        <td>${log.user}</td>
                        <td>${log.message}</td>
                        <td>
                            <button class="btn btn-sm btn-secondary" onclick="viewLogDetails('${log.id}')">Details</button>
                        </td>
                    `;
                    tbody.appendChild(row);
                });
            }
        })
        .catch(error => {
            console.error('Error loading system logs:', error);
        });
}

// Save profile settings
function saveProfileSettings() {
    const formData = new FormData(document.getElementById('profileForm'));
    
    fetch('SaveProfileSettings', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Profile settings saved successfully!');
        } else {
            alert('Error saving profile settings: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error saving profile settings');
    });
}

// Save security settings
function saveSecuritySettings() {
    const formData = new FormData(document.getElementById('securityForm'));
    
    fetch('SaveSecuritySettings', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Security settings saved successfully!');
            // Clear password fields
            document.getElementById('currentPassword').value = '';
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmNewPassword').value = '';
        } else {
            alert('Error saving security settings: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error saving security settings');
    });
}

// Save notification settings
function saveNotificationSettings() {
    const formData = new FormData(document.getElementById('notificationForm'));
    
    fetch('SaveNotificationSettings', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Notification settings saved successfully!');
        } else {
            alert('Error saving notification settings: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error saving notification settings');
    });
}

// Save system settings
function saveSystemSettings() {
    const formData = new FormData(document.getElementById('systemForm'));
    
    fetch('SaveSystemSettings', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('System settings saved successfully!');
        } else {
            alert('Error saving system settings: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error saving system settings');
    });
}

// Export data
function exportData() {
    const selectedData = [];
    if (document.getElementById('exportStaff').checked) selectedData.push('staff');
    if (document.getElementById('exportAttendance').checked) selectedData.push('attendance');
    if (document.getElementById('exportChecklist').checked) selectedData.push('checklist');
    if (document.getElementById('exportReports').checked) selectedData.push('reports');
    
    if (selectedData.length === 0) {
        alert('Please select at least one data type to export');
        return;
    }
    
    const format = document.getElementById('exportFormat').value;
    
    fetch('ExportData', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            dataTypes: selectedData.join(','),
            format: format
        })
    })
    .then(response => response.blob())
    .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'data_export_' + new Date().toISOString().split('T')[0] + '.' + format;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
    })
    .catch(error => {
        console.error('Error exporting data:', error);
        alert('Error exporting data');
    });
}

// Backup settings
function backupSettings() {
    fetch('BackupSettings')
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'settings_backup_' + new Date().toISOString().split('T')[0] + '.json';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
            alert('Settings backup completed successfully!');
        })
        .catch(error => {
            console.error('Error backing up settings:', error);
            alert('Error backing up settings');
        });
}

// Restore settings
function restoreSettings() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = function(e) {
        const file = e.target.files[0];
        const formData = new FormData();
        formData.append('backupFile', file);
        
        fetch('RestoreSettings', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Settings restored successfully! Page will reload.');
                location.reload();
            } else {
                alert('Error restoring settings: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error restoring settings');
        });
    };
    input.click();
}

// Clear old data
function clearOldData() {
    if (confirm('Are you sure you want to clear old data? This action cannot be undone.')) {
        fetch('ClearOldData', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Old data cleared successfully!');
                loadSystemStats();
            } else {
                alert('Error clearing old data: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error clearing old data');
        });
    }
}

// Refresh logs
function refreshLogs() {
    loadSystemLogs();
}

// Clear logs
function clearLogs() {
    if (confirm('Are you sure you want to clear all system logs?')) {
        fetch('ClearSystemLogs', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('System logs cleared successfully!');
                loadSystemLogs();
            } else {
                alert('Error clearing system logs: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error clearing system logs');
        });
    }
}

// Filter logs
function filterLogs() {
    const level = document.getElementById('logLevel').value;
    const rows = document.querySelectorAll('#logsTableBody tr');
    
    rows.forEach(row => {
        const levelCell = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
        if (level === 'all' || levelCell === level) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

// View log details
function viewLogDetails(logId) {
    fetch('GetLogDetails?id=' + logId)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Log Details:\n\n' + JSON.stringify(data.logDetails, null, 2));
            }
        })
        .catch(error => {
            console.error('Error viewing log details:', error);
        });
}

// Password confirmation validation
document.getElementById('confirmNewPassword').addEventListener('input', function() {
    const newPassword = document.getElementById('newPassword').value;
    const confirmNewPassword = this.value;
    
    if (newPassword !== confirmNewPassword) {
        this.setCustomValidity('Passwords do not match');
    } else {
        this.setCustomValidity('');
    }
});

// Initialize on page load
window.onload = function() {
    loadUserProfile();
    loadSystemSettings();
    loadSystemStats();
    loadSystemLogs();
};
</script>

<style>
.checkbox-group {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.checkbox-group label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 500;
}

.checkbox-group input[type="checkbox"] {
    margin: 0;
}

@media (max-width: 768px) {
    .checkbox-group {
        gap: 8px;
    }
    
    .checkbox-group label {
        font-size: 14px;
    }
}
</style>

</body>
</html>
