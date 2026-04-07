<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="config.SimpleDatabaseConfig" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Clear Fingerprints & Generate QR Codes</title>
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

.main {
    flex:1;
    padding:20px;
}

.management-container {
    max-width:1000px;
    margin:0 auto;
    background:white;
    padding:30px;
    border-radius:15px;
    box-shadow:0 4px 20px rgba(0,0,0,0.1);
}

.section {
    margin:20px 0;
    padding:20px;
    background: #f8f9fa;
    border-radius:10px;
    border:1px solid #e9ecef;
}

.btn {
    padding:12px 24px;
    border:none;
    background:#3498db;
    color:white;
    border-radius:8px;
    cursor:pointer;
    font-size:16px;
    margin:5px;
}

.btn-danger {
    background:#e74c3c;
}

.btn-success {
    background:#27ae60;
}

.btn-warning {
    background:#f39c12;
}

.btn-info {
    background:#17a2b8;
}

.btn:hover {
    opacity:0.9;
}

.status-message {
    padding:15px;
    border-radius:10px;
    margin-bottom:20px;
    display:none;
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

.stats {
    background:#2c3e50;
    color:white;
    padding:15px;
    border-radius:8px;
    margin:10px 0;
}

.stats h3 {
    margin:0 0 10px 0;
}

.stats-grid {
    display:grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap:15px;
}

.stat-item {
    background:rgba(255,255,255,0.1);
    padding:15px;
    border-radius:8px;
    text-align:center;
}

.stat-number {
    font-size:24px;
    font-weight:bold;
    color:#3498db;
}

.stat-label {
    font-size:14px;
    color:#ecf0f1;
    margin-top:5px;
}

.loading {
    text-align:center;
    padding:20px;
    font-style:italic;
    color:#6c757d;
}
</style>
</head>
<body>

<div class="navbar">
    Clear Fingerprints & Generate QR Codes | Welcome <%= session.getAttribute("username") %>
</div>

<div class="container">

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="personnelDashboard.jsp">Dashboard</a>
    <a href="attendance.jsp">Attendance</a>
    <a href="staffRegistration.jsp">Staff Registration</a>
    <a href="Logout">Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<div class="management-container">

<h2>🗑️ Clear Fingerprints & Generate QR Codes</h2>

<!-- Status Messages -->
<div id="statusMessage" class="status-message"></div>

<!-- Database Statistics -->
<div class="section">
    <h3>📊 Current Database Status</h3>
    
    <%
    Connection con = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        con = SimpleDatabaseConfig.getSimpleConnection();
        stmt = con.createStatement();
        
        // Count total staff
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM staff_registration");
        int totalStaff = 0;
        if (rs.next()) {
            totalStaff = rs.getInt("total");
        }
        rs.close();
        
        // Count staff with fingerprints
        rs = stmt.executeQuery("SELECT COUNT(*) as with_fingerprint FROM staff_registration WHERE fingerprint_data IS NOT NULL AND fingerprint_data != ''");
        int withFingerprints = 0;
        if (rs.next()) {
            withFingerprints = rs.getInt("with_fingerprint");
        }
        rs.close();
        
        // Count staff with QR codes
        rs = stmt.executeQuery("SELECT COUNT(*) as with_qr FROM staff_registration WHERE qr_code IS NOT NULL AND qr_code != ''");
        int withQRCodes = 0;
        if (rs.next()) {
            withQRCodes = rs.getInt("with_qr");
        }
        rs.close();
        
        // Count staff ready for QR generation
        int readyForQR = totalStaff - withQRCodes;
        
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (con != null) con.close();
        } catch(Exception e) {
            // Ignore cleanup errors
        }
    }
    %>
    
    <div class="stats-grid">
        <div class="stat-item">
            <div class="stat-number"><%= totalStaff %></div>
            <div class="stat-label">Total Staff</div>
        </div>
        <div class="stat-item">
            <div class="stat-number"><%= withFingerprints %></div>
            <div class="stat-label">With Fingerprints</div>
        </div>
        <div class="stat-item">
            <div class="stat-number"><%= withQRCodes %></div>
            <div class="stat-label">With QR Codes</div>
        </div>
        <div class="stat-item">
            <div class="stat-number"><%= readyForQR %></div>
            <div class="stat-label">Ready for QR</div>
        </div>
    </div>
</div>

<!-- Action Buttons -->
<div class="section">
    <h3>🔧 Management Actions</h3>
    
    <form method="post">
        <button type="submit" name="action" value="clear_fingerprints" class="btn btn-danger">
            🗑️ Clear All Fingerprints
        </button>
        
        <button type="submit" name="action" value="clear_qr" class="btn btn-warning">
            🗑️ Clear All QR Codes
        </button>
        
        <button type="submit" name="action" value="clear_all" class="btn btn-danger">
            🗑️ Clear All Data (Reset)
        </button>
        
        <button type="submit" name="action" value="generate_qr" class="btn btn-success">
            📱 Generate QR Codes for All Staff
        </button>
    </form>
</div>

<!-- Process Results -->
<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    Connection con2 = null;
    Statement stmt2 = null;
    ResultSet rs2 = null;
    
    try {
        con2 = SimpleDatabaseConfig.getSimpleConnection();
        stmt2 = con2.createStatement();
        
        if ("clear_fingerprints".equals(action)) {
            // Clear all fingerprint data
            int cleared = stmt2.executeUpdate("UPDATE staff_registration SET fingerprint_data = NULL WHERE fingerprint_data IS NOT NULL");
            out.println("<div class='status-message status-success'>✅ Cleared fingerprint data from " + cleared + " staff records</div>");
            
        } else if ("clear_qr".equals(action)) {
            // Clear all QR codes
            int cleared = stmt2.executeUpdate("UPDATE staff_registration SET qr_code = NULL WHERE qr_code IS NOT NULL");
            out.println("<div class='status-message status-success'>✅ Cleared QR codes from " + cleared + " staff records</div>");
            
        } else if ("clear_all".equals(action)) {
            // Clear all data
            int cleared = stmt2.executeUpdate("UPDATE staff_registration SET fingerprint_data = NULL, qr_code = NULL WHERE fingerprint_data IS NOT NULL OR qr_code IS NOT NULL");
            out.println("<div class='status-message status-success'>✅ Cleared all fingerprint and QR data from " + cleared + " staff records</div>");
            
        } else if ("generate_qr".equals(action)) {
            // Generate QR codes for all staff
            rs2 = stmt2.executeQuery("SELECT id, employee_id, first_name, last_name FROM staff_registration ORDER BY employee_id");
            int generated = 0;
            
            while (rs2.next()) {
                int staffId = rs2.getInt("id");
                String employeeId = rs2.getString("employee_id");
                String firstName = rs2.getString("first_name");
                String lastName = rs2.getString("last_name");
                
                // Generate QR code value
                String qrValue = "STAFF_" + staffId + "_" + employeeId + "_" + 
                                java.util.Base64.getEncoder().encodeToString((firstName + " " + lastName).getBytes());
                
                // Update QR code in database
                Statement updateStmt = con2.createStatement();
                updateStmt.executeUpdate("UPDATE staff_registration SET qr_code = '" + qrValue + "' WHERE id = " + staffId);
                updateStmt.close();
                
                generated++;
            }
            rs2.close();
            
            out.println("<div class='status-message status-success'>✅ Generated QR codes for " + generated + " staff members</div>");
            
        }
        
    } catch(Exception e) {
        out.println("<div class='status-message status-error'>❌ Error: " + e.getMessage() + "</div>");
    } finally {
        try {
            if (rs2 != null) rs2.close();
            if (stmt2 != null) stmt2.close();
            if (con2 != null) con2.close();
        } catch(Exception e) {
            // Ignore cleanup errors
        }
    }
}
%>

<!-- Navigation -->
<div class="section">
    <h3>🔗 Navigation</h3>
    <p><a href="staffRegistration.jsp" class="btn btn-info">📝 Staff Registration</a></p>
    <p><a href="testStaffFingerprint.jsp" class="btn btn-info">🔍 Test Fingerprint</a></p>
    <p><a href="clearStaffData.jsp" class="btn btn-info">🗑️ Clear Staff Data</a></p>
    <p><a href="index.jsp" class="btn">🏠 Login</a></p>
</div>

</div>

</div>

</body>
</html>
