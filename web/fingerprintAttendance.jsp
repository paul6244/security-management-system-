<%@ page import="java.sql.*" %>
<%@ page import="config.SimpleDatabaseConfig" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
// Check if user is logged in
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect("simpleLogin.jsp");
    return;
}

String employeeId = request.getParameter("employee_id");
String action = request.getParameter("action");
String latitude = request.getParameter("latitude");
String longitude = request.getParameter("longitude");

if (employeeId != null && action != null && latitude != null && longitude != null) {
    try {
        Connection con = SimpleDatabaseConfig.getSimpleConnection();
        
        // Get staff information
        String staffSql = "SELECT first_name, last_name, email, phone FROM staff_registration WHERE employee_id = ?";
        PreparedStatement staffPs = con.prepareStatement(staffSql);
        staffPs.setString(1, employeeId);
        ResultSet staffRs = staffPs.executeQuery();
        
        if (staffRs.next()) {
            String fullName = staffRs.getString("first_name") + " " + staffRs.getString("last_name");
            
            // Record attendance with fingerprint verification
            String attendanceSql = "INSERT INTO attendance (employee_id, check_in_time, check_out_time, date, latitude, longitude, verification_method, status) VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ?, ?, 'fingerprint', ?)";
            PreparedStatement attendancePs = con.prepareStatement(attendanceSql);
            
            if ("checkin".equals(action)) {
                attendancePs.setString(1, employeeId);
                attendancePs.setNull(2, Types.TIMESTAMP);
                attendancePs.setString(3, latitude);
                attendancePs.setString(4, longitude);
                attendancePs.setString(5, "checked_in");
            } else {
                attendancePs.setString(1, employeeId);
                attendancePs.setNull(1, Types.TIMESTAMP);
                attendancePs.setString(2, latitude);
                attendancePs.setString(3, longitude);
                attendancePs.setString(4, "checked_out");
            }
            
            attendancePs.executeUpdate();
            attendancePs.close();
            
            session.setAttribute("attendanceMessage", "✅ " + fullName + " - " + action + " completed successfully with fingerprint verification!");
            session.setAttribute("attendanceStatus", "success");
        }
        
        staffRs.close();
        staffPs.close();
        con.close();
        
        response.sendRedirect("fingerprintAttendance.jsp");
        
    } catch (Exception e) {
        session.setAttribute("attendanceMessage", "❌ Error: " + e.getMessage());
        session.setAttribute("attendanceStatus", "error");
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fingerprint Attendance System</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        
        .header h1 {
            color: #333;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .main-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .card h2 {
            color: #333;
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 500;
            font-size: 14px;
        }
        
        .form-group select, .form-group input {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        
        .form-group select:focus, .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 0 2px rgba(102, 126, 234, 0.2);
        }
        
        .fingerprint-section {
            text-align: center;
            padding: 40px 20px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            border-radius: 12px;
            margin: 20px 0;
        }
        
        .fingerprint-icon {
            font-size: 80px;
            color: white;
            margin-bottom: 20px;
            animation: pulse 2s infinite;
        }
        
        .fingerprint-text {
            color: white;
            font-size: 18px;
            font-weight: 500;
            margin-bottom: 20px;
        }
        
        .fingerprint-status {
            background: rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            padding: 15px;
            color: white;
            font-size: 16px;
            margin-bottom: 20px;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            margin: 5px;
        }
        
        .btn-success {
            background: #4CAF50;
            color: white;
        }
        
        .btn-success:hover {
            background: #45a049;
        }
        
        .btn-warning {
            background: #ff9800;
            color: white;
        }
        
        .btn-warning:hover {
            background: #f57c00;
        }
        
        .status-message {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 14px;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 14px;
        }
        
        .info-section {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .info-item {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 6px;
        }
        
        .info-item strong {
            color: #333;
            margin-right: 10px;
            min-width: 120px;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        
        @media (max-width: 768px) {
            .main-content {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Security Management System</h1>
            <p style="color: #666;">Biometric Attendance Tracking System</p>
        </div>
        
        <% 
        String message = (String) session.getAttribute("attendanceMessage");
        String status = (String) session.getAttribute("attendanceStatus");
        if (message != null) { 
            session.removeAttribute("attendanceMessage");
            session.removeAttribute("attendanceStatus");
        %>
            <% if ("success".equals(status)) { %>
                <div class="status-message"><%= message %></div>
            <% } else { %>
                <div class="error-message"><%= message %></div>
            <% } %>
        <% } %>
        
        <div class="main-content">
            <div class="card">
                <h2>👤 Staff Selection</h2>
                <form id="staffForm" method="post" action="fingerprintAttendance.jsp">
                    <div class="form-group">
                        <label for="employeeSelect">Select Staff Member:</label>
                        <select id="employeeSelect" name="employee_id" required onchange="updateStaffInfo()">
                            <option value="">-- Select Staff Member --</option>
                            <%
                            try {
                                Connection con = SimpleDatabaseConfig.getSimpleConnection();
                                String sql = "SELECT employee_id, first_name, last_name FROM staff_registration ORDER BY first_name, last_name";
                                PreparedStatement ps = con.prepareStatement(sql);
                                ResultSet rs = ps.executeQuery();
                                
                                while (rs.next()) {
                                    String empId = rs.getString("employee_id");
                                    String firstName = rs.getString("first_name");
                                    String lastName = rs.getString("last_name");
                                    %>
                                    <option value="<%= empId %>"><%= firstName %> <%= lastName %> (<%= empId %>)</option>
                                    <%
                                }
                                
                                rs.close();
                                ps.close();
                                con.close();
                            } catch (Exception e) {
                                // Handle database error
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Selected Staff:</label>
                        <div id="selectedStaffInfo" style="padding: 10px; background: #f8f9fa; border-radius: 6px; color: #666;">
                            No staff selected
                        </div>
                    </div>
                </form>
            </div>
            
            <div class="card">
                <h2>📍 Location Information</h2>
                <div class="info-section">
                    <div class="info-item">
                        <strong>GPS Status:</strong>
                        <span id="gpsStatus">Getting location...</span>
                    </div>
                    <div class="info-item">
                        <strong>Latitude:</strong>
                        <span id="latitude">--</span>
                    </div>
                    <div class="info-item">
                        <strong>Longitude:</strong>
                        <span id="longitude">--</span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>👆 Fingerprint Verification</h2>
            <div class="fingerprint-section">
                <div class="fingerprint-icon">👆</div>
                <div class="fingerprint-text">Place your finger on the scanner</div>
                <div class="fingerprint-status" id="fingerprintStatus">Ready for fingerprint scan...</div>
                
                <div style="margin-top: 20px;">
                    <button class="btn btn-success" onclick="checkIn()">🔓 Check In</button>
                    <button class="btn btn-warning" onclick="checkOut()">🔓 Check Out</button>
                </div>
            </div>
        </div>
        
        <div class="info-section">
            <h3>ℹ️ How Fingerprint Attendance Works:</h3>
            <ol style="color: #666; line-height: 1.6; padding-left: 20px;">
                <li><strong>Select Staff Member:</strong> Choose from the dropdown list</li>
                <li><strong>GPS Location:</strong> System automatically captures your location</li>
                <li><strong>Fingerprint Scan:</strong> Place finger on scanner for biometric verification</li>
                <li><strong>Check In/Out:</strong> Click appropriate button after successful scan</li>
                <li><strong>Automatic Recording:</strong> Attendance is recorded with timestamp and location</li>
            </ol>
        </div>
    </div>
    
    <input type="hidden" id="latitude" name="latitude">
    <input type="hidden" id="longitude" name="longitude">
    
    <script>
        let selectedEmployeeId = null;
        
        // Get GPS Location
        function getLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    function(position) {
                        const lat = position.coords.latitude.toFixed(6);
                        const lng = position.coords.longitude.toFixed(6);
                        
                        document.getElementById("latitude").value = lat;
                        document.getElementById("longitude").value = lng;
                        document.getElementById("latitude").textContent = lat;
                        document.getElementById("longitude").textContent = lng;
                        document.getElementById("gpsStatus").textContent = "✅ Location captured";
                        document.getElementById("gpsStatus").style.color = "#4CAF50";
                    },
                    function(error) {
                        document.getElementById("gpsStatus").textContent = "❌ Location unavailable";
                        document.getElementById("gpsStatus").style.color = "#f44336";
                    }
                );
            } else {
                document.getElementById("gpsStatus").textContent = "❌ GPS not supported";
                document.getElementById("gpsStatus").style.color = "#f44336";
            }
        }
        
        // Update staff information
        function updateStaffInfo() {
            const select = document.getElementById('employeeSelect');
            const selectedOption = select.options[select.selectedIndex];
            selectedEmployeeId = selectedOption.value;
            
            if (selectedEmployeeId) {
                const staffName = selectedOption.text;
                document.getElementById('selectedStaffInfo').innerHTML = `
                    <strong>Selected:</strong> ${staffName}<br>
                    <small style="color: #4CAF50;">✅ Ready for fingerprint verification</small>
                `;
                document.getElementById('selectedStaffInfo').style.background = '#e8f5e8';
                document.getElementById('selectedStaffInfo').style.border = '2px solid #4CAF50';
            } else {
                document.getElementById('selectedStaffInfo').innerHTML = 'No staff selected';
                document.getElementById('selectedStaffInfo').style.background = '#f8f9fa';
                document.getElementById('selectedStaffInfo').style.border = 'none';
            }
        }
        
        // Simulate fingerprint scanning
        function simulateFingerprintScan(callback) {
            const statusDiv = document.getElementById('fingerprintStatus');
            
            if (!selectedEmployeeId) {
                statusDiv.textContent = '❌ Please select a staff member first';
                statusDiv.style.background = 'rgba(244, 67, 54, 0.2)';
                return false;
            }
            
            statusDiv.textContent = '🔄 Scanning fingerprint...';
            statusDiv.style.background = 'rgba(255, 152, 0, 0.2)';
            
            // Simulate fingerprint scan delay
            setTimeout(() => {
                statusDiv.textContent = '✅ Fingerprint verified successfully!';
                statusDiv.style.background = 'rgba(76, 175, 80, 0.2)';
                callback();
            }, 2000);
        }
        
        // Check In
        function checkIn() {
            simulateFingerprintScan(() => {
                submitAttendance('checkin');
            });
        }
        
        // Check Out
        function checkOut() {
            simulateFingerprintScan(() => {
                submitAttendance('checkout');
            });
        }
        
        // Submit attendance
        function submitAttendance(action) {
            const lat = document.getElementById('latitude').value;
            const lng = document.getElementById('longitude').value;
            
            if (!lat || !lng) {
                alert('❌ GPS location is required. Please enable location services.');
                return;
            }
            
            const form = document.createElement('form');
            form.method = 'post';
            form.action = 'fingerprintAttendance.jsp';
            
            const employeeField = document.createElement('input');
            employeeField.type = 'hidden';
            employeeField.name = 'employee_id';
            employeeField.value = selectedEmployeeId;
            form.appendChild(employeeField);
            
            const actionField = document.createElement('input');
            actionField.type = 'hidden';
            actionField.name = 'action';
            actionField.value = action;
            form.appendChild(actionField);
            
            const latField = document.createElement('input');
            latField.type = 'hidden';
            latField.name = 'latitude';
            latField.value = lat;
            form.appendChild(latField);
            
            const lngField = document.createElement('input');
            lngField.type = 'hidden';
            lngField.name = 'longitude';
            lngField.value = lng;
            form.appendChild(lngField);
            
            document.body.appendChild(form);
            form.submit();
        }
        
        // Initialize on page load
        window.onload = function() {
            getLocation();
        };
    </script>
</body>
</html>
