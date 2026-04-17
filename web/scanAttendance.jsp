<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR Code Scanner - Attendance</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .header {
            background: rgba(255, 255, 255, 0.95);
            padding: 1rem 2rem;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .header h1 {
            color: #333;
            font-size: 1.8rem;
            font-weight: 600;
        }

        .container {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem;
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            max-width: 600px;
            width: 100%;
            text-align: center;
        }

        .card h2 {
            color: #333;
            margin-bottom: 1.5rem;
            font-size: 1.5rem;
        }

        .scanner-container {
            position: relative;
            width: 100%;
            max-width: 400px;
            height: 400px;
            margin: 0 auto 2rem;
            background: #000;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        #video {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .scanner-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
        }

        .scanner-frame {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 200px;
            height: 200px;
            border: 3px solid #00ff00;
            border-radius: 10px;
            box-shadow: 0 0 0 1000px rgba(0, 0, 0, 0.5);
        }

        .scanner-corners {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        .corner {
            position: absolute;
            width: 20px;
            height: 20px;
            border: 3px solid #00ff00;
        }

        .corner.top-left {
            top: -3px;
            left: -3px;
            border-right: none;
            border-bottom: none;
        }

        .corner.top-right {
            top: -3px;
            right: -3px;
            border-left: none;
            border-bottom: none;
        }

        .corner.bottom-left {
            bottom: -3px;
            left: -3px;
            border-right: none;
            border-top: none;
        }

        .corner.bottom-right {
            bottom: -3px;
            right: -3px;
            border-left: none;
            border-top: none;
        }

        .scanner-line {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: linear-gradient(90deg, transparent, #00ff00, transparent);
            animation: scan 2s linear infinite;
        }

        @keyframes scan {
            0% { top: 0; }
            100% { top: 100%; }
        }

        .manual-input {
            margin: 2rem 0;
            padding: 1.5rem;
            background: #f8f9fa;
            border-radius: 12px;
            text-align: left;
        }

        .manual-input h3 {
            color: #333;
            margin-bottom: 1rem;
            font-size: 1.2rem;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #555;
            font-weight: 500;
        }

        .form-group input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }

        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 25px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            margin: 0.5rem;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
        }

        .btn-success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        }

        .actions {
            margin-top: 2rem;
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .status {
            margin: 1rem 0;
            padding: 1rem;
            border-radius: 8px;
            font-weight: 500;
        }

        .status-scanning {
            background: #e3f2fd;
            color: #1976d2;
            border: 1px solid #bbdefb;
        }

        .status-success {
            background: #e8f5e8;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }

        .status-error {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ffcdd2;
        }

        .loading {
            display: none;
            text-align: center;
            padding: 2rem;
        }

        .loading-spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 1rem;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .camera-permission {
            background: #fff3cd;
            color: #856404;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            border: 1px solid #fdeaa7;
        }

        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .card {
                padding: 1.5rem;
            }
            
            .scanner-container {
                height: 300px;
                max-width: 300px;
            }
            
            .scanner-frame {
                width: 150px;
                height: 150px;
            }
            
            .actions {
                flex-direction: column;
                align-items: center;
            }
            
            .btn {
                width: 100%;
                max-width: 200px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>QR Code Scanner - Attendance</h1>
    </div>

    <div class="container">
        <div class="card">
            <h2>Scan QR Code for Attendance</h2>
            
            <div id="status" class="status status-scanning">
                Ready to scan QR code...
            </div>

            <div class="camera-permission" id="cameraPermission" style="display: none;">
                Please allow camera access to scan QR codes.
            </div>

            <div class="scanner-container">
                <video id="video" autoplay playsinline></video>
                <div class="scanner-overlay">
                    <div class="scanner-frame">
                        <div class="scanner-corners">
                            <div class="corner top-left"></div>
                            <div class="corner top-right"></div>
                            <div class="corner bottom-left"></div>
                            <div class="corner bottom-right"></div>
                        </div>
                        <div class="scanner-line"></div>
                    </div>
                </div>
            </div>

            <div class="loading" id="loading">
                <div class="loading-spinner"></div>
                <p>Processing QR code...</p>
            </div>

            <div class="manual-input">
                <h3>Manual Entry (if QR code doesn't work)</h3>
                <form id="manualForm">
                    <div class="form-group">
                        <label for="manualClassId">Class ID:</label>
                        <input type="text" id="manualClassId" name="classId" placeholder="e.g., class1" required>
                    </div>
                    <div class="form-group">
                        <label for="manualDate">Date:</label>
                        <input type="date" id="manualDate" name="date" required>
                    </div>
                    <div class="form-group">
                        <label for="manualStudentId">Student ID:</label>
                        <input type="text" id="manualStudentId" name="studentId" placeholder="Enter your student ID" required>
                    </div>
                    <button type="submit" class="btn btn-success">Mark Attendance Manually</button>
                </form>
            </div>

            <div class="actions">
                <button class="btn" onclick="startScanner()">Start Scanner</button>
                <button class="btn btn-secondary" onclick="stopScanner()">Stop Scanner</button>
                <button class="btn" onclick="goToGenerator()">Generate QR Code</button>
            </div>
        </div>
    </div>

    <!-- Include jsQR library -->
    <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js"></script>
    
    <script>
        let video = null;
        let canvas = null;
        let scanning = false;
        let stream = null;

        // Set today's date as default for manual form
        document.getElementById('manualDate').valueAsDate = new Date();

        // Initialize canvas
        function initializeCanvas() {
            canvas = document.createElement('canvas');
            canvas.width = 400;
            canvas.height = 400;
        }

        // Start camera and scanner
        async function startScanner() {
            try {
                video = document.getElementById('video');
                
                // Request camera permission
                stream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: 'environment' }
                });
                
                video.srcObject = stream;
                video.play();
                
                scanning = true;
                document.getElementById('status').className = 'status status-scanning';
                document.getElementById('status').textContent = 'Scanning for QR codes...';
                document.getElementById('cameraPermission').style.display = 'none';
                
                // Start scanning loop
                requestAnimationFrame(scan);
                
            } catch (error) {
                console.error('Error accessing camera:', error);
                document.getElementById('cameraPermission').style.display = 'block';
                document.getElementById('status').className = 'status status-error';
                document.getElementById('status').textContent = 'Camera access denied. Please use manual entry.';
            }
        }

        // Stop scanner
        function stopScanner() {
            scanning = false;
            
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
                stream = null;
            }
            
            if (video) {
                video.srcObject = null;
            }
            
            document.getElementById('status').className = 'status status-scanning';
            document.getElementById('status').textContent = 'Scanner stopped';
        }

        // Scan for QR codes
        function scan() {
            if (!scanning) return;
            
            if (video && video.readyState === video.HAVE_ENOUGH_DATA) {
                const context = canvas.getContext('2d');
                context.drawImage(video, 0, 0, canvas.width, canvas.height);
                
                const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
                const code = jsQR(imageData.data, imageData.width, imageData.height, {
                    inversionAttempts: 'dontInvert',
                });
                
                if (code) {
                    handleQRCode(code.data);
                    return;
                }
            }
            
            requestAnimationFrame(scan);
        }

        // Handle scanned QR code
        function handleQRCode(qrData) {
            stopScanner();
            
            document.getElementById('loading').style.display = 'block';
            document.getElementById('status').className = 'status status-success';
            document.getElementById('status').textContent = 'QR Code detected! Processing...';
            
            try {
                // Parse QR code data (expected format: attendance.jsp?id=class1&date=2026-04-14)
                const url = new URL(qrData, window.location.origin);
                const params = new URLSearchParams(url.search);
                
                const classId = params.get('id');
                const date = params.get('date');
                
                if (classId && date) {
                    // Prompt for student ID
                    const studentId = prompt('QR Code scanned successfully! Please enter your Student ID:');
                    
                    if (studentId && studentId.trim()) {
                        // Submit attendance
                        submitAttendance(classId, date, studentId.trim());
                    } else {
                        document.getElementById('loading').style.display = 'none';
                        document.getElementById('status').className = 'status status-error';
                        document.getElementById('status').textContent = 'Student ID is required';
                        startScanner(); // Restart scanner
                    }
                } else {
                    document.getElementById('loading').style.display = 'none';
                    document.getElementById('status').className = 'status status-error';
                    document.getElementById('status').textContent = 'Invalid QR code format';
                    startScanner(); // Restart scanner
                }
                
            } catch (error) {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('status').className = 'status status-error';
                document.getElementById('status').textContent = 'Error parsing QR code';
                startScanner(); // Restart scanner
            }
        }

        // Submit attendance
        function submitAttendance(classId, date, studentId) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'MarkAttendance';
            
            const classIdInput = document.createElement('input');
            classIdInput.type = 'hidden';
            classIdInput.name = 'id';
            classIdInput.value = classId;
            
            const dateInput = document.createElement('input');
            dateInput.type = 'hidden';
            dateInput.name = 'date';
            dateInput.value = date;
            
            const studentIdInput = document.createElement('input');
            studentIdInput.type = 'hidden';
            studentIdInput.name = 'studentId';
            studentIdInput.value = studentId;
            
            form.appendChild(classIdInput);
            form.appendChild(dateInput);
            form.appendChild(studentIdInput);
            
            document.body.appendChild(form);
            form.submit();
        }

        // Manual form submission
        document.getElementById('manualForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const classId = document.getElementById('manualClassId').value;
            const date = document.getElementById('manualDate').value;
            const studentId = document.getElementById('manualStudentId').value;
            
            if (classId && date && studentId) {
                submitAttendance(classId, date, studentId);
            }
        });

        // Navigation functions
        function goToGenerator() {
            window.location.href = 'viewAttendance.jsp';
        }

        // Initialize on page load
        window.addEventListener('load', function() {
            initializeCanvas();
            
            // Auto-start scanner if supported
            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                setTimeout(startScanner, 1000);
            } else {
                document.getElementById('status').className = 'status status-error';
                document.getElementById('status').textContent = 'Camera not supported. Please use manual entry.';
            }
        });

        // Cleanup on page unload
        window.addEventListener('beforeunload', function() {
            stopScanner();
        });
    </script>
</body>
</html>
