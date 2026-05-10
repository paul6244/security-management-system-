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
        <a href="checklistDashboard.jsp" class="nav-link active">
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
