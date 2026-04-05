<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<!DOCTYPE html>
<html>
<head>
<title>Fingerprint Registration Test</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">
<style>
body {
    font-family: 'Poppins', sans-serif;
    margin:0;
    background:#f4f6f9;
}

.container {
    max-width:800px;
    margin:50px auto;
    background:white;
    padding:30px;
    border-radius:15px;
    box-shadow:0 4px 20px rgba(0,0,0,0.1);
}

.form-group {
    margin-bottom:20px;
}

label {
    display:block;
    margin-bottom:5px;
    font-weight:600;
    color:#2c3e50;
}

input {
    width:100%;
    padding:12px;
    border:1px solid #ddd;
    border-radius:8px;
    font-size:14px;
    box-sizing:border-box;
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

/* Fingerprint Scanner Styles */
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
</style>
</head>
<body>

<div class="container">
    <h1>🔐 Fingerprint Registration Test</h1>
    <p>This page allows testing fingerprint registration without login requirements.</p>
    
    <!-- Status Messages -->
    <div id="statusMessage" class="status-message"></div>
    
    <div class="fingerprint-section">
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
                <div class="status-icon">👆</div>
                <div class="status-text">Ready to register fingerprint</div>
                <div class="status-description">Enter Employee ID and click Register</div>
            </div>
            
            <div class="fingerprint-actions">
                <div style="margin-bottom: 15px;">
                    <label for="employeeId">Employee ID:</label>
                    <input type="text" id="employeeId" placeholder="e.g., EM01, EM04" required>
                </div>
                
                <button type="button" class="btn" onclick="registerFingerprint()">
                    Register Fingerprint
                </button>
                <button type="button" class="btn" onclick="testFingerprint()" style="display:none;" id="testFingerprintBtn">
                    Test Fingerprint
                </button>
            </div>
        </div>
    </div>
    
    <div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 10px;">
        <h3>🔗 Navigation</h3>
        <p><a href="staffRegistration.jsp" class="btn">📝 Full Staff Registration (with login)</a></p>
        <p><a href="clearStaffData.jsp" class="btn">🗑️ Clear Staff Data</a></p>
        <p><a href="index.jsp" class="btn">🏠 Login</a></p>
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

// Generate simulated fingerprint data
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
    
    // Use simulated fingerprint (current working method)
    useSimulatedFingerprint(employeeId, statusDiv, scannerDiv);
}

// Use simulated fingerprint (current working method)
function useSimulatedFingerprint(employeeId, statusDiv, scannerDiv) {
    scannerDiv.classList.add('scanning');
    
    statusDiv.innerHTML = `
        <div class="status-icon scanning">Scanning</div>
        <div class="status-text">Scanning fingerprint...</div>
        <div class="status-description">Please place your finger on scanner</div>
    `;
    
    // Generate simulated fingerprint data
    setTimeout(() => {
        const fingerprintData = generateSimulatedFingerprint(employeeId);
        
        // Send to server
        fetch('FingerprintRegistration', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'employeeId=' + encodeURIComponent(employeeId) + '&fingerprintData=' + encodeURIComponent(fingerprintData) + '&type=simulated'
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('HTTP error! Status: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                // Remove scanning animation and add success
                scannerDiv.classList.remove('scanning');
                scannerDiv.classList.add('success');
                
                statusDiv.innerHTML = `
                    <div class="status-icon success">✅</div>
                    <div class="status-text">Fingerprint registered successfully!</div>
                    <div class="status-description">Biometric authentication is now enabled (simulated)</div>
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
                    <div class="status-icon error">❌</div>
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
            
            statusDiv.innerHTML = `
                <div class="status-icon error">❌</div>
                <div class="status-text">Network error</div>
                <div class="status-description">${error.message}</div>
            `;
            showStatus('Network error: ' + error.message, 'error');
            
            // Remove error class after 3 seconds
            setTimeout(() => {
                scannerDiv.classList.remove('error');
            }, 3000);
        });
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
        const fingerprintData = generateSimulatedFingerprint(employeeId);
        
        // Send to verification server
        fetch('FingerprintVerification', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'employeeId=' + encodeURIComponent(employeeId) + '&fingerprintData=' + encodeURIComponent(fingerprintData) + '&type=simulated'
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('HTTP error! Status: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                // Remove scanning animation and add success
                scannerDiv.classList.remove('scanning');
                scannerDiv.classList.add('success');
                
                statusDiv.innerHTML = `
                    <div class="status-icon success">✅</div>
                    <div class="status-text">Fingerprint verified!</div>
                    <div class="status-description">Match found for ${data.employeeName} (simulated)</div>
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
                    <div class="status-icon error">❌</div>
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
            
            statusDiv.innerHTML = `
                <div class="status-icon error">❌</div>
                <div class="status-text">Network error</div>
                <div class="status-description">${error.message}</div>
            `;
            showStatus('Network error: ' + error.message, 'error');
            
            // Remove error class after 3 seconds
            setTimeout(() => {
                scannerDiv.classList.remove('error');
            }, 3000);
        });
    }, 2000);
}
</script>

</body>
</html>
