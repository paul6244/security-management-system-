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
<title>Fix Item Names</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
table { border-collapse: collapse; width: 100%; margin: 20px 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
.success { color: green; }
.error { color: red; }
</style>
</head>
<body>

<h1>Fix Item Names - Update NULL item_ids</h1>

<%
try {
    Connection conn = DatabaseConfig.getConnection();
    
    if (conn == null) {
        out.println("<p class='error'>ERROR: Database connection is null</p>");
        return;
    }
    
    out.println("<h2>Current Shift Checks with NULL item_ids</h2>");
    
    // First, show current problematic records
    String checkSql = "SELECT sc.id, sc.item_id, u.username, b.name as branch, sc.status " +
                     "FROM shift_checks sc " +
                     "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                     "JOIN users u ON sp.user_id = u.id " +
                     "JOIN branches b ON sp.branch_id = b.id " +
                     "WHERE sc.item_id IS NULL OR sc.item_id = 0 " +
                     "ORDER BY sc.check_time DESC";
    PreparedStatement checkPs = conn.prepareStatement(checkSql);
    ResultSet checkRs = checkPs.executeQuery();
    
    boolean hasNullItems = false;
    out.println("<table>");
    out.println("<tr><th>ID</th><th>Item ID</th><th>Username</th><th>Branch</th><th>Status</th><th>Action</th></tr>");
    
    while (checkRs.next()) {
        hasNullItems = true;
        out.println("<tr>");
        out.println("<td>" + checkRs.getInt("id") + "</td>");
        out.println("<td>" + (checkRs.getObject("item_id") != null ? checkRs.getInt("item_id") : "NULL") + "</td>");
        out.println("<td>" + checkRs.getString("username") + "</td>");
        out.println("<td>" + checkRs.getString("branch") + "</td>");
        out.println("<td>" + checkRs.getString("status") + "</td>");
        out.println("<td><button onclick='updateItem(" + checkRs.getInt("id") + ")'>Fix</button></td>");
        out.println("</tr>");
    }
    
    if (!hasNullItems) {
        out.println("<tr><td colspan='6' style='text-align: center; color: green;'>No NULL item_ids found!</td></tr>");
    }
    
    out.println("</table>");
    checkRs.close();
    checkPs.close();
    
    conn.close();
    
} catch (Exception e) {
    out.println("<p class='error'>ERROR: " + e.getMessage() + "</p>");
    e.printStackTrace(new java.io.PrintWriter(out));
}
%>

<script>
function updateItem(shiftCheckId) {
    if (confirm('Update this record to use Building Access Control (item_id=4)?')) {
        fetch('UpdateItemId?shiftCheckId=' + shiftCheckId + '&itemId=4')
            .then(response => response.text())
            .then(result => {
                if (result.includes('success')) {
                    alert('Item ID updated successfully!');
                    location.reload();
                } else {
                    alert('Error: ' + result);
                }
            })
            .catch(error => {
                alert('Error: ' + error);
            });
    }
}
</script>

<br><br>
<a href="itemNameDebug.jsp">← Back to Debug</a>
<a href="reports.jsp">← Back to Reports</a>

</body>
</html>
