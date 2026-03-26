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
</head>
<body>

<div class="container">
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="logo">Security System</div>
        <div class="nav">
            <a href="admin.jsp">Dashboard</a>
            <a href="admin.jsp#personnel">Personnel</a>
            <a href="admin.jsp#users">Users</a>
            <a href="#reports">Reports</a>
            <a href="settings.jsp">Settings</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">

        <!-- HEADER -->
        <div class="header">
            <div>
                <h1>Security Reports</h1>
                <p>View and analyze incident reports and shift reports</p>
            </div>
            <div class="logout">
                <a href="Logout">Logout</a>
            </div>
        </div>

        <!-- FILTERS SECTION -->
        <div class="filters-section">
            <h3>Filter Reports</h3>
            <form method="GET" action="reports.jsp">
                <div class="filter-group">
                    <label>Date From:</label>
                    <input type="date" name="dateFrom" value="<%= request.getParameter("dateFrom") != null ? request.getParameter("dateFrom") : "" %>">
                </div>
                <div class="filter-group">
                    <label>Date To:</label>
                    <input type="date" name="dateTo" value="<%= request.getParameter("dateTo") != null ? request.getParameter("dateTo") : "" %>">
                </div>
                <div class="filter-group">
                    <label>Branch:</label>
                    <select name="branch">
                        <option value="">All Branches</option>
                        <%
                        ResultSet branchRs = Mymodel.getAllBranches();
                        if(branchRs != null) {
                            while(branchRs.next()) {
                        %>
                        <option value="<%= branchRs.getString("name") %>" <%= branchRs.getString("name").equals(request.getParameter("branch")) ? "selected" : "" %>><%= branchRs.getString("name") %></option>
                        <%
                            }
                            branchRs.close();
                        }
                        %>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Status:</label>
                    <select name="status">
                        <option value="">All Status</option>
                        <option value="OK" <%= "OK".equals(request.getParameter("status")) ? "selected" : "" %>>OK</option>
                        <option value="NOT_OK" <%= "NOT_OK".equals(request.getParameter("status")) ? "selected" : "" %>>INCIDENT</option>
                    </select>
                </div>
                <button type="submit" class="btn">Apply Filters</button>
            </form>
        </div>

        <!-- STATISTICS CARDS -->
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

        <!-- REPORTS TABLE -->
        <div class="reports-container">
            <h3>Incident Reports</h3>
            <table border="1" width="100%" cellpadding="10" style="background:white; border-radius:10px;">
                <thead>
                    <tr style="background:#2c3e50; color:white;">
                        <th>Date/Time</th>
                        <th>Branch</th>
                        <th>Personnel</th>
                        <th>User</th>
                        <th>Check Item</th>
                        <th>Status</th>
                        <th>Reason</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String dateFrom = request.getParameter("dateFrom");
                        String dateTo = request.getParameter("dateTo");
                        String branch = request.getParameter("branch");
                        String status = request.getParameter("status");
                        
                        // If no status filter is set, get all records including INCIDENT
                        if(status == null || status.isEmpty()) {
                            status = "all"; // Get all records
                        }
                        
                        ResultSet rs = Mymodel.getIncidentReports(dateFrom, dateTo, branch, status);
                        boolean hasData = false;
                        int totalRecords = 0;
                        
                        if(rs != null) {
                            while(rs.next()){
                                hasData = true;
                                totalRecords++;
                                String reportStatus = rs.getString("status");
                                boolean isIncident = "NOT_OK".equals(reportStatus);
                    %>
                    <tr>
                        <td><%= new SimpleDateFormat("MMM dd, yyyy HH:mm").format(rs.getTimestamp("check_time")) %></td>
                        <td><%= rs.getString("branch_name") %></td>
                        <td><%= rs.getString("personnel_name") %></td>
                        <td><%= rs.getString("user_name") %></td>
                        <td><%= rs.getString("item_name") %></td>
                        <td>
                            <span class="<%= isIncident ? "status-incident" : "status-ok" %>">
                                <%= isIncident ? "Incident" : "OK" %>
                            </span>
                        </td>
                        <td><%= rs.getString("reason") != null && !rs.getString("reason").isEmpty() ? rs.getString("reason") : "-" %></td>
                    </tr>
                    <%
                            }
                            rs.close();
                        } else {
                    %>
                    <tr>
                        <td colspan="7" style="text-align: center; color: #666;">No incident reports found matching your criteria.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>

        <!-- CHARTS SECTION -->
        <div class="charts-grid">
            <div class="chart-container">
                <h3>Incidents by Branch</h3>
                <canvas id="incidentsChart"></canvas>
            </div>
            <div class="chart-container">
                <h3>Reports Trend</h3>
                <canvas id="reportsChart"></canvas>
            </div>
        </div>

    </div>
</div>

<script>
    // Chart data variables
    var incidentLabels = [];
    var incidentData = [];
    
    <%
        ResultSet rsIncidents = Mymodel.getIncidentsByBranch();
        if(rsIncidents != null) {
            while(rsIncidents.next()){
                if(incidentLabels.length > 0) incidentLabels.push(",");
                if(incidentData.length > 0) incidentData.push(",");
                incidentLabels.push("'").append(rsIncidents.getString("branch_name")).append("'");
                incidentData.append(rsIncidents.getInt("total"));
        }
        rsIncidents.close();
    }
    %>

    // Chart data variables
    var reportLabels = [];
    var reportData = [];
    
    // Initialize charts
    window.onload = function() {
        // Incidents by Branch Chart
        new Chart(document.getElementById('incidentsChart'), {
            type: 'bar',
            data: {
                labels: [<%= incidentLabels.length() > 0 ? incidentLabels : "''" %>],
                datasets: [{
                    label: 'Incidents',
                    data: [<%= incidentData.length() > 0 ? incidentData : "0" %>],
                    backgroundColor: "#e74c3c"
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        // Reports Trend Chart
        new Chart(document.getElementById('reportsChart'), {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Reports',
                    data: [12, 19, 15, 25, 22, 30],
                    borderColor: '#3498db',
                    backgroundColor: 'rgba(52, 152, 219, 0.1)'
                }]
            }
        });
    };
</script>

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
        background-color: #3498db;
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 5px;
        cursor: pointer;
        font-weight: bold;
    }
    
    .btn:hover {
        background-color: #2980b9;
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
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        text-align: center;
    }
    
    .stat-card h4 {
        margin: 0 0 10px 0;
        color: #2c3e50;
        font-size: 14px;
    }
    
    .stat-card .number {
        font-size: 24px;
        font-weight: bold;
        color: #3498db;
        margin-bottom: 5px;
    }
    
    .stat-card.incident .number {
        color: #e74c3c;
    }
    
    .stat-card.success .number {
        color: #27ae60;
    }
    
    .status-incident {
        background: #f8d7da;
        color: #721c24;
        padding: 4px 8px;
        border-radius: 4px;
        font-weight: bold;
    }
    
    .status-ok {
        background: #d4edda;
        color: #155724;
        padding: 4px 8px;
        border-radius: 4px;
        font-weight: bold;
    }
    
    .charts-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
        gap: 20px;
        margin-top: 20px;
    }
    
    .chart-container {
        background: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .chart-container h3 {
        color: #2c3e50;
        margin-bottom: 15px;
    }
</style>
</body>
</html>
