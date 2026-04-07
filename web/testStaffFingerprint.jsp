<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<!DOCTYPE html>
<html>
<head>
<title>Staff Registration with Fingerprint - Test</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">
<style>
body {
    font-family: 'Poppins', sans-serif;
    margin:0;
    background:#f4f6f9;
    padding:20px;
}

.registration-container {
    max-width:1000px;
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

.btn-primary {
    background:#007bff;
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

.status-info {
    background:#d1ecf1;
    color:#0c5460;
    border:1px solid #bee5eb;
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

@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.1); }
    100% { transform: scale(1); }
}

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

.fingerprint-option {
    margin: 10px 0;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.fingerprint-option label {
    display: flex;
    align-items: center;
    cursor: pointer;
}

.fingerprint-option input[type="radio"] {
    margin-right: 10px;
    width: auto;
}
</style>
</head>
<body>

<div class="registration-container">

<h2>🔐 Staff Registration with Fingerprint - Test Mode</h2>
<p style="background: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 20px;">
    <strong>🧪 Test Mode:</strong> This page bypasses login requirements for testing fingerprint registration functionality.
</p>

<!-- Status Messages -->
<div id="statusMessage" class="status-message"></div>

<form id="staffRegistrationForm" onsubmit="return handleSubmit(event)">

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
        
        <div class="fingerprint-option">
            <label>
                <input type="radio" name="fingerprintOption" value="register" checked>
                <span>Register Fingerprint Now (Recommended)</span>
            </label>
        </div>
        
        <div class="fingerprint-actions">
            <button type="button" class="btn btn-primary" onclick="registerFingerprint()" id="registerFingerprintBtn">
                Register Fingerprint
            </button>
            <button type="button" class="btn" onclick="testFingerprint()" id="testFingerprintBtn" style="display:none;">
                Test Fingerprint
            </button>
        </div>
    </div>
</div>

<div style="text-align:center;">
    <button type="submit" class="btn btn-success" id="submitBtn">Register Staff with Fingerprint</button>
    <button type="reset" class="btn">Clear Form</button>
</div>

</form>

<div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 10px;">
    <h3>🔗 Navigation</h3>
    <p><a href="staffRegistration.jsp" class="btn">📝 Original Staff Registration</a></p>
    <p><a href="testFingerprint.jsp" class="btn">🔍 Fingerprint Testing Only</a></p>
    <p><a href="clearStaffData.jsp" class="btn">🗑️ Clear Staff Data</a></p>
    <p><a href="index.jsp" class="btn">🏠 Login</a></p>
</div>

</div>

<script>
let fingerprintRegistered = false;
let fingerprintData = null;

function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.className = 'status-message status-' + type;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 5000);
}

// Generate simulated fingerprint data
function generateSimulatedFingerprint(employeeId) {
    const baseData = "FP_" + employeeId + "_";
    let fingerprint = baseData;
    
    const hash = employeeId.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
    for (let i = 0; i < 100; i++) {
        fingerprint += String.fromCharCode(65 + (Math.abs(hash + i) % 26));
        fingerprint += String.fromCharCode(48 + (Math.abs(hash * (i + 1)) % 10));
    }
    
    return fingerprint;
}

// Handle form submission
function handleSubmit(event) {
    event.preventDefault();
    
    const firstName = document.getElementById('firstName').value.trim();
    const lastName = document.getElementById('lastName').value.trim();
    const email = document.getElementById('email').value.trim();
    const phone = document.getElementById('phone').value.trim();
    const department = document.getElementById('department').value;
    const position = document.getElementById('position').value.trim();
    const employeeId = document.getElementById('employeeId').value.trim();
    const officeLocation = document.getElementById('officeLocation').value.trim();
    const address = document.getElementById('address').value.trim();
    
    // Validate required fields
    if(!firstName || !lastName || !email || !phone || !department || !position || !employeeId) {
        showStatus('Please fill in all required fields', 'error');
        return false;
    }
    
    // Check fingerprint option
    const fingerprintOption = document.querySelector('input[name="fingerprintOption"]:checked').value;
    if (fingerprintOption === 'register' && !fingerprintRegistered) {
        showStatus('Please register fingerprint first', 'error');
        return false;
    }
    
    // Create form data
    const formData = new FormData();
    formData.append('firstName', firstName);
    formData.append('lastName', lastName);
    formData.append('email', email);
    formData.append('phone', phone);
    formData.append('department', department);
    formData.append('position', position);
    formData.append('employeeId', employeeId);
    formData.append('officeLocation', officeLocation);
    formData.append('address', address);
    
    if (fingerprintRegistered && fingerprintData) {
        formData.append('fingerprintData', fingerprintData);
    }
    
    // Submit to server
    fetch('StaffRegistrationWithFingerprint', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showStatus('✅ ' + data.message, 'success');
            // Reset form after successful submission
            document.getElementById('staffRegistrationForm').reset();
            fingerprintRegistered = false;
            fingerprintData = null;
            updateFingerprintStatus();
        } else {
            showStatus('❌ ' + data.message, 'error');
        }
    })
    .catch(error => {
        showStatus('❌ Network error: ' + error.message, 'error');
    });
    
    return false;
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
    
    useSimulatedFingerprint(employeeId, statusDiv, scannerDiv);
}

function useSimulatedFingerprint(employeeId, statusDiv, scannerDiv) {
    scannerDiv.classList.add('scanning');
    
    statusDiv.innerHTML = `
        <div class="status-icon scanning">Scanning</div>
        <div class="status-text">Scanning fingerprint...</div>
        <div class="status-description">Please place your finger on scanner</div>
    `;
    
    // Generate simulated fingerprint data
    setTimeout(() => {
        fingerprintData = generateSimulatedFingerprint(employeeId);
        fingerprintRegistered = true;
        
        // Remove scanning animation and add success
        scannerDiv.classList.remove('scanning');
        scannerDiv.classList.add('success');
        
        statusDiv.innerHTML = `
            <div class="status-icon success">Finger</div>
            <div class="status-text">Fingerprint registered successfully!</div>
            <div class="status-description">Biometric authentication is now enabled</div>
        `;
        
        document.getElementById('registerFingerprintBtn').style.display = 'none';
        document.getElementById('testFingerprintBtn').style.display = 'inline-block';
        
        showStatus('Fingerprint registered successfully! You can now submit staff registration.', 'success');
        
        // Remove success class after 3 seconds
        setTimeout(() => {
            scannerDiv.classList.remove('success');
        }, 3000);
    }, 2000);
}

function testFingerprint() {
    const employeeId = document.getElementById('employeeId').value.trim();
    
    if (!employeeId) {
        showStatus('Please enter Employee ID first', 'error');
        return;
    }
    
    const statusDiv = document.getElementById('fingerprintStatus');
    const scannerDiv = document.querySelector('.fingerprint-scanner');
    
    scannerDiv.classList.add('scanning');
    
    statusDiv.innerHTML = `
        <div class="status-icon scanning">Testing</div>
        <div class="status-text">Testing fingerprint...</div>
        <div class="status-description">Verifying fingerprint match</div>
    `;
    
    setTimeout(() => {
        // Remove scanning animation and add success
        scannerDiv.classList.remove('scanning');
        scannerDiv.classList.add('success');
        
        statusDiv.innerHTML = `
            <div class="status-icon success">Finger</div>
            <div class="status-text">Fingerprint verified!</div>
            <div class="status-description">Match found for ${employeeId}</div>
        `;
        
        showStatus('Fingerprint verification successful!', 'success');
        
        // Remove success class after 3 seconds
        setTimeout(() => {
            scannerDiv.classList.remove('success');
        }, 3000);
    }, 2000);
}

function updateFingerprintStatus() {
    const statusDiv = document.getElementById('fingerprintStatus');
    const registerBtn = document.getElementById('registerFingerprintBtn');
    const testBtn = document.getElementById('testFingerprintBtn');
    
    if (fingerprintRegistered) {
        registerBtn.style.display = 'none';
        testBtn.style.display = 'inline-block';
        statusDiv.innerHTML = `
            <div class="status-icon success">Finger</div>
            <div class="status-text">Fingerprint registered</div>
            <div class="status-description">Ready for biometric authentication</div>
        `;
    } else {
        registerBtn.style.display = 'inline-block';
        testBtn.style.display = 'none';
        statusDiv.innerHTML = `
            <div class="status-icon">Finger</div>
            <div class="status-text">Fingerprint not registered yet</div>
            <div class="status-description">Register fingerprint for biometric attendance</div>
        `;
    }
}

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    updateFingerprintStatus();
});
</script>

</body>
</html>
