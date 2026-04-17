<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.sql.*" %>
<%@ page import="config.DatabaseConfig" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Officer Reports</title>
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
            min-height: calc(100vh - 80px);
        }

        .sidebar {
            width: 250px;
            background: rgba(255, 255, 255, 0.95);
            padding: 2rem 0;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
        }

        .sidebar a {
            display: block;
            padding: 1rem 2rem;
            color: #333;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .sidebar a:hover {
            background: rgba(103, 126, 234, 0.1);
            color: #677eea;
        }

        .sidebar a.active {
            background: #677eea;
            color: white;
        }

        .main {
            flex: 1;
            padding: 2rem;
            overflow-y: auto;
        }

        .reports-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .report-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .report-card h3 {
            color: #333;
            margin-bottom: 1.5rem;
            font-size: 1.3rem;
        }

        .report-section {
            margin-bottom: 2rem;
        }

        .report-section h4 {
            color: #677eea;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 10px;
            text-align: center;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        .report-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .report-table th,
        .report-table td {
            padding: 0.75rem;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        .report-table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #333;
        }

        .report-table tr:hover {
            background: #f8f9fa;
        }

        .filter-section {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 2rem;
        }

        .filter-group {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            align-items: center;
        }

        .filter-group label {
            font-weight: 500;
            color: #333;
        }

        .filter-group input,
        .filter-group select {
            padding: 0.5rem;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 0.9rem;
        }

        .btn {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: #677eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5a6fd8;
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background: #5a6268;
        }

        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
        }

        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }

        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                padding: 1rem 0;
            }

            .main {
                padding: 1rem;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .filter-group {
                flex-direction: column;
                align-items: stretch;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Security Officer Reports</h1>
    </div>

    <div class="container">
        <div class="sidebar">
            <a href="personnelDashboard.jsp">Dashboard</a>
            <a href="personnelDashboard.jsp">Checklist</a>
            <a href="viewAttendance.jsp">QR Code</a>
            <a href="staffRegistration.jsp">Staff Registration</a>
            <a href="securityOfficerReports.jsp" class="active">Reports</a>
            <a href="securityOfficerSettings.jsp">Settings</a>
            <a href="Logout">Logout</a>
        </div>

        <div class="main">
            <div class="reports-container">
                <div class="alert alert-info">
                    <strong>Security Officer Reports:</strong> View your personal reports and activities. These reports are specific to your role and show only your assigned data.
                </div>

                <!-- Personal Statistics -->
                <div class="report-card">
                    <h3>My Personal Statistics</h3>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-number" id="myShifts">0</div>
                            <div class="stat-label">My Shifts This Month</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number" id="myChecklists">0</div>
                            <div class="stat-label">Checklists Completed</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number" id="myAttendance">0</div>
                            <div class="stat-label">My Attendance Records</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number" id="myQRScans">0</div>
                            <div class="stat-label">QR Code Scans</div>
                        </div>
                    </div>
                </div>

                <!-- My Recent Activities -->
                <div class="report-card">
                    <h3>My Recent Activities</h3>
                    <div class="filter-section">
                        <div class="filter-group">
                            <label>Date Range:</label>
                            <input type="date" id="startDate" value="">
                            <span>to</span>
                            <input type="date" id="endDate" value="">
                            <button class="btn btn-primary" onclick="filterActivities()">Filter</button>
                            <button class="btn btn-secondary" onclick="resetFilters()">Reset</button>
                        </div>
                    </div>
                    
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Activity Type</th>
                                <th>Description</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="activitiesTableBody">
                            <tr>
                                <td colspan="4">Loading activities...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- My Attendance Report -->
                <div class="report-card">
                    <h3>My Attendance Report</h3>
                    <div class="report-section">
                        <h4>Attendance Summary</h4>
                        <table class="report-table">
                            <thead>
                                <tr>
                                    <th>Period</th>
                                    <th>Days Present</th>
                                    <th>Days Absent</th>
                                    <th>Attendance Rate</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>This Week</td>
                                    <td id="weekPresent">0</td>
                                    <td id="weekAbsent">0</td>
                                    <td id="weekRate">0%</td>
                                </tr>
                                <tr>
                                    <td>This Month</td>
                                    <td id="monthPresent">0</td>
                                    <td id="monthAbsent">0</td>
                                    <td id="monthRate">0%</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- My Checklist Performance -->
                <div class="report-card">
                    <h3>My Checklist Performance</h3>
                    <div class="report-section">
                        <h4>Completion Rate</h4>
                        <table class="report-table">
                            <thead>
                                <tr>
                                    <th>Checklist Type</th>
                                    <th>Total Items</th>
                                    <th>Completed</th>
                                    <th>Completion Rate</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Daily Security</td>
                                    <td id="dailyTotal">0</td>
                                    <td id="dailyCompleted">0</td>
                                    <td id="dailyRate">0%</td>
                                </tr>
                                <tr>
                                    <td>Equipment Check</td>
                                    <td id="equipmentTotal">0</td>
                                    <td id="equipmentCompleted">0</td>
                                    <td id="equipmentRate">0%</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Load personal statistics
        function loadPersonalStats() {
            // Simulate loading personal statistics
            document.getElementById('myShifts').textContent = '12';
            document.getElementById('myChecklists').textContent = '45';
            document.getElementById('myAttendance').textContent = '18';
            document.getElementById('myQRScans').textContent = '23';
        }

        // Load activities
        function loadActivities() {
            const activities = [
                { date: '2026-04-17', type: 'Shift', description: 'Morning Shift - Gate Security', status: 'Completed' },
                { date: '2026-04-16', type: 'Checklist', description: 'Daily Security Checklist', status: 'Completed' },
                { date: '2026-04-16', type: 'QR Scan', description: 'Staff Attendance QR Code Scan', status: 'Completed' },
                { date: '2026-04-15', type: 'Shift', description: 'Evening Shift - Patrol', status: 'Completed' },
                { date: '2026-04-15', type: 'Checklist', description: 'Equipment Security Check', status: 'Completed' }
            ];

            const tbody = document.getElementById('activitiesTableBody');
            tbody.innerHTML = '';

            activities.forEach(activity => {
                const row = tbody.insertRow();
                row.innerHTML = `
                    <td>${activity.date}</td>
                    <td>${activity.type}</td>
                    <td>${activity.description}</td>
                    <td><span style="color: green;">${activity.status}</span></td>
                `;
            });
        }

        // Load attendance data
        function loadAttendanceData() {
            document.getElementById('weekPresent').textContent = '4';
            document.getElementById('weekAbsent').textContent = '1';
            document.getElementById('weekRate').textContent = '80%';
            document.getElementById('monthPresent').textContent = '16';
            document.getElementById('monthAbsent').textContent = '4';
            document.getElementById('monthRate').textContent = '80%';
        }

        // Load checklist data
        function loadChecklistData() {
            document.getElementById('dailyTotal').textContent = '10';
            document.getElementById('dailyCompleted').textContent = '8';
            document.getElementById('dailyRate').textContent = '80%';
            document.getElementById('equipmentTotal').textContent = '5';
            document.getElementById('equipmentCompleted').textContent = '4';
            document.getElementById('equipmentRate').textContent = '80%';
        }

        // Filter activities
        function filterActivities() {
            // Implement filtering logic here
            loadActivities(); // For now, just reload
        }

        // Reset filters
        function resetFilters() {
            document.getElementById('startDate').value = '';
            document.getElementById('endDate').value = '';
            loadActivities();
        }

        // Initialize page
        window.onload = function() {
            loadPersonalStats();
            loadActivities();
            loadAttendanceData();
            loadChecklistData();
            
            // Set default dates
            const today = new Date();
            const lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
            document.getElementById('startDate').value = lastWeek.toISOString().split('T')[0];
            document.getElementById('endDate').value = today.toISOString().split('T')[0];
        };
    </script>
</body>
</html>
