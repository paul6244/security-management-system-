<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="config.DatabaseConfig" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="servlets.GetFilteredReports" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Simple Reports Test</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
table { border-collapse: collapse; width: 100%; margin: 20px 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
.status-incident { color: #e74c3c; font-weight: bold; }
.status-ok { color: #27ae60; }
</style>
</head>
<body>

<h1>Simple Reports Test - Direct JSP</h1>

<%
try {
    Connection conn = DatabaseConfig.getConnection();
    
    if (conn == null) {
        out.println("<p style='color: red;'>ERROR: Database connection is null</p>");
        return;
    }
    
    // Direct query to get incident records
    String sql = "SELECT sc.id, sc.status, sc.reason, sc.check_time, u.username, b.name as branch, ci.item_name " +
                 "FROM shift_checks sc " +
                 "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                 "JOIN users u ON sp.user_id = u.id " +
                 "JOIN branches b ON sp.branch_id = b.id " +
                 "JOIN checklist_items ci ON sc.item_id = ci.id " +
                 "WHERE (sc.status='NOT_OK' OR sc.status='Not ok') " +
                 "ORDER BY sc.check_time DESC " +
                 "LIMIT 10";
    
    PreparedStatement ps = conn.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
    
    out.println("<h2>Incident Records (Direct JSP)</h2>");
    out.println("<table>");
    out.println("<tr><th>Date/Time</th><th>Officer</th><th>Branch</th><th>Item</th><th>Status</th><th>Reason</th></tr>");
    
    boolean hasRecords = false;
    while (rs.next()) {
        hasRecords = true;
        String status = rs.getString("status");
        boolean isIncident = status.equals("NOT_OK") || status.equals("Not ok");
        String statusClass = isIncident ? "status-incident" : "status-ok";
        String statusText = isIncident ? "Not ok" : "OK";
        String reason = rs.getString("reason");
        if (reason == null) reason = "N/A";
        
        // Format date
        SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        SimpleDateFormat outputFormat = new SimpleDateFormat("MMM dd, yyyy, h:mm a");
        String formattedDate = outputFormat.format(rs.getTimestamp("check_time"));
        
        out.println("<tr>");
        out.println("<td>" + formattedDate + "</td>");
        out.println("<td>" + rs.getString("username") + "</td>");
        out.println("<td>" + rs.getString("branch") + "</td>");
        out.println("<td>" + rs.getString("item_name") + "</td>");
        out.println("<td><span class='" + statusClass + "'>" + statusText + "</span></td>");
        out.println("<td>" + reason + "</td>");
        out.println("</tr>");
    }
    
    if (!hasRecords) {
        out.println("<tr><td colspan='6' style='text-align: center; color: #666;'>No incident records found</td></tr>");
    }
    
    out.println("</table>");
    rs.close();
    ps.close();
    conn.close();
    
} catch (Exception e) {
    out.println("<p style='color: red;'>ERROR: " + e.getMessage() + "</p>");
    e.printStackTrace(new java.io.PrintWriter(out));
}
%>

<br><br>
<h2>Test AJAX Call</h2>
<button onclick="testAJAX()">Test AJAX Call</button>
<div id="ajaxResult"></div>

<script>
function testAJAX() {
    const resultDiv = document.getElementById('ajaxResult');
    resultDiv.innerHTML = '<p>Testing AJAX...</p>';
    
    console.log('Starting AJAX test...');
    
    fetch('GetFilteredReports?status=all')
        .then(response => {
            console.log('Response status:', response.status);
            console.log('Response headers:', response.headers);
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            console.log('Data received:', data);
            console.log('Data type:', typeof data);
            console.log('Data length:', data ? data.length : 'null/undefined');
            
            if (data && data.length > 0) {
                let html = '<table border="1"><tr><th>Date/Time</th><th>Officer</th><th>Branch</th><th>Item</th><th>Status</th><th>Reason</th></tr>';
                
                data.forEach(report => {
                    console.log('Processing report:', report);
                    html += '<tr>';
                    html += '<td>' + report.checkTime + '</td>';
                    html += '<td>' + report.username + '</td>';
                    html += '<td>' + report.branch + '</td>';
                    html += '<td>' + report.itemName + '</td>';
                    html += '<td>' + report.status + '</td>';
                    html += '<td>' + (report.reason || 'N/A') + '</td>';
                    html += '</tr>';
                });
                
                html += '</table>';
                resultDiv.innerHTML = html;
            } else {
                resultDiv.innerHTML = '<p>No data received</p>';
            }
        })
        .catch(error => {
            console.error('Error:', error);
            resultDiv.innerHTML = '<p style="color: red;">Error: ' + error.message + '</p>';
        });
}
</script>

<br><br>
<a href="reports.jsp">← Back to Reports</a>

</body>
</html>
