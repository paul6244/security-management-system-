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
<title>Reports Dashboard</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    margin:0;
    padding:0;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height:100vh;
    color:white;
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
    border-radius:5px;
    margin-bottom:5px;
    transition:all 0.3s ease;
}

.sidebar a:hover {
    background:#2c3e50;
    transform:translateX(5px);
}

.sidebar a.active {
    background:#3498db;
}

.main {
    flex:1;
    padding:20px;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
}

.card {
    background:rgba(255,255,255,0.95);
    border-radius:15px;
    padding:25px;
    margin-bottom:20px;
    box-shadow:0 8px 32px rgba(0,0,0,0.1);
    backdrop-filter:blur(10px);
    border:1px solid rgba(255,255,255,0.2);
    color:#2c3e50;
}

.card h3 {
    color:#2c3e50;
    margin:0 0 20px 0;
    font-size:1.4em;
    font-weight:600;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.card-actions {
    display: flex;
    gap: 10px;
}

.btn {
    background:#3498db;
    color:white;
    border:none;
    padding:12px 24px;
    border-radius:8px;
    cursor:pointer;
    font-weight:500;
    transition:all 0.3s ease;
    font-size:14px;
}

.btn:hover {
    background:#2980b9;
    transform:translateY(-2px);
    box-shadow:0 4px 12px rgba(52,152,219,0.3);
}

.btn-secondary {
    background:#95a5a6;
}

.btn-secondary:hover {
    background:#7f8c8d;
}

.btn-danger {
    background:#e74c3c;
}

.btn-danger:hover {
    background:#c0392b;
}

.btn-success {
    background:#27ae60;
}

.btn-success:hover {
    background:#229954;
}

.form-control {
    width:100%;
    padding:12px;
    border:2px solid #ecf0f1;
    border-radius:8px;
    font-size:14px;
    transition:all 0.3s ease;
    box-sizing:border-box;
}

.form-control:focus {
    outline:none;
    border-color:#3498db;
    box-shadow:0 0 0 3px rgba(52,152,219,0.1);
}

.form-group {
    margin-bottom:20px;
}

.form-group label {
    display:block;
    margin-bottom:8px;
    font-weight:500;
    color:#2c3e50;
}

.table {
    width:100%;
    border-collapse:collapse;
    margin-top:20px;
    background:white;
    border-radius:10px;
    overflow:hidden;
    box-shadow:0 4px 12px rgba(0,0,0,0.1);
}

.table th {
    background:#34495e;
    color:white;
    padding:15px;
    text-align:left;
    font-weight:500;
}

.table td {
    padding:15px;
    border-bottom:1px solid #ecf0f1;
}

.table tr:hover {
    background:#f8f9fa;
}

.stats-grid {
    display:grid;
    grid-template-columns:repeat(auto-fit, minmax(250px, 1fr));
    gap:20px;
    margin-bottom:30px;
}

.stat-card {
    background:rgba(255,255,255,0.95);
    border-radius:15px;
    padding:25px;
    text-align:center;
    box-shadow:0 8px 32px rgba(0,0,0,0.1);
    backdrop-filter:blur(10px);
    border:1px solid rgba(255,255,255,0.2);
    color:#2c3e50;
    transition:transform 0.3s ease;
}

.stat-card:hover {
    transform:translateY(-5px);
}

.stat-card h4 {
    color:#7f8c8d;
    margin:0 0 10px 0;
    font-size:0.9em;
    font-weight:500;
    text-transform:uppercase;
    letter-spacing:1px;
}

.stat-number {
    font-size:2.5em;
    font-weight:700;
    color:#2c3e50;
    margin-bottom:10px;
}

.stat-label {
    color:#95a5a6;
    font-size:0.85em;
}

.navbar {
    background:rgba(52,73,94,0.95);
    padding:15px 25px;
    color:white;
    font-weight:600;
    backdrop-filter:blur(10px);
    border-bottom:1px solid rgba(255,255,255,0.1);
}

@media (max-width: 768px) {
    .container {
        flex-direction:column;
    }
    
    .sidebar {
        width:100%;
        order:2;
    }
    
    .main {
        order:1;
    }
    
    .stats-grid {
        grid-template-columns:1fr;
    }
    
    .card {
        padding:15px;
    }
    
    .form-group {
        margin-bottom:15px;
    }
}
</style>
</head>
<body>

<div class="navbar">
    Reports Dashboard | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="checklistDashboard.jsp">Checklist</a>
    <a href="viewAttendance.jsp">QR Code</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="securityOfficerReports.jsp" class="active">Reports</a>
    <a href="securityOfficerSettings.jsp">Settings</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<!-- REPORTS OVERVIEW -->
<div class="card">
    <div class="card-header">
        <h3>Reports Overview</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="generateCustomReport()">Generate Report</button>
            <button class="btn btn-secondary" onclick="exportAllReports()">Export All</button>
        </div>
    </div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card">
                <h4>Total Reports</h4>
                <div class="stat-number" id="totalReports">Loading...</div>
                <div class="stat-label">All Reports</div>
            </div>
            
            <div class="stat-card">
                <h4>This Month</h4>
                <div class="stat-number" id="monthlyReports">Loading...</div>
                <div class="stat-label">Monthly Reports</div>
            </div>
            
            <div class="stat-card">
                <h4>Pending Review</h4>
                <div class="stat-number" id="pendingReports">Loading...</div>
                <div class="stat-label">Awaiting Review</div>
            </div>
            
            <div class="stat-card">
                <h4>Completed</h4>
                <div class="stat-number" id="completedReports">Loading...</div>
                <div class="stat-label">Completed Reports</div>
            </div>
        </div>
    </div>
</div>

<!-- REPORT GENERATION -->
<div class="card" id="reportGenerationCard" style="display: none;">
    <div class="card-header">
        <h3>Generate Custom Report</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="hideReportGeneration()">Cancel</button>
        </div>
    </div>
    <div class="card-body">
        <form id="reportForm" class="form-section">
            <div class="form-group">
                <label for="reportType">Report Type *</label>
                <select id="reportType" name="reportType" class="form-control" required>
                    <option value="">Select Report Type</option>
                    <option value="attendance">Attendance Report</option>
                    <option value="checklist">Checklist Report</option>
                    <option value="incident">Incident Report</option>
                    <option value="performance">Performance Report</option>
                    <option value="staff">Staff Report</option>
                    <option value="summary">Summary Report</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="dateRange">Date Range *</label>
                <div class="date-range-group">
                    <input type="date" id="startDate" name="startDate" class="form-control" required>
                    <span>to</span>
                    <input type="date" id="endDate" name="endDate" class="form-control" required>
                </div>
            </div>
            
            <div class="form-group">
                <label for="department">Department</label>
                <select id="department" name="department" class="form-control">
                    <option value="">All Departments</option>
                    <option value="security">Security</option>
                    <option value="administration">Administration</option>
                    <option value="operations">Operations</option>
                    <option value="maintenance">Maintenance</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="branch">Branch</label>
                <select id="branch" name="branch" class="form-control">
                    <option value="">All Branches</option>
                    <%
                        try {
                            ResultSet branchRs = Mymodel.getBranches();
                            while(branchRs != null && branchRs.next()) {
                    %>
                    <option value="<%= branchRs.getInt("id") %>"><%= branchRs.getString("name") %></option>
                    <%
                            }
                            if(branchRs != null) branchRs.close();
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </select>
            </div>
            
            <div class="form-group">
                <label for="staffMember">Staff Member</label>
                <select id="staffMember" name="staffMember" class="form-control">
                    <option value="">All Staff</option>
                    <!-- Staff members will be loaded here -->
                </select>
            </div>
            
            <div class="form-group">
                <label for="reportFormat">Report Format *</label>
                <select id="reportFormat" name="reportFormat" class="form-control" required>
                    <option value="pdf">PDF</option>
                    <option value="excel">Excel</option>
                    <option value="csv">CSV</option>
                    <option value="html">HTML</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="includeCharts">Include Charts</label>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="includeCharts" checked> Include charts and graphs
                    </label>
                    <label>
                        <input type="checkbox" name="includeDetails" checked> Include detailed data
                    </label>
                    <label>
                        <input type="checkbox" name="includeSummary" checked> Include summary section
                    </label>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Generate Report</button>
                <button type="button" class="btn btn-secondary" onclick="hideReportGeneration()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- CHARTS SECTION -->
<div class="card">
    <div class="card-header">
        <h3>Analytics Dashboard</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="refreshCharts()">Refresh Charts</button>
        </div>
    </div>
    <div class="card-body">
        <div class="charts-grid">
            <div class="chart-container">
                <h4>Attendance Trends</h4>
                <canvas id="attendanceChart"></canvas>
            </div>
            
            <div class="chart-container">
                <h4>Checklist Completion</h4>
                <canvas id="checklistChart"></canvas>
            </div>
            
            <div class="chart-container">
                <h4>Incident Reports</h4>
                <canvas id="incidentChart"></canvas>
            </div>
            
            <div class="chart-container">
                <h4>Performance Metrics</h4>
                <canvas id="performanceChart"></canvas>
            </div>
        </div>
    </div>
</div>

<!-- RECENT REPORTS -->
<div class="card">
    <div class="card-header">
        <h3>Recent Reports</h3>
        <div class="card-actions">
            <input type="text" id="searchReports" class="form-control" placeholder="Search reports..." style="width: 250px;" onkeyup="searchReports()">
        </div>
    </div>
    <div class="card-body">
        <div class="table-container">
            <table id="reportsTable" class="table">
                <thead>
                    <tr>
                        <th>Report Type</th>
                        <th>Date Range</th>
                        <th>Generated By</th>
                        <th>Status</th>
                        <th>Format</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="reportsTableBody">
                    <!-- Reports will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- SCHEDULED REPORTS -->
<div class="card">
    <div class="card-header">
        <h3>Scheduled Reports</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="showScheduledReportForm()">Add Schedule</button>
        </div>
    </div>
    <div class="card-body">
        <div class="table-container">
            <table id="scheduledReportsTable" class="table">
                <thead>
                    <tr>
                        <th>Report Name</th>
                        <th>Type</th>
                        <th>Schedule</th>
                        <th>Next Run</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="scheduledReportsTableBody">
                    <!-- Scheduled reports will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- SCHEDULED REPORT FORM -->
<div class="card" id="scheduledReportCard" style="display: none;">
    <div class="card-header">
        <h3>Add Scheduled Report</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="hideScheduledReportForm()">Cancel</button>
        </div>
    </div>
    <div class="card-body">
        <form id="scheduledReportForm" class="form-section">
            <div class="form-group">
                <label for="reportName">Report Name *</label>
                <input type="text" id="reportName" name="reportName" class="form-control" placeholder="Enter report name" required>
            </div>
            
            <div class="form-group">
                <label for="scheduledReportType">Report Type *</label>
                <select id="scheduledReportType" name="scheduledReportType" class="form-control" required>
                    <option value="">Select Report Type</option>
                    <option value="attendance">Attendance Report</option>
                    <option value="checklist">Checklist Report</option>
                    <option value="incident">Incident Report</option>
                    <option value="performance">Performance Report</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="scheduleType">Schedule Type *</label>
                <select id="scheduleType" name="scheduleType" class="form-control" required>
                    <option value="">Select Schedule</option>
                    <option value="daily">Daily</option>
                    <option value="weekly">Weekly</option>
                    <option value="monthly">Monthly</option>
                    <option value="quarterly">Quarterly</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="recipients">Email Recipients</label>
                <textarea id="recipients" name="recipients" class="form-control" rows="3" placeholder="Enter email addresses (comma separated)"></textarea>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Add Schedule</button>
                <button type="button" class="btn btn-secondary" onclick="hideScheduledReportForm()">Cancel</button>
            </div>
        </form>
    </div>
</div>

</div>

<script>
// Show/Hide Report Generation Form
function showReportGeneration() {
    document.getElementById('reportGenerationCard').style.display = 'block';
    loadStaffMembers();
    // Set default date range (last 30 days)
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 30);
    document.getElementById('startDate').value = startDate.toISOString().split('T')[0];
    document.getElementById('endDate').value = endDate.toISOString().split('T')[0];
}

function hideReportGeneration() {
    document.getElementById('reportGenerationCard').style.display = 'none';
    document.getElementById('reportForm').reset();
}

// Show/Hide Scheduled Report Form
function showScheduledReportForm() {
    document.getElementById('scheduledReportCard').style.display = 'block';
}

function hideScheduledReportForm() {
    document.getElementById('scheduledReportCard').style.display = 'none';
    document.getElementById('scheduledReportForm').reset();
}

// Load staff members
function loadStaffMembers() {
    fetch('GetStaffMembers')
        .then(response => response.json())
        .then(data => {
            const select = document.getElementById('staffMember');
            select.innerHTML = '<option value="">All Staff</option>';
            
            data.staff.forEach(member => {
                const option = document.createElement('option');
                option.value = member.id;
                option.textContent = member.name + ' - ' + member.email;
                select.appendChild(option);
            });
        })
        .catch(error => {
            console.error('Error loading staff members:', error);
        });
}

// Load reports
function loadReports() {
    fetch('GetReports')
        .then(response => response.json())
        .then(data => {
            const tbody = document.getElementById('reportsTableBody');
            tbody.innerHTML = '';
            
            data.reports.forEach(report => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td><span class="badge badge-${report.type}">${report.type}</span></td>
                    <td>${report.dateRange}</td>
                    <td>${report.generatedBy}</td>
                    <td><span class="badge badge-${report.status}">${report.status}</span></td>
                    <td>${report.format}</td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="downloadReport(${report.id})">Download</button>
                        <button class="btn btn-sm btn-secondary" onclick="viewReport(${report.id})">View</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteReport(${report.id})">Delete</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
            
            updateStats(data);
        })
        .catch(error => {
            console.error('Error loading reports:', error);
        });
}

// Load scheduled reports
function loadScheduledReports() {
    fetch('GetScheduledReports')
        .then(response => response.json())
        .then(data => {
            const tbody = document.getElementById('scheduledReportsTableBody');
            tbody.innerHTML = '';
            
            data.scheduledReports.forEach(report => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${report.name}</td>
                    <td><span class="badge badge-${report.type}">${report.type}</span></td>
                    <td>${report.schedule}</td>
                    <td>${report.nextRun}</td>
                    <td><span class="badge badge-${report.status}">${report.status}</span></td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="editScheduledReport(${report.id})">Edit</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteScheduledReport(${report.id})">Delete</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        })
        .catch(error => {
            console.error('Error loading scheduled reports:', error);
        });
}

// Update statistics
function updateStats(data) {
    document.getElementById('totalReports').textContent = data.totalReports || '0';
    document.getElementById('monthlyReports').textContent = data.monthlyReports || '0';
    document.getElementById('pendingReports').textContent = data.pendingReports || '0';
    document.getElementById('completedReports').textContent = data.completedReports || '0';
}

// Generate custom report
function generateCustomReport() {
    showReportGeneration();
}

// Handle report form submission
document.getElementById('reportForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    
    fetch('GenerateReport', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Report generated successfully!');
            hideReportGeneration();
            loadReports();
            // Auto-download if format is file-based
            if (data.downloadUrl) {
                window.open(data.downloadUrl, '_blank');
            }
        } else {
            alert('Error generating report: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error generating report');
    });
});

// Handle scheduled report form submission
document.getElementById('scheduledReportForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    
    fetch('AddScheduledReport', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Scheduled report added successfully!');
            hideScheduledReportForm();
            loadScheduledReports();
        } else {
            alert('Error adding scheduled report: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error adding scheduled report');
    });
});

// Search reports
function searchReports() {
    const searchTerm = document.getElementById('searchReports').value.toLowerCase();
    const rows = document.querySelectorAll('#reportsTableBody tr');
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

// Download report
function downloadReport(id) {
    fetch('DownloadReport?id=' + id)
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'report_' + id + '_' + new Date().toISOString().split('T')[0];
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error downloading report:', error);
            alert('Error downloading report');
        });
}

// View report
function viewReport(id) {
    fetch('ViewReport?id=' + id)
        .then(response => response.text())
        .then(html => {
            // Open report in new window or modal
            const newWindow = window.open('', '_blank');
            newWindow.document.write(html);
        })
        .catch(error => {
            console.error('Error viewing report:', error);
            alert('Error viewing report');
        });
}

// Delete report
function deleteReport(id) {
    if (confirm('Are you sure you want to delete this report?')) {
        fetch('DeleteReport', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                reportId: id
            })
        })
        .then(response => response.text())
        .then(data => {
            if (data.includes('success')) {
                loadReports();
            } else {
                alert('Error deleting report: ' + data);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting report');
        });
    }
}

// Edit scheduled report
function editScheduledReport(id) {
    fetch('GetScheduledReport?id=' + id)
        .then(response => response.json())
        .then(data => {
            // Populate form with scheduled report data
            const report = data.scheduledReport;
            document.getElementById('reportName').value = report.name;
            document.getElementById('scheduledReportType').value = report.type;
            document.getElementById('scheduleType').value = report.schedule;
            document.getElementById('recipients').value = report.recipients;
            showScheduledReportForm();
        })
        .catch(error => {
            console.error('Error editing scheduled report:', error);
        });
}

// Delete scheduled report
function deleteScheduledReport(id) {
    if (confirm('Are you sure you want to delete this scheduled report?')) {
        fetch('DeleteScheduledReport', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                reportId: id
            })
        })
        .then(response => response.text())
        .then(data => {
            if (data.includes('success')) {
                loadScheduledReports();
            } else {
                alert('Error deleting scheduled report: ' + data);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting scheduled report');
        });
    }
}

// Export all reports
function exportAllReports() {
    fetch('ExportAllReports')
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'all_reports_' + new Date().toISOString().split('T')[0] + '.zip';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error exporting all reports:', error);
            alert('Error exporting all reports');
        });
}

// Initialize charts
function initializeCharts() {
    // Attendance Chart
    const attendanceCtx = document.getElementById('attendanceChart').getContext('2d');
    new Chart(attendanceCtx, {
        type: 'line',
        data: {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            datasets: [{
                label: 'Attendance',
                data: [65, 59, 80, 81, 56, 55, 40],
                borderColor: 'rgb(75, 192, 192)',
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
    
    // Checklist Chart
    const checklistCtx = document.getElementById('checklistChart').getContext('2d');
    new Chart(checklistCtx, {
        type: 'bar',
        data: {
            labels: ['Security', 'Safety', 'Maintenance', 'Operations'],
            datasets: [{
                label: 'Completion Rate',
                data: [85, 92, 78, 88],
                backgroundColor: [
                    'rgba(255, 99, 132, 0.2)',
                    'rgba(54, 162, 235, 0.2)',
                    'rgba(255, 205, 86, 0.2)',
                    'rgba(75, 192, 192, 0.2)'
                ],
                borderColor: [
                    'rgba(255, 99, 132, 1)',
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 205, 86, 1)',
                    'rgba(75, 192, 192, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
    
    // Incident Chart
    const incidentCtx = document.getElementById('incidentChart').getContext('2d');
    new Chart(incidentCtx, {
        type: 'doughnut',
        data: {
            labels: ['Minor', 'Moderate', 'Major', 'Critical'],
            datasets: [{
                data: [12, 19, 3, 5],
                backgroundColor: [
                    'rgba(255, 206, 86, 0.2)',
                    'rgba(255, 159, 64, 0.2)',
                    'rgba(255, 99, 132, 0.2)',
                    'rgba(153, 102, 255, 0.2)'
                ],
                borderColor: [
                    'rgba(255, 206, 86, 1)',
                    'rgba(255, 159, 64, 1)',
                    'rgba(255, 99, 132, 1)',
                    'rgba(153, 102, 255, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
    
    // Performance Chart
    const performanceCtx = document.getElementById('performanceChart').getContext('2d');
    new Chart(performanceCtx, {
        type: 'radar',
        data: {
            labels: ['Attendance', 'Checklist', 'Response Time', 'Documentation', 'Training'],
            datasets: [{
                label: 'Current Month',
                data: [85, 92, 78, 88, 90],
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
            }, {
                label: 'Previous Month',
                data: [80, 88, 75, 85, 85],
                borderColor: 'rgb(255, 99, 132)',
                backgroundColor: 'rgba(255, 99, 132, 0.2)',
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

// Refresh charts
function refreshCharts() {
    // Reload chart data
    initializeCharts();
}

// Initialize on page load
window.onload = function() {
    loadReports();
    loadScheduledReports();
    initializeCharts();
};
</script>

<style>
.charts-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.chart-container {
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.chart-container h4 {
    margin: 0 0 15px 0;
    color: #2c3e50;
    font-size: 16px;
    font-weight: 600;
}

.date-range-group {
    display: flex;
    gap: 10px;
    align-items: center;
}

.date-range-group span {
    color: #6b7280;
    font-weight: 500;
}

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
    .charts-grid {
        grid-template-columns: 1fr;
    }
    
    .date-range-group {
        flex-direction: column;
        align-items: stretch;
    }
    
    .date-range-group span {
        text-align: center;
    }
}
</style>

</body>
</html>
