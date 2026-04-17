<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance Result</title>
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

        .alert {
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            font-size: 1.1rem;
            font-weight: 500;
        }

        .alert-success {
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
            color: #155724;
            border: 2px solid #c3e6cb;
        }

        .alert-warning {
            background: linear-gradient(135deg, #fff3cd 0%, #fdeaa7 100%);
            color: #856404;
            border: 2px solid #fdeaa7;
        }

        .alert-error {
            background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
            color: #721c24;
            border: 2px solid #f5c6cb;
        }

        .details {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            text-align: left;
        }

        .details h3 {
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

        .icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .icon-success {
            color: #28a745;
        }

        .icon-warning {
            color: #ffc107;
        }

        .icon-error {
            color: #dc3545;
        }

        .actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 25px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
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
        <h1>Attendance Result</h1>
    </div>

    <div class="container">
        <div class="card">
            <c:choose>
                <c:when test="${messageType == 'success'}">
                    <div class="icon icon-success">â</div>
                    <div class="alert alert-success">${message}</div>
                </c:when>
                <c:when test="${messageType == 'warning'}">
                    <div class="icon icon-warning">â ï¸</div>
                    <div class="alert alert-warning">${message}</div>
                </c:when>
                <c:otherwise>
                    <div class="icon icon-error">â</div>
                    <div class="alert alert-error">${message}</div>
                </c:otherwise>
            </c:choose>

            <c:if test="${not empty staffId and not empty date and not empty employeeId}">
                <div class="details">
                    <h3>Attendance Details</h3>
                    <div class="detail-row">
                        <span class="detail-label">Staff ID:</span>
                        <span class="detail-value">${staffId}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Date:</span>
                        <span class="detail-value">${date}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Employee ID:</span>
                        <span class="detail-value">${employeeId}</span>
                    </div>
                    <c:if test="${not empty timestamp}">
                        <div class="detail-row">
                            <span class="detail-label">Timestamp:</span>
                            <span class="detail-value">${timestamp}</span>
                        </div>
                    </c:if>
                </div>
            </c:if>

                    </div>
    </div>

    <script>
        // Auto-redirect to scanner after 5 seconds if there was an error
        setTimeout(function() {
            const alertElement = document.querySelector('.alert-error');
            if (alertElement) {
                window.location.href = 'scanAttendance.jsp';
            }
        }, 5000);
    </script>
</body>
</html>
