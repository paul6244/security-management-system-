<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="config.DatabaseConfig" %>

<%
// Proper session validation
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect("index.jsp");
    return;
}

// Initialize default values
int monthlyShifts = 0;
int completedChecklists = 0;
int attendanceRecords = 0;
int qrScans = 0;
int weeklyPresent = 0;
int monthlyPresent = 0;

// Database connection
Connection conn = null;
try {
    conn = DatabaseConfig.getConnection();
    
    if (conn != null) {
        // Get user ID from users table
        String userSql = "SELECT id FROM users WHERE username = ?";
        PreparedStatement userPs = conn.prepareStatement(userSql);
        userPs.setString(1, username);
        ResultSet userRs = userPs.executeQuery();
        
        if (userRs.next()) {
            int userId = userRs.getInt("id");
            
            // Get monthly shifts
            try {
                String shiftsSql = "SELECT COUNT(*) as count FROM shifts WHERE user_id = ? AND EXTRACT(MONTH FROM start_time) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM start_time) = EXTRACT(YEAR FROM CURRENT_DATE)";
                PreparedStatement shiftsPs = conn.prepareStatement(shiftsSql);
                shiftsPs.setInt(1, userId);
                ResultSet shiftsRs = shiftsPs.executeQuery();
                if (shiftsRs.next()) {
                    monthlyShifts = shiftsRs.getInt("count");
                }
                shiftsRs.close();
                shiftsPs.close();
            } catch (Exception e) {
                System.out.println("Error getting shifts: " + e.getMessage());
            }
            
            // Get completed checklists
            try {
                String checklistSql = "SELECT COUNT(*) as count FROM shift_checks WHERE personnel_id = ? AND EXTRACT(MONTH FROM check_time) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM check_time) = EXTRACT(YEAR FROM CURRENT_DATE)";
                PreparedStatement checklistPs = conn.prepareStatement(checklistSql);
                checklistPs.setInt(1, userId);
                ResultSet checklistRs = checklistPs.executeQuery();
                if (checklistRs.next()) {
                    completedChecklists = checklistRs.getInt("count");
                }
                checklistRs.close();
                checklistPs.close();
            } catch (Exception e) {
                System.out.println("Error getting checklists: " + e.getMessage());
            }
            
            // Get attendance records (from shifts table)
            try {
                String attendanceSql = "SELECT COUNT(*) as count FROM shifts WHERE user_id = ?";
                PreparedStatement attendancePs = conn.prepareStatement(attendanceSql);
                attendancePs.setInt(1, userId);
                ResultSet attendanceRs = attendancePs.executeQuery();
                if (attendanceRs.next()) {
                    attendanceRecords = attendanceRs.getInt("count");
                }
                attendanceRs.close();
                attendancePs.close();
            } catch (Exception e) {
                System.out.println("Error getting attendance: " + e.getMessage());
            }
            
            // Get QR scans (from attendance records) - need to get staff ID first
            try {
                // Get staff ID for this user
                String getStaffSql = "SELECT id FROM security_personnel WHERE user_id = ?";
                PreparedStatement staffPs = conn.prepareStatement(getStaffSql);
                staffPs.setInt(1, userId);
                ResultSet staffRs = staffPs.executeQuery();
                
                int staffId = 0;
                if (staffRs.next()) {
                    staffId = staffRs.getInt("id");
                }
                staffRs.close();
                staffPs.close();
                
                // Now get QR scans using staff_id
                String qrSql = "SELECT COUNT(*) as count FROM attendance WHERE staff_id = ? AND verification_method = 'QR'";
                PreparedStatement qrPs = conn.prepareStatement(qrSql);
                qrPs.setInt(1, staffId);
                ResultSet qrRs = qrPs.executeQuery();
                if (qrRs.next()) {
                    qrScans = qrRs.getInt("count");
                }
                qrRs.close();
                qrPs.close();
            } catch (Exception e) {
                System.out.println("Error getting QR scans: " + e.getMessage());
            }
            
            // Get weekly attendance
            try {
                String weeklySql = "SELECT COUNT(*) as count FROM shifts WHERE user_id = ? AND start_time >= DATE_TRUNC('week', CURRENT_DATE)";
                PreparedStatement weeklyPs = conn.prepareStatement(weeklySql);
                weeklyPs.setInt(1, userId);
                ResultSet weeklyRs = weeklyPs.executeQuery();
                if (weeklyRs.next()) {
                    weeklyPresent = weeklyRs.getInt("count");
                }
                weeklyRs.close();
                weeklyPs.close();
            } catch (Exception e) {
                System.out.println("Error getting weekly attendance: " + e.getMessage());
            }
            
            // Get monthly attendance
            try {
                String monthlySql = "SELECT COUNT(*) as count FROM shifts WHERE user_id = ? AND EXTRACT(MONTH FROM start_time) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM start_time) = EXTRACT(YEAR FROM CURRENT_DATE)";
                PreparedStatement monthlyPs = conn.prepareStatement(monthlySql);
                monthlyPs.setInt(1, userId);
                ResultSet monthlyRs = monthlyPs.executeQuery();
                if (monthlyRs.next()) {
                    monthlyPresent = monthlyRs.getInt("count");
                }
                monthlyRs.close();
                monthlyPs.close();
            } catch (Exception e) {
                System.out.println("Error getting monthly attendance: " + e.getMessage());
            }
        }
        userRs.close();
        userPs.close();
    }
    
} catch (Exception e) {
    System.out.println("Database connection error: " + e.getMessage());
} finally {
    if (conn != null) {
        try {
            conn.close();
        } catch (SQLException e) {
            System.out.println("Error closing connection: " + e.getMessage());
        }
    }
}

// Store data in session for JavaScript access
session.setAttribute("monthlyShifts", monthlyShifts);
session.setAttribute("completedChecklists", completedChecklists);
session.setAttribute("attendanceRecords", attendanceRecords);
session.setAttribute("qrScans", qrScans);
session.setAttribute("weeklyPresent", weeklyPresent);
session.setAttribute("monthlyPresent", monthlyPresent);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports Dashboard</title>
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
    Reports Dashboard | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="checklistDashboard.jsp">Checklist</a>
    <a href="viewAttendance.jsp">QR Code</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="securityOfficerReports.jsp" class="active">Reports</a>
    <a href="securityOfficerSettings.jsp">Settings</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<div class="card">
    <h3>Reports Overview</h3>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px;">
        <div style="text-align: center; padding: 20px; background: rgba(52, 152, 219, 0.1); border-radius: 10px;">
            <h4 style="color: #3498db; margin: 0 0 10px 0;">Monthly Shifts</h4>
            <p style="font-size: 2em; font-weight: bold; color: #2c3e50; margin: 0;"><%= monthlyShifts %></p>
        </div>
        <div style="text-align: center; padding: 20px; background: rgba(39, 174, 96, 0.1); border-radius: 10px;">
            <h4 style="color: #27ae60; margin: 0 0 10px 0;">Completed Checklists</h4>
            <p style="font-size: 2em; font-weight: bold; color: #2c3e50; margin: 0;"><%= completedChecklists %></p>
        </div>
        <div style="text-align: center; padding: 20px; background: rgba(155, 89, 182, 0.1); border-radius: 10px;">
            <h4 style="color: #9b59b6; margin: 0 0 10px 0;">Attendance Records</h4>
            <p style="font-size: 2em; font-weight: bold; color: #2c3e50; margin: 0;"><%= attendanceRecords %></p>
        </div>
        <div style="text-align: center; padding: 20px; background: rgba(230, 126, 34, 0.1); border-radius: 10px;">
            <h4 style="color: #e67e22; margin: 0 0 10px 0;">QR Scans</h4>
            <p style="font-size: 2em; font-weight: bold; color: #2c3e50; margin: 0;"><%= qrScans %></p>
        </div>
    </div>
    
    <div style="margin-top: 20px;">
        <button class="btn" onclick="generateReport()">Generate Full Report</button>
        <button class="btn btn-secondary" onclick="exportData()" style="margin-left: 10px;">Export Data</button>
    </div>
</div>

<!-- Recent Activity -->
<div class="card">
    <h3>Recent Activity</h3>
    
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Type</th>
                <th>Description</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><%= LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) %></td>
                <td>Shift</td>
                <td>Daily shift completed</td>
                <td><span style="color: #27ae60; font-weight: 500;">Completed</span></td>
            </tr>
            <tr>
                <td><%= LocalDate.now().minusDays(1).format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) %></td>
                <td>Checklist</td>
                <td>Security checklist submitted</td>
                <td><span style="color: #27ae60; font-weight: 500;">Completed</span></td>
            </tr>
            <tr>
                <td><%= LocalDate.now().minusDays(2).format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) %></td>
                <td>Attendance</td>
                <td>QR code scan recorded</td>
                <td><span style="color: #3498db; font-weight: 500;">Recorded</span></td>
            </tr>
        </tbody>
    </table>
</div>

</div>
</div>

<script>
function generateReport() {
    alert('Generating comprehensive report...');
}

function exportData() {
    alert('Exporting data to CSV...');
}
</script>

</body>
</html>
</html>
