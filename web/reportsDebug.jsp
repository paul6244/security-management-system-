<%@ page import="java.sql.*" %>
<%@ page import="model.Mymodel" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="config.DatabaseConfig" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Reports Debug</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
table { border-collapse: collapse; width: 100%; margin: 20px 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
.success { color: green; }
.error { color: red; }
.info { color: blue; }
</style>
</head>
<body>

<h1>Reports Debug - Direct Database Query</h1>

<%
try {
    Connection conn = DatabaseConfig.getConnection();
    
    if (conn == null) {
        out.println("<p class='error'>ERROR: Database connection is null</p>");
        return;
    }
    
    out.println("<p class='success'>SUCCESS: Database connection established</p>");
    
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
    
    out.println("<h2>Incident Records (Direct Query)</h2>");
    out.println("<table>");
    out.println("<tr><th>ID</th><th>Username</th><th>Branch</th><th>Item</th><th>Status</th><th>Reason</th><th>Time</th></tr>");
    
    boolean hasRecords = false;
    while (rs.next()) {
        hasRecords = true;
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id") + "</td>");
        out.println("<td>" + rs.getString("username") + "</td>");
        out.println("<td>" + rs.getString("branch") + "</td>");
        out.println("<td>" + rs.getString("item_name") + "</td>");
        out.println("<td>" + rs.getString("status") + "</td>");
        out.println("<td>" + (rs.getString("reason") != null ? rs.getString("reason") : "") + "</td>");
        out.println("<td>" + rs.getTimestamp("check_time") + "</td>");
        out.println("</tr>");
    }
    
    if (!hasRecords) {
        out.println("<tr><td colspan='7' class='info'>No incident records found</td></tr>");
    }
    
    out.println("</table>");
    rs.close();
    ps.close();
    
    // Now test the GetFilteredReports servlet directly
    out.println("<h2>Test GetFilteredReports Servlet</h2>");
    out.println("<button onclick='testServlet()'>Test Servlet Call</button>");
    out.println("<div id='servletResult'></div>");
    
    conn.close();
    
} catch (Exception e) {
    out.println("<p class='error'>ERROR: " + e.getMessage() + "</p>");
    out.println("<pre>");
    e.printStackTrace(new java.io.PrintWriter(out));
    out.println("</pre>");
}
%>

<script>
function testServlet() {
    const resultDiv = document.getElementById('servletResult');
    resultDiv.innerHTML = '<p>Testing servlet...</p>';
    
    fetch('GetFilteredReports')
        .then(response => {
            console.log('Response status:', response.status);
            console.log('Response headers:', response.headers);
            return response.text();
        })
        .then(data => {
            console.log('Raw response:', data);
            resultDiv.innerHTML = '<h3>Servlet Response:</h3><pre>' + data + '</pre>';
        })
        .catch(error => {
            console.error('Error:', error);
            resultDiv.innerHTML = '<p class="error">Error: ' + error.message + '</p>';
        });
}
</script>

<br><br>
<a href="reports.jsp">← Back to Reports</a>
<a href="personnelDashboard.jsp">← Personnel Dashboard</a>

</body>
</html>
