<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="config.DatabaseConfig" %>

<%
String staffId = request.getParameter("staffId");
String date = request.getParameter("date");

String message = "";
String messageType = "success";

if (staffId != null && date != null && !staffId.isEmpty() && !date.isEmpty()) {
    try {
        int staffIdInt = Integer.parseInt(staffId);
        Connection conn = DatabaseConfig.getConnection();
        if(conn != null) {
            // Check if attendance already exists for today
            String checkSql = "SELECT COUNT(*) FROM attendance WHERE staff_id = ? AND DATE(check_in_time) = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, staffIdInt);
            checkStmt.setString(2, date);
            ResultSet checkRs = checkStmt.executeQuery();
            
            boolean attendanceExists = false;
            if(checkRs.next()) {
                attendanceExists = checkRs.getInt(1) > 0;
            }
            checkRs.close();
            checkStmt.close();
            
            if (!attendanceExists) {
                // Insert new attendance record
                String insertSql = "INSERT INTO attendance (staff_id, check_in_time, attendance_type) VALUES (?, CURRENT_TIMESTAMP, 'qr')";
                PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                insertStmt.setInt(1, staffIdInt);
                insertStmt.executeUpdate();
                insertStmt.close();
                
                message = "Attendance marked successfully for Staff ID: " + staffId + " on " + date;
            } else {
                message = "Attendance already marked for this staff member on " + date;
                messageType = "error";
            }
            
            conn.close();
        } else {
            message = "Database connection error";
            messageType = "error";
        }
    } catch(Exception e) {
        message = "Error marking attendance: " + e.getMessage();
        messageType = "error";
    }
} else {
    message = "Invalid parameters. Staff ID and date are required.";
    messageType = "error";
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mark Attendance</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            max-width: 600px;
            width: 100%;
            text-align: center;
        }
        
        .message {
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            font-size: 1.1rem;
        }
        
        .message.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .message.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
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
            text-decoration: none;
            display: inline-block;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }
        
        .staff-info {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Attendance Marked</h1>
        
        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <div class="staff-info">
            <strong>Staff ID:</strong> <%= staffId != null ? staffId : "N/A" %><br>
            <strong>Date:</strong> <%= date != null ? date : "N/A" %><br>
            <strong>Time:</strong> <%= new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date()) %>
        </div>
        
        <div style="margin-top: 2rem;">
            <a href="viewAttendance.jsp" class="btn">Generate Another QR Code</a>
            <a href="personnelDashboard.jsp" class="btn">Back to Dashboard</a>
        </div>
    </div>
</body>
</html>
