<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
<title>Security Dashboard</title>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="css/shared-ui.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* Override any conflicting styles to ensure consistency */
body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg-secondary);
    color: var(--text-primary);
    margin: 0;
    padding: 0;
}

/* Mobile-First Responsive Design */
.container {
    display:flex;
    min-height:100vh;
}

.sidebar {
    width:250px;
    background:#34495e;
    padding:20px;
    min-height:100vh;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
}

.sidebar a {
    display:block;
    padding:15px;
    color:white;
    text-decoration:none;
    font-size: 14px;
    transition: background 0.3s ease;
}

.sidebar a:hover {
    background:#34495e;
}

.main {
    flex:1;
    padding:20px;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
}

.card {
    background:white;
    padding:20px;
    margin-bottom:20px;
    border-radius:10px;
    box-shadow:0 2px 8px rgba(0,0,0,0.1);
    color: #333;
}

.card h3 {
    margin-top:0;
    margin-bottom:15px;
    color: #2c3e50;
    font-size: 18px;
}

.btn {
    padding:10px 15px;
    background:#3498db;
    color:white;
    border:none;
    border-radius:5px;
    cursor:pointer;
    font-size: 14px;
    transition: background 0.3s ease;
    min-height: 44px;
    min-width: 44px;
}

.btn:hover {
    background:#2980b9;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap:20px;
    margin-bottom:20px;
}

.stat-card {
    background: white;
    padding:20px;
    border-radius:10px;
    box-shadow:0 2px 8px rgba(0,0,0,0.1);
    text-align: center;
    color: #333;
}

.stat-value {
    font-size: 24px;
    font-weight: bold;
    color: #3498db;
    margin:10px 0;
}

.stat-label {
    font-size: 14px;
    color: #666;
}

/* Mobile Responsive Design */
@media (max-width: 768px) {
    .container {
        flex-direction: column;
    }
    
    .sidebar {
        width: 100%;
        padding: 15px;
        min-height: auto;
    }
    
    .sidebar a {
        padding: 12px 15px;
        font-size: 16px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }
    
    .main {
        padding: 15px;
    }
    
    .card {
        padding: 15px;
        margin-bottom: 15px;
    }
    
    .card h3 {
        font-size: 16px;
    }
    
    .stats-grid {
        grid-template-columns: 1fr;
        gap: 15px;
    }
    
    .stat-card {
        padding: 15px;
    }
    
    .stat-value {
        font-size: 20px;
    }
    
    .btn {
        width: 100%;
        margin: 5px 0;
        padding: 15px;
        font-size: 16px;
    }
}

@media (max-width: 480px) {
    .sidebar {
        padding: 10px;
    }
    
    .sidebar a {
        padding: 10px 12px;
        font-size: 14px;
    }
    
    .main {
        padding: 10px;
    }
    
    .card {
        padding: 10px;
        margin-bottom: 10px;
    }
    
    .card h3 {
        font-size: 14px;
    }
    
    .stat-card {
        padding: 10px;
    }
    
    .stat-value {
        font-size: 18px;
    }
    
    .btn {
        padding: 12px;
        font-size: 14px;
    }
}

/* Touch-friendly improvements */
@media (hover: none) and (pointer: coarse) {
    .sidebar a {
        min-height: 44px;
        display: flex;
        align-items: center;
    }
    
    .btn {
        min-height: 44px;
        min-width: 44px;
    }
    
    .card {
        margin: 10px 0;
    }
}

.btn-danger {
    background:red;
}

table {
    width:100%;
    border-collapse: collapse;
}

th, td {
    padding:10px;
    border-bottom:1px solid #ddd;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 20px;
}

.stat-card {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
    text-align: center;
    border: 1px solid #e9ecef;
    transition: transform 0.2s;
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.stat-card h4 {
    margin: 0 0 10px 0;
    color: #2c3e50;
    font-size: 14px;
    font-weight: 600;
}

.stat-number {
    font-size: 24px;
    font-weight: bold;
    color: #3498db;
    margin-bottom: 5px;
}

.stat-number small {
    display: block;
    font-size: 12px;
    color: #666;
    font-weight: normal;
    margin-top: 5px;
}

.btn-secondary {
    background: #6c757d;
    margin-left: 10px;
}

.btn-secondary:hover {
    background: #5a6268;
}
</style>
</head>

<body>

<div class="navbar">
    <div class="navbar-header">
        <h2>Security Management System</h2>
        <div class="navbar-user">
            <span><%= session.getAttribute("username") %></span>
        </div>
    </div>
    <nav class="navbar-nav">
        <a href="personnelDashboard.jsp" class="nav-link active">
            <i class="nav-icon">📊</i>
            <span class="nav-text">Dashboard</span>
        </a>
        <a href="checklistDashboard.jsp" class="nav-link">
            <i class="nav-icon">✓</i>
            <span class="nav-text">Checklist</span>
        </a>
        <a href="viewAttendance.jsp" class="nav-link">
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
        <a href="securityOfficerSettings.jsp" class="nav-link">
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

<!-- MAIN -->
<div class="main">

<!-- SHIFT CONTROL -->
<div class="card">
    <div class="card-header">
        <h3>Shift Control</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="startShift()">Start Shift</button>
            <button class="btn btn-secondary" onclick="endShift()">End Shift</button>
        </div>
    </div>
    <div class="card-body">
        <div id="shiftStatus" class="text-center">
            <p>Ready to start your shift</p>
        </div>
    </div>
</div>

<!-- CHECKLIST -->
<div class="card">
    <div class="card-header">
        <h3>Shift Checklist</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="completeChecklist()">Complete Checklist</button>
        </div>
    </div>
    <div class="card-body">

<!-- ORIGINAL FORM -->

<form action="SaveChecklist" method="post" id="mainForm">

<form action="SaveChecklist" method="post" onsubmit="showShiftNotification('end')" id="mainForm">


<table>
<thead>
<tr>
    <th>Item</th>
    <th>Status</th>
    <th>Reason</th>
</tr>
</thead>

<tbody>

<%
ResultSet rs = Mymodel.getChecklistItems();
if(rs == null) {
    out.println("<tr><td colspan='3' style='text-align: center; color: red;'>Error loading checklist items. Please check database connection.</td></tr>");
} else {
    boolean hasItems = false;
    while(rs != null && rs.next()){
        hasItems = true;
        int id = rs.getInt("id");
%>

<tr>
<td><%= rs.getString("item_name") %></td>

<td>
    <!-- IMPORTANT: name must be item_ID -->
    <select name="item_<%= id %>" onchange="toggleReason(<%= id %>, this.value)" form="mainForm">
        <option value="OK" selected>OK</option>
        <option value="NOT_OK">NOT_OK</option>
    </select>
</td>

<td>
    <input type="text"
           id="reason_<%= id %>"
           name="reason_<%= id %>"
           placeholder="Enter reason"
           form="mainForm"
           style="display:none; width:100%;">
</td>

</tr>

<%
    }
    if(!hasItems) {
        out.println("<tr><td colspan='3' style='text-align: center; color: #666;'>No checklist items found. Please add items to the checklist_items table.</td></tr>");
    }
}
if(rs != null) rs.close();
%>

</tbody>
</table>

<br>

<button class="btn btn-danger" type="submit">End Shift & Submit Checklist</button>

</form>
</div>

<!-- PERSONNEL REPORTS -->
<div class="card">
    <div class="card-header">
        <h3>My Reports</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="exportMyReport()">Export Report</button>
            <button class="btn btn-secondary" onclick="window.open('testConnection.jsp', '_blank')">Test Database</button>
        </div>
    </div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card">
                <h4>My Attendance</h4>
                <div class="stat-number">
            <%
            try {
                Connection con = DatabaseConfig.getConnection();
                
                String currentUser = session.getAttribute("username").toString();
                
                // Get user ID from users table
                String userSql = "SELECT id FROM users WHERE username = ?";
                PreparedStatement userPs = con.prepareStatement(userSql);
                userPs.setString(1, currentUser);
                ResultSet userRs = userPs.executeQuery();
                
                if(userRs.next()) {
                    int userId = userRs.getInt("id");
                    
                    // Check if user has security personnel record
                    String personnelSql = "SELECT id FROM security_personnel WHERE user_id = ?";
                    PreparedStatement personnelPs = con.prepareStatement(personnelSql);
                    personnelPs.setInt(1, userId);
                    ResultSet personnelRs = personnelPs.executeQuery();
                    
                    if(personnelRs.next()) {
                        int personnelId = personnelRs.getInt("id");
                        
                        // Get today's attendance from shifts table
                        String todaySql = "SELECT COUNT(*) as count FROM shifts WHERE user_id = ? AND DATE(start_time) = CURRENT_DATE";
                        PreparedStatement todayPs = con.prepareStatement(todaySql);
                        todayPs.setInt(1, userId);
                        ResultSet todayRs = todayPs.executeQuery();
                        
                        if(todayRs.next()) {
                            int todayCount = todayRs.getInt("count");
                            out.println(todayCount > 0 ? "Present" : "Absent");
                        }
                        todayRs.close();
                        todayPs.close();
                        
                        // Get this month's attendance
                        String monthSql = "SELECT COUNT(*) as count FROM shifts WHERE user_id = ? AND EXTRACT(MONTH FROM start_time) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM start_time) = EXTRACT(YEAR FROM CURRENT_DATE)";
                        PreparedStatement monthPs = con.prepareStatement(monthSql);
                        monthPs.setInt(1, userId);
                        ResultSet monthRs = monthPs.executeQuery();
                        
                        if(monthRs.next()) {
                            out.println("<small>This month: " + monthRs.getInt("count") + " days</small>");
                        }
                        monthRs.close();
                        monthPs.close();
                    } else {
                        out.println("N/A");
                        out.println("<small>No personnel record</small>");
                    }
                    personnelRs.close();
                    personnelPs.close();
                } else {
                    out.println("N/A");
                    out.println("<small>User not found</small>");
                }
                userRs.close();
                userPs.close();
                con.close();
            } catch(Exception e) {
                out.println("Error: " + e.getMessage());
            }
            %>
        </div>
    </div>
    
    <div class="stat-card">
        <h4>My Shift Status</h4>
        <div class="stat-number">
            <%
            try {
                Connection con = DatabaseConfig.getConnection();
                
                String currentUser = session.getAttribute("username").toString();
                
                // Get user ID from users table
                String userSql = "SELECT id FROM users WHERE username = ?";
                PreparedStatement userPs = con.prepareStatement(userSql);
                userPs.setString(1, currentUser);
                ResultSet userRs = userPs.executeQuery();
                
                if(userRs.next()) {
                    int userId = userRs.getInt("id");
                    
                    // Check for active shift in shifts table
                    String shiftSql = "SELECT id, start_time FROM shifts WHERE user_id = ? AND end_time IS NULL";
                    PreparedStatement shiftPs = con.prepareStatement(shiftSql);
                    shiftPs.setInt(1, userId);
                    ResultSet shiftRs = shiftPs.executeQuery();
                    
                    if(shiftRs.next()) {
                        out.println("Active");
                        out.println("<small>Shift started at " + shiftRs.getTimestamp("start_time").toString().substring(11, 16) + "</small>");
                    } else {
                        out.println("Inactive");
                        out.println("<small>No active shift</small>");
                    }
                    shiftRs.close();
                    shiftPs.close();
                } else {
                    out.println("N/A");
                    out.println("<small>User not found</small>");
                }
                userRs.close();
                userPs.close();
                con.close();
            } catch(Exception e) {
                out.println("Error: " + e.getMessage());
            }
            %>
        </div>
    </div>
    
    <div class="stat-card">
        <h4>My Checklist</h4>
        <div class="stat-number">
            <%
            try {
                Connection con = DatabaseConfig.getConnection();
                
                String currentUser = session.getAttribute("username").toString();
                
                // Get user ID from users table
                String userSql = "SELECT id FROM users WHERE username = ?";
                PreparedStatement userPs = con.prepareStatement(userSql);
                userPs.setString(1, currentUser);
                ResultSet userRs = userPs.executeQuery();
                
                if(userRs.next()) {
                    int userId = userRs.getInt("id");
                    
                    // Get personnel ID from security_personnel table
                    String personnelSql = "SELECT id FROM security_personnel WHERE user_id = ?";
                    PreparedStatement personnelPs = con.prepareStatement(personnelSql);
                    personnelPs.setInt(1, userId);
                    ResultSet personnelRs = personnelPs.executeQuery();
                    
                    if(personnelRs.next()) {
                        int personnelId = personnelRs.getInt("id");
                        
                        // Check shift_checks for today's checklist status
                        String checklistSql = "SELECT status FROM shift_checks WHERE personnel_id = ? AND DATE(check_time) = CURRENT_DATE ORDER BY check_time DESC LIMIT 1";
                        PreparedStatement checklistPs = con.prepareStatement(checklistSql);
                        checklistPs.setInt(1, personnelId);
                        ResultSet checklistRs = checklistPs.executeQuery();
                        
                        if(checklistRs.next()) {
                            String status = checklistRs.getString("status");
                            if(status.equals("OK")) {
                                out.println("OK");
                                out.println("<small>All items completed</small>");
                            } else {
                                out.println("Not ok");
                                out.println("<small>Issues found</small>");
                            }
                        } else {
                            out.println("Not ok");
                            out.println("<small>No checklist submitted</small>");
                        }
                        checklistRs.close();
                        checklistPs.close();
                    } else {
                        out.println("N/A");
                        out.println("<small>No personnel record</small>");
                    }
                    personnelRs.close();
                    personnelPs.close();
                } else {
                    out.println("N/A");
                    out.println("<small>User not found</small>");
                }
                userRs.close();
                userPs.close();
                con.close();
            } catch(Exception e) {
                out.println("Error: " + e.getMessage());
            }
            %>
        </div>
    </div>
    
    <div class="stat-card">
        <h4>My Performance</h4>
        <div class="stat-number">
            <%
            try {
                Connection con = DatabaseConfig.getConnection();
                
                String currentUser = session.getAttribute("username").toString();
                
                // Get user ID from users table
                String userSql = "SELECT id FROM users WHERE username = ?";
                PreparedStatement userPs = con.prepareStatement(userSql);
                userPs.setString(1, currentUser);
                ResultSet userRs = userPs.executeQuery();
                
                if(userRs.next()) {
                    int userId = userRs.getInt("id");
                    
                    // Get personnel ID from security_personnel table
                    String personnelSql = "SELECT id FROM security_personnel WHERE user_id = ?";
                    PreparedStatement personnelPs = con.prepareStatement(personnelSql);
                    personnelPs.setInt(1, userId);
                    ResultSet personnelRs = personnelPs.executeQuery();
                    
                    if(personnelRs.next()) {
                        int personnelId = personnelRs.getInt("id");
                        
                        // Calculate performance based on shift_checks
                        String performanceSql = "SELECT COUNT(*) as total, SUM(CASE WHEN status = 'OK' THEN 1 ELSE 0 END) as ok_checks FROM shift_checks WHERE personnel_id = ? AND DATE(check_time) >= CURRENT_DATE - INTERVAL '7 days'";
                        PreparedStatement performancePs = con.prepareStatement(performanceSql);
                        performancePs.setInt(1, personnelId);
                        ResultSet performanceRs = performancePs.executeQuery();
                        
                        if(performanceRs.next()) {
                            int total = performanceRs.getInt("total");
                            int okChecks = performanceRs.getInt("ok_checks");
                            
                            if(total > 0) {
                                int performanceRate = (okChecks * 100) / total;
                                out.println(performanceRate + "%");
                                out.println("<small>Success rate this week</small>");
                            } else {
                                out.println("N/A");
                                out.println("<small>No data</small>");
                            }
                        }
                        performanceRs.close();
                        performancePs.close();
                    } else {
                        out.println("N/A");
                        out.println("<small>No personnel record</small>");
                    }
                    personnelRs.close();
                    personnelPs.close();
                } else {
                    out.println("N/A");
                    out.println("<small>User not found</small>");
                }
                userRs.close();
                userPs.close();
                con.close();
            } catch(Exception e) {
                out.println("Error: " + e.getMessage());
            }
            %>
        </div>
    </div>
</div>

</div>
    </div>
</div>

</div>

</div>

<!-- Popup Notification -->
<div id="notificationPopup" style="display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 1000; min-width: 300px; text-align: center;">
    <h3 id="notificationTitle" style="color: black; margin: 0 0 10px 0;"></h3>
    <p id="notificationMessage" style="color: black; margin: 0 0 15px 0;"></p>
    <button class="btn" onclick="closeNotification()" style="margin-top: 10px;">OK</button>
</div>

<!-- Overlay -->
<div id="overlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 999;"></div>

<script>
function toggleReason(id, value){
    let input = document.getElementById("reason_" + id);

    if(value === "NOT_OK"){
        input.style.display = "block";
        input.setAttribute("required", "true");
    } else {
        input.style.display = "none";
        input.removeAttribute("required");
        input.value = "";
    }
}

function showShiftNotification(type) {
    const popup = document.getElementById('notificationPopup');
    const overlay = document.getElementById('overlay');
    const title = document.getElementById('notificationTitle');
    const message = document.getElementById('notificationMessage');
    
    if (type === 'start') {
        title.textContent = 'Shift Started';
        message.textContent = 'Your shift has been successfully started. Please complete your checklist items.';
    } else if (type === 'end') {
        title.textContent = 'Shift Ended';
        message.textContent = 'Your shift has been ended and checklist submitted successfully.';
    } else if (type === 'export') {
        title.textContent = 'Report Exported';
        message.textContent = 'Your personal report has been downloaded successfully.';
    }
    
    // Show popup
    popup.style.display = 'block';
    overlay.style.display = 'block';
    
    // Auto-hide after 3 seconds
    setTimeout(() => {
        closeNotification();
    }, 3000);
}

function closeNotification() {
    document.getElementById('notificationPopup').style.display = 'none';
    document.getElementById('overlay').style.display = 'none';
}

// Real-time stats update function
function updateRealTimeStats() {
    const currentUser = '<%= session.getAttribute("username") %>';
    
    fetch('GetRealTimeStats?username=' + encodeURIComponent(currentUser))
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                console.error('Error fetching stats:', data.error);
                return;
            }
            
            // Update Attendance Card
            if (data.attendance) {
                const attendanceCard = document.querySelector('.stat-card:nth-child(1) .stat-number');
                if (attendanceCard) {
                    attendanceCard.innerHTML = data.attendance.today + 
                        '<br><small>This month: ' + data.attendance.monthly + '</small>';
                }
            }
            
            // Update Shift Status Card
            if (data.shiftStatus) {
                const shiftCard = document.querySelector('.stat-card:nth-child(2) .stat-number');
                if (shiftCard) {
                    shiftCard.innerHTML = data.shiftStatus.status + 
                        '<br><small>' + data.shiftStatus.message + '</small>';
                }
            }
            
            // Update Checklist Card
            if (data.checklist) {
                const checklistCard = document.querySelector('.stat-card:nth-child(3) .stat-number');
                if (checklistCard) {
                    checklistCard.innerHTML = data.checklist.status + 
                        '<br><small>' + data.checklist.message + '</small>';
                }
            }
            
            // Update Performance Card
            if (data.performance) {
                const performanceCard = document.querySelector('.stat-card:nth-child(4) .stat-number');
                if (performanceCard) {
                    performanceCard.innerHTML = data.performance.rate + 
                        '<br><small>' + data.performance.message + '</small>';
                }
            }
        })
        .catch(error => {
            console.error('Error updating stats:', error);
        });
}

function exportMyReport() {
    // Create a simple export of personal data
    const currentUser = '<%= session.getAttribute("username") %>';
    const reportData = generatePersonalReport(currentUser);
    
    // Create and download CSV file
    const blob = new Blob([reportData], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'my_report_' + new Date().toISOString().split('T')[0] + '.csv';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
    
    showShiftNotification('export');
}

function generatePersonalReport(username) {
    // Simple CSV header and data
    let csv = 'Personal Security Report\n';
    csv += 'Generated:,' + new Date().toLocaleString() + '\n';
    csv += 'User:,' + username + '\n\n';
    csv += 'Metric,Value,Notes\n';
    csv += 'Dashboard Access,Personal Dashboard,Viewed from personnel dashboard\n';
    csv += 'Shift Status,Check shift control,Use shift control buttons\n';
    csv += 'Checklist Completion,Track daily items,Complete checklist items\n';
    csv += 'Attendance Tracking,Personal attendance,View attendance reports\n';
    
    return csv;
}

// Check for URL parameters to show notifications
window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('status');
    const message = urlParams.get('message');
    
    if (status && message) {
        showNotificationFromParams(status, message);
    }
    
    // Start real-time updates
    updateRealTimeStats();
    setInterval(updateRealTimeStats, 30000); // Update every 30 seconds
};

function showNotificationFromParams(status, message) {
    const popup = document.getElementById('notificationPopup');
    const overlay = document.getElementById('overlay');
    const title = document.getElementById('notificationTitle');
    const messageEl = document.getElementById('notificationMessage');
    
    if (status === 'success') {
        title.textContent = 'Success';
        messageEl.textContent = message;
    } else if (status === 'error') {
        title.textContent = 'Error';
        messageEl.textContent = message;
    }
    
    popup.style.display = 'block';
    overlay.style.display = 'block';
    
    // Auto-hide after 5 seconds for parameter-based notifications
    setTimeout(() => {
        closeNotification();
    }, 5000);
}
</script>

</body>
</html>
