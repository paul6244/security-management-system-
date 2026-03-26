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
            <a href="#users">Users</a>
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
                    <h3>Total Reports</h3>
                    <h2><%= Mymodel.getTotalReports() %></h2>
                </div>
                <div class="card card4">
                    <h3>Total Incidents</h3>
                    <h2><%= Mymodel.getTotalIncidents() %></h2>
                </div>
            </div>

            <!-- CHARTS -->
            <div class="charts-grid">
                <div class="chart-container">
                    <h3>Personnel by Branch</h3>
                    <canvas id="branchChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Reports Trend</h3>
                    <canvas id="reportChart"></canvas>
                </div>
            </div>
        </div>

        <!-- PERSONNEL SECTION -->
        <div id="personnel" class="section" style="display: none;">
            <div class="header">
                <div>
                    <h1>Security Personnel Management</h1>
                    <p>View, search, and manage all security personnel</p>
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
                            <th>ID</th>
                            <th>Username</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Branch</th>
                            <th>Shift</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            ResultSet rs = Mymodel.getAllSecurityPersonnel();
                            if(rs != null) {
                                while(rs.next()){
                        %>
                        <tr class="personnel-row">
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getString("username") %></td>
                            <td class="username"><%= rs.getString("name") %></td>
                            <td class="email"><%= rs.getString("email") %></td>
                            <td class="branch"><%= rs.getString("branch_name") %></td>
                            <td><%= rs.getString("shift_time") %></td>
                            <td>
                                <button class="delete-btn" onclick="deletePersonnel(<%= rs.getInt("id") %>, '<%= rs.getString("name") %>')">Delete</button>
                            </td>
                        </tr>
                        <%
                                }
                                rs.close();
                            } else {
                        %>
                        <tr>
                            <td colspan="7" style="text-align: center; color: #666;">No personnel records found.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- USERS SECTION -->
        <div id="users" class="section" style="display: none;">
            <div class="header">
                <div>
                    <h1>User Management</h1>
                    <p>View and manage all system users (including personnel)</p>
                </div>
            </div>

            <!-- SEARCH BAR -->
            <div class="search-section">
                <div class="search-container">
                    <input type="text" id="searchUsersInput" placeholder="Search users by name, email, or role..." onkeyup="searchUsers()">
                    <button class="search-btn" onclick="searchUsers()">Search</button>
                    <button class="clear-btn" onclick="clearUsersSearch()">Clear</button>
                </div>
            </div>

            <!-- USERS TABLE -->
            <div class="table-section">
                <h2>All System Users</h2>

                <table id="usersTable" border="1" width="100%" cellpadding="10" style="background:white; border-radius:10px;">
                    <thead>
                        <tr style="background:#2c3e50; color:white;">
                            <th>ID</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Personnel Name</th>
                            <th>Branch</th>
                            <th>Created</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            ResultSet userRs = Mymodel.getAllUsers();
                            if(userRs != null) {
                                while(userRs.next()){
                        %>
                        <tr class="user-row">
                            <td><%= userRs.getInt("id") %></td>
                            <td><%= userRs.getString("username") %></td>
                            <td><%= userRs.getString("email") %></td>
                            <td><%= userRs.getString("role") %></td>
                            <td><%= userRs.getString("personnel_name") != null ? userRs.getString("personnel_name") : "N/A" %></td>
                            <td><%= userRs.getString("branch_name") != null ? userRs.getString("branch_name") : "N/A" %></td>
                            <td><%= userRs.getTimestamp("created_at") %></td>
                        </tr>
                        <%
                                }
                                userRs.close();
                            } else {
                        %>
                        <tr>
                            <td colspan="7" style="text-align: center; color: #666;">No users found.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<script>
    // Navigation
    function showSection(sectionId) {
        const sections = document.querySelectorAll('.section');
        sections.forEach(section => section.style.display = 'none');
        
        const targetSection = document.getElementById(sectionId);
        if (targetSection) {
            targetSection.style.display = 'block';
        }
    }

    // Navigation click handlers
    document.querySelectorAll('.nav a').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            showSection(targetId);
        });
    });

    // Search functionality for personnel
    function searchPersonnel() {
        const input = document.getElementById('searchInput');
        const filter = input.value.toLowerCase();
        const table = document.getElementById('personnelTable');
        const rows = table.getElementsByTagName('tr');
        
        let visibleCount = 0;
        for (let i = 1; i < rows.length; i++) {
            const row = rows[i];
            const text = row.textContent.toLowerCase();
            
            if (text.includes(filter)) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        }
        
        showSearchResults(visibleCount);
    }

    // Search functionality for users
    function searchUsers() {
        const input = document.getElementById('searchUsersInput');
        const filter = input.value.toLowerCase();
        const table = document.getElementById('usersTable');
        const rows = table.getElementsByTagName('tr');
        
        let visibleCount = 0;
        for (let i = 1; i < rows.length; i++) {
            const row = rows[i];
            const text = row.textContent.toLowerCase();
            
            if (text.includes(filter)) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        }
        
        showUsersSearchResults(visibleCount);
    }

    function clearSearch() {
        document.getElementById('searchInput').value = '';
        searchPersonnel();
    }

    function clearUsersSearch() {
        document.getElementById('searchUsersInput').value = '';
        searchUsers();
    }

    function showSearchResults(count) {
        const existingMessage = document.getElementById('searchMessage');
        if (existingMessage) {
            existingMessage.remove();
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

    function showUsersSearchResults(count) {
        const existingMessage = document.getElementById('usersSearchMessage');
        if (existingMessage) {
            existingMessage.remove();
        }
        
        // Show message if no results
        if (count === 0) {
            const table = document.getElementById('usersTable');
            const message = document.createElement('div');
            message.id = 'usersSearchMessage';
            message.style.textAlign = 'center';
            message.style.padding = '20px';
            message.style.color = '#666';
            message.innerHTML = 'No users found matching your search criteria.';
            table.parentNode.insertBefore(message, table);
        }
    }

    // Delete personnel functionality
    function deletePersonnel(personnelId, personnelName) {
        if (confirm(`Are you sure you want to delete ${personnelName}? This action cannot be undone.`)) {
            // Create a form to submit the delete request
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'DeletePersonnel';
            
            const personnelIdInput = document.createElement('input');
            personnelIdInput.type = 'hidden';
            personnelIdInput.name = 'personnelId';
            personnelIdInput.value = personnelId;
            
            form.appendChild(personnelIdInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

    // Initialize charts
    window.onload = function() {
        showSection('dashboard');
        
        // Branch distribution chart
        const branchCtx = document.getElementById('branchChart').getContext('2d');
        new Chart(branchCtx, {
            type: 'pie',
            data: {
                labels: ['Main Branch', 'North Branch', 'South Branch', 'East Branch'],
                datasets: [{
                    data: [12, 8, 6, 4],
                    backgroundColor: ['#3498db', '#e74c3c', '#f39c12', '#2ecc71']
                }]
            }
        });

        // Reports trend chart
        const reportCtx = document.getElementById('reportChart').getContext('2d');
        new Chart(reportCtx, {
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

    // Add search on Enter key
    document.getElementById('searchInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchPersonnel();
        }
    });

    document.getElementById('searchUsersInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchUsers();
        }
    });
</script>

<style>
    .delete-btn {
        background-color: #e74c3c;
        color: white;
        border: none;
        padding: 5px 10px;
        border-radius: 3px;
        cursor: pointer;
        font-size: 12px;
    }
    
    .delete-btn:hover {
        background-color: #c0392b;
    }
    
    .user-row:hover {
        background-color: #f5f5f5;
    }
    
    #usersTable {
        width: 100%;
        border-collapse: collapse;
    }
    
    #usersTable th, #usersTable td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }
    
    #usersTable th {
        background-color: #2c3e50;
        color: white;
        font-weight: bold;
    }
    
    #usersTable tr:hover {
        background-color: #f5f5f5;
    }
    
    .personnel-row:hover {
        background-color: #f5f5f5;
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
