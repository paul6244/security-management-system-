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
<title>QR Code Dashboard</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="css/shared-ui.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/qrcode-generator/qrcode.min.js"></script>
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
        <a href="qrCodeDashboard.jsp" class="nav-link active">
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

<!-- QR CODE OVERVIEW -->
<div class="card">
    <div class="card-header">
        <h3>QR Code Overview</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="showGenerateQRForm()">Generate QR Code</button>
            <button class="btn btn-secondary" onclick="exportQRData()">Export Data</button>
        </div>
    </div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card">
                <h4>Total QR Codes</h4>
                <div class="stat-number" id="totalQRCodes">Loading...</div>
                <div class="stat-label">Generated Codes</div>
            </div>
            
            <div class="stat-card">
                <h4>Active Scans</h4>
                <div class="stat-number" id="activeScans">Loading...</div>
                <div class="stat-label">Today's Scans</div>
            </div>
            
            <div class="stat-card">
                <h4>Staff Members</h4>
                <div class="stat-number" id="staffMembers">Loading...</div>
                <div class="stat-label">With QR Codes</div>
            </div>
            
            <div class="stat-card">
                <h4>Scan Success Rate</h4>
                <div class="stat-number" id="scanSuccessRate">Loading...</div>
                <div class="stat-label">Success Rate</div>
            </div>
        </div>
    </div>
</div>

<!-- GENERATE QR CODE -->
<div class="card" id="generateQRCard" style="display: none;">
    <div class="card-header">
        <h3>Generate QR Code</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="hideGenerateQRForm()">Cancel</button>
        </div>
    </div>
    <div class="card-body">
        <form id="generateQRForm" class="form-section">
            <div class="form-group">
                <label for="staffMember">Staff Member *</label>
                <select id="staffMember" name="staffMember" class="form-control" required>
                    <option value="">Select Staff Member</option>
                    <!-- Staff members will be loaded here -->
                </select>
            </div>
            
            <div class="form-group">
                <label for="qrType">QR Code Type *</label>
                <select id="qrType" name="qrType" class="form-control" required>
                    <option value="attendance">Attendance</option>
                    <option value="identification">Identification</option>
                    <option value="access">Access Control</option>
                    <option value="emergency">Emergency Contact</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="qrDescription">Description</label>
                <textarea id="qrDescription" name="qrDescription" class="form-control" rows="3" placeholder="Enter QR code description (optional)"></textarea>
            </div>
            
            <div class="form-group">
                <label for="qrExpiry">Expiry Date</label>
                <input type="date" id="qrExpiry" name="qrExpiry" class="form-control">
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Generate QR Code</button>
                <button type="button" class="btn btn-secondary" onclick="hideGenerateQRForm()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- QR CODE DISPLAY -->
<div class="card" id="qrDisplayCard" style="display: none;">
    <div class="card-header">
        <h3>Generated QR Code</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="downloadQRCode()">Download QR Code</button>
            <button class="btn btn-secondary" onclick="printQRCode()">Print QR Code</button>
        </div>
    </div>
    <div class="card-body text-center">
        <div id="qrCodeContainer" style="margin: 20px 0;">
            <!-- QR code will be displayed here -->
        </div>
        <div id="qrCodeInfo" style="margin-top: 20px;">
            <!-- QR code information will be displayed here -->
        </div>
    </div>
</div>

<!-- QR CODES TABLE -->
<div class="card">
    <div class="card-header">
        <h3>All QR Codes</h3>
        <div class="card-actions">
            <input type="text" id="searchQR" class="form-control" placeholder="Search QR codes..." style="width: 250px;" onkeyup="searchQRCodes()">
        </div>
    </div>
    <div class="card-body">
        <div class="table-container">
            <table id="qrTable" class="table">
                <thead>
                    <tr>
                        <th>Staff Member</th>
                        <th>QR Code Type</th>
                        <th>Description</th>
                        <th>Generated Date</th>
                        <th>Expiry Date</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="qrTableBody">
                    <!-- QR codes will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- QR SCANNER -->
<div class="card">
    <div class="card-header">
        <h3>QR Scanner</h3>
        <div class="card-actions">
            <button class="btn btn-primary" onclick="startQRScanner()">Start Scanner</button>
            <button class="btn btn-secondary" onclick="stopQRScanner()">Stop Scanner</button>
        </div>
    </div>
    <div class="card-body">
        <div class="form-group">
            <label for="scanResult">Scan Result</label>
            <textarea id="scanResult" class="form-control" rows="4" placeholder="QR code scan results will appear here..." readonly></textarea>
        </div>
        
        <div class="form-group">
            <label for="scanNotes">Scan Notes</label>
            <textarea id="scanNotes" class="form-control" rows="3" placeholder="Add notes about the scan (optional)"></textarea>
        </div>
        
        <div class="form-actions">
            <button class="btn btn-primary" onclick="saveScanResult()">Save Scan Result</button>
            <button class="btn btn-secondary" onclick="clearScanResult()">Clear</button>
        </div>
    </div>
</div>

<!-- ATTENDANCE LOGS -->
<div class="card">
    <div class="card-header">
        <h3>Recent Attendance Logs</h3>
        <div class="card-actions">
            <button class="btn btn-secondary" onclick="exportAttendanceLogs()">Export Logs</button>
        </div>
    </div>
    <div class="card-body">
        <div class="table-container">
            <table id="attendanceTable" class="table">
                <thead>
                    <tr>
                        <th>Date & Time</th>
                        <th>Staff Member</th>
                        <th>QR Code Type</th>
                        <th>Location</th>
                        <th>Status</th>
                        <th>Notes</th>
                    </tr>
                </thead>
                <tbody id="attendanceTableBody">
                    <!-- Attendance logs will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

</div>

<script>
// Show/Hide Generate QR Form
function showGenerateQRForm() {
    document.getElementById('generateQRCard').style.display = 'block';
    loadStaffMembers();
}

function hideGenerateQRForm() {
    document.getElementById('generateQRCard').style.display = 'none';
    document.getElementById('generateQRForm').reset();
}

// Load staff members
function loadStaffMembers() {
    fetch('GetStaffMembers')
        .then(response => response.json())
        .then(data => {
            const select = document.getElementById('staffMember');
            select.innerHTML = '<option value="">Select Staff Member</option>';
            
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

// Generate QR Code
function generateQRCode() {
    const form = document.getElementById('generateQRForm');
    const formData = new FormData(form);
    
    fetch('GenerateQRCode', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            displayQRCode(data.qrCode);
            hideGenerateQRForm();
            document.getElementById('qrDisplayCard').style.display = 'block';
            loadQRCodes();
        } else {
            alert('Error generating QR code: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error generating QR code');
    });
}

// Display QR Code
function displayQRCode(qrData) {
    const qr = qrcode(0, 'M');
    qr.addData(qrData.content);
    qr.make();
    
    const container = document.getElementById('qrCodeContainer');
    container.innerHTML = qr.createImgTag(5);
    
    const info = document.getElementById('qrCodeInfo');
    info.innerHTML = `
        <h4>QR Code Information</h4>
        <p><strong>Staff Member:</strong> ${qrData.staffName}</p>
        <p><strong>Type:</strong> ${qrData.type}</p>
        <p><strong>Description:</strong> ${qrData.description || 'N/A'}</p>
        <p><strong>Generated:</strong> ${qrData.generatedDate}</p>
        <p><strong>Expiry:</strong> ${qrData.expiryDate || 'No expiry'}</p>
    `;
}

// Load QR Codes
function loadQRCodes() {
    fetch('GetQRCodes')
        .then(response => response.json())
        .then(data => {
            const tbody = document.getElementById('qrTableBody');
            tbody.innerHTML = '';
            
            data.qrCodes.forEach(qr => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${qr.staffName}</td>
                    <td><span class="badge badge-${qr.type}">${qr.type}</span></td>
                    <td>${qr.description || '-'}</td>
                    <td>${qr.generatedDate}</td>
                    <td>${qr.expiryDate || 'No expiry'}</td>
                    <td><span class="badge badge-${qr.status}">${qr.status}</span></td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="viewQRCode(${qr.id})">View</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteQRCode(${qr.id})">Delete</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
            
            updateStats(data);
        })
        .catch(error => {
            console.error('Error loading QR codes:', error);
        });
}

// Update statistics
function updateStats(data) {
    document.getElementById('totalQRCodes').textContent = data.totalQRCodes || '0';
    document.getElementById('activeScans').textContent = data.activeScans || '0';
    document.getElementById('staffMembers').textContent = data.staffMembers || '0';
    document.getElementById('scanSuccessRate').textContent = data.scanSuccessRate || '0%';
}

// Search QR codes
function searchQRCodes() {
    const searchTerm = document.getElementById('searchQR').value.toLowerCase();
    const rows = document.querySelectorAll('#qrTableBody tr');
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

// View QR Code
function viewQRCode(id) {
    fetch('GetQRCode?id=' + id)
        .then(response => response.json())
        .then(data => {
            displayQRCode(data.qrCode);
            document.getElementById('qrDisplayCard').style.display = 'block';
        })
        .catch(error => {
            console.error('Error viewing QR code:', error);
        });
}

// Delete QR Code
function deleteQRCode(id) {
    if (confirm('Are you sure you want to delete this QR code?')) {
        fetch('DeleteQRCode', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                qrId: id
            })
        })
        .then(response => response.text())
        .then(data => {
            if (data.includes('success')) {
                loadQRCodes();
            } else {
                alert('Error deleting QR code: ' + data);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting QR code');
        });
    }
}

// QR Scanner functions
function startQRScanner() {
    // Implementation for starting QR scanner
    alert('QR Scanner started - Point camera at QR code');
}

function stopQRScanner() {
    // Implementation for stopping QR scanner
    alert('QR Scanner stopped');
}

// Save scan result
function saveScanResult() {
    const scanResult = document.getElementById('scanResult').value;
    const scanNotes = document.getElementById('scanNotes').value;
    
    if (!scanResult) {
        alert('Please scan a QR code first');
        return;
    }
    
    fetch('SaveScanResult', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            scanResult: scanResult,
            scanNotes: scanNotes
        })
    })
    .then(response => response.text())
    .then(data => {
        if (data.includes('success')) {
            alert('Scan result saved successfully!');
            clearScanResult();
            loadAttendanceLogs();
        } else {
            alert('Error saving scan result: ' + data);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error saving scan result');
    });
}

// Clear scan result
function clearScanResult() {
    document.getElementById('scanResult').value = '';
    document.getElementById('scanNotes').value = '';
}

// Load attendance logs
function loadAttendanceLogs() {
    fetch('GetAttendanceLogs')
        .then(response => response.json())
        .then(data => {
            const tbody = document.getElementById('attendanceTableBody');
            tbody.innerHTML = '';
            
            data.logs.forEach(log => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${log.dateTime}</td>
                    <td>${log.staffName}</td>
                    <td><span class="badge badge-${log.type}">${log.type}</span></td>
                    <td>${log.location}</td>
                    <td><span class="badge badge-${log.status}">${log.status}</span></td>
                    <td>${log.notes || '-'}</td>
                `;
                tbody.appendChild(row);
            });
        })
        .catch(error => {
            console.error('Error loading attendance logs:', error);
        });
}

// Export functions
function exportQRData() {
    fetch('ExportQRData')
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'qr_codes_' + new Date().toISOString().split('T')[0] + '.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error exporting QR data:', error);
            alert('Error exporting QR data');
        });
}

function exportAttendanceLogs() {
    fetch('ExportAttendanceLogs')
        .then(response => response.blob())
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'attendance_logs_' + new Date().toISOString().split('T')[0] + '.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        })
        .catch(error => {
            console.error('Error exporting attendance logs:', error);
            alert('Error exporting attendance logs');
        });
}

// Download QR Code
function downloadQRCode() {
    const qrImage = document.querySelector('#qrCodeContainer img');
    if (qrImage) {
        const link = document.createElement('a');
        link.href = qrImage.src;
        link.download = 'qr_code_' + new Date().toISOString().split('T')[0] + '.png';
        link.click();
    }
}

// Print QR Code
function printQRCode() {
    window.print();
}

// Initialize on page load
window.onload = function() {
    loadQRCodes();
    loadAttendanceLogs();
    
    // Set default expiry date to 1 year from now
    const expiryDate = new Date();
    expiryDate.setFullYear(expiryDate.getFullYear() + 1);
    document.getElementById('qrExpiry').value = expiryDate.toISOString().split('T')[0];
};

// Handle form submission
document.getElementById('generateQRForm').addEventListener('submit', function(e) {
    e.preventDefault();
    generateQRCode();
});
</script>

</body>
</html>
