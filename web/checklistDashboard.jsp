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
<title>Checklist Dashboard</title>
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
    Checklist Dashboard | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="checklistDashboard.jsp" class="active">Checklist</a>
    <a href="viewAttendance.jsp">QR Code</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="securityOfficerReports.jsp">Reports</a>
    <a href="securityOfficerSettings.jsp">Settings</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<!-- CHECKLIST OVERVIEW -->
<div class="card">
    <div class="card-header">
        <h3>Checklist Overview</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="showAddChecklistForm()">Add Checklist Item</button>
            <button class="btn btn-secondary" onclick="exportChecklist()">Export Checklist</button>
        </div>
    </div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card">
                <h4>Total Items</h4>
                <div class="stat-number" id="totalItems">Loading...</div>
                <div class="stat-label">All Checklist Items</div>
            </div>
            
            <div class="stat-card">
                <h4>Completed Today</h4>
                <div class="stat-number" id="completedToday">Loading...</div>
                <div class="stat-label">Today's Completion</div>
            </div>
            
            <div class="stat-card">
                <h4>Pending Items</h4>
                <div class="stat-number" id="pendingItems">Loading...</div>
                <div class="stat-label">Items to Complete</div>
            </div>
            
            <div class="stat-card">
                <h4>Completion Rate</h4>
                <div class="stat-number" id="completionRate">Loading...</div>
                <div class="stat-label">Success Rate</div>
            </div>
        </div>
    </div>
</div>

<!-- ADD CHECKLIST ITEM -->
<div class="card" id="addChecklistCard" style="display: none;">
    <div class="card-header">
        <h3>Add Checklist Item</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="hideAddChecklistForm()">Cancel</button>
        </div>
    </div>
    <div class="card-body">
        <form action="AddChecklistItem" method="post" class="form-section">
            <div class="form-group">
                <label for="itemName">Item Name *</label>
                <input type="text" id="itemName" name="itemName" class="form-control" placeholder="Enter checklist item name" required>
            </div>
            
            <div class="form-group">
                <label for="itemDescription">Description</label>
                <textarea id="itemDescription" name="itemDescription" class="form-control" rows="3" placeholder="Enter item description (optional)"></textarea>
            </div>
            
            <div class="form-group">
                <label for="itemCategory">Category</label>
                <select id="itemCategory" name="itemCategory" class="form-control">
                    <option value="">Select Category</option>
                    <option value="security">Security</option>
                    <option value="safety">Safety</option>
                    <option value="maintenance">Maintenance</option>
                    <option value="operational">Operational</option>
                    <option value="other">Other</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="itemPriority">Priority</label>
                <select id="itemPriority" name="itemPriority" class="form-control">
                    <option value="low">Low</option>
                    <option value="medium" selected>Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Add Item</button>
                <button type="button" class="btn btn-secondary" onclick="hideAddChecklistForm()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- CHECKLIST ITEMS TABLE -->
<div class="card">
    <div class="card-header">
        <h3>All Checklist Items</h3>
        <div class="card-actions">
            <input type="text" id="searchChecklist" class="form-control" placeholder="Search checklist items..." style="width: 250px;" onkeyup="searchChecklistItems()">
        </div>
    </div>
    <div class="card-body">
        <div class="table-container">
            <table id="checklistTable" class="table">
                <thead>
                    <tr>
                        <th>Item Name</th>
                        <th>Description</th>
                        <th>Category</th>
                        <th>Priority</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="checklistTableBody">
                    <!-- Checklist items will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- SHIFT CHECKLIST -->
<div class="card">
    <div class="card-header">
        <h3>Current Shift Checklist</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="completeShiftChecklist()">Complete Checklist</button>
        </div>
    </div>
    <div class="card-body">
        <form id="shiftChecklistForm" class="form-section">
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
            
            <div id="shiftChecklistItems">
                <!-- Shift checklist items will be loaded here -->
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Submit Checklist</button>
                <button type="button" class="btn btn-secondary" onclick="clearShiftChecklist()">Clear</button>
            </div>
        </form>
    </div>
</div>

</div>

<script>
// Show/Hide Add Checklist Form
function showAddChecklistForm() {
    document.getElementById('addChecklistCard').style.display = 'block';
}

function hideAddChecklistForm() {
    document.getElementById('addChecklistCard').style.display = 'none';
    document.getElementById('itemName').value = '';
    document.getElementById('itemDescription').value = '';
    document.getElementById('itemCategory').value = '';
    document.getElementById('itemPriority').value = 'medium';
}

// Load checklist items
function loadChecklistItems() {
    fetch('GetChecklistItems')
        .then(response => response.json())
        .then(data => {
            const tbody = document.getElementById('checklistTableBody');
            tbody.innerHTML = '';
            
            data.items.forEach(item => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${item.name}</td>
                    <td>${item.description || '-'}</td>
                    <td><span class="badge badge-${item.category}">${item.category}</span></td>
                    <td><span class="badge badge-${item.priority}">${item.priority}</span></td>
                    <td><span class="badge badge-${item.status}">${item.status}</span></td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="editChecklistItem(${item.id})">Edit</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteChecklistItem(${item.id})">Delete</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
            
            updateStats(data);
        })
        .catch(error => {
            console.error('Error loading checklist items:', error);
        });
}

// Load shift checklist items
function loadShiftChecklistItems() {
    fetch('GetShiftChecklistItems')
        .then(response => response.json())
        .then(data => {
            const container = document.getElementById('shiftChecklistItems');
            container.innerHTML = '';
            
            data.items.forEach(item => {
                const itemDiv = document.createElement('div');
                itemDiv.className = 'form-group';
                itemDiv.innerHTML = `
                    <label>${item.name}</label>
                    <select name="item_${item.id}" class="form-control">
                        <option value="OK" selected>OK</option>
                        <option value="NOT_OK">NOT OK</option>
                    </select>
                    <input type="text" name="reason_${item.id}" class="form-control" placeholder="Enter reason if NOT OK" style="display: none; margin-top: 5px;">
                `;
                container.appendChild(itemDiv);
            });
        })
        .catch(error => {
            console.error('Error loading shift checklist items:', error);
        });
}

// Update statistics
function updateStats(data) {
    document.getElementById('totalItems').textContent = data.total || '0';
    document.getElementById('completedToday').textContent = data.completedToday || '0';
    document.getElementById('pendingItems').textContent = data.pending || '0';
    document.getElementById('completionRate').textContent = data.completionRate || '0%';
}

// Search checklist items
function searchChecklistItems() {
    const searchTerm = document.getElementById('searchChecklist').value.toLowerCase();
    const rows = document.querySelectorAll('#checklistTableBody tr');
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

// Edit checklist item
function editChecklistItem(id) {
    // Implementation for editing checklist item
    console.log('Edit checklist item:', id);
}

// Delete checklist item
function deleteChecklistItem(id) {
    if (confirm('Are you sure you want to delete this checklist item?')) {
        fetch('DeleteChecklistItem', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                itemId: id
            })
        })
        .then(response => response.text())
        .then(data => {
            if (data.includes('success')) {
                loadChecklistItems();
            } else {
                alert('Error deleting checklist item: ' + data);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting checklist item');
        });
    }
}

// Complete shift checklist
function completeShiftChecklist() {
    const form = document.getElementById('shiftChecklistForm');
    const formData = new FormData(form);
    
    fetch('CompleteShiftChecklist', {
        method: 'POST',
        body: formData
    })
    .then(response => response.text())
    .then(data => {
        if (data.includes('success')) {
            alert('Checklist completed successfully!');
            loadChecklistItems();
        } else {
            alert('Error completing checklist: ' + data);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error completing checklist');
    });
}

// Clear shift checklist
function clearShiftChecklist() {
    document.getElementById('shiftChecklistForm').reset();
}

// Export checklist
function exportChecklist() {
    fetch('ExportChecklist')
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'checklist_' + new Date().toISOString().split('T')[0] + '.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error exporting checklist:', error);
            alert('Error exporting checklist');
        });
}

// Initialize on page load
window.onload = function() {
    loadChecklistItems();
    loadShiftChecklistItems();
    
    // Set today's date as default
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('shiftDate').value = today;
};
</script>

</body>
</html>
