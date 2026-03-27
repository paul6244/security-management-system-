<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - Security Management System</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .reports-container {
            padding: 20px;
        }
        .filters-section {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .filters-section h3 {
            color: #2c3e50;
            margin-bottom: 15px;
        }
        .filter-group {
            display: inline-block;
            margin-right: 20px;
            margin-bottom: 10px;
        }
        .filter-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .filter-group input, .filter-group select {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: 150px;
        }
        .btn {
            background: #3498db;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
        }
        .btn:hover {
            background: #2980b9;
        }
        .btn-export {
            background: #27ae60;
        }
        .btn-export:hover {
            background: #229954;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            text-align: center;
        }
        .stat-card h4 {
            color: #666;
            margin-bottom: 10px;
            font-size: 14px;
        }
        .stat-card .number {
            font-size: 32px;
            font-weight: bold;
            color: #2c3e50;
        }
        .stat-card.incident .number {
            color: #e74c3c;
        }
        .stat-card.success .number {
            color: #27ae60;
        }
        .reports-table {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .table-responsive {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: #2c3e50;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: bold;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .status-ok {
            background: #d4edda;
            color: #155724;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-incident {
            background: #f8d7da;
            color: #721c24;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .charts-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #666;
            font-style: italic;
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
            <a href="#" class="active">Reports</a>
            <a href="settings.jsp">Settings</a>
        </div>
        <div class="logout">
            <a href="Logout">Logout</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="header">
            <div>
                <h1>Security Reports</h1>
                <p>View and analyze shift reports and incidents</p>
            </div>
        </div>

        <div class="reports-container">
            <!-- Statistics Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h4>Total Reports</h4>
                    <div class="number"><%= Mymodel.getTotalReports() %></div>
                </div>
                <div class="stat-card incident">
                    <h4>Total Incidents</h4>
                    <div class="number"><%= Mymodel.getTotalIncidents() %></div>
                </div>
                <div class="stat-card success">
                    <h4>OK Reports</h4>
                    <div class="number"><%= Mymodel.getTotalReports() - Mymodel.getTotalIncidents() %></div>
                </div>
                <div class="stat-card">
                    <h4>Active Personnel</h4>
                    <div class="number"><%= Mymodel.getTotalPersonnel() %></div>
                </div>
            </div>

            <!-- Filters Section -->
            <div class="filters-section">
                <h3>Filters</h3>
                <form action="reports.jsp" method="get">
                    <div class="filter-group">
                        <label for="dateFrom">Date From:</label>
                        <input type="date" id="dateFrom" name="dateFrom" value="<%= request.getParameter("dateFrom") != null ? request.getParameter("dateFrom") : "" %>">
                    </div>
                    <div class="filter-group">
                        <label for="dateTo">Date To:</label>
                        <input type="date" id="dateTo" name="dateTo" value="<%= request.getParameter("dateTo") != null ? request.getParameter("dateTo") : "" %>">
                    </div>
                    <div class="filter-group">
                        <label for="branch">Branch:</label>
                        <select id="branch" name="branch">
                            <option value="">All Branches</option>
                            <%
                            ResultSet rsBranches = Mymodel.getBranches();
                            while(rsBranches != null && rsBranches.next()){
                                String selectedBranch = request.getParameter("branch");
                                boolean isSelected = selectedBranch != null && selectedBranch.equals(rsBranches.getString("id"));
                            %>
                                <option value="<%= rsBranches.getInt("id") %>" <%= isSelected ? "selected" : "" %>>
                                    <%= rsBranches.getString("name") %>
                                </option>
                            <%
                            }
                            if(rsBranches != null) rsBranches.close();
                            %>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="status">Status:</label>
                        <select id="status" name="status">
                            <option value="">All Status</option>
                            <option value="OK" <%= "OK".equals(request.getParameter("status")) ? "selected" : "" %>>OK</option>
                            <option value="NOT_OK" <%= "NOT_OK".equals(request.getParameter("status")) ? "selected" : "" %>>INCIDENT</option>
                        </select>
                    </div>
                    <button type="submit" class="btn">Apply Filters</button>
                    <button type="button" class="btn btn-export" onclick="exportReports()">Export to CSV</button>
                </form>
            </div>

            <!-- Charts Section -->
            <div class="charts-section">
                <div class="chart-container">
                    <h3>Reports Trend</h3>
                    <canvas id="reportsChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Incidents by Branch</h3>
                    <canvas id="incidentsChart"></canvas>
                </div>
            </div>

            <!-- Reports Table -->
            <div class="reports-table">
                <h3>Shift Reports</h3>
                
                <!-- Dynamic Reports Table -->
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Date/Time</th>
                                <th>Officer</th>
                                <th>Branch</th>
                                <th>Item</th>
                                <th>Status</th>
                                <th>Reason</th>
                            </tr>
                        </thead>
                        <tbody id="reportTableBody">
                            <tr>
                                <td colspan="6" style="text-align: center; padding: 20px;">Loading reports...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Prepare chart data from server-side variables
<%
    StringBuilder reportLabels = new StringBuilder();
    StringBuilder reportData = new StringBuilder();
    
    ResultSet rsReports = Mymodel.getReportsByDate();
    if(rsReports != null) {
        while(rsReports.next()){
            if(reportLabels.length() > 0) reportLabels.append(",");
            if(reportData.length() > 0) reportData.append(",");
            reportLabels.append("'").append(rsReports.getString("date")).append("'");
            reportData.append(rsReports.getInt("total"));
        }
        rsReports.close();
    }

    StringBuilder incidentLabels = new StringBuilder();
    StringBuilder incidentData = new StringBuilder();
    
    ResultSet rsIncidents = Mymodel.getIncidentsByBranch();
    if(rsIncidents != null) {
        while(rsIncidents.next()){
            if(incidentLabels.length() > 0) incidentLabels.append(",");
            if(incidentData.length() > 0) incidentData.append(",");
            incidentLabels.append("'").append(rsIncidents.getString("branch_name")).append("'");
            incidentData.append(rsIncidents.getInt("total"));
        }
        rsIncidents.close();
    }
%>

// Chart data variables
var reportLabels = [<%= reportLabels.length() > 0 ? reportLabels : "''" %>];
var reportData = [<%= reportData.length() > 0 ? reportData : "0" %>];
var incidentLabels = [<%= incidentLabels.length() > 0 ? incidentLabels : "''" %>];
var incidentData = [<%= incidentData.length() > 0 ? incidentData : "0" %>];

// Reports Trend Chart
new Chart(document.getElementById("reportsChart"), {
    type: "line",
    data: {
        labels: reportLabels,
        datasets: [{
            label: "Reports",
            data: reportData,
            borderColor: "#3498db",
            backgroundColor: "rgba(52, 152, 219, 0.1)",
            tension: 0.3,
            fill: true
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { display: true }
        },
        scales: {
            y: {
                beginAtZero: true
            }
        }
    }
});

// Incidents by Branch Chart
new Chart(document.getElementById("incidentsChart"), {
    type: "bar",
    data: {
        labels: incidentLabels,
        datasets: [{
            label: "Incidents",
            data: incidentData,
            backgroundColor: "#e74c3c"
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { display: true }
        },
        scales: {
            y: {
                beginAtZero: true
            }
        }
    }
});

// Export to CSV function
function exportReports() {
    const table = document.querySelector('table');
    let csv = [];
    
    // Get headers
    const headers = [];
    table.querySelectorAll('thead th').forEach(th => {
        headers.push(th.textContent.trim());
    });
    csv.push(headers.join(','));
    
    // Get data rows
    table.querySelectorAll('tbody tr').forEach(tr => {
        const row = [];
        tr.querySelectorAll('td').forEach(td => {
            let text = td.textContent.trim();
            // Escape quotes and commas
            if(text.includes(',') || text.includes('"')) {
                text = '"' + text.replace(/"/g, '""') + '"';
            }
            row.push(text);
        });
        csv.push(row.join(','));
    });
    
    // Create and download CSV file
    const csvContent = csv.join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'security_reports_' + new Date().toISOString().split('T')[0] + '.csv';
    a.click();
    window.URL.revokeObjectURL(url);
}

// Set today's date as default for date filters
document.addEventListener('DOMContentLoaded', function() {
    const today = new Date().toISOString().split('T')[0];
    if(!document.getElementById('dateTo').value) {
        document.getElementById('dateTo').value = today;
    }
});
</script>

<script>
// Load filtered reports via AJAX
function loadFilteredReports() {
    const dateFrom = document.getElementById('dateFrom').value;
    const dateTo = document.getElementById('dateTo').value;
    const branch = document.getElementById('branch').value;
    const status = document.getElementById('status').value;
    
    // Build query parameters
    const params = new URLSearchParams();
    if (dateFrom) params.append('dateFrom', dateFrom);
    if (dateTo) params.append('dateTo', dateTo);
    if (branch) params.append('branch', branch);
    if (status) params.append('status', status);
    
    // Show loading state
    const tableBody = document.getElementById('reportTableBody');
    tableBody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">Loading reports...</td></tr>';
    
    // Fetch filtered reports
    fetch('/GetFilteredReports?' + params.toString())
        .then(response => response.json())
        .then(data => {
            displayReports(data);
        })
        .catch(error => {
            console.error('Error loading reports:', error);
            tableBody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #e74c3c;">Error loading reports. Please try again.</td></tr>';
        });
}

// Display reports in table
function displayReports(reports) {
    const tableBody = document.getElementById('reportTableBody');
    
    if (!reports || reports.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #666;">No reports found matching your criteria.</td></tr>';
        return;
    }
    
    let html = '';
    reports.forEach(report => {
        const isIncident = report.status === 'NOT_OK' || report.status === 'Not ok';
        const statusClass = isIncident ? 'status-incident' : 'status-ok';
        const statusText = isIncident ? 'Not ok' : 'OK';
        const reasonText = report.reason && report.reason.trim() !== '' ? report.reason : '-';
        
        html += `
            <tr>
                <td>${formatDateTime(report.checkTime)}</td>
                <td>${report.username}</td>
                <td>${report.branch}</td>
                <td>${report.itemName}</td>
                <td>
                    <span class="${statusClass}">${statusText}</span>
                </td>
                <td>${reasonText}</td>
            </tr>
        `;
    });
    
    tableBody.innerHTML = html;
}

// Format date/time for display
function formatDateTime(dateTimeStr) {
    if (!dateTimeStr) return '';
    
    const date = new Date(dateTimeStr);
    return date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Auto-load reports when page loads
document.addEventListener('DOMContentLoaded', function() {
    // Load initial reports
    loadFilteredReports();
    
    // Add event listeners to filter controls
    ['dateFrom', 'dateTo', 'branch', 'status'].forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            element.addEventListener('change', loadFilteredReports);
        }
    });
    
    // Override form submission to use AJAX
    const filterForm = document.querySelector('form');
    if (filterForm) {
        filterForm.addEventListener('submit', function(e) {
            e.preventDefault();
            loadFilteredReports();
        });
    }
});
</script>

</body>
</html>
