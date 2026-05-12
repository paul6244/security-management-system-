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
    <title>QR Code Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            margin:0;
            padding:0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height:100vh;
            color:white;
        }

        .navbar {
            background:rgba(52,73,94,0.95);
            padding:15px 25px;
            color:white;
            font-weight:600;
            backdrop-filter:blur(10px);
            border-bottom:1px solid rgba(255,255,255,0.1);
        }

        .container {
            display:flex;
            min-height:100vh;
        }

        .sidebar {
            width:250px;
            background:#34495e;
            padding:20px;
            min-height:100vh;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .sidebar a {
            display:block;
            padding:15px;
            color:white;
            text-decoration:none;
            border-radius:5px;
            margin-bottom:5px;
            transition:all 0.3s ease;
        }

        .sidebar a:hover {
            background:#2c3e50;
            transform:translateX(5px);
        }

        .sidebar a.active {
            background:#3498db;
        }

        .main {
            flex:1;
            padding:20px;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .card {
            background:rgba(255,255,255,0.95);
            border-radius:15px;
            padding:25px;
            margin-bottom:20px;
            box-shadow:0 8px 32px rgba(0,0,0,0.1);
            backdrop-filter:blur(10px);
            border:1px solid rgba(255,255,255,0.2);
            color:#2c3e50;
        }

        .card h3 {
            color:#2c3e50;
            margin:0 0 20px 0;
            font-size:1.4em;
            font-weight:600;
        }

        .btn {
            background:#3498db;
            color:white;
            border:none;
            padding:12px 24px;
            border-radius:8px;
            cursor:pointer;
            font-weight:500;
            transition:all 0.3s ease;
            font-size:14px;
        }

        .btn:hover {
            background:#2980b9;
            transform:translateY(-2px);
            box-shadow:0 4px 12px rgba(52,152,219,0.3);
        }

        .btn-secondary {
            background:#95a5a6;
        }

        .btn-secondary:hover {
            background:#7f8c8d;
        }

        .table {
            width:100%;
            border-collapse:collapse;
            margin-top:20px;
            background:white;
            border-radius:10px;
            overflow:hidden;
            box-shadow:0 4px 12px rgba(0,0,0,0.1);
        }

        .table th {
            background:#34495e;
            color:white;
            padding:15px;
            text-align:left;
            font-weight:500;
        }

        .table td {
            padding:15px;
            border-bottom:1px solid #ecf0f1;
        }

        .table tr:hover {
            background:#f8f9fa;
        }

        @media (max-width: 768px) {
            .container {
                flex-direction:column;
            }
            
            .sidebar {
                width:100%;
                order:2;
            }
            
            .main {
                order:1;
            }
            
            .card {
                padding:15px;
            }
        }
    </style>
</head>
<body>

<div class="navbar">
    QR Code Dashboard | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="checklistDashboard.jsp">Checklist</a>
    <a href="viewAttendance.jsp" class="active">QR Code</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="securityOfficerReports.jsp">Reports</a>
    <a href="securityOfficerSettings.jsp">Settings</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<div class="card">
    <h3>QR Code Attendance System</h3>
    
    <div style="text-align: center; margin: 20px 0;">
        <p style="color: #2c3e50; margin-bottom: 20px;">Scan the QR code below to mark your attendance</p>
        
        <div style="background: white; padding: 20px; border-radius: 10px; display: inline-block; margin: 20px 0;">
            <div id="qrcode" style="width: 200px; height: 200px; margin: 0 auto; display: flex; align-items: center; justify-content: center; border: 2px dashed #3498db; border-radius: 8px;">
                <span style="color: #7f8c8d; font-size: 14px;">QR Code Loading...</span>
            </div>
        </div>
        
        <div style="margin-top: 20px;">
            <button class="btn" onclick="generateQRCode()">Generate New QR Code</button>
            <button class="btn btn-secondary" onclick="refreshQRCode()" style="margin-left: 10px;">Refresh</button>
        </div>
    </div>
</div>

<!-- Attendance Log -->
<div class="card">
    <h3>Recent Attendance</h3>
    
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Name</th>
                <th>Check In</th>
                <th>Check Out</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>2026-05-12</td>
                <td>John Doe</td>
                <td>08:30 AM</td>
                <td>05:30 PM</td>
                <td><span style="color: #27ae60; font-weight: 500;">Present</span></td>
            </tr>
            <tr>
                <td>2026-05-12</td>
                <td>Jane Smith</td>
                <td>09:15 AM</td>
                <td>-</td>
                <td><span style="color: #f39c12; font-weight: 500;">Late</span></td>
            </tr>
            <tr>
                <td>2026-05-11</td>
                <td>Mike Johnson</td>
                <td>08:00 AM</td>
                <td>05:00 PM</td>
                <td><span style="color: #27ae60; font-weight: 500;">Present</span></td>
            </tr>
        </tbody>
    </table>
</div>

</div>
</div>

<script>
function generateQRCode() {
    const qrContainer = document.getElementById('qrcode');
    qrContainer.innerHTML = '<img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=ATTENDANCE_' + new Date().getTime() + '" alt="QR Code" style="width: 200px; height: 200px;">';
}

function refreshQRCode() {
    generateQRCode();
}

// Generate QR code on page load
window.onload = function() {
    generateQRCode();
};
</script>

</body>
</html>
                refreshQR();
            }
        }, 300000); // 5 minutes
    </script>
</body>
</html>
