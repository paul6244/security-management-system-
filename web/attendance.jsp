<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Face Recognition Attendance System</title>
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

.main-content {
    flex:1;
    padding:20px;
    background:white;
}

.status-section {
    padding:15px;
    border-radius:10px;
    margin-bottom:20px;
    text-align:center;
    font-weight:600;
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

.status-warning {
    background:#fff3cd;
    color:#856404;
    border:1px solid #ffeaa7;
}

.info-grid {
    display:grid;
    grid-template-columns: 1fr 1fr;
    gap:20px;
    margin-bottom:20px;
}

.info-item {
    background:#f8f9fa;
    padding:15px;
    border-radius:8px;
    text-align:center;
}

.info-label {
    font-weight:600;
    color:#2c3e50;
    margin-bottom:5px;
}

.info-value {
    color:#3498db;
    font-weight:600;
}

.card {
    background:white;
    padding:20px;
    border-radius:10px;
    box-shadow:0 2px 10px rgba(0,0,0,0.1);
    margin-bottom:20px;
}

.card h3 {
    margin-top:0;
    color:#2c3e50;
    text-align:center;
    margin-bottom:20px;
}

.btn {
    background:#3498db;
    color:white;
    padding:12px 24px;
    border:none;
    border-radius:5px;
    cursor:pointer;
    font-size:14px;
}

.btn:hover {
    background:#2980b9;
}

.btn-success {
    background:#27ae60;
}

.btn-success:hover {
    background:#229954;
}

.btn:disabled {
    background:#95a5a6;
    cursor:not-allowed;
}

.btn-small {
    padding:8px 15px;
    font-size:12px;
    margin:0 5px;
    background:#6c757d;
    color:white;
    border:none;
    border-radius:5px;
    cursor:pointer;
}

.btn-small:hover {
    background:#5a6268;
}

.form-group {
    margin-bottom:15px;
}

.form-group label {
    display:block;
    font-weight:600;
    margin-bottom:5px;
    color:#2c3e50;
}

.form-group select, .form-group input {
    width:100%;
    padding:10px;
    border:1px solid #ddd;
    border-radius:5px;
    font-size:14px;
    box-sizing:border-box;
}

.photo-display {
    text-align:center;
    margin:15px 0;
}

.photo-display img {
    max-width:200px;
    max-height:200px;
    border:2px solid #3498db;
    border-radius:8px;
}

.camera-section {
    text-align:center;
    margin:20px 0;
}

.camera-section video {
    width:100%;
    max-width:400px;
    border:2px solid #ddd;
    border-radius:8px;
}

.attendance-list {
    max-height:300px;
    overflow-y:auto;
}

.attendance-item {
    display:flex;
    align-items:center;
    padding:12px;
    background:#f8f9fa;
    border-radius:8px;
    border-left:4px solid #27ae60;
    margin-bottom:10px;
}

.attendance-item .info {
    flex:1;
}

.attendance-item .photo {
    width:40px;
    height:40px;
    border-radius:50%;
    object-fit:cover;
    border:2px solid #ddd;
    margin-left:10px;
}

.empty-state {
    text-align:center;
    color:#666;
    padding:20px;
    border:1px solid #ddd;
    border-radius:8px;
}

.empty-state .icon {
    font-size:24px;
    margin-bottom:10px;
}

.error-state {
    text-align:center;
    color:#e74c3c;
    padding:20px;
    border:1px solid #e74c3c;
    border-radius:8px;
}

.error-state .icon {
    font-size:24px;
    margin-bottom:10px;
}

.button-group {
    text-align:center;
    margin:20px 0;
}

.button-group button {
    margin:0 10px;
}

.diagnostic-section {
    background:#f8f9fa;
    padding:15px;
    border-radius:8px;
    margin:15px 0;
    border:1px solid #ddd;
}

.diagnostic-section h4 {
    margin-top:0;
    color:#2c3e50;
}

.diagnostic-section pre {
    background:white;
    padding:10px;
    border-radius:5px;
    font-size:11px;
    overflow-x:auto;
    margin:10px 0;
}

.diagnostic-section .btn {
    margin:5px;
    font-size:12px;
    padding:8px 15px;
}
</style>
</head>
<body>
<div class="navbar">
    Security Management System - Face Recognition Attendance
</div>

<div class="container">
    <div class="sidebar">
        <a href="personnelDashboard.jsp">Dashboard</a>
        <a href="attendance.jsp">Attendance</a>
        <a href="staffRegistration.jsp">Staff Registration</a>
        
    </div>
    
    <div class="main-content">
        <!-- Status Messages -->
        <div class="status-section" id="statusMessage" style="display:none;"></div>

        <!-- URL Parameters Display -->
        <%
        String urlMessage = "";
        String urlType = "";
        String urlParam = request.getParameter("success");
        if(urlParam != null && urlParam.equals("1")) {
            String message = request.getParameter("message");
            urlMessage = (message != null) ? java.net.URLDecoder.decode(message, "UTF-8") : "Attendance submitted successfully!";
            urlType = "success";
        }
        String errorParam = request.getParameter("error");
        if(errorParam != null) {
            if(errorParam.equals("already_checked_in")) {
                urlMessage = "Staff member already checked in today!";
                urlType = "error";
            } else if(errorParam.equals("attendance_failed")) {
                urlMessage = "Failed to record attendance!";
                urlType = "error";
            } else if(errorParam.equals("system_error")) {
                urlMessage = "System error occurred! Check diagnostic section below.";
                urlType = "error";
            }
        }
        
        if(!urlMessage.isEmpty()) {
        %>
        <div class="status-section status-<%= urlType %>">
            <%= urlMessage %>
        </div>
        <%
        }
        %>

        <!-- Diagnostic Section (shown when there's an error) -->
        <% if(errorParam != null && errorParam.equals("system_error")) { %>
        <div class="diagnostic-section">
            <h4>System Error Diagnostics</h4>
            <p>The attendance system encountered an error. Check these common issues:</p>
            
            <%
            String diagnosticStatus = "";
            String diagnosticType = "info";
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
                diagnosticStatus = "✅ Database connection successful!";
                diagnosticType = "success";
                
                // Check tables
                DatabaseMetaData meta = con.getMetaData();
                
                // Check staff_registration
                ResultSet tables = meta.getTables(null, null, "staff_registration", new String[] {"TABLE"});
                if(tables.next()) {
                    diagnosticStatus += "<br>✅ staff_registration table exists";
                    
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM staff_registration");
                    if(rs.next()) {
                        int count = rs.getInt("count");
                        diagnosticStatus += "<br>✅ Found " + count + " staff members";
                        if(count == 0) {
                            diagnosticStatus += "<br>⚠️ No staff data - Add staff members first!";
                            diagnosticType = "warning";
                        }
                    }
                    rs.close();
                    stmt.close();
                } else {
                    diagnosticStatus += "<br>❌ staff_registration table missing";
                    diagnosticType = "error";
                }
                tables.close();
                
                // Check attendance table
                tables = meta.getTables(null, null, "attendance", new String[] {"TABLE"});
                if(tables.next()) {
                    diagnosticStatus += "<br>✅ attendance table exists";
                } else {
                    diagnosticStatus += "<br>❌ attendance table missing";
                    diagnosticType = "error";
                }
                tables.close();
                
                con.close();
                
            } catch(Exception e) {
                diagnosticStatus = "❌ Database error: " + e.getMessage();
                diagnosticType = "error";
            }
            %>
            
            <div class="status-section status-<%= diagnosticType %>">
                <%= diagnosticStatus %>
            </div>
            
            <h5>🔧 Quick Fixes:</h5>
            <div class="button-group">
                <button class="btn btn-small" onclick="showFixSQL()">Show Fix SQL</button>
                <button class="btn btn-small" onclick="createAttendanceFolder()">Create Selfie Folder</button>
                <button class="btn btn-small" onclick="reloadPage()">Reload Page</button>
            </div>
            
            <div id="fixSQL" style="display:none;">
                <h6>Run this SQL in phpMyAdmin:</h6>
                <pre>
-- Fix attendance table
DROP TABLE IF EXISTS attendance;
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(255),
    staff_id INT,
    employee_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    selfie_path VARCHAR(255),
    face_verified BOOLEAN DEFAULT FALSE,
    attendance_type VARCHAR(20) DEFAULT 'qr'
);

-- Add sample staff if needed
INSERT INTO staff_registration (first_name, last_name, email, phone, department, position, employee_id, office_location, address, selfie_path) VALUES
('John', 'Doe', 'john@university.edu', '+233-24-123-4567', 'Computer Science', 'Lecturer', 'EMP001', 'Room 201, Building A', '123 University Avenue, Kumasi, Ghana', 'staff_photos/EMP001_1640000000000.png');
                </pre>
            </div>
            
            <h6>📁 Create Selfie Folder:</h6>
            <p>Create this folder: <code>C:/xampp/tomcat/webapps/SecurityManagementSystem/attendance_selfies/</code></p>
        </div>
        <% } %>

        <!-- Info Grid -->
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Location</div>
                <div class="info-value" id="locationInfo">Getting GPS...</div>
            </div>
            <div class="info-item">
                <div class="info-label">Selected Staff</div>
                <div class="info-value" id="userInfo">No staff selected yet</div>
            </div>
        </div>

        <!-- Face Recognition Section -->
        <div class="card">
            <h3>Face Recognition Attendance</h3>
            
            <div class="form-group">
                <label for="staffSelect">Select Staff Member:</label>
                <select id="staffSelect" onchange="loadStaffPhoto()">
                    <option value="">-- Select Staff --</option>
                    <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
                        String sql = "SELECT id, first_name, last_name, employee_id, selfie_path FROM staff_registration ORDER BY first_name, last_name";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        while(rs.next()) {
                            int id = rs.getInt("id");
                            String firstName = rs.getString("first_name");
                            String lastName = rs.getString("last_name");
                            String employeeId = rs.getString("employee_id");
                            String selfiePath = rs.getString("selfie_path");
                            String fullName = firstName + " " + lastName;
                    %>
                            <option value="<%= id %>" data-employee-id="<%= employeeId %>" data-selfie="<%= selfiePath != null ? selfiePath : "" %>">
                                <%= fullName %> (<%= employeeId %>)
                            </option>
                    <%
                        }
                        rs.close();
                        ps.close();
                        con.close();
                    } catch(Exception e) {
                        e.printStackTrace();
                    %>
                        <option value="">Error loading staff</option>
                    <%
                    }
                    %>
                </select>
            </div>

            <div class="photo-display" id="registrationPhotoDisplay" style="display:none;">
                <h4>Registration Photo</h4>
                <img id="registrationPhoto" alt="Registration Photo">
            </div>

            <div class="form-group" id="manualStaffEntry" style="display:none;">
                <h4>Manual Staff Entry</h4>
                <input type="text" id="manualStaffId" placeholder="Enter Staff ID or Employee ID">
                <div class="button-group">
                    <button class="btn btn-success" onclick="submitManualStaff()">Submit</button>
                    <button class="btn" onclick="hideManualStaffEntry()">Cancel</button>
                </div>
            </div>

            <div class="button-group">
                <button class="btn btn-small" onclick="showManualStaffEntry()">Enter Staff ID Manually</button>
            </div>
        </div>

        <!-- Today's Attendance Section -->
        <div class="card">
            <h3>Today's Attendance</h3>
            <div class="attendance-list" id="todayAttendance">
                <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
                    
                    // Test basic connection first
                    Statement testStmt = con.createStatement();
                    ResultSet testRs = testStmt.executeQuery("SELECT 1 as test");
                    if(testRs.next()) {
                        testRs.close();
                        testStmt.close();
                        
                        // Check if attendance table exists
                        DatabaseMetaData meta = con.getMetaData();
                        ResultSet tables = meta.getTables(null, null, "attendance", new String[] {"TABLE"});
                        
                        if(tables.next()) {
                            // Table exists, now try to load data
                            String sql = "SELECT a.id, a.staff_id, a.employee_id, a.first_name, a.last_name, " +
                                        "a.check_in_time, a.face_verified, a.selfie_path " +
                                        "FROM attendance a " +
                                        "WHERE DATE(a.check_in_time) = CURRENT_DATE " +
                                        "ORDER BY a.check_in_time DESC";
                            
                            PreparedStatement ps = con.prepareStatement(sql);
                            ResultSet rs = ps.executeQuery();
                            
                            SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
                            boolean hasData = false;
                            
                            // Count total records with separate query
                            String countSql = "SELECT COUNT(*) as total FROM attendance a WHERE DATE(a.check_in_time) = CURRENT_DATE";
                            PreparedStatement countPs = con.prepareStatement(countSql);
                            ResultSet countRs = countPs.executeQuery();
                            int totalCount = 0;
                            if(countRs.next()) {
                                totalCount = countRs.getInt("total");
                            }
                            countRs.close();
                            countPs.close();
                            
                            if(totalCount > 0) {
                        %>
                                <div style="margin-bottom:15px; font-weight:600; color:#2c3e50;">
                                    Total Checked In: <%= totalCount %> staff members
                                </div>
                        <%
                            }
                            
                            while(rs.next()) {
                                hasData = true;
                                int id = rs.getInt("id");
                                int staffId = rs.getInt("staff_id");
                                String employeeId = rs.getString("employee_id");
                                String firstName = rs.getString("first_name");
                                String lastName = rs.getString("last_name");
                                Timestamp checkInTime = rs.getTimestamp("check_in_time");
                                boolean faceVerified = rs.getBoolean("face_verified");
                                String selfiePath = rs.getString("selfie_path");
                                
                                String fullName = firstName + " " + lastName;
                                String formattedTime = timeFormat.format(checkInTime);
                        %>
                            <div class="attendance-item">
                                <div class="info">
                                    <div style="font-weight:600; color:#2c3e50;"><%= fullName %></div>
                                    <div style="font-size:12px; color:#666;"><%= employeeId %> • <%= formattedTime %></div>
                                    <div style="font-size:11px; color:#27ae60;">✅ Face Verified</div>
                                </div>
                                <% if(selfiePath != null && !selfiePath.isEmpty()) { %>
                                    <img src="<%= selfiePath %>" class="photo" alt="Attendance Selfie">
                                <% } %>
                            </div>
                        <%
                            }
                            
                            rs.close();
                            ps.close();
                            
                            if(!hasData) {
                        %>
                            <div class="empty-state">
                                <div class="icon">📅</div>
                                <div>No attendance records for today yet</div>
                                <small>Be the first to check in!</small>
                            </div>
                        <%
                            }
                        } else {
                            // Attendance table doesn't exist
                        %>
                            <div class="error-state">
                                <div class="icon">❌</div>
                                <div>Attendance table does not exist!</div>
                                <small>Please create the attendance table first</small>
                            </div>
                        <%
                        }
                        tables.close();
                        
                    } else {
                        // Basic query failed
                    %>
                        <div class="error-state">
                            <div class="icon">❌</div>
                            <div>Database query failed!</div>
                            <small>Check database connection and permissions</small>
                        </div>
                    <%
                    }
                    testRs.close();
                    testStmt.close();
                    con.close();
                    
                } catch(ClassNotFoundException e) {
                    // MySQL driver not found
                %>
                    <div class="error-state">
                        <div class="icon">❌</div>
                        <div>MySQL Driver not found!</div>
                        <small><%= e.getMessage() %></small>
                    </div>
                <%
                } catch(SQLException e) {
                    // SQL error
                %>
                    <div class="error-state">
                        <div class="icon">❌</div>
                        <div>Database SQL Error!</div>
                        <small><%= e.getMessage() %></small>
                    </div>
                <%
                } catch(Exception e) {
                    // Other error
                %>
                    <div class="error-state">
                        <div class="icon">❌</div>
                        <div>System Error!</div>
                        <small><%= e.getMessage() %></small>
                    </div>
                <%
                }
                %>
            </div>
        </div>

        <!-- Camera Section -->
        <div class="card">
            <h3>Take Selfie</h3>
            <div class="camera-section">
                <video id="camera" autoplay></video>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="button-group">
            <button class="btn" onclick="submitAttendance()" id="submitBtn" disabled>
                Submit Attendance
            </button>
            <button class="btn" onclick="resetAttendance()">
                Reset
            </button>
        </div>
    </div>
</div>

<!-- Hidden Form -->
<form id="attendanceForm" action="ScanQR" method="post">
    <input type="hidden" name="staff_id" id="staff_id">
    <input type="hidden" name="latitude" id="latitude">
    <input type="hidden" name="longitude" id="longitude">
    <input type="hidden" name="selfie" id="selfie">
</form>

<script>
// Status message function
function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.className = 'status-section status-' + type;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 5000);
}

// Diagnostic functions
function showFixSQL() {
    const fixDiv = document.getElementById('fixSQL');
    fixDiv.style.display = fixDiv.style.display === 'none' ? 'block' : 'none';
}

function createAttendanceFolder() {
    showStatus('Please create folder: C:/xampp/tomcat/webapps/SecurityManagementSystem/attendance_selfies/', 'info');
}

function reloadPage() {
    location.reload();
}

// Load staff photo when selected
function loadStaffPhoto() {
    const staffSelect = document.getElementById('staffSelect');
    const staffId = staffSelect.value;
    
    if(!staffId) {
        document.getElementById('registrationPhotoDisplay').style.display = 'none';
        document.getElementById('userInfo').textContent = 'No staff selected yet';
        document.getElementById('staff_id').value = '';
        checkFormReady();
        return;
    }
    
    const selectedOption = staffSelect.options[staffSelect.selectedIndex];
    const staffName = selectedOption.text;
    const selfiePath = selectedOption.getAttribute('data-selfie');
    
    const photoDisplay = document.getElementById('registrationPhotoDisplay');
    const photoImg = document.getElementById('registrationPhoto');
    
    if(selfiePath && selfiePath.trim() !== '') {
        photoImg.src = selfiePath;
        photoDisplay.style.display = 'block';
        showStatus('Loaded registration photo for ' + staffName, 'success');
    } else {
        photoDisplay.style.display = 'none';
        showStatus('No registration photo found for ' + staffName, 'error');
    }
    
    document.getElementById('staff_id').value = staffId;
    document.getElementById('userInfo').innerHTML = '<strong>Selected:</strong><br>' + staffName;
    
    checkFormReady();
}

// Manual staff entry functions
function showManualStaffEntry() {
    document.getElementById('manualStaffEntry').style.display = 'block';
    document.getElementById('manualStaffId').focus();
    showStatus('Manual staff entry activated', 'info');
}

function hideManualStaffEntry() {
    document.getElementById('manualStaffEntry').style.display = 'none';
    document.getElementById('manualStaffId').value = '';
}

function submitManualStaff() {
    const staffId = document.getElementById('manualStaffId').value.trim();
    
    if(!staffId) {
        showStatus('Please enter staff ID or Employee ID', 'error');
        return;
    }
    
    document.getElementById('staff_id').value = staffId;
    document.getElementById('userInfo').innerHTML = '<strong>Manual Entry:</strong><br>ID: ' + staffId;
    
    hideManualStaffEntry();
    checkFormReady();
}

// Get GPS Location
function getLocation() {
    if(navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function(position) {
                const lat = position.coords.latitude.toFixed(6);
                const lng = position.coords.longitude.toFixed(6);
                
                document.getElementById("latitude").value = lat;
                document.getElementById("longitude").value = lng;
                document.getElementById("locationInfo").textContent = lat + ', ' + lng;
                showStatus('Location captured successfully', 'success');
                
                checkFormReady();
            },
            function(error) {
                document.getElementById("locationInfo").textContent = "Location unavailable";
                showStatus('Unable to get GPS location', 'error');
            }
        );
    } else {
        document.getElementById("locationInfo").textContent = "GPS not supported";
        showStatus('GPS not supported by browser', 'error');
    }
}

// Camera for Selfie
let video = document.getElementById("camera");
let stream = null;

function startCamera() {
    if(navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        navigator.mediaDevices.getUserMedia({ video: true })
        .then(function(mediaStream) {
            stream = mediaStream;
            video.srcObject = stream;
            showStatus('Camera ready', 'success');
        })
        .catch(function(error) {
            showStatus('Unable to access camera', 'error');
        });
    } else {
        showStatus('Camera not supported', 'error');
    }
}

// Check if form is ready to submit
function checkFormReady() {
    const staffId = document.getElementById("staff_id").value;
    const lat = document.getElementById("latitude").value;
    const lng = document.getElementById("longitude").value;
    const submitBtn = document.getElementById("submitBtn");
    
    if(staffId && lat && lng) {
        submitBtn.disabled = false;
        submitBtn.classList.add('btn-success');
        submitBtn.innerHTML = 'Ready to Submit';
    } else {
        submitBtn.disabled = true;
        submitBtn.classList.remove('btn-success');
        submitBtn.innerHTML = 'Submit Attendance';
    }
}

// Submit Attendance
function submitAttendance() {
    const staffId = document.getElementById("staff_id").value;
    const lat = document.getElementById("latitude").value;
    const lng = document.getElementById("longitude").value;
    
    if(!staffId || !lat || !lng) {
        showStatus('Please select staff and ensure location is captured', 'error');
        return;
    }
    
    if(!stream || !video.videoWidth || !video.videoHeight) {
        showStatus('Camera not ready for selfie capture', 'error');
        return;
    }
    
    showStatus('Capturing selfie for verification...', 'info');
    
    try {
        let canvas = document.createElement("canvas");
        canvas.width = video.videoWidth || 640;
        canvas.height = video.videoHeight || 480;
        
        let ctx = canvas.getContext("2d");
        ctx.drawImage(video, 0, 0);
        
        let dataURL = canvas.toDataURL("image/png");
        document.getElementById("selfie").value = dataURL;
        
        const submitBtn = document.getElementById("submitBtn");
        submitBtn.disabled = true;
        submitBtn.innerHTML = 'Submitting...';
        
        showStatus('Submitting attendance...', 'info');
        
        document.getElementById("attendanceForm").submit();
        
    } catch(error) {
        showStatus('Error capturing selfie: ' + error.message, 'error');
        console.error('Selfie capture error:', error);
    }
}

// Reset Attendance
function resetAttendance() {
    document.getElementById("staff_id").value = "";
    document.getElementById("userInfo").textContent = "No staff selected yet";
    document.getElementById("submitBtn").disabled = true;
    document.getElementById("submitBtn").classList.remove('btn-success');
    document.getElementById("submitBtn").innerHTML = 'Submit Attendance';
    document.getElementById("staffSelect").selectedIndex = 0;
    document.getElementById("registrationPhotoDisplay").style.display = 'none';
    showStatus('Attendance reset', 'info');
}

// Initialize on page load
window.onload = function() {
    getLocation();
    startCamera();
};
</script>

</body>
</html>
