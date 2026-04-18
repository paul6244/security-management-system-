<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR Attendance - Mark Attendance</title>
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
            max-width: 500px;
            width: 100%;
            text-align: center;
        }

        .card h2 {
            color: #333;
            margin-bottom: 1.5rem;
            font-size: 1.5rem;
        }

        .qr-info {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            text-align: left;
        }

        .qr-info h3 {
            color: #333;
            margin-bottom: 1rem;
            font-size: 1.2rem;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem 0;
            border-bottom: 1px solid #e9ecef;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            color: #666;
            font-weight: 500;
        }

        .detail-value {
            color: #333;
            font-weight: 600;
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

        .actions {
            margin-top: 2rem;
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
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
            
            .btn {
                width: 100%;
                max-width: 200px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>QR Attendance System</h1>
    </div>

    <div class="container">
        <div class="card">
            <h2>Mark Your Attendance</h2>
            
            <div id="alert" class="alert"></div>

            <c:if test="${not empty param.staffId and not empty param.date}">
                <div class="qr-info">
                    <h3>Session Information</h3>
                    <div class="detail-row">
                        <span class="detail-label">Staff ID:</span>
                        <span class="detail-value">${param.staffId}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Date:</span>
                        <span class="detail-value">${param.date}</span>
                    </div>
                </div>

                <form id="attendanceForm" method="POST" action="MarkAttendance">
                    <input type="hidden" name="staffId" value="${param.staffId}">
                    <input type="hidden" name="date" value="${param.date}">
                    
                    <div class="form-group">
                        <label for="employeeId">Employee ID:</label>
                        <input type="text" id="employeeId" name="employeeId" placeholder="Enter your Employee ID" required>
                    </div>
                    
                    <button type="submit" class="btn">Mark Attendance</button>
                </form>
            </c:if>

            <c:if test="${empty param.staffId or empty param.date}">
                <div class="alert alert-error" style="display: block;">
                    Invalid QR code or missing parameters. Please scan a valid QR code.
                </div>
            </c:if>

                    </div>
    </div>

    <script>
        // Focus on employee ID input when page loads
        window.addEventListener('load', function() {
            const employeeIdInput = document.getElementById('studentId');
            if (studentIdInput) {
                employeeIdInput.focus();
            }
        });

        // Form submission handler
        document.getElementById('attendanceForm').addEventListener('submit', function(e) {
            const employeeId = document.getElementById('studentId').value.trim();
            
            if (!employeeId) {
                e.preventDefault();
                showAlert('Please enter your Employee ID', 'error');
                return;
            }
            
            // Show loading state
            showAlert('Marking attendance...', 'success');
        });

        function showAlert(message, type) {
            const alert = document.getElementById('alert');
            alert.textContent = message;
            alert.className = 'alert alert-' + type;
            alert.style.display = 'block';
        }
    </script>
</body>
</html>
