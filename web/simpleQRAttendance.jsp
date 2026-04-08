<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<!DOCTYPE html>
<html>
<head>
<title>Simple QR Attendance</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body {
    font-family: 'Poppins', sans-serif;
    margin:0;
    padding:20px;
    background:linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height:100vh;
}

.container {
    max-width:500px;
    margin:0 auto;
    background:white;
    border-radius:20px;
    box-shadow:0 20px 40px rgba(0,0,0,0.2);
    padding:30px;
}

.header {
    text-align:center;
    margin-bottom:30px;
}

.header h1 {
    color:#2c3e50;
    font-size:32px;
    margin:0;
}

.header p {
    color:#6c757d;
    font-size:16px;
    margin:10px 0;
}

.staff-selector {
    margin-bottom:30px;
}

.staff-selector select {
    width:100%;
    padding:15px;
    border:2px solid #dee2e6;
    border-radius:10px;
    font-size:16px;
    background:white;
    margin-bottom:10px;
}

.qr-display {
    background:#f8f9fa;
    border:2px solid #dee2e6;
    border-radius:15px;
    padding:20px;
    text-align:center;
    margin:20px 0;
    display:none;
}

.qr-display.show {
    display:block;
}

.qr-code {
    width:200px;
    height:200px;
    background:white;
    border:2px solid #000;
    margin:0 auto 15px;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:12px;
    padding:10px;
}

.qr-placeholder {
    color:#999;
    font-size:14px;
}

.btn {
    padding:15px 30px;
    border:none;
    background:#28a745;
    color:white;
    border-radius:10px;
    font-size:16px;
    cursor:pointer;
    width:100%;
    margin:10px 0;
    transition:all 0.3s ease;
}

.btn:hover {
    background:#218838;
    transform:translateY(-2px);
}

.btn-success {
    background:#28a745;
}

.btn-info {
    background:#17a2b8;
}

.status-message {
    padding:15px;
    border-radius:10px;
    margin:20px 0;
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

.instructions {
    background:#e9ecef;
    padding:20px;
    border-radius:10px;
    margin:20px 0;
}

.instructions h3 {
    color:#2c3e50;
    margin:0 0 15px 0;
}

.instructions ul {
    margin:0;
    padding-left:20px;
}

.instructions li {
    margin:8px 0;
    color:#495057;
    line-height:1.5;
}

.navigation {
    text-align:center;
    margin:30px 0;
}

.navigation a {
    display:inline-block;
    margin:10px;
    padding:12px 20px;
    background:#2c3e50;
    color:white;
    text-decoration:none;
    border-radius:8px;
    transition:all 0.3s ease;
}

.navigation a:hover {
    background:#34495e;
    transform:translateY(-2px);
}
</style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1>📱 Simple QR Attendance</h1>
        <p>Quick and easy attendance with QR codes</p>
    </div>
    
    <!-- Status Messages -->
    <div id="statusMessage" class="status-message"></div>
    
    <!-- Staff Selection -->
    <div class="staff-selector">
        <label style="display:block; margin-bottom:10px; font-weight:600; color:#2c3e50;">
            Select Your Name:
        </label>
        <select id="staffSelect" onchange="showQRCode()">
            <option value="">-- Choose your name --</option>
        </select>
    </div>
    
    <!-- QR Code Display -->
    <div class="qr-display" id="qrDisplay">
        <h3 style="color:#2c3e50; margin:0 0 15px 0;">Your QR Code</h3>
        <div class="qr-code" id="qrCode">
            <div class="qr-placeholder">QR Code will appear here</div>
        </div>
        <p style="color:#6c757d; font-size:14px; margin:10px 0 0 15px;">
            Show this QR code to check in
        </p>
    </div>
    
    <!-- Instructions -->
    <div class="instructions">
        <h3>📋 How to Use</h3>
        <ul>
            <li><strong>Step 1:</strong> Select your name from the dropdown above</li>
            <li><strong>Step 2:</strong> Your unique QR code will appear</li>
            <li><strong>Step 3:</strong> Show this QR code to check in</li>
            <li><strong>Step 4:</strong> Done! Attendance recorded automatically</li>
        </ul>
    </div>
    
    <!-- Navigation -->
    <div class="navigation">
        <a href="qrAttendanceScanner.jsp" class="btn btn-info">📷 Scan QR Code</a>
        <a href="attendance.jsp" class="btn btn-success">📊 View Attendance</a>
        <a href="index.jsp" class="btn">🔐 Logout</a>
    </div>
</div>

<script>
// Load staff members
async function loadStaffMembers() {
    try {
        const response = await fetch('GetStaffMembers');
        const staff = await response.json();
        
        const select = document.getElementById('staffSelect');
        select.innerHTML = '<option value="">-- Choose your name --</option>';
        
        staff.forEach(member => {
            const option = document.createElement('option');
            option.value = member.employee_id;
            option.textContent = member.first_name + ' ' + member.last_name;
            select.appendChild(option);
        });
        
    } catch (error) {
        console.error('Error loading staff:', error);
        showStatus('Error loading staff members', 'error');
    }
}

function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.className = 'status-message status-' + type;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 5000);
}

function showQRCode() {
    const staffId = document.getElementById('staffSelect').value;
    
    if (!staffId) {
        document.getElementById('qrDisplay').classList.remove('show');
        return;
    }
    
    // Generate QR code
    generateQRCode(staffId);
}

function generateQRCode(staffId) {
    try {
        showStatus('Generating QR code...', 'info');
        
        // Create QR code data
        const qrData = 'STAFF_' + staffId + '_' + new Date().getTime();
        
        // Simple QR code display (text-based for demo)
        const qrDiv = document.getElementById('qrCode');
        qrDiv.innerHTML = `
            <div style="font-size:10px; word-break:break-all; padding:10px;">
                ${qrData}
            </div>
        `;
        
        document.getElementById('qrDisplay').classList.add('show');
        showStatus('QR code generated successfully!', 'success');
        
        // Mark attendance with QR code
        markAttendanceWithQR(staffId, qrData);
        
    } catch (error) {
        console.error('QR generation error:', error);
        showStatus('Error generating QR code', 'error');
    }
}

async function markAttendanceWithQR(staffId, qrData) {
    try {
        const response = await fetch('QRCodeAttendance', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'staffId=' + encodeURIComponent(staffId) + '&qrData=' + encodeURIComponent(qrData)
        });
        
        const result = await response.json();
        
        if (result.success) {
            showStatus('Attendance marked successfully!', 'success');
        } else {
            showStatus('Error: ' + result.message, 'error');
        }
        
    } catch (error) {
        console.error('Attendance error:', error);
        showStatus('Network error', 'error');
    }
}

// Load staff members when page loads
document.addEventListener('DOMContentLoaded', loadStaffMembers);
</script>

</body>
</html>
