<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>QR Code Attendance System</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">
<style>
body {
    font-family: 'Poppins', sans-serif;
    margin:0;
    background:#f4f6f9;
}

.navbar {
    background:#1e2a38;
    color:white;
    padding:15px;
    font-size:20px;
    text-align:center;
}

.container {
    display:flex;
    min-height:calc(100vh - 60px);
}

.sidebar {
    width:220px;
    background:#2c3e50;
    color:white;
}

.sidebar a {
    display:block;
    padding:15px;
    color:white;
    text-decoration:none;
}

.sidebar a:hover {
    background:#34495e;
}

.main {
    flex:1;
    padding:20px;
}

.attendance-container {
    max-width:1200px;
    margin:0 auto;
    background:white;
    padding:30px;
    border-radius:15px;
    box-shadow:0 4px 20px rgba(0,0,0,0.1);
}

.section {
    margin:20px 0;
    padding:20px;
    background: #f8f9fa;
    border-radius:10px;
    border:1px solid #e9ecef;
}

.qr-display {
    text-align:center;
    margin:20px 0;
    padding:30px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius:15px;
    box-shadow:0 8px 32px rgba(0,0,0,0.1);
}

.qr-code {
    width:200px;
    height:200px;
    margin:0 auto 20px;
    background:white;
    padding:20px;
    border-radius:10px;
    box-shadow:0 4px 20px rgba(0,0,0,0.1);
    position:relative;
}

.qr-code img {
    width:100%;
    height:100%;
    border-radius:8px;
}

.qr-instructions {
    background:#e3f2fd;
    color:white;
    padding:15px;
    border-radius:10px;
    margin-top:20px;
    text-align:center;
}

.status-message {
    padding:15px;
    border-radius:10px;
    margin-bottom:20px;
    display:none;
}

.status-success {
    background:#d4edda;
    color:#155724;
    border:1px solid #c3e6cb;
}

.status-error {
    background:#f8d7da;
    color:#721c24;
    border:1px solid #f5c6cb;
}

.status-info {
    background:#d1ecf1;
    color:#0c5460;
    border:1px solid #bee5eb;
}

.btn {
    padding:12px 24px;
    border:none;
    background:#3498db;
    color:white;
    border-radius:8px;
    cursor:pointer;
    font-size:16px;
    margin:5px;
}

.btn-success {
    background:#27ae60;
}

.btn-primary {
    background:#007bff;
}

.btn:hover {
    opacity:0.9;
}

.search-box {
    margin:20px 0;
}

.search-input {
    width:100%;
    padding:12px;
    border:1px solid #ddd;
    border-radius:8px;
    font-size:16px;
    box-sizing:border-box;
}

.staff-grid {
    display:grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap:20px;
    margin:20px 0;
}

.staff-card {
    background:white;
    padding:20px;
    border-radius:10px;
    box-shadow:0 2px 10px rgba(0,0,0,0.1);
    text-align:center;
}

.staff-name {
    font-size:18px;
    font-weight:600;
    color:#2c3e50;
    margin-bottom:10px;
}

.staff-id {
    font-size:14px;
    color:#6c757d;
    margin-bottom:5px;
}

.qr-value {
    font-family:monospace;
    font-size:12px;
    background:#f8f9fa;
    padding:8px;
    border-radius:5px;
    margin:10px 0;
    word-break:break-all;
}

.scan-button {
    background:#28a745;
    color:white;
    border:none;
    padding:10px 20px;
    border-radius:8px;
    cursor:pointer;
    font-size:14px;
    margin-top:10px;
}

.scan-button:hover {
    background:#1e5e35;
}

.instructions {
    background:#e8f5e8;
    color:white;
    padding:15px;
    border-radius:10px;
    margin-top:20px;
    text-align:center;
    font-size:14px;
    line-height:1.5;
}

.loading {
    text-align:center;
    padding:20px;
    font-style:italic;
    color:#6c757d;
}

@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.05); }
    100% { transform: scale(1); }
}

.pulse {
    animation: pulse 2s infinite;
}

@media (max-width:768px) {
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
    
    .staff-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>

<div class="navbar">
    QR Code Attendance System | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="attendance.jsp">Attendance</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="qrAttendance.jsp">QR Attendance</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<div class="attendance-container">

<h2>📱 QR Code Attendance System</h2>
<p style="background:#e3f2fd; color:white; padding:10px; border-radius:5px; margin-bottom:20px;">
    <strong>📱 Mobile-Friendly Attendance:</strong> Staff can scan QR codes with their phones instead of fingerprint scanners. Perfect for mobile workforce management!
</p>

<!-- Status Messages -->
<div id="statusMessage" class="status-message"></div>

<!-- Search Section -->
<div class="section">
    <h3>🔍 Search Staff Member</h3>
    <div class="search-box">
        <input type="text" id="searchInput" class="search-input" placeholder="Search by name or employee ID..." onkeyup="searchStaff()">
    </div>
</div>

<!-- QR Code Display Section -->
<div class="qr-display">
    <h3>📱 Scan QR Code for Attendance</h3>
    
    <div id="qrCodeDisplay" class="qr-code" style="display:none;">
        <div class="loading">
            <div class="pulse">🔄 Loading QR Code...</div>
        </div>
    </div>
    
    <div class="qr-instructions">
        <h4>📱 How to Use QR Code:</h4>
        <ol style="text-align:left; color:#2c3e50;">
            <li><strong>1. Open Phone Camera:</strong> Use your phone's camera app</li>
            <li><strong>2. Scan QR Code:</strong> Point camera at the QR code above</li>
            <li><strong>3. Auto-Check In:</strong> System will automatically record attendance</li>
            <li><strong>4. Confirmation:</strong> Success message will appear</li>
        </ol>
    </div>
</div>

<!-- Staff List Section -->
<div class="section">
    <h3>👥 All Staff Members</h3>
    
    <div id="staffList" class="staff-grid">
        <div class="loading">
            <div class="pulse">🔄 Loading staff list...</div>
        </div>
    </div>
</div>

<!-- Instructions Section -->
<div class="instructions">
    <h3>📋 System Instructions</h3>
    <p><strong>For Staff:</strong></p>
    <ul style="text-align:left; color:#2c3e50;">
        <li>1. Search for your name in the search box above</li>
        <li>2. Click "Show QR" to display your QR code</li>
        <li>3. Scan QR code with your phone camera</li>
        <li>4. System will automatically record your attendance</li>
    </ul>
    
    <p><strong>For Administrators:</strong></p>
    <ul style="text-align:left; color:#2c3e50;">
        <li>1. View all staff QR codes at once</li>
        <li>2. Generate QR codes for all staff members</li>
        <li>3. Clear QR codes when needed</li>
        <li>4. Track attendance records</li>
    </ul>
</div>

</div>

</div>

</body>

<script>
// Global variables
let currentQRCode = null;
let currentStaffId = null;

// Show status message
function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.className = 'status-message status-' + type;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 5000);
}

// Search staff members
function searchStaff() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const staffCards = document.querySelectorAll('.staff-card');
    
    staffCards.forEach(card => {
        const name = card.querySelector('.staff-name').textContent.toLowerCase();
        const id = card.querySelector('.staff-id').textContent.toLowerCase();
        
        if (name.includes(searchTerm) || id.includes(searchTerm)) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// Show QR code for specific staff
function showQRCode(staffId, staffName) {
    currentStaffId = staffId;
    
    const qrDisplay = document.getElementById('qrCodeDisplay');
    const staffList = document.getElementById('staffList');
    
    // Hide staff list and show loading
    staffList.style.display = 'none';
    qrDisplay.style.display = 'block';
    
    // Show loading state
    qrDisplay.innerHTML = `
        <div class="loading">
            <div class="pulse">🔄 Loading QR Code for ${staffName}...</div>
        </div>
    `;
    
    // Fetch QR code from server
    fetch('GetQRCode?staffId=' + encodeURIComponent(staffId), {
        method: 'GET'
    })
    .then(response => response.text())
    .then(qrCode => {
        if (qrCode && qrCode.trim() !== '') {
            currentQRCode = qrCode;
            
            // Display QR code
            qrDisplay.innerHTML = `
                <div class="qr-code">
                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(qrCode)}" alt="QR Code for ${staffName}">
                    
                    <div class="qr-instructions">
                        <h4>📱 Scan for Attendance</h4>
                        <p><strong>Staff:</strong> ${staffName}</p>
                        <p><strong>ID:</strong> ${staffId}</p>
                        <p><strong>QR Value:</strong></p>
                        <div class="qr-value">${qrCode}</div>
                        
                        <button class="scan-button" onclick="markAttendance('${staffId}', '${staffName}')">
                            📱 Mark Attendance
                        </button>
                        
                        <button class="scan-button" onclick="hideQRCode()">
                            ✖ Close
                        </button>
                    </div>
                </div>
            `;
            
            // Auto-scan for attendance after 5 seconds
            setTimeout(() => {
                markAttendance(staffId, staffName);
            }, 5000);
            
        } else {
            qrDisplay.innerHTML = `
                <div class="loading">
                    <div class="pulse">❌ QR Code not available</div>
                </div>
            `;
            
            setTimeout(() => {
                hideQRCode();
            }, 2000);
        }
    })
    .catch(error => {
        showStatus('Error loading QR code: ' + error.message, 'error');
        hideQRCode();
    });
}

// Mark attendance
function markAttendance(staffId, staffName) {
    fetch('MarkAttendance', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'staffId=' + encodeURIComponent(staffId) + '&staffName=' + encodeURIComponent(staffName)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showStatus(`✅ Attendance marked for ${staffName} at ${new Date().toLocaleString()}`, 'success');
            
            // Hide QR code after successful attendance
            setTimeout(() => {
                hideQRCode();
            }, 2000);
        } else {
            showStatus('❌ Failed to mark attendance: ' + data.message, 'error');
        }
    })
    .catch(error => {
        showStatus('❌ Network error: ' + error.message, 'error');
    });
}

// Hide QR code
function hideQRCode() {
    const qrDisplay = document.getElementById('qrCodeDisplay');
    const staffList = document.getElementById('staffList');
    
    qrDisplay.style.display = 'none';
    staffList.style.display = 'block';
    currentQRCode = null;
    currentStaffId = null;
}

// Load staff list on page load
function loadStaffList() {
    const staffList = document.getElementById('staffList');
    
    // Show loading state
    staffList.innerHTML = `
        <div class="loading">
            <div class="pulse">🔄 Loading staff list...</div>
        </div>
    `;
    
    fetch('GetAllStaffQR', {
        method: 'GET'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success && data.staff && data.staff.length > 0) {
            let html = '';
            
            data.staff.forEach(staff => {
                html += `
                    <div class="staff-card">
                        <div class="staff-name">${staff.first_name} ${staff.last_name}</div>
                        <div class="staff-id">ID: ${staff.employee_id}</div>
                        
                        <button class="btn btn-primary" onclick="showQRCode('${staff.id}', '${staff.first_name} ${staff.last_name}')">
                            📱 Show QR
                        </button>
                    </div>
                `;
            });
            
            staffList.innerHTML = html;
        } else {
            staffList.innerHTML = `
                <div class="loading">
                    <div class="pulse">❌ No staff found</div>
                </div>
            `;
        }
    })
    .catch(error => {
        showStatus('Error loading staff list: ' + error.message, 'error');
    });
}

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    loadStaffList();
});
</script>

</html>
