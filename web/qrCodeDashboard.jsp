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
    QR Code Dashboard | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="checklistDashboard.jsp">Checklist</a>
    <a href="qrCodeDashboard.jsp" class="active">QR Code</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="securityOfficerReports.jsp">Reports</a>
    <a href="securityOfficerSettings.jsp">Settings</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
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
