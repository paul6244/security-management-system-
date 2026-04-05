<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Real Fingerprint Scanner Setup Guide</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            background: rgba(255,255,255,0.1); 
            padding: 30px; 
            border-radius: 15px; 
        }
        .section { 
            margin: 20px 0; 
            padding: 20px; 
            background: rgba(255,255,255,0.05); 
            border-radius: 10px; 
        }
        .code { 
            background: #2c3e50; 
            padding: 15px; 
            border-radius: 5px; 
            font-family: monospace; 
            margin: 10px 0;
        }
        .step { 
            background: #27ae60; 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 5px;
        }
        .warning { 
            background: #e74c3c; 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 5px;
        }
        .note {
            background: #f39c12; 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 5px;
        }
        a { color: #667eea; text-decoration: none; }
        a:hover { text-decoration: underline; }
        h1, h2 { color: #667eea; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Real Fingerprint Scanner Setup Guide</h1>
        
        <div class="section">
            <h2>📋 Current System Status</h2>
            <div class="step">
                <strong>✅ Animated Scanner:</strong> Visual fingerprint scanner created<br>
                <strong>✅ Database Column:</strong> fingerprint_data field ready<br>
                <strong>✅ Registration:</strong> Simulated fingerprint data working<br>
                <strong>🔄 Real Scanner:</strong> Ready for laptop integration
            </div>
        </div>

        <div class="section">
            <h2>🎯 How to Use Your Laptop's Fingerprint Scanner</h2>
            
            <div class="step">
                <h3>Step 1: Check if Your Laptop Has Fingerprint Scanner</h3>
                <p>Most modern laptops have built-in fingerprint scanners. Check for:</p>
                <ul>
                    <li>Fingerprint sensor on keyboard deck or palm rest</li>
                    <li>Windows Hello compatible (Windows 10/11)</li>
                    <li>Touch ID compatible (MacBooks)</li>
                    <li>Biometric device in Device Manager</li>
                </ul>
            </div>

            <div class="step">
                <h3>Step 2: Enable Fingerprint in System</h3>
                <p><strong>Windows:</strong> Settings > Accounts > Sign-in options > Fingerprint</p>
                <p><strong>Mac:</strong> System Preferences > Touch ID</p>
                <p>Register your fingerprint with your operating system first.</p>
            </div>

            <div class="step">
                <h3>Step 3: Test Current System</h3>
                <p>Go to <a href="staffRegistration.jsp">Staff Registration</a> and try fingerprint registration with current simulation.</p>
                <p>The system generates simulated fingerprint data that works with the database.</p>
            </div>
        </div>

        <div class="section">
            <h2>🔧 Integration Options</h2>
            
            <div class="note">
                <h3>Option A: Keep Current Simulation (Recommended)</h3>
                <p><strong>Pros:</strong> Works immediately, no hardware needed</p>
                <p><strong>How:</strong> System generates consistent fingerprint data for each employee ID</p>
                <p><strong>Use:</strong> Enter Employee ID, click "Register Fingerprint"</p>
            </div>

            <div class="warning">
                <h3>Option B: Real Fingerprint Integration (Advanced)</h3>
                <p><strong>Requirements:</strong> WebAuthn API, HTTPS, modern browser</p>
                <p><strong>Limitations:</strong> Requires browser support, HTTPS certificate</p>
                <p><strong>Status:</strong> Not implemented yet (requires development)</p>
            </div>
        </div>

        <div class="section">
            <h2>💻 Current Implementation Details</h2>
            
            <div class="code">
                <strong>Registration Process:</strong><br>
                1. User enters Employee ID (EM01, EM04)<br>
                2. Clicks "Register Fingerprint"<br>
                3. System generates: FP_EM01_[unique_data]<br>
                4. Stores in database fingerprint_data column<br>
                5. Animated scanner shows visual feedback<br>
                <br>
                <strong>Verification Process:</strong><br>
                1. User enters Employee ID<br>
                2. Clicks "Test Fingerprint"<br>
                3. System generates same fingerprint data<br>
                4. Compares with stored data<br>
                5. Shows success/failure
            </div>
        </div>

        <div class="section">
            <h2>🚀 Next Steps</h2>
            <div class="step">
                <p><strong>1. Fix Database:</strong> <a href="fixFingerprintDatabase.jsp">Run Database Fix</a></p>
                <p><strong>2. Test Registration:</strong> <a href="staffRegistration.jsp">Register Fingerprints</a></p>
                <p><strong>3. Test Verification:</strong> Use "Test Fingerprint" button</p>
                <p><strong>4. Use Attendance:</strong> <a href="fingerprintAttendance.jsp">Fingerprint Attendance</a></p>
            </div>
        </div>

        <div class="section">
            <h2>📞 Troubleshooting</h2>
            <div class="warning">
                <p><strong>If registration fails:</strong></p>
                <ul>
                    <li>Run <a href="fixFingerprintDatabase.jsp">Database Fix</a></li>
                    <li>Check browser console (F12) for errors</li>
                    <li>Verify Employee ID exists (EM01, EM04)</li>
                    <li>Ensure database connection is working</li>
                </ul>
            </div>
        </div>

        <div class="section">
            <p><strong>🏠 Return to:</strong></p>
            <p><a href="staffRegistration.jsp">Staff Registration</a> | <a href="index.jsp">Login</a></p>
        </div>
    </div>
</body>
</html>
