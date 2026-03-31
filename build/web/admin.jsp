<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>

<%
    if(session.getAttribute("username") == null){
        response.sendRedirect("index.jsp");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="container">

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="logo">Security System</div>
        <div class="nav">
            <a href="#dashboard">Dashboard</a>
            <a href="#personnel">Personnel</a>
            <a href="userManagement.jsp">Users</a>
            <a href="reports.jsp">Reports</a>
            <a href="settings.jsp">Settings</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">

        <!-- HEADER -->
        <div class="header">
            <div>
                <h1>Welcome <%= session.getAttribute("username") %></h1>
                <p>Security Management Dashboard</p>
            </div>
            <div class="logout">
                <a href="Logout">Logout</a>
            </div>
        </div>

        <!-- DASHBOARD SECTION -->
        <div id="dashboard" class="section">
            <!-- ANALYTICS CARDS -->
            <div class="analytics-grid">
                <div class="card card1">
                    <h3>Total Security Staff</h3>
                    <h2><%= Mymodel.getTotalPersonnel() %></h2>
                </div>
                <div class="card card2">
                    <h3>Active Branches</h3>
                    <h2><%= Mymodel.getTotalBranches() %></h2>
                </div>
                <div class="card card3">
                    <h3>Shift Reports</h3>
                    <h2><%= Mymodel.getTotalReports() %></h2>
                </div>
                <div class="card card4">
                    <h3>Incidents</h3>
                    <h2><%= Mymodel.getTotalIncidents() %></h2>
                </div>
            </div>

            <!-- GET CHART DATA -->
            <%
                ResultSet rsReports = Mymodel.getReportsByDate();
                StringBuilder reportLabels = new StringBuilder();
                StringBuilder reportData = new StringBuilder();
                if(rsReports != null) {
                    while(rsReports.next()){
                        if(reportLabels.length() > 0) reportLabels.append(",");
                        if(reportData.length() > 0) reportData.append(",");
                        reportLabels.append("'").append(rsReports.getString("date")).append("'");
                        reportData.append(rsReports.getInt("total"));
                    }
                    rsReports.close();
                }

                ResultSet rsIncidents = Mymodel.getIncidentsByBranch();
                StringBuilder incidentLabels = new StringBuilder();
                StringBuilder incidentData = new StringBuilder();
                boolean hasIncidents = false;
                
                if(rsIncidents != null) {
                    while(rsIncidents.next()){
                        hasIncidents = true;
                        if(incidentLabels.length() > 0) incidentLabels.append(",");
                        if(incidentData.length() > 0) incidentData.append(",");
                        String branchName = rsIncidents.getString("branch_name");
                        int count = rsIncidents.getInt("total");
                        incidentLabels.append("'").append(branchName != null ? branchName : "Unknown").append("'");
                        incidentData.append(count);
                    }
                    rsIncidents.close();
                }
                
                // If no incidents found, show all branches with 0
                if(!hasIncidents) {
                    incidentLabels.append("'No Data'");
                    incidentData.append("0");
                }
            %>

            <!-- CHARTS -->
            <div class="charts">
                <div class="chart-box">
                    <h3>Security Reports</h3>
                    <canvas id="reportChart"></canvas>
                </div>
                <div class="chart-box">
                    <h3>Incidents by Branch</h3>
                    <canvas id="incidentChart"></canvas>
                </div>
            </div>
        </div>

        <!-- PERSONNEL SECTION -->
        <div id="personnel" class="section" style="display: none;">
            <div class="header">
                <div>
                    <h1>Security Personnel Management</h1>
                    <p>View and search all security personnel</p>
                </div>
            </div>

            <!-- SEARCH BAR -->
            <div class="search-section">
                <div class="search-container">
                    <input type="text" id="searchInput" placeholder="Search personnel by name, email, or branch..." onkeyup="searchPersonnel()">
                    <button class="search-btn" onclick="searchPersonnel()">Search</button>
                    <button class="clear-btn" onclick="clearSearch()">Clear</button>
                </div>
            </div>

            <!-- PERSONNEL TABLE -->
            <div class="table-section">
                <h2>All Security Personnel</h2>

                <table id="personnelTable" border="1" width="100%" cellpadding="10" style="background:white; border-radius:10px;">
                    <thead>
                        <tr style="background:#2c3e50; color:white;">
                            <th>Name</th>
                            <th>Email</th>
                            <th>Branch</th>
                            <th>Shift Time</th>
                            <th>ID</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            ResultSet rs = Mymodel.getAllPersonnel();
                            if(rs != null) {
                                while(rs.next()){
                        %>
                        <tr class="personnel-row">
                            <td class="username"><%= rs.getString("name") %></td>
                            <td class="email"><%= rs.getString("email") %></td>
                            <td class="branch"><%= rs.getString("branch_name") %></td>
                            <td class="shift-time"><%= rs.getString("shift_time") %></td>
                            <td class="id"><%= rs.getInt("id") %></td>
                        </tr>
                        <% 
                                }
                                rs.close();
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<script>
    // Navigation functionality
    function showSection(sectionId) {
        // Hide all sections
        const sections = document.querySelectorAll('.section');
        sections.forEach(section => {
            section.style.display = 'none';
        });
        
        // Show selected section
        const selectedSection = document.getElementById(sectionId);
        if (selectedSection) {
            selectedSection.style.display = 'block';
        }
        
        // Update active nav link
        const navLinks = document.querySelectorAll('.nav a');
        navLinks.forEach(link => {
            link.classList.remove('active');
        });
        
        const activeLink = document.querySelector(`.nav a[href="#${sectionId}"]`);
        if (activeLink) {
            activeLink.classList.add('active');
        }
    }

    // Search functionality
    function searchPersonnel() {
        const input = document.getElementById('searchInput');
        const filter = input.value.toLowerCase();
        const table = document.getElementById('personnelTable');
        const rows = table.getElementsByTagName('tr');
        
        let visibleCount = 0;
        
        // Loop through all table rows (except the header)
        for (let i = 1; i < rows.length; i++) {
            const row = rows[i];
            const cells = row.getElementsByTagName('td');
            let found = false;
            
            // Search through all cells in the row
            for (let j = 0; j < cells.length; j++) {
                const cellText = cells[j].textContent || cells[j].innerText;
                if (cellText.toLowerCase().indexOf(filter) > -1) {
                    found = true;
                    break;
                }
            }
            
            // Show or hide the row
            if (found) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        }
        
        // Show message if no results found
        showSearchResults(visibleCount);
    }

    function clearSearch() {
        document.getElementById('searchInput').value = '';
        searchPersonnel();
    }

    function showSearchResults(count) {
        // Remove existing message if any
        const existingMsg = document.getElementById('searchMessage');
        if (existingMsg) {
            existingMsg.remove();
        }
        
        // Show message if no results
        if (count === 0) {
            const table = document.getElementById('personnelTable');
            const message = document.createElement('div');
            message.id = 'searchMessage';
            message.style.textAlign = 'center';
            message.style.padding = '20px';
            message.style.color = '#666';
            message.innerHTML = 'No personnel found matching your search criteria.';
            table.parentNode.insertBefore(message, table);
        }
    }

    // Handle navigation clicks
    document.addEventListener('DOMContentLoaded', function() {
        const navLinks = document.querySelectorAll('.nav a');
        
        navLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                const href = this.getAttribute('href');
                
                if (href.startsWith('#')) {
                    const sectionId = href.substring(1);
                    showSection(sectionId);
                } else {
                    // For external links, navigate normally
                    window.location.href = href;
                }
            });
        });
        
        // Show dashboard by default
        showSection('dashboard');
        
        // Add search on Enter key
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchPersonnel();
            }
        });
    });

    // REPORT CHART
    new Chart(document.getElementById("reportChart"), {
        type: "line",
        data: {
            labels: [<%= (reportLabels.length() > 0 ? reportLabels.toString() : "") %>],
            datasets: [{
                label: "Reports",
                data: [<%= (reportData.length() > 0 ? reportData.toString() : "0") %>],
                borderWidth: 2,
                fill: false,
                borderColor: "#3498db",
                tension: 0.3
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: true }
            }
        }
    });

    // INCIDENT CHART
    new Chart(document.getElementById("incidentChart"), {
        type: "bar",
        data: {
            labels: [<%= (incidentLabels != null && incidentLabels.length() > 0) ? incidentLabels.toString() : "" %>],
            datasets: [{
                label: "Incidents",
                data: [<%= (incidentData != null && incidentData.length() > 0) ? incidentData.toString() : "0" %>],
                backgroundColor: "#e74c3c"
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: true }
            }
        }
    });
</script>

<style>
    .section {
        display: none;
    }
    
    .nav a.active {
        background-color: #3498db;
        color: white;
    }
    
    .search-section {
        margin: 20px 0;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 8px;
    }
    
    .search-container {
        display: flex;
        gap: 10px;
        align-items: center;
        max-width: 600px;
        margin: 0 auto;
    }
    
    #searchInput {
        flex: 1;
        padding: 12px;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-size: 14px;
    }
    
    .search-btn, .clear-btn {
        padding: 12px 20px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 14px;
        transition: background-color 0.3s;
    }
    
    .search-btn {
        background-color: #3498db;
        color: white;
    }
    
    .search-btn:hover {
        background-color: #2980b9;
    }
    
    .clear-btn {
        background-color: #95a5a6;
        color: white;
    }
    
    .clear-btn:hover {
        background-color: #7f8c8d;
    }
    
    .personnel-row:hover {
        background-color: #f5f5f5;
    }
    
    .table-section {
        margin: 20px 0;
        padding: 20px;
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    #personnelTable {
        width: 100%;
        border-collapse: collapse;
    }
    
    #personnelTable th, #personnelTable td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }
    
    #personnelTable th {
        background-color: #2c3e50;
        color: white;
        font-weight: bold;
    }
    
    #personnelTable tr:hover {
        background-color: #f5f5f5;
    }
</style>

</body>
</html>