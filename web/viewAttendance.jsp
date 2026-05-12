<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="config.DatabaseConfig" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR Code Attendance System</title>
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

        .form-group {
            margin-bottom: 1.5rem;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #555;
            font-weight: 500;
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus, .form-group select:focus {
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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }

        .qr-container {
            margin: 2rem 0;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 10px;
            min-height: 300px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .qr-container img {
            max-width: 100%;
            height: auto;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .qr-info {
            margin-top: 1rem;
            padding: 1rem;
            background: #e9ecef;
            border-radius: 8px;
            font-size: 0.9rem;
            color: #666;
        }

        .actions {
            margin-top: 2rem;
            display: flex;
            justify-content: center;
            gap: 1rem;
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

        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            display: none;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .card {
                padding: 1.5rem;
            }
            
            .actions {
                flex-direction: column;
                align-items: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
                <h2>Generate Attendance QR Code</h2>
                
                <div id="alert" class="alert"></div>

                <form id="qrForm">
                    <div class="form-group">
                        <label for="staffId">Select Staff Member:</label>
                        <select id="staffId" name="staffId" required>
                            <option value="">-- Select Staff Member --</option>
                            <%
                                Connection conn = null;
                                ResultSet rs = null;
                                try {
                                    conn = DatabaseConfig.getConnection();
                                    if(conn != null) {
                                        String sql = "SELECT sr.id, sr.first_name, sr.last_name, sr.department, sr.position, sr.employee_id " +
                                                        "FROM staff_registration sr " +
                                                        "ORDER BY sr.first_name, sr.last_name";
                                        PreparedStatement stmt = conn.prepareStatement(sql);
                                        rs = stmt.executeQuery();
                                        
                                        while(rs.next()) {
                                            String staffId = rs.getString("id");
                                            String firstName = rs.getString("first_name");
                                            String lastName = rs.getString("last_name");
                                            String department = rs.getString("department");
                                            String position = rs.getString("position");
                                            String employeeId = rs.getString("employee_id");
                            %>
                            <option value="<%= staffId %>"><%= firstName %> <%= lastName %> - <%= department %> (<%= position %>)</option>
                            <%
                                        }
                                        rs.close();
                                        stmt.close();
                                    }
                                } catch(Exception e) {
                                    // Handle database connection error gracefully
                                    out.println("<option value=''>Database connection error</option>");
                                } finally {
                                    try {
                                        if(rs != null) rs.close();
                                        if(conn != null) conn.close();
                                    } catch(Exception e) {
                                        // Ignore cleanup errors
                                    }
                                }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="date">Date:</label>
                        <input type="date" id="date" name="date" required>
                    </div>

                    <button type="submit" class="btn">Generate QR Code</button>
                </form>

                <div class="loading" id="loading">
                    <div class="loading-spinner"></div>
                    <p>Generating QR Code...</p>
                </div>

                <div class="qr-container" id="qrContainer" style="display: none;">
                    <img id="qrImage" alt="Attendance QR Code">
                    <div class="qr-info">
                        <strong>QR Code Generated!</strong><br>
                        Staff can scan this code to mark their attendance.<br>
                        <span id="qrUrl"></span>
                    </div>
                </div>

                <div class="actions">
                    <button class="btn" onclick="refreshQR()">Refresh QR Code</button>
                    <button class="btn btn-secondary" onclick="goToScanner()">Open Scanner</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Set today's date as default
        document.getElementById('date').valueAsDate = new Date();

        // Form submission handler
        document.getElementById('qrForm').addEventListener('submit', function(e) {
            e.preventDefault();
            generateQRCode();
        });

        function generateQRCode() {
            const staffId = document.getElementById('staffId').value;
            const date = document.getElementById('date').value;
            
            if (!staffId || !date) {
                showAlert('Please select a staff member and date', 'error');
                return;
            }
            
            // Show loading
            document.getElementById('loading').style.display = 'block';
            document.getElementById('qrContainer').style.display = 'none';
            hideAlert();
            
            // Generate QR code
            var qrData = 'ATTENDANCE_' + staffId + '_' + date;
            var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=' + encodeURIComponent(qrData);
            var fullUrl = 'qrAttendance.jsp?staffId=' + encodeURIComponent(staffId) + '&date=' + encodeURIComponent(date);

            // Load QR code image
            const img = new Image();
            img.onload = function() {
                document.getElementById('qrImage').src = qrUrl;
                document.getElementById('qrUrl').textContent = fullUrl;
                document.getElementById('loading').style.display = 'none';
                document.getElementById('qrContainer').style.display = 'block';
            };
            img.onerror = function() {
                document.getElementById('loading').style.display = 'none';
                showAlert('Error generating QR code. Please try again.', 'error');
            };
            img.src = qrUrl;
        }

        function refreshQR() {
            generateQRCode();
        }

        function goToScanner() {
            window.location.href = 'scanAttendance.jsp';
        }

        function showAlert(message, type) {
            const alert = document.getElementById('alert');
            alert.textContent = message;
            alert.className = 'alert alert-' + type;
            alert.style.display = 'block';
        }

        function hideAlert() {
            document.getElementById('alert').style.display = 'none';
        }

        // Auto-refresh QR code every 5 minutes
        setInterval(function() {
            if (document.getElementById('qrContainer').style.display !== 'none') {
                generateQRCode();
            }
        }, 300000); // 5 minutes
    </script>

</body>
</html>
