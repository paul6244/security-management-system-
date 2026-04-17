<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<!DOCTYPE html>
<html>
<head>
<title>QR Code Attendance Scanner</title>
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

.scanner-container {
    max-width:600px;
    margin:0 auto;
    background:white;
    border-radius:20px;
    box-shadow:0 20px 40px rgba(0,0,0,0.2);
    overflow:hidden;
}

.scanner-header {
    background:#2c3e50;
    color:white;
    padding:30px;
    text-align:center;
}

.scanner-header h1 {
    margin:0;
    font-size:28px;
    font-weight:600;
}

.scanner-content {
    padding:30px;
}

.qr-scanner {
    background:#f8f9fa;
    border:2px dashed #dee2e6;
    border-radius:15px;
    padding:40px;
    text-align:center;
    margin:20px 0;
    transition:all 0.3s ease;
}

.qr-scanner.scanning {
    border-color:#007bff;
    background:#e7f3ff;
}

.qr-scanner.success {
    border-color:#28a745;
    background:#d4edda;
}

.qr-scanner.error {
    border-color:#dc3545;
    background:#f8d7da;
}

.scanner-icon {
    font-size:64px;
    margin-bottom:20px;
    animation:scan 2s infinite;
}

@keyframes scan {
    0%, 100% { transform:scale(1); }
    50% { transform:scale(1.1); }
}

.scanner-text {
    font-size:18px;
    font-weight:600;
    color:#2c3e50;
    margin-bottom:10px;
}

.scanner-status {
    font-size:14px;
    color:#6c757d;
    margin-bottom:20px;
}

.camera-button {
    background:#007bff;
    color:white;
    border:none;
    padding:15px 30px;
    border-radius:10px;
    font-size:16px;
    cursor:pointer;
    margin:10px 5px;
    transition:all 0.3s ease;
}

.camera-button:hover {
    background:#0056b3;
    transform:translateY(-2px);
}

.camera-button:disabled {
    background:#6c757d;
    cursor:not-allowed;
}

.manual-input {
    margin:20px 0;
}

.manual-input input {
    width:100%;
    padding:15px;
    border:2px solid #dee2e6;
    border-radius:10px;
    font-size:16px;
    margin-bottom:10px;
    box-sizing:border-box;
}

.submit-button {
    background:#28a745;
    color:white;
    border:none;
    padding:15px 30px;
    border-radius:10px;
    font-size:16px;
    cursor:pointer;
    width:100%;
    transition:all 0.3s ease;
}

.submit-button:hover {
    background:#218838;
    transform:translateY(-2px);
}

.result-display {
    background:#e9ecef;
    border-radius:10px;
    padding:20px;
    margin:20px 0;
    display:none;
}

.result-display.show {
    display:block;
}

.result-header {
    font-size:18px;
    font-weight:600;
    color:#2c3e50;
    margin-bottom:10px;
}

.result-info {
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:15px;
    margin-bottom:15px;
}

.info-item {
    background:white;
    padding:15px;
    border-radius:8px;
    border:1px solid #dee2e6;
}

.info-label {
    font-size:12px;
    color:#6c757d;
    margin-bottom:5px;
}

.info-value {
    font-size:16px;
    font-weight:600;
    color:#2c3e50;
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

.navigation {
    text-align:center;
    margin:30px 0;
}

.navigation a {
    display:inline-block;
    margin:10px;
    padding:10px 20px;
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

@media (max-width:768px) {
    .scanner-container {
        margin:10px;
        border-radius:15px;
    }
    
    .scanner-header {
        padding:20px;
    }
    
    .scanner-header h1 {
        font-size:24px;
    }
    
    .scanner-content {
        padding:20px;
    }
    
    .qr-scanner {
        padding:30px;
    }
    
    .result-info {
        grid-template-columns:1fr;
        gap:10px;
    }
}
</style>
</head>
<body>

<div class="scanner-container">
    <div class="scanner-header">
        <h1>📱 QR Code Attendance Scanner</h1>
        <p style="margin:10px 0 0; font-size:14px; opacity:0.9;">
            Scan QR code with your phone camera or enter manually
        </p>
    </div>
    
    <div class="scanner-content">
        <!-- Status Messages -->
        <div id="statusMessage" class="status-message"></div>
        
        <!-- QR Scanner -->
        <div class="qr-scanner" id="qrScanner">
            <div class="scanner-icon">📷</div>
            <div class="scanner-text">Tap to scan QR code</div>
            <div class="scanner-status" id="scannerStatus">Position QR code within frame</div>
        </div>
        
        <!-- Camera Buttons -->
        <div style="text-align:center; margin:20px 0;">
            <button class="camera-button" onclick="startCamera()" id="startCameraBtn">
                📷 Start Camera
            </button>
            <button class="camera-button" onclick="stopCamera()" id="stopCameraBtn" disabled>
                🛑 Stop Camera
            </button>
        </div>
        
        <!-- Manual QR Input -->
        <div class="manual-input">
            <label style="display:block; margin-bottom:10px; font-weight:600; color:#2c3e50;">
                Or enter QR code manually:
            </label>
            <input type="text" id="manualQRInput" placeholder="Enter QR code value" 
                   style="width:100%; padding:15px; border:2px solid #dee2e6; border-radius:10px; font-size:16px; box-sizing:border-box;">
        </div>
        
        <!-- Submit Button -->
        <button class="submit-button" onclick="submitAttendance()">
            ✅ Mark Attendance
        </button>
        
        <!-- Result Display -->
        <div class="result-display" id="resultDisplay">
            <div class="result-header">✅ Attendance Marked Successfully</div>
            <div class="result-info">
                <div class="info-item">
                    <div class="info-label">Staff Name</div>
                    <div class="info-value" id="staffName">-</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Employee ID</div>
                    <div class="info-value" id="employeeId">-</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Department</div>
                    <div class="info-value" id="department">-</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Time</div>
                    <div class="info-value" id="attendanceTime">-</div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Navigation -->
    <div class="navigation">
        <a href="personnelDashboard.jsp">🏠 Dashboard</a>
        <a href="index.jsp">🔐 Logout</a>
    </div>
</div>

<!-- Hidden video element for camera -->
<video id="video" style="display:none;"></video>
<canvas id="canvas" style="display:none;"></canvas>

<script>
let scanning = false;
let stream = null;

function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.className = 'status-message status-' + type;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 5000);
}

function updateScannerStatus(status, isScanning = false) {
    const scannerDiv = document.getElementById('qrScanner');
    const statusText = document.getElementById('scannerStatus');
    
    scannerDiv.className = 'qr-scanner' + (isScanning ? ' scanning' : '');
    statusText.textContent = status;
}

async function startCamera() {
    try {
        updateScannerStatus('Requesting camera access...', true);
        
        const video = document.getElementById('video');
        const canvas = document.getElementById('canvas');
        const context = canvas.getContext('2d');
        
        stream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: 'environment' }
        });
        
        video.srcObject = stream;
        video.style.display = 'block';
        
        document.getElementById('startCameraBtn').disabled = true;
        document.getElementById('stopCameraBtn').disabled = false;
        
        updateScannerStatus('Camera active - Point at QR code', true);
        
        // Start QR code scanning simulation
        scanning = true;
        scanForQRCode();
        
    } catch (error) {
        console.error('Camera error:', error);
        showStatus('Camera access denied: ' + error.message, 'error');
        updateScannerStatus('Camera unavailable', false);
    }
}

function stopCamera() {
    if (stream) {
        stream.getTracks().forEach(track => track.stop());
        stream = null;
    }
    
    document.getElementById('video').style.display = 'none';
    document.getElementById('startCameraBtn').disabled = false;
    document.getElementById('stopCameraBtn').disabled = true;
    
    scanning = false;
    updateScannerStatus('Camera stopped', false);
}

function scanForQRCode() {
    if (!scanning) return;
    
    // Simulate QR code detection
    setTimeout(() => {
        if (scanning) {
            // Random chance to "find" a QR code for demo
            if (Math.random() > 0.7) {
                const qrData = generateSimulatedQRData();
                processQRCode(qrData);
            } else {
                updateScannerStatus('Scanning... Keep QR code in frame', true);
                scanForQRCode(); // Continue scanning
            }
        }
    }, 2000);
}

function generateSimulatedQRData() {
    const sampleQRCodes = [
        'STAFF_1_EM01_cGF1bGdsd2U',
        'STAFF_2_EM02_sm9ob2Fpc3Rvcg',
        'STAFF_3_EM03_QWxhcmFuZGxlc',
        'STAFF_4_EM04='
    ];
    
    return sampleQRCodes[Math.floor(Math.random() * sampleQRCodes.length)];
}

function processQRCode(qrData) {
    stopCamera();
    
    updateScannerStatus('QR Code detected!', false);
    document.getElementById('qrScanner').className = 'qr-scanner success';
    
    // Parse QR code data
    const parts = qrData.split('_');
    if (parts.length >= 3) {
        const staffId = parts[2];
        validateAndMarkAttendance(staffId, qrData);
    } else {
        showStatus('Invalid QR code format', 'error');
        document.getElementById('qrScanner').className = 'qr-scanner error';
    }
}

async function validateAndMarkAttendance(staffId, qrData) {
    try {
        showStatus('Validating QR code...', 'info');
        
        const response = await fetch('QRCodeAttendance', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'staffId=' + encodeURIComponent(staffId) + '&qrData=' + encodeURIComponent(qrData)
        });
        
        const result = await response.json();
        
        if (result.success) {
            displayAttendanceResult(result.staff);
            showStatus('Attendance marked successfully!', 'success');
        } else {
            showStatus('Error: ' + result.message, 'error');
            document.getElementById('qrScanner').className = 'qr-scanner error';
        }
        
    } catch (error) {
        console.error('Validation error:', error);
        showStatus('Network error: ' + error.message, 'error');
    }
}

function displayAttendanceResult(staff) {
    const resultDiv = document.getElementById('resultDisplay');
    
    document.getElementById('staffName').textContent = staff.first_name + ' ' + staff.last_name;
    document.getElementById('employeeId').textContent = staff.employee_id;
    document.getElementById('department').textContent = staff.department;
    document.getElementById('attendanceTime').textContent = new Date().toLocaleString();
    
    resultDiv.classList.add('show');
}

// Manual QR code submission
function submitAttendance() {
    const manualQR = document.getElementById('manualQRInput').value.trim();
    
    if (!manualQR) {
        showStatus('Please enter QR code or scan with camera', 'error');
        return;
    }
    
    processQRCode(manualQR);
}

// Auto-start camera if supported
document.addEventListener('DOMContentLoaded', function() {
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        updateScannerStatus('Camera ready - Click start to begin', false);
    } else {
        updateScannerStatus('Camera not supported - Use manual entry', false);
    }
});
</script>

</body>
</html>
