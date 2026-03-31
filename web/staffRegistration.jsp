<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="model.Mymodel" %>
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

<!-- Selfie Capture Section -->
<div class="form-group full-width">
    <label>Staff Photo (Required)</label>
    <div style="display:flex; gap:20px; align-items:flex-start;">
        <div style="flex:1;">
            <video id="registrationCamera" autoplay style="width:100%; max-width:300px; border:2px solid #ddd; border-radius:8px;"></video>
            <canvas id="registrationCanvas" style="display:none;"></canvas>
            <input type="hidden" name="selfie" id="registrationSelfie">
            
            <div style="margin-top:10px;">
                <button type="button" class="btn" onclick="startRegistrationCamera()">Start Camera</button>
                <button type="button" class="btn btn-success" onclick="captureRegistrationSelfie()">Capture Photo</button>
                <button type="button" class="btn" onclick="retakeRegistrationSelfie()">Retake</button>
            </div>
        </div>
        <div style="flex:1;">
            <div id="selfiePreview" style="text-align:center; padding:20px; border:2px dashed #ddd; border-radius:8px; min-height:200px;">
                <div style="color:#666;">No photo captured yet</div>
            </div>
            <small style="color:#666; display:block; margin-top:10px;">
                This photo will be used for face verification during attendance check-in.
            </small>
        </div>
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
// Load registered staff from database using PostgreSQL
try {
    Connection con = SimpleDatabaseConfig.getSimpleConnection();
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
    con.close();
    
    if(!hasStaff) {
%>

<div style="text-align:center; padding:40px; background:#f8f9fa; border-radius:10px; margin:20px 0;">
    <h3 style="color:#6c757d; margin-bottom:10px;">No Staff Members Registered</h3>
    <p style="color:#6c757d;">Please register staff members using the form above to see them here.</p>
    <button class="btn btn-success" onclick="location.href='staffRegistration.jsp'">Register Staff</button>
</div>

<%
    }
} catch(SQLException e) {
%>

<div style="text-align:center; padding:40px; background:#f8d7da; border-radius:10px; margin:20px 0;">
    <h3 style="color:#721c24; margin-bottom:10px;">MySQL Driver Not Found</h3>
    <p style="color:#721c24;">The MySQL JDBC driver is not available. Please add the MySQL connector JAR to your project.</p>
    <p style="color:#721c24;">Download from: https://dev.mysql.com/downloads/connector/j/</p>
</div>

<%
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

// Registration Camera Functions
let registrationStream = null;
let registrationSelfieCaptured = false;

function startRegistrationCamera() {
    const video = document.getElementById('registrationCamera');
    
    if(navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        navigator.mediaDevices.getUserMedia({ video: true })
        .then(function(mediaStream) {
            registrationStream = mediaStream;
            video.srcObject = mediaStream;
            showStatus('Camera ready for photo capture', 'success');
        })
        .catch(function(error) {
            showStatus('Unable to access camera: ' + error.message, 'error');
        });
    } else {
        showStatus('Camera not supported by browser', 'error');
    }
}

function captureRegistrationSelfie() {
    const video = document.getElementById('registrationCamera');
    const canvas = document.getElementById('registrationCanvas');
    const preview = document.getElementById('selfiePreview');
    
    if(!registrationStream) {
        showStatus('Please start camera first', 'error');
        return;
    }
    
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    
    let ctx = canvas.getContext("2d");
    ctx.drawImage(video, 0, 0);
    
    let dataURL = canvas.toDataURL("image/png");
    document.getElementById('registrationSelfie').value = dataURL;
    
    // Show preview
    preview.innerHTML = '<img src="' + dataURL + '" alt="Staff Photo" style="max-width:100%; max-height:200px; border-radius:8px;">';
    
    registrationSelfieCaptured = true;
    showStatus('Photo captured successfully!', 'success');
    
    // Stop camera after capture
    if(registrationStream) {
        registrationStream.getTracks().forEach(track => track.stop());
        registrationStream = null;
    }
}

function retakeRegistrationSelfie() {
    registrationSelfieCaptured = false;
    document.getElementById('registrationSelfie').value = '';
    document.getElementById('selfiePreview').innerHTML = '<div style="color:#666;">No photo captured yet</div>';
    showStatus('Photo cleared. You can capture a new one.', 'info');
}

// Validate selfie before form submission
function validateRegistrationForm() {
    const firstName = document.getElementById('firstName').value.trim();
    const lastName = document.getElementById('lastName').value.trim();
    const email = document.getElementById('email').value.trim();
    const phone = document.getElementById('phone').value.trim();
    const department = document.getElementById('department').value;
    const position = document.getElementById('position').value.trim();
    const employeeId = document.getElementById('employeeId').value.trim();
    const selfie = document.getElementById('registrationSelfie').value;
    
    if(!firstName || !lastName || !email || !phone || !department || !position || !employeeId) {
        showStatus('Please fill in all required fields', 'error');
        return false;
    }
    
    if(!registrationSelfieCaptured || !selfie) {
        showStatus('Please capture a staff photo', 'error');
        return false;
    }
    
    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if(!emailRegex.test(email)) {
        showStatus('Please enter a valid email address', 'error');
        return false;
    }
    
    // Phone validation
    const phoneRegex = /^[\d\s\-\+\(\)]+$/;
    if(!phoneRegex.test(phone.replace(/\s/g, ''))) {
        showStatus('Please enter a valid phone number', 'error');
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
};

</script>

</body>
</html>
