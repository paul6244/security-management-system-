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
<title>Staff Registration</title>

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

.registration-container {
    max-width:800px;
    margin:0 auto;
    background:white;
    padding:30px;
    border-radius:15px;
    box-shadow:0 4px 20px rgba(0,0,0,0.1);
}

.form-grid {
    display:grid;
    grid-template-columns: 1fr 1fr;
    gap:20px;
    margin-bottom:20px;
}

.form-group {
    margin-bottom:20px;
}

.form-group.full-width {
    grid-column: 1 / -1;
}

label {
    display:block;
    margin-bottom:5px;
    font-weight:600;
    color:#2c3e50;
}

input, select, textarea {
    width:100%;
    padding:12px;
    border:1px solid #ddd;
    border-radius:8px;
    font-size:14px;
    box-sizing:border-box;
}

textarea {
    height:100px;
    resize:vertical;
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

.btn:hover {
    opacity:0.9;
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

.staff-list {
    margin-top:30px;
}

.staff-card {
    background:#f8f9fa;
    border:1px solid #e9ecef;
    border-radius:10px;
    padding:20px;
    margin-bottom:15px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.staff-info h4 {
    margin:0 0 10px 0;
    color:#2c3e50;
}

.staff-info p {
    margin:5px 0;
    color:#7f8c8d;
    font-size:14px;
}

.qr-preview {
    width:80px;
    height:80px;
    border:1px solid #ddd;
    border-radius:8px;
    display:flex;
    align-items:center;
    justify-content:center;
    background:white;
    font-size:12px;
    color:#999;
}

/* Fingerprint Registration Styles */
.fingerprint-section {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius:12px;
    padding:20px;
    margin:20px 0;
}

.fingerprint-container {
    background: rgba(255, 255, 255, 0.95);
    border-radius:10px;
    padding:20px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.fingerprint-status {
    display: flex;
    align-items: center;
    gap:15px;
    padding:20px;
    background: #f8f9fa;
    border-radius:8px;
    margin-bottom:20px;
    border: 2px solid #e9ecef;
}

.status-icon {
    font-size: 48px;
    width: 60px;
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: #e9ecef;
}

.status-icon.scanning {
    animation: pulse 2s infinite;
    background: #fff3cd;
}

.status-icon.success {
    background: #d4edda;
}

.status-icon.error {
    background: #f8d7da;
}

.status-text {
    font-size: 18px;
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 5px;
}

.status-description {
    font-size: 14px;
    color: #6c757d;
}

.fingerprint-actions {
    display: flex;
    gap: 10px;
    justify-content: center;
}

.btn-primary {
    background: #007bff;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 16px;
    font-weight: 500;
    transition: background-color 0.3s;
}

.btn-primary:hover {
    background: #0056b3;
}

.btn-secondary {
    background: #6c757d;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 16px;
    font-weight: 500;
    transition: background-color 0.3s;
}

.btn-info {
    background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.btn-info:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(23, 132, 104, 0.3);
}

@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.1); }
    100% { transform: scale(1); }
}

/* Fingerprint Scanner Styles */
.fingerprint-scanner {
    width: 120px;
    height: 120px;
    margin: 0 auto 20px;
    position: relative;
}

.scanner-inner {
    width: 100%;
    height: 100%;
    background: linear-gradient(145deg, #2c3e50, #34495e);
    border-radius: 50%;
    position: relative;
    overflow: hidden;
    box-shadow: 
        0 8px 32px rgba(0, 0, 0, 0.3),
        inset 0 2px 8px rgba(255, 255, 255, 0.1);
    border: 3px solid #667eea;
}

.fingerprint-pattern {
    position: absolute;
    width: 80%;
    height: 80%;
    top: 10%;
    left: 10%;
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    align-items: center;
}

.fp-line {
    width: 60%;
    height: 3px;
    background: linear-gradient(90deg, 
        transparent 0%, 
        #667eea 20%, 
        #764ba2 50%, 
        #667eea 80%, 
        transparent 100%);
    border-radius: 2px;
    opacity: 0.8;
}

.fp-line:nth-child(1) { width: 70%; }
.fp-line:nth-child(2) { width: 65%; }
.fp-line:nth-child(3) { width: 75%; }
.fp-line:nth-child(4) { width: 60%; }
.fp-line:nth-child(5) { width: 70%; }
.fp-line:nth-child(6) { width: 65%; }
.fp-line:nth-child(7) { width: 75%; }
.fp-line:nth-child(8) { width: 60%; }

.scanner-line {
    position: absolute;
    width: 100%;
    height: 2px;
    background: linear-gradient(90deg, 
        transparent 0%, 
        #00ff88 25%, 
        #00ff88 75%, 
        transparent 100%);
    top: 50%;
    left: 0;
    transform: translateY(-50%);
    animation: scan 2s linear infinite;
    opacity: 0;
}

.scanner-glow {
    position: absolute;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle, 
        rgba(102, 126, 234, 0.3) 0%, 
        transparent 70%);
    border-radius: 50%;
    opacity: 0;
    animation: glow 2s ease-in-out infinite;
}

.scanner-label {
    text-align: center;
    margin-top: 10px;
    font-size: 12px;
    color: #667eea;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1px;
}

@keyframes scan {
    0% { top: 0%; opacity: 0; }
    10% { opacity: 1; }
    90% { opacity: 1; }
    100% { top: 100%; opacity: 0; }
}

@keyframes glow {
    0%, 100% { opacity: 0; }
    50% { opacity: 1; }
}

/* Scanning state animation */
.fingerprint-scanner.scanning .scanner-line {
    opacity: 1;
}

.fingerprint-scanner.scanning .scanner-glow {
    opacity: 1;
}

.fingerprint-scanner.scanning .scanner-inner {
    border-color: #00ff88;
    box-shadow: 
        0 8px 32px rgba(0, 255, 136, 0.3),
        inset 0 2px 8px rgba(0, 255, 136, 0.2);
}

.fingerprint-scanner.success .scanner-inner {
    border-color: #27ae60;
    background: linear-gradient(145deg, #27ae60, #2ecc71);
}

.fingerprint-scanner.error .scanner-inner {
    border-color: #e74c3c;
    background: linear-gradient(145deg, #c0392b, #e74c3c);
}

</style>
</head>
<body>

<div class="navbar">
    Staff Registration | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="attendance.jsp">Attendance</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<div class="registration-container">

<h2>Register New Staff Member</h2>

<!-- Status Messages -->
<div id="statusMessage" class="status-message"></div>

<form id="staffRegistrationForm" action="StaffRegistration" method="post">

<div class="form-grid">

<div class="form-group">
    <label for="firstName">First Name *</label>
    <input type="text" id="firstName" name="firstName" required>
</div>

<div class="form-group">
    <label for="lastName">Last Name *</label>
    <input type="text" id="lastName" name="lastName" required>
</div>

<div class="form-group">
    <label for="email">Email Address *</label>
    <input type="email" id="email" name="email" required>
</div>

<div class="form-group">
    <label for="phone">Phone Number *</label>
    <input type="tel" id="phone" name="phone" required>
</div>

<div class="form-group">
    <label for="department">Department *</label>
    <select id="department" name="department" required>
        <option value="">Select Department</option>
        <option value="Computer Science">Computer Science</option>
        <option value="Mathematics">Mathematics</option>
        <option value="Physics">Physics</option>
        <option value="Chemistry">Chemistry</option>
        <option value="Biology">Biology</option>
        <option value="Engineering">Engineering</option>
        <option value="Business">Business</option>
        <option value="Arts">Arts</option>
        <option value="Administration">Administration</option>
        <option value="Library">Library</option>
    </select>
</div>

<div class="form-group">
    <label for="position">Position/Role *</label>
    <select id="position" name="position" required>
        <option value="">Select Position</option>
        <option value="Lecturer">Lecturer</option>
        <option value="Professor">Professor</option>
        <option value="Assistant Professor">Assistant Professor</option>
        <option value="Teaching Assistant">Teaching Assistant</option>
        <option value="Lab Technician">Lab Technician</option>
        <option value="Administrator">Administrator</option>
        <option value="Librarian">Librarian</option>
        <option value="Staff">Staff</option>
    </select>
</div>

<div class="form-group">
    <label for="employeeId">Employee ID *</label>
    <input type="text" id="employeeId" name="employeeId" required>
</div>

<div class="form-group">
    <label for="officeLocation">Office Location</label>
    <input type="text" id="officeLocation" name="officeLocation" placeholder="e.g., Room 201, Building A">
</div>

<div class="form-group full-width">
    <label for="address">Address</label>
    <textarea id="address" name="address" placeholder="Full address"></textarea>
</div>

<!-- Fingerprint Registration Section -->
<div class="form-group full-width fingerprint-section">
    <label>Fingerprint Registration</label>
    <div class="fingerprint-container">
        <!-- Fingerprint Scanner Image -->
        <div class="fingerprint-scanner">
            <div class="scanner-inner">
                <div class="fingerprint-pattern">
                    <div class="fp-line"></div>
                    <div class="fp-line"></div>
                    <div class="fp-line"></div>
                    <div class="fp-line"></div>
                    <div class="fp-line"></div>
                    <div class="fp-line"></div>
                    <div class="fp-line"></div>
                    <div class="fp-line"></div>
                </div>
                <div class="scanner-line"></div>
                <div class="scanner-glow"></div>
            </div>
            <div class="scanner-label">Place Finger Here</div>
        </div>
        
        <div class="fingerprint-status" id="fingerprintStatus">
            <div class="status-icon">Finger</div>
            <div class="status-text">Fingerprint not registered yet</div>
            <div class="status-description">Register fingerprint for biometric attendance</div>
        </div>
        <div class="fingerprint-actions">
            <button type="button" class="btn btn-primary" onclick="registerFingerprint()" id="registerFingerprintBtn">
                Register Fingerprint
            </button>
            <button type="button" class="btn btn-secondary" onclick="testFingerprint()" id="testFingerprintBtn" style="display:none;">
                Test Fingerprint
            </button>
        </div>
    </div>
</div>

<div style="text-align:center;">
    <button type="submit" class="btn btn-success">Register Staff</button>
    <button type="reset" class="btn">Clear Form</button>
</div>

</form>

</div>

<!-- Staff List -->
<div class="registration-container staff-list">

<h3>Registered Staff Members</h3>

<div id="staffListContainer">

<%
Connection con = null;
try {
    con = SimpleDatabaseConfig.getSimpleConnection();
    String sql = "SELECT * FROM staff_registration ORDER BY created_at DESC";
    PreparedStatement ps = con.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
    
    boolean hasStaff = false;
    while(rs.next()) {
        hasStaff = true;
        int id = rs.getInt("id");
        String firstName = rs.getString("first_name");
        String lastName = rs.getString("last_name");
        String email = rs.getString("email");
        String department = rs.getString("department");
        String position = rs.getString("position");
        String employeeId = rs.getString("employee_id");
        Timestamp createdAt = rs.getTimestamp("created_at");
%>

<div class="staff-card">
    <div class="staff-info">
        <h4><%= firstName + " " + lastName %></h4>
        <p><strong>Employee ID:</strong> <%= employeeId %></p>
        <p><strong>Email:</strong> <%= email %></p>
        <p><strong>Department:</strong> <%= department %></p>
        <p><strong>Position:</strong> <%= position %></p>
        <p><strong>Registered:</strong> <%= createdAt.toString() %></p>
        
        <!-- QR Code Value Display -->
        <div style="margin-top:15px; padding:10px; background:#e3f2fd; border-radius:5px; font-size:12px;">
            <strong>QR Code Value:</strong><br>
            <code style="background:#fff; padding:5px; border-radius:3px; display:inline-block; margin-top:5px;">
                STAFF_<%= id %>_<%= employeeId %>_<%= java.util.Base64.getEncoder().encodeToString(email.getBytes()).substring(0, 8) %>
            </code>
            <br><small style="color:#666;">This is the value contained in the QR code</small>
        </div>
    </div>
    <div class="qr-preview" id="qr_<%= id %>">
        <div style="text-align:center;">No QR</div>
    </div>
</div>

<%
    }
    rs.close();
    ps.close();
    
    if(!hasStaff) {
%>

<div style="text-align:center; padding:40px; background:#f8f9fa; border-radius:10px; margin:20px 0;">
    <h3 style="color:#6c757d; margin-bottom:10px;">No Staff Members Registered</h3>
    <p style="color:#6c757d;">Please register staff members using the form above to see them here.</p>
</div>

<%
    }
} catch(SQLException e) {
%>

<div style="text-align:center; padding:40px; background:#f8d7da; border-radius:10px; margin:20px 0;">
    <h3 style="color:#721c24; margin-bottom:10px;">Database Error</h3>
    <p style="color:#721c24;">Unable to connect to database: <%= e.getMessage() %></p>
    <p style="color:#721c24;">Please check database configuration and try again.</p>
</div>

<%
} catch(Exception e) {
%>

<div style="text-align:center; padding:40px; background:#f8d7da; border-radius:10px; margin:20px 0;">
    <h3 style="color:#721c24; margin-bottom:10px;">System Error</h3>
    <p style="color:#721c24;">An unexpected error occurred: <%= e.getMessage() %></p>
</div>

<%
} finally {
    if(con != null) {
        try {
            con.close();
        } catch(Exception e) {
            // Ignore connection close error
        }
    }
}
%>

</div>

<div style="text-align:center; margin-top:20px;">
    <button class="btn btn-success" onclick="generateAllStaffQRCodes()">Generate QR Codes for All Staff</button>
    <button class="btn" onclick="downloadAllStaffQRCodes()">Download All QR Codes</button>
</div>

</div>

</div>
</div>

<script>

function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.className = 'status-message status-' + type;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 5000);
}

// Validate form before submission
function validateRegistrationForm() {
    const firstName = document.getElementById('firstName').value.trim();
    const lastName = document.getElementById('lastName').value.trim();
    const email = document.getElementById('email').value.trim();
    const phone = document.getElementById('phone').value.trim();
    const department = document.getElementById('department').value;
    const position = document.getElementById('position').value.trim();
    const employeeId = document.getElementById('employeeId').value.trim();
    
    if(!firstName || !lastName || !email || !phone || !department || !position || !employeeId) {
        showStatus('Please fill in all required fields', 'error');
        return false;
    }
    
    // Phone validation
    const phonePattern = /^(\+[0-9]{10,15}|[0-9]{10})$/;
    if(!phonePattern.test(phone)) {
        showStatus('Please enter a valid phone number (e.g., +233596244927 or 0596244927)', 'error');
        return false;
    }
    
    return true;
}

// Override form submission to validate first
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('staffRegistrationForm');
    if(form) {
        form.addEventListener('submit', function(e) {
            if(!validateRegistrationForm()) {
                e.preventDefault();
                return false;
            }
        });
    }
});

// Generate QR code content
function generateStaffQRCode(staffId, fullName, employeeId, email) {
    // Create unique QR code content using multiple staff identifiers
    const qrContent = 'STAFF_' + staffId + '_' + employeeId + '_' + btoa(email).substring(0, 8);
    
    // Use QR Server API (more reliable than Google Charts)
    const qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=80x80&data=' + encodeURIComponent(qrContent);
    
    const qrDiv = document.getElementById('qr_' + staffId);
    qrDiv.innerHTML = '<img src="' + qrUrl + '" alt="QR Code for ' + fullName + '" style="width:100%; height:100%; border-radius:8px;">';
    
    showStatus('QR code generated for ' + fullName, 'success');
}

function generateAllStaffQRCodes() {
    const staffCards = document.querySelectorAll('.staff-card');
    let generated = 0;
    
    staffCards.forEach(card => {
        const staffId = card.querySelector('.qr-preview').id.replace('qr_', '');
        const fullName = card.querySelector('h4').textContent;
        
        // Extract employee ID and email from staff info
        const staffInfo = card.querySelectorAll('p');
        let employeeId = '';
        let email = '';
        
        staffInfo.forEach(p => {
            if(p.textContent.includes('Employee ID:')) {
                employeeId = p.textContent.replace('Employee ID:', '').trim();
            }
            if(p.textContent.includes('Email:')) {
                email = p.textContent.replace('Email:', '').trim();
            }
        });
        
        // Create unique QR code content
        const qrContent = 'STAFF_' + staffId + '_' + employeeId + '_' + btoa(email).substring(0, 8);
        const qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=80x80&data=' + encodeURIComponent(qrContent);
        
        const qrDiv = card.querySelector('.qr-preview');
        qrDiv.innerHTML = '<img src="' + qrUrl + '" alt="QR Code for ' + fullName + '" style="width:100%; height:100%; border-radius:8px;">';
        
        generated++;
    });
    
    showStatus('Generated ' + generated + ' unique QR codes successfully!', 'success');
}

function downloadAllStaffQRCodes() {
    const qrImages = document.querySelectorAll('.qr-preview img');
    let downloaded = 0;
    
    qrImages.forEach((img, index) => {
        setTimeout(() => {
            const staffCard = img.closest('.staff-card');
            const fullName = staffCard.querySelector('h4').textContent;
            const staffId = staffCard.querySelector('.qr-preview').id.replace('qr_', '');
            
            const link = document.createElement('a');
            link.href = img.src;
            link.download = 'QR_' + fullName.replace(' ', '_') + '_' + staffId + '.png';
            link.target = '_blank';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
            downloaded++;
            
            if(downloaded === qrImages.length) {
                showStatus('Downloaded ' + downloaded + ' QR codes successfully!', 'success');
            }
        }, index * 200); // Delay between downloads
    });
}

// Fingerprint Registration Functions
function registerFingerprint() {
    const employeeId = document.getElementById('employeeId').value.trim();
    
    if (!employeeId) {
        showStatus('Please enter Employee ID first', 'error');
        document.getElementById('employeeId').focus();
        return;
    }
    
    const statusDiv = document.getElementById('fingerprintStatus');
    const scannerDiv = document.querySelector('.fingerprint-scanner');
    
    // Check if browser supports WebAuthn (real fingerprint)
    if (window.PublicKeyCredential && navigator.credentials) {
        // Try real fingerprint first
        tryRealFingerprint(employeeId, statusDiv, scannerDiv);
    } else {
        // Fall back to simulation
        useSimulatedFingerprint(employeeId, statusDiv, scannerDiv);
    }
}

// Try to use real fingerprint scanner
async function tryRealFingerprint(employeeId, statusDiv, scannerDiv) {
    try {
        scannerDiv.classList.add('scanning');
        statusDiv.innerHTML = `
            <div class="status-icon scanning">Scanning</div>
            <div class="status-text">Scanning real fingerprint...</div>
            <div class="status-description">Please place your finger on the scanner</div>
        `;
        
        // Create WebAuthn credential request
        const credentialRequestOptions = {
            publicKey: {
                challenge: new Uint8Array(32),
                rp: {
                    name: "Security Management System",
                    id: window.location.hostname
                },
                user: {
                    id: new TextEncoder().encode(employeeId),
                    name: employeeId,
                    displayName: employeeId
                },
                authenticatorSelection: {
                    authenticatorAttachment: "platform",
                    userVerification: "required"
                }
            }
        };
        
        // Request real fingerprint
        const credential = await navigator.credentials.get(credentialRequestOptions);
        
        if (credential) {
            // Convert fingerprint data to string
            const fingerprintData = arrayBufferToBase64(credential.rawId);
            
            // Send to server
            sendFingerprintToServer(employeeId, fingerprintData, statusDiv, scannerDiv, 'real');
        } else {
            throw new Error('No fingerprint provided');
        }
        
    } catch (error) {
        console.log('Real fingerprint not available, using simulation:', error.message);
        // Fall back to simulation
        useSimulatedFingerprint(employeeId, statusDiv, scannerDiv);
    }
}

// Use simulated fingerprint (current working method)
function useSimulatedFingerprint(employeeId, statusDiv, scannerDiv) {
    scannerDiv.classList.add('scanning');
    
    statusDiv.innerHTML = `
        <div class="status-icon scanning">Scanning</div>
        <div class="status-text">Scanning fingerprint...</div>
        <div class="status-description">Please place your finger on the scanner</div>
    `;
    
    // Generate simulated fingerprint data
    setTimeout(() => {
        const fingerprintData = generateSimulatedFingerprint(employeeId);
        sendFingerprintToServer(employeeId, fingerprintData, statusDiv, scannerDiv, 'simulated');
    }, 2000);
}

// Send fingerprint data to server
function sendFingerprintToServer(employeeId, fingerprintData, statusDiv, scannerDiv, type) {
    console.log(`Sending ${type} fingerprint registration for employee:`, employeeId);
    console.log('Fingerprint data length:', fingerprintData.length);
    
    fetch('FingerprintRegistration', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'employeeId=' + encodeURIComponent(employeeId) + '&fingerprintData=' + encodeURIComponent(fingerprintData) + '&type=' + encodeURIComponent(type)
    })
    .then(response => {
        console.log('Response status:', response.status);
        if (!response.ok) {
            throw new Error('HTTP error! Status: ' + response.status);
        }
        return response.json();
    })
    .then(data => {
        console.log('Response data:', data);
        if (data.success) {
            // Remove scanning animation and add success
            scannerDiv.classList.remove('scanning');
            scannerDiv.classList.add('success');
            
            statusDiv.innerHTML = `
                <div class="status-icon success">Success</div>
                <div class="status-text">Fingerprint registered successfully!</div>
                <div class="status-description">Biometric authentication is now enabled (${type})</div>
            `;
            document.getElementById('registerFingerprintBtn').style.display = 'none';
            document.getElementById('testFingerprintBtn').style.display = 'inline-block';
            showStatus('Fingerprint registered successfully!', 'success');
            
            // Remove success class after 3 seconds
            setTimeout(() => {
                scannerDiv.classList.remove('success');
            }, 3000);
        } else {
            // Remove scanning animation and add error
            scannerDiv.classList.remove('scanning');
            scannerDiv.classList.add('error');
            
            statusDiv.innerHTML = `
                <div class="status-icon error">Error</div>
                <div class="status-text">Registration failed</div>
                <div class="status-description">${data.message}</div>
            `;
            showStatus('Fingerprint registration failed: ' + data.message, 'error');
            
            // Remove error class after 3 seconds
            setTimeout(() => {
                scannerDiv.classList.remove('error');
            }, 3000);
        }
    })
    .catch(error => {
        // Remove scanning animation and add error
        scannerDiv.classList.remove('scanning');
        scannerDiv.classList.add('error');
        
        console.error('Fingerprint registration error:', error);
        console.error('Error details:', error.message);
        statusDiv.innerHTML = `
            <div class="status-icon error">Error</div>
            <div class="status-text">Registration failed</div>
            <div class="status-description">Network error occurred: ${error.message}</div>
        `;
        showStatus('Network error during fingerprint registration: ' + error.message, 'error');
        
        // Remove error class after 3 seconds
        setTimeout(() => {
            scannerDiv.classList.remove('error');
        }, 3000);
    });
}

// Convert ArrayBuffer to Base64
function arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
}

function testFingerprint() {
    const employeeId = document.getElementById('employeeId').value.trim();
    
    if (!employeeId) {
        showStatus('Please enter Employee ID first', 'error');
        return;
    }
    
    const statusDiv = document.getElementById('fingerprintStatus');
    const scannerDiv = document.querySelector('.fingerprint-scanner');
    
    // Check if browser supports WebAuthn (real fingerprint)
    if (window.PublicKeyCredential && navigator.credentials) {
        // Try real fingerprint first
        tryRealFingerprintVerification(employeeId, statusDiv, scannerDiv);
    } else {
        // Fall back to simulation
        useSimulatedFingerprintVerification(employeeId, statusDiv, scannerDiv);
    }
}

// Try to use real fingerprint for verification
async function tryRealFingerprintVerification(employeeId, statusDiv, scannerDiv) {
    try {
        scannerDiv.classList.add('scanning');
        
        statusDiv.innerHTML = `
            <div class="status-icon scanning">Testing</div>
            <div class="status-text">Testing real fingerprint...</div>
            <div class="status-description">Verifying fingerprint match</div>
        `;
        
        // Create WebAuthn assertion request
        const assertionOptions = {
            publicKey: {
                challenge: new Uint8Array(32),
                rp: {
                    name: "Security Management System",
                    id: window.location.hostname
                },
                userVerification: "required"
            }
        }
        };
        
        // Request real fingerprint verification
        const assertion = await navigator.credentials.get(assertionOptions);
        
        if (assertion) {
            // Convert fingerprint data to string
            const fingerprintData = arrayBufferToBase64(assertion.rawId);
            
            // Send to verification server
            sendVerificationToServer(employeeId, fingerprintData, statusDiv, scannerDiv, 'real');
        } else {
            throw new Error('No fingerprint provided');
        }
        
    } catch (error) {
        showStatus('Real fingerprint error: ' + error.message, 'error');
        console.error('Windows Hello error:', error);
    }
}

// Try to use real fingerprint for verification
async function tryRealFingerprintVerification(employeeId, statusDiv, scannerDiv) {
    try {
        scannerDiv.classList.add('scanning');
        
        statusDiv.innerHTML = `
            <div class="status-icon scanning">Testing</div>
            <div class="status-text">Testing real fingerprint...</div>
            <div class="status-description">Verifying fingerprint match</div>
        `;
        
        // Create WebAuthn assertion request
        const assertionOptions = {
            publicKey: {
                challenge: new Uint8Array(32),
                rp: {
                    name: "Security Management System",
                    id: window.location.hostname
                },
                userVerification: "required"
            }
        };
        
        // Request real fingerprint verification
        const assertion = await navigator.credentials.get(assertionOptions);
        
        if (assertion) {
            // Convert fingerprint data to string
            const fingerprintData = arrayBufferToBase64(assertion.rawId);
            
            // Send to verification server
            sendVerificationToServer(employeeId, fingerprintData, statusDiv, scannerDiv, 'real');
        } else {
            throw new Error('No fingerprint provided');
        }
        
    } catch (error) {
        console.log('Real fingerprint verification not available, using simulation:', error.message);
        // Fall back to simulation
        useSimulatedFingerprintVerification(employeeId, statusDiv, scannerDiv);
    }
}
}


// Use simulated fingerprint verification (current working method)
function useSimulatedFingerprintVerification(employeeId, statusDiv, scannerDiv) {
    scannerDiv.classList.add('scanning');
    
    statusDiv.innerHTML = `
        <div class="status-icon scanning">Testing</div>
        <div class="status-text">Testing fingerprint...</div>
        <div class="status-description">Verifying fingerprint match</div>
    `;
    
    setTimeout(() => {
        const fingerprintData = generateSimulatedFingerprint(employeeId);
        
        // Send to verification server
        sendVerificationToServer(employeeId, fingerprintData, statusDiv, scannerDiv, 'simulated');
    }, 2000);
}

// Send fingerprint verification to server
function sendVerificationToServer(employeeId, fingerprintData, statusDiv, scannerDiv, type) {
    console.log(`Sending ${type} fingerprint verification for employee:`, employeeId);
    console.log('Fingerprint data length:', fingerprintData.length);
    
    fetch('FingerprintVerification', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'employeeId=' + encodeURIComponent(employeeId) + '&fingerprintData=' + encodeURIComponent(fingerprintData) + '&type=' + encodeURIComponent(type)
    })
    .then(response => {
        console.log('Verification response status:', response.status);
        if (!response.ok) {
            throw new Error('HTTP error! Status: ' + response.status);
        }
        return response.json();
    })
    .then(data => {
        console.log('Verification response data:', data);
        if (data.success) {
            // Remove scanning animation and add success
            scannerDiv.classList.remove('scanning');
            scannerDiv.classList.add('success');
            
            statusDiv.innerHTML = `
                <div class="status-icon success">Success</div>
                <div class="status-text">Fingerprint verified!</div>
                <div class="status-description">Match found for ${data.employeeName} (${type})</div>
            `;
            showStatus('Fingerprint verification successful!', 'success');
            
            // Remove success class after 3 seconds
            setTimeout(() => {
                scannerDiv.classList.remove('success');
            }, 3000);
        } else {
            // Remove scanning animation and add error
            scannerDiv.classList.remove('scanning');
            scannerDiv.classList.add('error');
            
            statusDiv.innerHTML = `
                <div class="status-icon error">Error</div>
                <div class="status-text">Verification failed</div>
                <div class="status-description">${data.message}</div>
            `;
            showStatus('Fingerprint verification failed: ' + data.message, 'error');
            
            // Remove error class after 3 seconds
            setTimeout(() => {
                scannerDiv.classList.remove('error');
            }, 3000);
        }
    })
    .catch(error => {
        // Remove scanning animation and add error
        scannerDiv.classList.remove('scanning');
        scannerDiv.classList.add('error');
        
        console.error('Fingerprint verification error:', error);
        console.error('Verification error details:', error.message);
        statusDiv.innerHTML = `
            <div class="status-icon error">Error</div>
            <div class="status-text">Verification failed</div>
            <div class="status-description">Network error occurred: ${error.message}</div>
        `;
        showStatus('Network error during fingerprint verification: ' + error.message, 'error');
        
        // Remove error class after 3 seconds
        setTimeout(() => {
            scannerDiv.classList.remove('error');
        }, 3000);
    });
}

function generateSimulatedFingerprint(employeeId) {
    // Generate a consistent but unique fingerprint template based on employee ID
    const baseData = "FP_" + employeeId + "_";
    let fingerprint = baseData;
    
    // Add random-looking but deterministic data
    const hash = employeeId.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
    for (let i = 0; i < 100; i++) {
        fingerprint += String.fromCharCode(65 + (Math.abs(hash + i) % 26));
        fingerprint += String.fromCharCode(48 + (Math.abs(hash * (i + 1)) % 10));
    }
    
    return fingerprint;
}

// Check for success parameter
window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    if(urlParams.get('success') === '1') {
        showStatus('Staff registered successfully!', 'success');
        // Auto-generate QR code for the new staff after a delay
        setTimeout(() => {
            generateAllStaffQRCodes();
        }, 1000);
    }
    
    // Check if real fingerprint registration is enabled
    const enableRealFingerprint = urlParams.get('realFingerprint') === '1';
    
    if (enableRealFingerprint) {
        // Add real fingerprint registration button
        const realFingerprintBtn = document.createElement('button');
        realFingerprintBtn.innerHTML = '🔐 Use Real Fingerprint';
        realFingerprintBtn.className = 'btn btn-info';
        realFingerprintBtn.style.margin = '10px';
        realFingerprintBtn.onclick = registerRealFingerprint;
        
        // Insert after the existing register button
        const registerBtn = document.getElementById('registerFingerprintBtn');
        registerBtn.parentNode.insertBefore(realFingerprintBtn, registerBtn.nextSibling);
    }
}

// Real Windows Hello fingerprint registration
async function registerRealFingerprint() {
    const employeeId = document.getElementById('employeeId').value.trim();
    
    if (!employeeId) {
        showStatus('Please enter Employee ID first', 'error');
        document.getElementById('employeeId').focus();
        return;
    }
    
    try {
        // Check if WebAuthn is available
        if (!window.PublicKeyCredential || !navigator.credentials) {
            throw new Error('WebAuthn not supported in this browser');
        }
        
        showStatus('Requesting fingerprint from Windows Hello...', 'info');
        
        // Create WebAuthn credential request
        const publicKey = {
            challenge: new Uint8Array(32),
            rp: { 
                name: "Security Management System",
                id: window.location.hostname 
            },
            user: {
                id: new TextEncoder().encode(employeeId),
                name: employeeId,
                displayName: employeeId
            },
            pubKeyCredParams: [{ 
                type: "public-key", 
                alg: -7 
            }],
            authenticatorSelection: {
                authenticatorAttachment: "platform",
                userVerification: "required"
            },
            timeout: 60000,
            attestation: "direct"
        };

        // Request credential creation
        const credential = await navigator.credentials.create({ publicKey });
        
        if (credential) {
            // Convert credential ID to Base64
            const credentialId = btoa(String.fromCharCode(...new Uint8Array(credential.rawId)));
            
            showStatus('Registering fingerprint with system...', 'info');
            
            // Send ONLY credential ID to server (server will handle the actual fingerprint)
            const response = await fetch('FingerprintRegistration', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/x-www-form-urlencoded' 
                },
                body: `employeeId=${encodeURIComponent(employeeId)}&credentialId=${encodeURIComponent(credentialId)}&type=windows_hello`
            });
            
            if (response.ok) {
                const result = await response.json();
                if (result.success) {
                    showStatus('Windows Hello fingerprint registered successfully!', 'success');
                    alert('Fingerprint registered via Windows Hello!');
                } else {
                    showStatus('Registration failed: ' + result.message, 'error');
                }
            } else {
                throw new Error('Network error');
            }
        } else {
            throw new Error('No fingerprint provided');
        }
        
    } catch (error) {
        showStatus('Real fingerprint error: ' + error.message, 'error');
        console.error('Windows Hello error:', error);
    }
};

</script>

</body>
</html>
