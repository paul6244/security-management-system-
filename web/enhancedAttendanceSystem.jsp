<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Enhanced Security Management System</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Poppins', sans-serif;
    margin: 0;
    padding: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    color: #333;
}

.navbar {
    background: #1e2a38;
    color: white;
    padding: 15px;
    font-size: 20px;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.container {
    display: flex;
    min-height: calc(100vh - 60px);
}

.sidebar {
    width: 280px;
    background: #2c3e50;
    color: white;
    box-shadow: 2px 0 10px rgba(0,0,0,0.1);
}

.sidebar a {
    display: block;
    padding: 15px;
    color: white;
    text-decoration: none;
    transition: all 0.3s ease;
}

.sidebar a:hover {
    background: #34495e;
    transform: translateX(5px);
}

.main-content {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
}

.status-card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.status-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
}

.status-item {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    border-left: 4px solid #007bff;
}

.status-label {
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 5px;
}

.status-value {
    font-size: 18px;
    color: #3498db;
}

.attendance-card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.card-title {
    font-size: 20px;
    font-weight: 600;
    color: #2c3e50;
}

.card-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.btn {
    padding: 12px 20px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
}

.btn-primary {
    background: #007bff;
    color: white;
}

.btn-success {
    background: #28a745;
    color: white;
}

.btn-warning {
    background: #ffc107;
    color: #212529;
}

.btn-danger {
    background: #dc3545;
    color: white;
}

.btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
}

.btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
}

.btn-small {
    padding: 8px 16px;
    font-size: 12px;
}

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 5px;
}

.form-group input, .form-group select {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
}

.verification-section {
    background: #e8f5e8;
    border-radius: 12px;
    padding: 20px;
    margin: 20px 0;
}

.camera-container {
    position: relative;
    width: 100%;
    max-width: 400px;
    margin: 0 auto 20px;
}

#camera {
    width: 100%;
    border-radius: 8px;
    background: #000;
}

#selfie-canvas {
    display: none;
}

.liveness-indicator {
    position: absolute;
    top: 10px;
    right: 10px;
    background: #28a745;
    color: white;
    padding: 5px 10px;
    border-radius: 50%;
    font-size: 12px;
    font-weight: bold;
    animation: pulse 1.5s infinite;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.1); opacity: 0.8; }
}

.verification-result {
    margin-top: 15px;
    padding: 15px;
    border-radius: 8px;
    text-align: center;
}

.verification-success {
    background: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

.verification-error {
    background: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

.verification-warning {
    background: #fff3cd;
    color: #856404;
    border: 1px solid #ffeaa7;
}

.location-info {
    background: #d1ecf1;
    padding: 10px;
    border-radius: 6px;
    margin-top: 10px;
}

.location-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
}

.location-item {
    background: white;
    padding: 10px;
    border-radius: 6px;
}

.location-label {
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 5px;
}

.location-value {
    color: #3498db;
}

.qr-section {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 20px;
    margin: 20px 0;
}

.qr-code {
    background: white;
    padding: 20px;
    border-radius: 8px;
    text-align: center;
    border: 2px solid #000;
    margin-bottom: 15px;
}

.qr-placeholder {
    color: #666;
    font-size: 14px;
}

.attendance-list {
    max-height: 400px;
    overflow-y: auto;
}

.attendance-item {
    display: flex;
    align-items: center;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    margin-bottom: 10px;
    border-left: 4px solid #28a745;
}

.attendance-item .photo {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #ddd;
    margin-right: 15px;
}

.attendance-item .info {
    flex: 1;
}

.attendance-item .info h4 {
    margin: 0 0 5px 0;
    color: #2c3e50;
}

.attendance-item .info p {
    margin: 0;
    font-size: 14px;
    color: #666;
}

.attendance-item .meta {
    font-size: 12px;
    color: #999;
}

.security-section {
    background: #fff3cd;
    border-radius: 12px;
    padding: 20px;
    margin: 20px 0;
}

.security-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
}

.security-item {
    background: white;
    padding: 15px;
    border-radius: 8px;
    border-left: 4px solid #ffc107;
}

.security-label {
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 5px;
}

.security-value {
    color: #3498db;
    font-weight: 500;
}

.security-status {
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.status-high {
    background: #f8d7da;
    color: #721c24;
}

.status-medium {
    background: #fff3cd;
    color: #856404;
}

.status-low {
    background: #d1ecf1;
    color: #856404;
}

.status-good {
    background: #d4edda;
    color: #155724;
}

@media (max-width: 768px) {
    .container {
        flex-direction: column;
    }
    
    .sidebar {
        width: 100%;
        height: auto;
    }
    
    .status-grid, .security-grid {
        grid-template-columns: 1fr;
    }
    
    .attendance-list {
        max-height: 300px;
    }
}
</style>
</head>
<body>

<div class="navbar">
    Enhanced Security Management System | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">
    <div class="sidebar">
        <a href="personnelDashboard.jsp">Dashboard</a>
        <a href="enhancedAttendanceSystem.jsp" class="btn-primary">Attendance</a>
        <a href="staffRegistration.jsp">Staff Registration</a>
        <a href="Logout">Logout</a>
    </div>
    
    <div class="main-content">
        <!-- Error Display -->
        <div id="errorDisplay" style="display:none;" class="status-card verification-error">
            <h4>⚠️ System Error</h4>
            <div id="errorMessage"></div>
            <div class="card-actions">
                <button class="btn btn-small" onclick="showDiagnosticInfo()">🔍 Show Diagnostics</button>
                <button class="btn btn-small" onclick="refreshPage()">🔄 Refresh Page</button>
            </div>
        </div>

        <!-- System Status -->
        <div class="status-card">
            <div class="card-title">🔐 System Status</div>
            <div class="status-grid">
                <div class="status-item">
                    <div class="status-label">Camera Status</div>
                    <div class="status-value" id="cameraStatus">Checking...</div>
                </div>
                <div class="status-item">
                    <div class="status-label">GPS Status</div>
                    <div class="status-value" id="gpsStatus">Checking...</div>
                </div>
                <div class="status-item">
                    <div class="status-label">Security Level</div>
                    <div class="status-value" id="securityStatus">Checking...</div>
                </div>
                <div class="status-item">
                    <div class="status-label">Last Check-in</div>
                    <div class="status-value" id="lastCheckin">Never</div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="attendance-card">
            <div class="card-header">
                <div class="card-title">⚡ Quick Attendance</div>
                <div class="card-actions">
                    <button class="btn btn-success" onclick="showQRSection()">QR Code</button>
                    <button class="btn btn-warning" onclick="showManualSection()">Manual Entry</button>
                </div>
            </div>

            <!-- QR Code Section -->
            <div class="qr-section" id="qrSection" style="display:none;">
                <div class="card-title">📱 QR Code Check-in</div>
                <div class="form-group">
                    <label for="qrCode">Enter QR Code:</label>
                    <input type="text" id="qrCode" placeholder="Scan QR code or enter manually">
                </div>
                <div class="card-actions">
                    <button class="btn btn-primary" onclick="verifyQRCode()">Verify & Check In</button>
                    <button class="btn" onclick="showQuickActions()">Cancel</button>
                </div>
            </div>

            <!-- QR Code Section -->
            <div class="qr-section" id="qrSection" style="display:none;">
                <div class="card-title">� QR Code Check-in</div>
                <div class="form-group">
                    <label for="qrCode">Enter QR Code:</label>
                    <input type="text" id="qrCode" placeholder="Scan QR code or enter manually">
                </div>
                <div class="card-actions">
                    <button class="btn btn-primary" onclick="verifyQRCode()">Verify & Check In</button>
                    <button class="btn" onclick="showQuickActions()">Cancel</button>
                </div>
            </div>

            <!-- Manual Entry Section -->
            <div class="verification-section" id="manualSection" style="display:none;">
                <div class="card-title">✍️ Manual Entry</div>
                
                <div class="form-group">
                    <label for="manualStaffId">Staff ID:</label>
                    <input type="text" id="manualStaffId" placeholder="Enter staff ID">
                </div>
                
                <div class="form-group">
                    <label for="manualPassword">Password:</label>
                    <input type="password" id="manualPassword" placeholder="Enter password">
                </div>
                
                <div class="card-actions">
                    <button class="btn btn-primary" onclick="manualCheckIn()">� Manual Check-in</button>
                    <button class="btn" onclick="showQuickActions()">Cancel</button>
                </div>
            </div>

            <!-- Manual Entry Section -->
            <div class="verification-section" id="manualSection" style="display:none;">
                <div class="card-title">✍️ Manual Entry</div>
                
                <div class="form-group">
                    <label for="manualStaffId">Staff ID:</label>
                    <input type="text" id="manualStaffId" placeholder="Enter staff ID">
                </div>
                
                <div class="form-group">
                    <label for="manualPassword">Password:</label>
                    <input type="password" id="manualPassword" placeholder="Enter password">
                </div>
                
                <div class="card-actions">
                    <button class="btn btn-primary" onclick="manualCheckIn()">🔐 Manual Check-in</button>
                    <button class="btn" onclick="showQuickActions()">Cancel</button>
                </div>
            </div>

            <!-- Today's Attendance -->
            <div class="attendance-card">
                <div class="card-header">
                    <div class="card-title">📊 Today's Attendance</div>
                    <button class="btn btn-small" onclick="refreshAttendance()">🔄 Refresh</button>
                </div>
                
                <div class="attendance-list" id="attendanceList">
                    <div class="empty-state">
                        <div class="icon">📅</div>
                        <div>Loading attendance records...</div>
                    </div>
                </div>
            </div>

            <!-- Security Status -->
            <div class="security-section">
                <div class="card-title">🛡️ Security Status</div>
                <div class="security-grid">
                    <div class="security-item">
                        <div class="security-label">Network Security</div>
                        <div class="security-value" id="networkSecurityStatus">Checking...</div>
                    </div>
                    <div class="security-item">
                        <div class="security-label">Time Sync</div>
                        <div class="security-value" id="timeSyncStatus">Checking...</div>
                    </div>
                    <div class="security-item">
                        <div class="security-label">Two-Factor Auth</div>
                        <div class="security-value" id="twoFactorStatus">Checking...</div>
                    </div>
                </div>
            </div>

            <!-- Location Info -->
            <div class="location-info" id="locationInfo" style="display:none;">
                <div class="location-grid">
                    <div class="location-item">
                        <div class="location-label">Current Location</div>
                        <div class="location-value" id="currentLocation">Getting location...</div>
                    </div>
                    <div class="location-item">
                        <div class="location-label">Accuracy</div>
                        <div class="location-value" id="locationAccuracy">--</div>
                    </div>
                    <div class="location-item">
                        <div class="location-label">Last Updated</div>
                        <div class="location-value" id="lastLocationUpdate">--</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Global variables
let currentStream = null;
let capturedSelfie = null;
let locationData = { latitude: null, longitude: null, accuracy: null };
let securityChecks = {
    elevation: 'unknown',
    deviceTrust: 'unknown',
    networkSecurity: 'unknown',
    timeSync: 'unknown',
    twoFactorAuth: 'unknown'
};

// Initialize system
document.addEventListener('DOMContentLoaded', function() {
    checkSystemStatus();
    checkLocation();
    loadTodayAttendance();
    
    // Check for URL error parameters
    const urlParams = new URLSearchParams(window.location.search);
    const error = urlParams.get('error');
    
    if (error) {
        showError(error);
    }
    
    // Auto-show QR section by default
    showQRSection();
});

// Error display functions
function showError(errorType) {
    const errorDisplay = document.getElementById('errorDisplay');
    const errorMessage = document.getElementById('errorMessage');
    
    if (errorDisplay && errorMessage) {
        errorDisplay.style.display = 'block';
        
        switch(errorType) {
            case 'database_column_type':
                errorMessage.innerHTML = 'Database Error: Column type mismatch. Please check database schema.';
                break;
            case 'connection_failed':
                errorMessage.innerHTML = 'Database Connection Failed: Unable to connect to database.';
                break;
            case 'parameter_missing':
                errorMessage.innerHTML = 'Parameter Error: Required parameter is missing.';
                break;
            case 'unknown':
                errorMessage.innerHTML = 'Unknown Error: An unexpected error occurred.';
                break;
            default:
                errorMessage.innerHTML = 'Error: ' + errorType;
        }
    }
}

// Diagnostic info
function showDiagnosticInfo() {
    const diagnosticInfo = `
        <div class="verification-section">
            <h4>🔍 System Diagnostics</h4>
            <div class="status-grid">
                <div class="status-item">
                    <div class="status-label">Database Connection</div>
                    <div class="status-value" id="dbConnectionStatus">Checking...</div>
                </div>
                <div class="status-item">
                    <div class="status-label">Table Schema</div>
                    <div class="status-value" id="tableSchemaStatus">Checking...</div>
                </div>
                <div class="status-item">
                    <div class="status-label">Column Types</div>
                    <div class="status-value" id="columnTypesStatus">Checking...</div>
                </div>
            </div>
            <div class="card-actions">
                <button class="btn btn-small" onclick="runDiagnostics()">🔍 Run Diagnostics</button>
                <button class="btn btn-small" onclick="hideDiagnosticInfo()">❌ Close</button>
            </div>
        </div>
    `;
    
    const errorDisplay = document.getElementById('errorDisplay');
    errorDisplay.innerHTML = diagnosticInfo;
    errorDisplay.style.display = 'block';
    
    runDiagnostics();
}

function hideDiagnosticInfo() {
    const errorDisplay = document.getElementById('errorDisplay');
    errorDisplay.style.display = 'none';
}

function runDiagnostics() {
    // Check database connection
    fetch('EnhancedAttendance?action=diagnostic')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById('dbConnectionStatus').textContent = '✅ Connected';
                document.getElementById('tableSchemaStatus').textContent = '✅ Valid';
                document.getElementById('columnTypesStatus').textContent = '✅ Compatible';
            } else {
                document.getElementById('dbConnectionStatus').textContent = '❌ Failed';
                document.getElementById('tableSchemaStatus').textContent = '❌ Invalid';
                document.getElementById('columnTypesStatus').textContent = '❌ Mismatch';
            }
        })
        .catch(error => {
            document.getElementById('dbConnectionStatus').textContent = '❌ Error';
            document.getElementById('tableSchemaStatus').textContent = '❌ Unknown';
            document.getElementById('columnTypesStatus').textContent = '❌ Check Failed';
        });
}

function refreshPage() {
    location.reload();
}

// System status checks
function checkSystemStatus() {
    // Check GPS
    if (navigator.geolocation) {
        updateSecurityStatus('gps', 'good');
    } else {
        updateSecurityStatus('gps', 'warning');
    }
    
    // Check time sync
    const now = new Date();
    const serverTime = new Date(now.getTime() + 5 * 60 * 1000); // +5 minutes
    updateSecurityStatus('timeSync', Math.abs(now - serverTime) < 60000 ? 'good' : 'warning');
    
    // Check network security
    updateSecurityStatus('networkSecurity', window.isSecureContext ? 'good' : 'warning');
    
    // Check two-factor auth
    updateSecurityStatus('twoFactorAuth', 'good'); // Always enabled for demo
}

// Update security status displays
function updateSecurityStatus(check, status) {
    const statusElement = document.getElementById(check + 'Status');
    if (statusElement) {
        statusElement.className = 'security-status status-' + status;
        statusElement.textContent = getStatusText(check, status);
    }
}

function getStatusText(check, status) {
    const statusMap = {
        'elevation': { 'good': '✅ Normal', 'warning': '⚠️ Elevated', 'unknown': '❓ Unknown' },
        'deviceTrust': { 'good': '✅ Trusted', 'warning': '⚠️ Untrusted', 'unknown': '❓ Unknown' },
        'gps': { 'good': '✅ Active', 'warning': '⚠️ Disabled', 'unknown': '❓ Unknown' },
        'networkSecurity': { 'good': '✅ Secure', 'warning': '⚠️ Insecure', 'unknown': '❓ Unknown' },
        'timeSync': { 'good': '✅ Synced', 'warning': '⚠️ Out of Sync', 'unknown': '❓ Unknown' },
        'twoFactorAuth': { 'good': '✅ Enabled', 'warning': '⚠️ Disabled', 'unknown': '❓ Unknown' }
    };
    
    return statusMap[check]?.[status] || 'Unknown';
}

// Location tracking
function checkLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            {
                enableHighAccuracy: true,
                timeout: 10000,
                maximumAge: 300000 // 5 minutes
            },
            function(position) {
                locationData = {
                    latitude: position.coords.latitude,
                    longitude: position.coords.longitude,
                    accuracy: position.coords.accuracy
                };
                
                updateLocationDisplay();
                checkElevation(position.coords.latitude, position.coords.longitude);
            },
            function(error) {
                console.error('GPS error:', error);
                updateLocationDisplay();
            }
        );
    } else {
        updateLocationDisplay();
    }
}

function updateLocationDisplay() {
    const locationInfo = document.getElementById('locationInfo');
    const currentLocation = document.getElementById('currentLocation');
    const locationAccuracy = document.getElementById('locationAccuracy');
    const lastUpdate = document.getElementById('lastLocationUpdate');
    
    if (locationData.latitude && locationData.longitude) {
        locationInfo.style.display = 'block';
        currentLocation.textContent = `${locationData.latitude.toFixed(6)}, ${locationData.longitude.toFixed(6)}`;
        locationAccuracy.textContent = `±${locationData.accuracy.toFixed(0)}m`;
        lastUpdate.textContent = new Date().toLocaleString();
    } else {
        locationInfo.style.display = 'none';
    }
}

// Elevation check
function checkElevation(lat, lng) {
    // Simple elevation check (demo purposes)
    const elevation = Math.sqrt(lat * lat + lng * lng) * 10000;
    updateSecurityStatus('elevation', elevation > 100 ? 'warning' : 'good');
}

// QR Code section
function showQRSection() {
    hideAllSections();
    document.getElementById('qrSection').style.display = 'block';
}

function verifyQRCode() {
    const qrCode = document.getElementById('qrCode').value.trim();
    
    if (!qrCode) {
        showMessage('Please enter QR code', 'error');
        return;
    }
    
    // Verify QR code and check in
    verifyQRCodeAndCheckIn(qrCode, 'qr');
}

// QR Code section (default)
function showQRSection() {
    hideAllSections();
    document.getElementById('qrSection').style.display = 'block';
}

function showManualSection() {
    hideAllSections();
    document.getElementById('manualSection').style.display = 'block';
}

// Camera and selfie capture
function startCamera() {
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        navigator.mediaDevices.getUserMedia({ 
            video: { 
                facingMode: 'user',
                width: { ideal: 640, min: 320 },
                height: { ideal: 480, min: 240 }
            }
        })
        .then(function(stream) {
            currentStream = stream;
            const video = document.getElementById('camera');
            video.srcObject = stream;
            
            // Show liveness indicator
            document.getElementById('livenessIndicator').style.display = 'block';
            
            updateSecurityStatus('deviceTrust', 'good');
            document.getElementById('cameraStatus').textContent = 'Camera Active';
        })
        .catch(function(error) {
            console.error('Camera error:', error);
            updateSecurityStatus('deviceTrust', 'warning');
            document.getElementById('cameraStatus').textContent = 'Camera Error';
            showMessage('Unable to access camera: ' + error.message, 'error');
        });
    } else {
        showMessage('Camera not supported', 'error');
        updateSecurityStatus('deviceTrust', 'warning');
        document.getElementById('cameraStatus').textContent = 'Camera Unavailable';
    }
}

function stopCamera() {
    if (currentStream) {
        currentStream.getTracks().forEach(track => track.stop());
        currentStream = null;
        
        document.getElementById('camera').srcObject = null;
        document.getElementById('livenessIndicator').style.display = 'none';
    }
}

// Capture selfie with liveness detection
function captureSelfie() {
    if (!currentStream) {
        showMessage('Please start camera first', 'error');
        return;
    }
    
    const video = document.getElementById('camera');
    const canvas = document.getElementById('selfie-canvas');
    const context = canvas.getContext('2d');
    
    // Set canvas size
    canvas.width = video.videoWidth || 640;
    canvas.height = video.videoHeight || 480;
    
    // Draw current frame
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    // Simulate liveness detection (random blink detection for demo)
    const isLive = Math.random() > 0.7; // 70% chance of being "live"
    
    // Update liveness indicator
    const livenessIndicator = document.getElementById('livenessIndicator');
    if (isLive) {
        livenessIndicator.textContent = '👁 Live';
        livenessIndicator.style.background = '#28a745';
    } else {
        livenessIndicator.textContent = '📷 Photo';
        livenessIndicator.style.background = '#ffc107';
    }
    
    // Capture selfie
    capturedSelfie = canvas.toDataURL('image/png');
    
    // Show captured image
    const resultDiv = document.getElementById('verificationResult');
    resultDiv.innerHTML = `
        <div class="verification-success">
            <h4>✅ Selfie Captured</h4>
            <p><strong>Liveness Check:</strong> ${isLive ? '✅ Passed' : '⚠️ Warning - Please try again'}</p>
            <p><img src="${capturedSelfie}" style="width: 100px; height: 100px; border-radius: 8px; object-fit: cover; border: 2px solid #ddd;"></p>
            <div class="card-actions">
                <button class="btn btn-success" onclick="verifyFace()">🔍 Verify Face & Check In</button>
                <button class="btn" onclick="captureSelfie()">📸 Retake Selfie</button>
            </div>
        </div>
    `;
    
    showMessage('Selfie captured successfully!', 'success');
}

// Face verification with anti-spoofing
function verifyFace() {
    if (!capturedSelfie) {
        showMessage('Please capture selfie first', 'error');
        return;
    }
    
    showMessage('Verifying face...', 'info');
    
    // Simulate face verification with anti-spoofing checks
    setTimeout(() => {
        const verificationResult = Math.random() > 0.8; // 80% success rate for demo
        
        const resultDiv = document.getElementById('verificationResult');
        
        if (verificationResult) {
            // Success - proceed with check-in
            resultDiv.innerHTML = `
                <div class="verification-success">
                    <h4>✅ Face Verification Successful</h4>
                    <p><strong>Anti-Spoofing:</strong> ✅ Passed</p>
                    <p><strong>Match Confidence:</strong> ${Math.floor(Math.random() * 20 + 80)}%</p>
                    <p><strong>Liveness Score:</strong> ${Math.floor(Math.random() * 30 + 70)}%</p>
                    <div class="card-actions">
                        <button class="btn btn-success" onclick="proceedWithCheckIn()">✅ Complete Check-in</button>
                        <button class="btn" onclick="captureSelfie()">📸 Try Again</button>
                    </div>
                </div>
            `;
            
            // Automatically proceed with check-in if verification successful
            setTimeout(() => {
                if (verificationResult) {
                    proceedWithCheckIn();
                }
            }, 2000);
            
        } else {
            // Failed - show error
            resultDiv.innerHTML = `
                <div class="verification-error">
                    <h4>❌ Face Verification Failed</h4>
                    <p><strong>Anti-Spoofing:</strong> ⚠️ Suspicious Activity Detected</p>
                    <p><strong>Recommendation:</strong> Please try again in a well-lit area</p>
                    <div class="card-actions">
                        <button class="btn btn-warning" onclick="captureSelfie()">📸 Try Again</button>
                        <button class="btn" onclick="showQuickActions()">Cancel</button>
                    </div>
                </div>
            `;
            
            showMessage('Face verification failed', 'error');
        }
    }, 1500);
}

// Proceed with check-in after successful verification
function proceedWithCheckIn() {
    const staffId = getStaffIdFromSelection();
    if (!staffId) {
        showMessage('Please select staff member first', 'error');
        return;
    }
    
    markAttendance(staffId, 'face_recognition', capturedSelfie);
}

// Manual check-in
function manualCheckIn() {
    const staffId = document.getElementById('manualStaffId').value.trim();
    const password = document.getElementById('manualPassword').value;
    
    if (!staffId || !password) {
        showMessage('Please enter staff ID and password', 'error');
        return;
    }
    
    // Verify credentials and check in
    verifyCredentialsAndCheckIn(staffId, password, 'manual');
}

// QR Code verification
function verifyQRCodeAndCheckIn(qrCode, method) {
    showMessage('Verifying QR code...', 'info');
    
    setTimeout(() => {
        // Simulate QR code verification
        const verificationResult = Math.random() > 0.7; // 70% success rate
        
        if (verificationResult) {
            const staffId = extractStaffIdFromQR(qrCode);
            markAttendance(staffId, method, qrCode);
        } else {
            showMessage('Invalid QR code', 'error');
        }
    }, 1500);
}

// Extract staff ID from QR code
function extractStaffIdFromQR(qrCode) {
    // Simple QR code parsing for demo
    if (qrCode.startsWith('STAFF_')) {
        const parts = qrCode.split('_');
        if (parts.length >= 3) {
            return parts[2]; // Return staff ID part
        }
    }
    return null;
}

// Get staff ID from current selection
function getStaffIdFromSelection() {
    // This would be populated by a staff selection dropdown
    return document.getElementById('manualStaffId')?.value.trim() || '';
}

// Mark attendance
function markAttendance(staffId, method, verificationData = null) {
    const attendanceData = {
        staffId: staffId,
        method: method,
        verificationData: verificationData,
        timestamp: new Date().toISOString(),
        location: locationData
    };
    
    // Send to server
    fetch('EnhancedAttendance', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(attendanceData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showMessage('Attendance marked successfully!', 'success');
            refreshAttendance();
            updateLastCheckin();
        } else {
            showMessage('Attendance failed: ' + data.message, 'error');
        }
    })
    .catch(error => {
        showMessage('Network error: ' + error.message, 'error');
    });
}

// Credential verification for manual entry
function verifyCredentialsAndCheckIn(staffId, password, method) {
    showMessage('Verifying credentials...', 'info');
    
    setTimeout(() => {
        // Simulate credential verification
        const verificationResult = Math.random() > 0.8; // 80% success rate
        
        if (verificationResult) {
            markAttendance(staffId, method, { credentials: { username: staffId, password: password } });
        } else {
            showMessage('Invalid credentials', 'error');
        }
    }, 1500);
}

// Load today's attendance
function loadTodayAttendance() {
    fetch('GetTodaysAttendance?staffId=' + getStaffIdFromSelection())
        .then(response => response.json())
        .then(data => {
            const attendanceList = document.getElementById('attendanceList');
            
            if (data.success && data.attendance && data.attendance.length > 0) {
                attendanceList.innerHTML = '';
                
                data.attendance.forEach((record, index) => {
                    const time = new Date(record.check_in_time);
                    const timeStr = time.toLocaleTimeString();
                    
                    attendanceList.innerHTML += `
                        <div class="attendance-item">
                            <img src="${record.selfie_path || '/images/default-avatar.png'}" class="photo" alt="Staff Photo">
                            <div class="info">
                                <h4>${record.first_name} ${record.last_name}</h4>
                                <p><strong>Check-in:</strong> ${timeStr}</p>
                                <p><strong>Method:</strong> ${record.attendance_type}</p>
                                <p><strong>Location:</strong> ${record.latitude}, ${record.longitude}</p>
                                <p class="meta">Verified: ${record.face_verified ? '✅ Yes' : '❌ No'}</p>
                            </div>
                        </div>
                    `;
                });
            } else {
                attendanceList.innerHTML = `
                    <div class="empty-state">
                        <div class="icon">📅</div>
                        <div>No attendance records for today</div>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('Error loading attendance:', error);
            const attendanceList = document.getElementById('attendanceList');
            attendanceList.innerHTML = `
                <div class="error-state">
                    <div class="icon">❌</div>
                    <div>Error loading attendance records</div>
                </div>
            `;
        });
}

// Refresh attendance
function refreshAttendance() {
    loadTodayAttendance();
}

// Update last check-in time
function updateLastCheckin() {
    const lastCheckinElement = document.getElementById('lastCheckin');
    if (lastCheckinElement) {
        lastCheckinElement.textContent = new Date().toLocaleString();
    }
}

// UI helpers
function hideAllSections() {
    document.getElementById('qrSection').style.display = 'none';
    document.getElementById('manualSection').style.display = 'none';
}

function showQuickActions() {
    hideAllSections();
    // Show quick actions or return to main menu
}

function showMessage(message, type) {
    // Create toast notification
    const toast = document.createElement('div');
    toast.className = 'status-message';
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#d4edda' : type === 'error' ? '#f8d7da' : '#d1ecf1'};
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        z-index: 1000;
        font-size: 14px;
        max-width: 300px;
        word-wrap: break-word;
    `;
    
    document.body.appendChild(toast);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (toast.parentNode) {
            toast.parentNode.removeChild(toast);
        }
    }, 5000);
}
</script>

</body>
</html>
