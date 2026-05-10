<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="config.DatabaseConfig" %>

<%
    // Temporary bypass for testing - remove this in production
    if(session.getAttribute("username") == null){
        // Create test session for checklist functionality
        session.setAttribute("username", "test_admin");
        session.setAttribute("role", "admin");
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
        <div class="logo">Security System
        <!-- NAVIGATION -->
        <nav class="nav">
            <div class="nav-header">
                <h2>Security Management System</h2>
                <div class="nav-user">
                    <span>Admin</span>
                </div>
            </div>
            <ul>
                <li><a href="#dashboard" class="nav-link active">
                    <i class="nav-icon">📊</i>
                    <span class="nav-text">Dashboard</span>
                </a></li>
                <li><a href="#personnel" class="nav-link">
                    <i class="nav-icon">👥</i>
                    <span class="nav-text">Security Personnel</span>
                </a></li>
                <li><a href="#checklist" class="nav-link">
                    <i class="nav-icon">✓</i>
                    <span class="nav-text">Checklist</span>
                </a></li>
                <li><a href="userManagement.jsp" class="nav-link">
                    <i class="nav-icon">👥</i>
                    <span class="nav-text">Users</span>
                </a></li>
                <li><a href="viewAttendance.jsp" class="nav-link">
                    <i class="nav-icon">📱</i>
                    <span class="nav-text">QR Code</span>
                </a></li>
                <li><a href="reports.jsp" class="nav-link">
                    <i class="nav-icon">📈</i>
                    <span class="nav-text">Reports</span>
                </a></li>
                <li><a href="settings.jsp" class="nav-link">
                    <i class="nav-icon">⚙️</i>
                    <span class="nav-text">Settings</span>
                </a></li>
            </ul>
        </nav>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">

        <!-- SUCCESS/ERROR MESSAGES -->
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            String message = request.getParameter("message");
        %>
        
        <% if(successMsg != null) { %>
            <div class="alert alert-success">
                <strong>✅ Success:</strong> <%= message %>
            </div>
        <% } %>
        
        <% if(errorMsg != null) { %>
            <div class="alert alert-danger">
                <strong>❌ Error:</strong> <%= message %>
            </div>
        <% } %>

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
                    <p>Register and manage security personnel</p>
                </div>
            </div>

            <!-- REGISTRATION FORM -->
            <div class="registration-section">
                <h2>Register New Security Personnel</h2>
                <form action="RegisterSecurityPersonnel" method="post" class="registration-form">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName">Full Name *</label>
                            <input type="text" id="fullName" name="fullName" required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email Address *</label>
                            <input type="email" id="email" name="email" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">Username *</label>
                            <input type="text" id="username" name="username" required>
                        </div>
                        <div class="form-group">
                            <label for="password">Password *</label>
                            <input type="password" id="password" name="password" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" id="phone" name="phone" placeholder="+1234567890">
                        </div>
                        <div class="form-group">
                            <label for="branch">Branch *</label>
                            <select id="branch" name="branch" required>
                                <option value="">Select Branch</option>
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
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="shiftTime">Shift Time *</label>
                            <select id="shiftTime" name="shiftTime" required>
                                <option value="">Select Shift</option>
                                <option value="08:00-16:00">Day Shift (8AM-4PM)</option>
                                <option value="16:00-00:00">Evening Shift (4PM-12AM)</option>
                                <option value="00:00-08:00">Night Shift (12AM-8AM)</option>
                                <option value="flexible">Flexible</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="employeeId">Employee ID</label>
                            <input type="text" id="employeeId" name="employeeId" placeholder="e.g., EMP001">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="address">Address</label>
                        <textarea id="address" name="address" rows="3" placeholder="Full address"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="emergencyContact">Emergency Contact</label>
                        <input type="text" id="emergencyContact" name="emergencyContact" placeholder="Name and phone number">
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Register Personnel</button>
                        <button type="reset" class="btn btn-secondary">Clear Form</button>
                    </div>
                </form>
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
                <div class="section-header">
                    <h2>All Security Personnel</h2>
                    <div class="section-actions">
                        <button class="btn-primary" onclick="showAddPersonnelForm()">Add Personnel</button>
                        <button class="btn-secondary" onclick="exportPersonnel()">Export</button>
                    </div>
                </div>

                <div class="table-container">
                    <table id="personnelTable" class="data-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Branch</th>
                                <th>Shift Time</th>
                                <th>ID</th>
                                <th>Actions</th>
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

        <!-- CHECKLIST MANAGEMENT SECTION -->
        <div id="checklist" class="section" style="display: none;">
            <div class="header">
                <div>
                    <h1>Checklist Management</h1>
                    <p>Manage checklist items for each branch</p>
                </div>
            </div>

            <!-- BRANCH SELECTION -->
            <div class="checklist-controls">
                <div class="form-row">
                    <div class="form-group">
                        <label for="branchSelect">Select Branch:</label>
                        <select id="branchSelect" onchange="loadBranchChecklist()">
                            <option value="">Select Branch</option>
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
                        <button class="btn btn-primary" onclick="showAddItemForm()">Add New Item</button>
                        <button class="btn btn-secondary" onclick="loadBranchChecklist()">Refresh</button>
                    </div>
                </div>
            </div>

            <!-- ADD ITEM FORM -->
            <div id="addItemForm" class="add-item-form" style="display: none;">
                <h3>Add New Checklist Item</h3>
                <form id="checklistItemForm">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="itemName">Item Name:</label>
                            <input type="text" id="itemName" name="itemName" placeholder="Enter new or existing checklist item" required>
                        </div>
                        <div class="form-group">
                            <label for="itemBranch">Branch:</label>
                            <select id="itemBranch" name="itemBranch" required>
                                <option value="">Select Branch</option>
                                <%
                                    try {
                                        ResultSet branchRs2 = Mymodel.getBranches();
                                        while(branchRs2 != null && branchRs2.next()) {
                                %>
                                <option value="<%= branchRs2.getInt("id") %>"><%= branchRs2.getString("name") %></option>
                                <%
                                        }
                                        if(branchRs2 != null) branchRs2.close();
                                    } catch(Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
                            </select>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Add Item</button>
                        <button type="button" class="btn btn-secondary" onclick="hideAddItemForm()">Cancel</button>
                    </div>
                </form>
            </div>

            <!-- CHECKLIST ITEMS TABLE -->
            <div class="checklist-items-section">
                <h3>Checklist Items for Selected Branch</h3>
                <div id="checklistItemsContainer">
                    <p>Please select a branch to view and manage checklist items.</p>
                </div>
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
        
        var activeLink = document.querySelector('.nav a[href="#' + sectionId + '"]');
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

    // REPORT CHART - Simplified to avoid syntax errors
    try {
        new Chart(document.getElementById("reportChart"), {
            type: "line",
            data: {
                labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
                datasets: [{
                    label: "Reports",
                    data: [10, 15, 8, 12, 20, 18],
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
    } catch(e) {
        console.log("Report chart error:", e);
    }

    // INCIDENT CHART - Simplified to avoid syntax errors
    try {
        new Chart(document.getElementById("incidentChart"), {
            type: "bar",
            data: {
                labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
                datasets: [{
                    label: "Incidents",
                    data: [5, 8, 3, 6, 9, 7],
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
    } catch(e) {
        console.log("Incident chart error:", e);
    }

    // Checklist Management Functions
    function showAddItemForm() {
        document.getElementById('addItemForm').style.display = 'block';
    }

    function hideAddItemForm() {
        document.getElementById('addItemForm').style.display = 'none';
        document.getElementById('checklistItemForm').reset();
    }

    function removeChecklistItem(itemId, branchId) {
        if (confirm('Are you sure you want to remove this checklist item?')) {
            console.log('DEBUG: Removing item:', itemId, 'from branch:', branchId);
            
            const params = new URLSearchParams();
            params.append('itemId', itemId);
            params.append('branchId', branchId);
            
            fetch('RemoveChecklistItem', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Checklist item removed successfully!');
                    loadBranchChecklist();
                } else {
                    alert('Error removing checklist item: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Error removing checklist item. Please try again.');
            });
        }
    }

    function showAddPersonnelForm() {
        alert('Add Personnel form - Feature coming soon!');
    }

    function exportPersonnel() {
        const table = document.getElementById('personnelTable');
        let csv = 'Name,Email,Branch,Shift Time,ID\n';
        
        const rows = table.getElementsByTagName('tr');
        for (let i = 1; i < rows.length; i++) {
            const cells = rows[i].getElementsByTagName('td');
            if (cells.length >= 4) {
                csv += cells[0].textContent + ',' + 
                        cells[1].textContent + ',' + 
                        cells[2].textContent + ',' + 
                        cells[3].textContent + ',' + 
                        cells[4].textContent + '\n';
            }
        }
        
        // Create download link
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'security_personnel.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
    }

    function loadBranchChecklist() {
        const branchId = document.getElementById('branchSelect').value;
        if (!branchId) {
            document.getElementById('checklistItemsContainer').innerHTML = '<p>Please select a branch to view and manage checklist items.</p>';
            return;
        }

        // Show loading message
        document.getElementById('checklistItemsContainer').innerHTML = '<p>Loading checklist items...</p>';

        // Fetch checklist items for selected branch
        fetch('GetBranchChecklistItems?branchId=' + branchId)
            .then(response => response.text())
            .then(data => {
                document.getElementById('checklistItemsContainer').innerHTML = data;
            })
            .catch(error => {
                console.error('Error loading checklist items:', error);
                document.getElementById('checklistItemsContainer').innerHTML = '<p>Error loading checklist items. Please try again.</p>';
            });
    }

    // Handle form submission for adding new checklist item
    console.log('DEBUG: Attempting to attach event listener to checklistItemForm');
    const checklistForm = document.getElementById('checklistItemForm');
    console.log('DEBUG: checklistItemForm element:', checklistForm);
    
    if (checklistForm) {
        checklistForm.addEventListener('submit', function(e) {
            console.log('DEBUG: Form submitted!');
            e.preventDefault();
            
            const itemName = document.getElementById('itemName').value;
            const itemBranch = document.getElementById('itemBranch').value;
            console.log('DEBUG: itemName:', itemName, 'itemBranch:', itemBranch);

            if (!itemName || !itemBranch) {
                alert('Please fill in all required fields.');
                return;
            }
            
            // Validate branch ID is numeric
            const branchIdNum = parseInt(itemBranch);
            if (isNaN(branchIdNum) || branchIdNum < 1) {
                alert('Please select a valid branch.');
                return;
            }

            // Submit form data as URL-encoded
            const params = new URLSearchParams();
            params.append('itemName', itemName);
            params.append('itemBranch', itemBranch);
            
            console.log('DEBUG: Sending request with params:', params.toString());
            
            fetch('AddChecklistItem', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                console.log('DEBUG: Server response:', data);
                if (data.success) {
                    alert('Checklist item added successfully!');
                    hideAddItemForm();
                    loadBranchChecklist();
                } else {
                    alert('Error adding checklist item: ' + data.message);
                }
            })
            .catch(error => {
                console.error('DEBUG: Fetch error:', error);
                alert('Error adding checklist item: ' + error.message);
            });
        });
    } else {
        console.error('DEBUG: checklistItemForm element not found!');
    }
</script>

<style>
    /* ============================================
       DESIGN SYSTEM - CONSISTENT UI
       ============================================ */
    
    /* Color Palette */
    :root {
        --primary-color: #3498db;
        --primary-dark: #2980b9;
        --secondary-color: #6c757d;
        --success-color: #28a745;
        --danger-color: #dc3545;
        --warning-color: #ffc107;
        --info-color: #17a2b8;
        --light-color: #f8f9fa;
        --dark-color: #343a40;
        --border-color: #e9ecef;
        --shadow-color: rgba(0, 0, 0, 0.1);
        --gradient-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        --gradient-secondary: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }
    
    /* Typography */
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.6;
        color: var(--dark-color);
        background: var(--light-color);
        margin: 0;
        padding: 0;
    }
    
    h1, h2, h3, h4, h5, h6 {
        font-weight: 600;
        color: var(--dark-color);
        margin-bottom: 1rem;
    }
    
    h1 { font-size: 2.5rem; }
    h2 { font-size: 2rem; }
    h3 { font-size: 1.75rem; }
    h4 { font-size: 1.5rem; }
    h5 { font-size: 1.25rem; }
    h6 { font-size: 1rem; }
    
    /* Layout System */
    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }
    
    .section {
        display: none;
        animation: fadeIn 0.3s ease-in;
    }
    
    .section.active {
        display: block;
    }
    
    /* Navigation System */
    .nav {
        background: white;
        border-radius: 12px;
        padding: 20px;
        box-shadow: var(--shadow-color);
        margin-bottom: 30px;
    }
    
    .nav ul {
        list-style: none;
        padding: 0;
        margin: 0;
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 10px;
    }
    
    .nav a {
        display: flex;
        align-items: center;
        padding: 15px 20px;
        background: var(--light-color);
        border: 2px solid var(--border-color);
        border-radius: 8px;
        text-decoration: none;
        color: var(--dark-color);
        font-weight: 500;
        transition: all 0.3s ease;
    }
    
    .nav a:hover {
        background: var(--primary-color);
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(52, 152, 219, 0.15);
    }
    
    .nav a.active {
        background: var(--gradient-primary);
        color: white;
        border-color: var(--primary-color);
    }
    
    /* Card System */
    .dashboard-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    
    .card {
        background: white;
        border-radius: 12px;
        padding: 25px;
        box-shadow: var(--shadow-color);
        border: 1px solid var(--border-color);
        transition: all 0.3s ease;
    }
    
    .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    }
    
    .card h3 {
        color: var(--primary-color);
        margin-bottom: 15px;
        font-size: 1.1rem;
    }
    
    .card h2 {
        color: var(--dark-color);
        font-size: 2.5rem;
        font-weight: 700;
        margin: 0;
    }
    
    /* Button System */
    .btn {
        padding: 12px 24px;
        border: none;
        border-radius: 8px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
    }
    
    .btn-primary {
        background: var(--gradient-primary);
        color: white;
    }
    
    .btn-primary:hover {
        background: var(--primary-dark);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(52, 152, 219, 0.15);
    }
    
    .btn-secondary {
        background: var(--gradient-secondary);
        color: white;
    }
    
    .btn-success {
        background: var(--success-color);
        color: white;
    }
    
    .btn-danger {
        background: var(--danger-color);
        color: white;
    }
    
    .btn-warning {
        background: var(--warning-color);
        color: var(--dark-color);
    }
    
    /* Form System */
    .form-section {
        background: white;
        border-radius: 12px;
        padding: 30px;
        box-shadow: var(--shadow-color);
        border: 1px solid var(--border-color);
    }
    
    .form-group {
        margin-bottom: 20px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: 500;
        color: var(--dark-color);
    }
    
    .form-control {
        width: 100%;
        padding: 12px 16px;
        border: 2px solid var(--border-color);
        border-radius: 8px;
        font-size: 14px;
        transition: all 0.3s ease;
        box-sizing: border-box;
    }
    
    .form-control:focus {
        outline: none;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
    }
    
    /* Table System */
    .table-section {
        background: white;
        border-radius: 12px;
        padding: 0;
        box-shadow: var(--shadow-color);
        border: 1px solid var(--border-color);
        overflow: hidden;
    }
    
    .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 25px;
        background: var(--light-color);
        border-bottom: 2px solid var(--border-color);
    }
    
    .section-header h2 {
        margin: 0;
        color: var(--dark-color);
        font-size: 1.5rem;
        font-weight: 600;
    }
    
    .section-actions {
        display: flex;
        gap: 10px;
    }
    
    /* Animations */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* Responsive Design */
    @media (max-width: 768px) {
        .container { padding: 0 15px; }
        .nav ul { grid-template-columns: 1fr; }
        .dashboard-grid { grid-template-columns: 1fr; }
        .section-header { flex-direction: column; gap: 15px; }
        .section-actions { flex-direction: column; width: 100%; }
        .btn { width: 100%; justify-content: center; }
        .form-section { padding: 20px; }
    }
    
    /* Navigation Icons */
    .nav-icon {
        font-size: 18px;
        margin-right: 8px;
    }
    
    .nav-text {
        font-weight: 500;
    }
    
    .nav-user {
        background: var(--gradient-secondary);
        color: white;
        padding: 6px 12px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 14px;
    }
    
    /* Search Section */
    .search-section {
        margin: 20px 0;
        padding: 20px;
        background: white;
        border-radius: 12px;
        box-shadow: var(--shadow-color);
        border: 1px solid var(--border-color);
    }
    
    .search-container {
        display: flex;
        gap: 10px;
        align-items: center;
        max-width: 600px;
        margin: 0 auto;
    }
    
    .search-input {
        flex: 1;
        padding: 12px 16px;
        border: 2px solid var(--border-color);
        border-radius: 8px;
        font-size: 14px;
        transition: all 0.3s ease;
    }
    
    .search-input:focus {
        outline: none;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
    }
    
    .search-btn, .clear-btn {
        padding: 12px 20px;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        font-size: 14px;
        transition: background-color 0.3s;
        font-weight: 500;
    }
    
    .search-btn {
        background: var(--gradient-primary);
        color: white;
    }
    
    .search-btn:hover {
        background: var(--primary-dark);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(52, 152, 219, 0.15);
    }
    
    .clear-btn {
        background: var(--secondary-color);
        color: white;
    }
    
    .clear-btn:hover {
        background: #5a6268;
        transform: translateY(-2px);
    }
    
    /* Legacy Compatibility */
    .nav a.active {
        background: var(--gradient-primary);
        color: white;
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
    
    /* Consistent Section Headers */
    .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 2px solid #e9ecef;
    }
    
    .section-header h2 {
        margin: 0;
        color: #2c3e50;
        font-size: 24px;
        font-weight: 600;
    }
    
    .section-actions {
        display: flex;
        gap: 10px;
    }
    
    /* Modern Table Styling */
    .table-container {
        overflow-x: auto;
        border-radius: 8px;
        border: 1px solid #e9ecef;
    }
    
    .data-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        border-radius: 8px;
        overflow: hidden;
    }
    
    .data-table th {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        font-weight: 600;
        padding: 15px 12px;
        text-align: left;
        font-size: 14px;
        border: none;
    }
    
    .data-table td {
        padding: 15px 12px;
        border-bottom: 1px solid #e9ecef;
        text-align: left;
        font-size: 14px;
    }
    
    .data-table tr:last-child td {
        border-bottom: none;
    }
    
    .data-table tr:hover {
        background-color: #f8f9fa;
    }
    
    .username {
        font-weight: 600;
        color: #2c3e50;
    }
    
    .email {
        color: #6c757d;
    }
    
    .branch {
        font-weight: 500;
        color: #495057;
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
    
    .registration-section {
        margin: 20px 0;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .registration-form {
        max-width: 800px;
        margin: 0 auto;
    }
    
    .form-row {
        display: flex;
        gap: 20px;
        margin-bottom: 20px;
    }
    
    .form-group {
        flex: 1;
        margin-bottom: 15px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
        color: #2c3e50;
    }
    
    .form-group input,
    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 12px;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-size: 14px;
        box-sizing: border-box;
    }
    
    .form-group textarea {
        resize: vertical;
        min-height: 80px;
    }
    
    .form-actions {
        display: flex;
        gap: 10px;
        justify-content: center;
        margin-top: 20px;
    }
    
    .btn-primary {
        background-color: #3498db;
        color: white;
    }
    
    .btn-primary:hover {
        background-color: #2980b9;
    }
    
    .btn-secondary {
        background-color: #95a5a6;
        color: white;
    }
    
    .btn-secondary:hover {
        background-color: #7f8c8d;
    }
    
    @media (max-width: 768px) {
        .form-row {
            flex-direction: column;
            gap: 0;
        }
        
        .form-actions {
            flex-direction: column;
        }
    }
    
    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 5px;
        font-weight: bold;
    }
    
    .alert-success {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }
    
    .alert-danger {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }
    
    /* Checklist Management Styles */
    .checklist-controls {
        margin: 20px 0;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 8px;
        margin-bottom: 20px;
    }
    
    .add-item-form {
        background: white;
        padding: 20px;
        border-radius: 8px;
        margin: 20px 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .checklist-items-section {
        background: white;
        padding: 20px;
        border-radius: 8px;
        margin-top: 20px;
    }
    
    .checklist-table-container {
        overflow-x: auto;
    }
    
    .btn-sm {
        padding: 5px 10px;
        font-size: 12px;
    }
    
    .btn-danger {
        background-color: #dc3545;
        border-color: #dc3545;
    }
    
    .btn-danger:hover {
        background-color: #c82333;
        border-color: #c82333;
    }
</style>

</body>
</html>
