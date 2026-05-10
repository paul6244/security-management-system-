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
<title>Security Dashboard</title>
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
    </div>
    <div class="card-body">
        <form action="SaveChecklist" method="post" id="mainForm" class="form-section">
            <div class="form-group">
                <label for="shiftDate">Shift Date</label>
                <input type="date" id="shiftDate" name="shiftDate" class="form-control" required>
            </div>
            
            <div class="form-group">
                <label for="shiftType">Shift Type</label>
                <select id="shiftType" name="shiftType" class="form-control" required>
                    <option value="">Select Shift Type</option>
                    <option value="day">Day Shift</option>
                    <option value="night">Night Shift</option>
                    <option value="flexible">Flexible</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="checklistItems">Checklist Items</label>
                <textarea id="checklistItems" name="checklistItems" class="form-control" rows="5" placeholder="Enter checklist items, one per line" required></textarea>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Save Checklist</button>
                <button type="button" class="btn btn-secondary" onclick="clearChecklistForm()">Clear</button>
            </div>
        </form>
    </div>
</div>

<!-- PERSONNEL REPORTS -->
<div class="card">
    <div class="card-header">
        <h3>My Reports</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="exportPersonnelReport()">Export Report</button>
            <button class="btn btn-secondary" onclick="window.open('testConnection.jsp', '_blank')">Test Database</button>
        </div>
    </div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card">
                <h4>My Attendance</h4>
                <div class="stat-number" id="attendanceStat">Loading...</div>
                <div class="stat-label">Today's Status</div>
            </div>
            
            <div class="stat-card">
                <h4>My Shift Status</h4>
                <div class="stat-number" id="shiftStat">Loading...</div>
                <div class="stat-label">Current Shift</div>
            </div>
            
            <div class="stat-card">
                <h4>My Checklist</h4>
                <div class="stat-number" id="checklistStat">Loading...</div>
                <div class="stat-label">Today's Completion</div>
            </div>
            
            <div class="stat-card">
                <h4>My Performance</h4>
                <div class="stat-number" id="performanceStat">Loading...</div>
                <div class="stat-label">Success Rate</div>
            </div>
        </div>
    </div>
</div>

</div>

<script>
function startShift() {
    const shiftDate = document.getElementById('shiftDate').value;
    const shiftType = document.getElementById('shiftType').value;
    
    if (!shiftDate || !shiftType) {
        alert('Please select shift date and type.');
        return;
    }
    
    fetch('StartShift', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            shiftDate: shiftDate,
            shiftType: shiftType
        })
    })
    .then(response => response.text())
    .then(data => {
        if (data.includes('success')) {
            document.getElementById('shiftStatus').innerHTML = '<p class="text-success">✅ Shift started successfully!</p>';
        } else {
            document.getElementById('shiftStatus').innerHTML = '<p class="text-error">❌ Error: ' + data + '</p>';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        document.getElementById('shiftStatus').innerHTML = '<p class="text-error">❌ Error starting shift</p>';
    });
}

function endShift() {
    fetch('EndShift', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            action: 'end'
        })
    })
    .then(response => response.text())
    .then(data => {
        if (data.includes('success')) {
            document.getElementById('shiftStatus').innerHTML = '<p class="text-success">✅ Shift ended successfully!</p>';
        } else {
            document.getElementById('shiftStatus').innerHTML = '<p class="text-error">❌ Error: ' + data + '</p>';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        document.getElementById('shiftStatus').innerHTML = '<p class="text-error">❌ Error ending shift</p>';
    });
}

function clearChecklistForm() {
    document.getElementById('checklistItems').value = '';
    document.getElementById('shiftDate').value = '';
    document.getElementById('shiftType').value = '';
}

function exportPersonnelReport() {
    const currentUser = '<%= session.getAttribute("username") %>';
    
    fetch('GetPersonnelReport?username=' + encodeURIComponent(currentUser))
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'personnel_report_' + new Date().toISOString().split('T')[0] + '.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error exporting report:', error);
            alert('Error exporting report. Please try again.');
        });
}

// Real-time stats update
function updateRealTimeStats() {
    const currentUser = '<%= session.getAttribute("username") %>';
    
    fetch('GetRealTimeStats?username=' + encodeURIComponent(currentUser))
        .then(response => response.json())
        .then(data => {
            // Update Attendance Card
            const attendanceCard = document.getElementById('attendanceStat');
            if (attendanceCard && data.attendance) {
                attendanceCard.innerHTML = data.attendance.today + 
                    '<br><small>This month: ' + data.attendance.monthly + '</small>';
            }
            
            // Update Shift Status Card
            const shiftCard = document.getElementById('shiftStat');
            if (shiftCard && data.shiftStatus) {
                shiftCard.innerHTML = data.shiftStatus.status + 
                    '<br><small>' + data.shiftStatus.message + '</small>';
            }
            
            // Update Checklist Card
            const checklistCard = document.getElementById('checklistStat');
            if (checklistCard && data.checklist) {
                checklistCard.innerHTML = data.checklist.status + 
                    '<br><small>' + data.checklist.message + '</small>';
            }
            
            // Update Performance Card
            const performanceCard = document.getElementById('performanceStat');
            if (performanceCard && data.performance) {
                performanceCard.innerHTML = data.performance.rate + 
                    '<br><small>' + data.performance.message + '</small>';
            }
        })
        .catch(error => {
            console.error('Error updating stats:', error);
        });
}

// Auto-update stats every 30 seconds
setInterval(updateRealTimeStats, 30000);
</script>

</body>
</html>
