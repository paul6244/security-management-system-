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
<title>Staff Registration</title>
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
        <a href="checklistDashboard.jsp" class="nav-link">
            <i class="nav-icon">✓</i>
            <span class="nav-text">Checklist</span>
        </a>
        <a href="qrCodeDashboard.jsp" class="nav-link">
            <i class="nav-icon">📱</i>
            <span class="nav-text">QR Code</span>
        </a>
        <a href="staffRegistration.jsp" class="nav-link active">
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

<!-- STAFF REGISTRATION OVERVIEW -->
<div class="card">
    <div class="card-header">
        <h3>Staff Registration Overview</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="showRegistrationForm()">Register New Staff</button>
            <button class="btn btn-secondary" onclick="exportStaffData()">Export Staff Data</button>
        </div>
    </div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card">
                <h4>Total Staff</h4>
                <div class="stat-number" id="totalStaff">Loading...</div>
                <div class="stat-label">All Staff Members</div>
            </div>
            
            <div class="stat-card">
                <h4>Active Staff</h4>
                <div class="stat-number" id="activeStaff">Loading...</div>
                <div class="stat-label">Currently Active</div>
            </div>
            
            <div class="stat-card">
                <h4>New This Month</h4>
                <div class="stat-number" id="newStaff">Loading...</div>
                <div class="stat-label">New Registrations</div>
            </div>
            
            <div class="stat-card">
                <h4>Departments</h4>
                <div class="stat-number" id="departments">Loading...</div>
                <div class="stat-label">Total Departments</div>
            </div>
        </div>
    </div>
</div>

<!-- STAFF REGISTRATION FORM -->
<div class="card" id="registrationCard" style="display: none;">
    <div class="card-header">
        <h3>Register New Staff Member</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="hideRegistrationForm()">Cancel</button>
        </div>
    </div>
    <div class="card-body">
        <form action="RegisterStaff" method="post" class="form-section">
            <!-- Personal Information -->
            <div class="form-section">
                <h4>Personal Information</h4>
                
                <div class="form-group">
                    <label for="firstName">First Name *</label>
                    <input type="text" id="firstName" name="firstName" class="form-control" placeholder="Enter first name" required>
                </div>
                
                <div class="form-group">
                    <label for="lastName">Last Name *</label>
                    <input type="text" id="lastName" name="lastName" class="form-control" placeholder="Enter last name" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email Address *</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="Enter email address" required>
                </div>
                
                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="tel" id="phone" name="phone" class="form-control" placeholder="Enter phone number">
                </div>
                
                <div class="form-group">
                    <label for="dateOfBirth">Date of Birth</label>
                    <input type="date" id="dateOfBirth" name="dateOfBirth" class="form-control">
                </div>
                
                <div class="form-group">
                    <label for="gender">Gender</label>
                    <select id="gender" name="gender" class="form-control">
                        <option value="">Select Gender</option>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="other">Other</option>
                    </select>
                </div>
            </div>
            
            <!-- Account Information -->
            <div class="form-section">
                <h4>Account Information</h4>
                
                <div class="form-group">
                    <label for="username">Username *</label>
                    <input type="text" id="username" name="username" class="form-control" placeholder="Enter username" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="Enter password" required>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" placeholder="Confirm password" required>
                </div>
                
                <div class="form-group">
                    <label for="role">Role *</label>
                    <select id="role" name="role" class="form-control" required>
                        <option value="">Select Role</option>
                        <option value="security_officer">Security Officer</option>
                        <option value="supervisor">Supervisor</option>
                        <option value="admin">Admin</option>
                        <option value="staff">Staff</option>
                    </select>
                </div>
            </div>
            
            <!-- Employment Information -->
            <div class="form-section">
                <h4>Employment Information</h4>
                
                <div class="form-group">
                    <label for="employeeId">Employee ID *</label>
                    <input type="text" id="employeeId" name="employeeId" class="form-control" placeholder="Enter employee ID" required>
                </div>
                
                <div class="form-group">
                    <label for="department">Department *</label>
                    <select id="department" name="department" class="form-control" required>
                        <option value="">Select Department</option>
                        <option value="security">Security</option>
                        <option value="administration">Administration</option>
                        <option value="operations">Operations</option>
                        <option value="maintenance">Maintenance</option>
                        <option value="management">Management</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="branch">Branch *</label>
                    <select id="branch" name="branch" class="form-control" required>
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
                    <label for="shiftTime">Shift Time *</label>
                    <select id="shiftTime" name="shiftTime" class="form-control" required>
                        <option value="">Select Shift</option>
                        <option value="08:00-16:00">Day Shift (8AM-4PM)</option>
                        <option value="16:00-00:00">Evening Shift (4PM-12AM)</option>
                        <option value="00:00-08:00">Night Shift (12AM-8AM)</option>
                        <option value="flexible">Flexible</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="hireDate">Hire Date *</label>
                    <input type="date" id="hireDate" name="hireDate" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="position">Position *</label>
                    <input type="text" id="position" name="position" class="form-control" placeholder="Enter position" required>
                </div>
            </div>
            
            <!-- Contact Information -->
            <div class="form-section">
                <h4>Contact Information</h4>
                
                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea id="address" name="address" class="form-control" rows="3" placeholder="Enter full address"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="city">City</label>
                    <input type="text" id="city" name="city" class="form-control" placeholder="Enter city">
                </div>
                
                <div class="form-group">
                    <label for="country">Country</label>
                    <input type="text" id="country" name="country" class="form-control" placeholder="Enter country">
                </div>
                
                <div class="form-group">
                    <label for="emergencyContact">Emergency Contact *</label>
                    <input type="text" id="emergencyContact" name="emergencyContact" class="form-control" placeholder="Enter emergency contact name and phone" required>
                </div>
            </div>
            
            <!-- Additional Information -->
            <div class="form-section">
                <h4>Additional Information</h4>
                
                <div class="form-group">
                    <label for="skills">Skills</label>
                    <textarea id="skills" name="skills" class="form-control" rows="3" placeholder="Enter relevant skills (comma separated)"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="certifications">Certifications</label>
                    <textarea id="certifications" name="certifications" class="form-control" rows="3" placeholder="Enter certifications (comma separated)"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="notes">Additional Notes</label>
                    <textarea id="notes" name="notes" class="form-control" rows="3" placeholder="Enter any additional notes"></textarea>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Register Staff</button>
                <button type="button" class="btn btn-secondary" onclick="hideRegistrationForm()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- STAFF MEMBERS TABLE -->
<div class="card">
    <div class="card-header">
        <h3>All Staff Members</h3>
        <div class="card-actions">
            <input type="text" id="searchStaff" class="form-control" placeholder="Search staff members..." style="width: 250px;" onkeyup="searchStaffMembers()">
        </div>
    </div>
    <div class="card-body">
        <div class="table-container">
            <table id="staffTable" class="table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Department</th>
                        <th>Branch</th>
                        <th>Position</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="staffTableBody">
                    <!-- Staff members will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- BULK IMPORT -->
<div class="card">
    <div class="card-header">
        <h3>Bulk Import Staff</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="downloadImportTemplate()">Download Template</button>
        </div>
    </div>
    <div class="card-body">
        <form id="bulkImportForm" class="form-section">
            <div class="form-group">
                <label for="importFile">Import File (CSV)</label>
                <input type="file" id="importFile" name="importFile" class="form-control" accept=".csv">
            </div>
            
            <div class="form-group">
                <label for="importOptions">Import Options</label>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="skipDuplicates" checked> Skip duplicates
                    </label>
                    <label>
                        <input type="checkbox" name="sendWelcomeEmail" checked> Send welcome email
                    </label>
                    <label>
                        <input type="checkbox" name="generateQRCode" checked> Generate QR code
                    </label>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Import Staff</button>
                <button type="button" class="btn btn-secondary" onclick="clearImportForm()">Clear</button>
            </div>
        </form>
    </div>
</div>

</div>

<script>
// Show/Hide Registration Form
function showRegistrationForm() {
    document.getElementById('registrationCard').style.display = 'block';
    // Set today's date as default for hire date
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('hireDate').value = today;
}

function hideRegistrationForm() {
    document.getElementById('registrationCard').style.display = 'none';
    document.getElementById('registrationCard').querySelector('form').reset();
}

// Load staff members
function loadStaffMembers() {
    fetch('GetStaffMembers')
        .then(response => response.json())
        .then(data => {
            const tbody = document.getElementById('staffTableBody');
            tbody.innerHTML = '';
            
            data.staff.forEach(member => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${member.firstName} ${member.lastName}</td>
                    <td>${member.email}</td>
                    <td><span class="badge badge-${member.department}">${member.department}</span></td>
                    <td>${member.branch}</td>
                    <td>${member.position}</td>
                    <td><span class="badge badge-${member.status}">${member.status}</span></td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="viewStaff(${member.id})">View</button>
                        <button class="btn btn-sm btn-secondary" onclick="editStaff(${member.id})">Edit</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteStaff(${member.id})">Delete</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
            
            updateStats(data);
        })
        .catch(error => {
            console.error('Error loading staff members:', error);
        });
}

// Update statistics
function updateStats(data) {
    document.getElementById('totalStaff').textContent = data.totalStaff || '0';
    document.getElementById('activeStaff').textContent = data.activeStaff || '0';
    document.getElementById('newStaff').textContent = data.newStaff || '0';
    document.getElementById('departments').textContent = data.departments || '0';
}

// Search staff members
function searchStaffMembers() {
    const searchTerm = document.getElementById('searchStaff').value.toLowerCase();
    const rows = document.querySelectorAll('#staffTableBody tr');
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

// View staff member
function viewStaff(id) {
    fetch('GetStaffMember?id=' + id)
        .then(response => response.json())
        .then(data => {
            // Display staff member details in a modal or new section
            console.log('View staff:', data.staff);
        })
        .catch(error => {
            console.error('Error viewing staff:', error);
        });
}

// Edit staff member
function editStaff(id) {
    fetch('GetStaffMember?id=' + id)
        .then(response => response.json())
        .then(data => {
            // Populate form with staff member data for editing
            const staff = data.staff;
            document.getElementById('firstName').value = staff.firstName;
            document.getElementById('lastName').value = staff.lastName;
            document.getElementById('email').value = staff.email;
            // ... populate other fields
            showRegistrationForm();
        })
        .catch(error => {
            console.error('Error editing staff:', error);
        });
}

// Delete staff member
function deleteStaff(id) {
    if (confirm('Are you sure you want to delete this staff member?')) {
        fetch('DeleteStaffMember', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                staffId: id
            })
        })
        .then(response => response.text())
        .then(data => {
            if (data.includes('success')) {
                loadStaffMembers();
            } else {
                alert('Error deleting staff member: ' + data);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting staff member');
        });
    }
}

// Export staff data
function exportStaffData() {
    fetch('ExportStaffData')
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'staff_data_' + new Date().toISOString().split('T')[0] + '.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error exporting staff data:', error);
            alert('Error exporting staff data');
        });
}

// Bulk import functions
function downloadImportTemplate() {
    fetch('DownloadImportTemplate')
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'staff_import_template.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error downloading template:', error);
            alert('Error downloading template');
        });
}

function clearImportForm() {
    document.getElementById('bulkImportForm').reset();
}

// Handle bulk import form submission
document.getElementById('bulkImportForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData();
    const fileInput = document.getElementById('importFile');
    
    if (!fileInput.files.length) {
        alert('Please select a file to import');
        return;
    }
    
    formData.append('importFile', fileInput.files[0]);
    
    // Add checkbox values
    const checkboxes = document.querySelectorAll('#bulkImportForm input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        formData.append(checkbox.name, checkbox.checked);
    });
    
    fetch('BulkImportStaff', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Staff imported successfully! ' + data.importedCount + ' staff members added.');
            clearImportForm();
            loadStaffMembers();
        } else {
            alert('Error importing staff: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error importing staff');
    });
});

// Password confirmation validation
document.getElementById('confirmPassword').addEventListener('input', function() {
    const password = document.getElementById('password').value;
    const confirmPassword = this.value;
    
    if (password !== confirmPassword) {
        this.setCustomValidity('Passwords do not match');
    } else {
        this.setCustomValidity('');
    }
});

// Initialize on page load
window.onload = function() {
    loadStaffMembers();
};
</script>

</body>
</html>
