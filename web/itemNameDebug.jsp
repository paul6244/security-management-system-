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
<title>Item Name Debug</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
table { border-collapse: collapse; width: 100%; margin: 20px 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
</style>
</head>
<body>

<h1>Item Name Debug - Database Investigation</h1>

<%
try {
    Connection conn = DatabaseConfig.getConnection();
    
    if (conn == null) {
        out.println("<p style='color: red;'>ERROR: Database connection is null</p>");
        return;
    }
    
    out.println("<h2>All Checklist Items in Database</h2>");
    String checklistSql = "SELECT id, item_name FROM checklist_items ORDER BY id";
    PreparedStatement checklistPs = conn.prepareStatement(checklistSql);
    ResultSet checklistRs = checklistPs.executeQuery();
    
    out.println("<table>");
    out.println("<tr><th>ID</th><th>Item Name</th></tr>");
    
    while (checklistRs.next()) {
        out.println("<tr>");
        out.println("<td>" + checklistRs.getInt("id") + "</td>");
        out.println("<td>" + checklistRs.getString("item_name") + "</td>");
        out.println("</tr>");
    }
    
    out.println("</table>");
    checklistRs.close();
    checklistPs.close();
    
    out.println("<h2>Shift Checks with Item Names</h2>");
    String shiftCheckSql = "SELECT sc.id, sc.item_id, ci.item_name, u.username, b.name as branch, sc.status " +
                       "FROM shift_checks sc " +
                       "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                       "JOIN users u ON sp.user_id = u.id " +
                       "JOIN branches b ON sp.branch_id = b.id " +
                       "LEFT JOIN checklist_items ci ON sc.item_id = ci.id " +
                       "ORDER BY sc.check_time DESC " +
                       "LIMIT 10";
    PreparedStatement shiftCheckPs = conn.prepareStatement(shiftCheckSql);
    ResultSet shiftCheckRs = shiftCheckPs.executeQuery();
    
    out.println("<table>");
    out.println("<tr><th>Shift ID</th><th>Item ID</th><th>Item Name</th><th>Username</th><th>Branch</th><th>Status</th></tr>");
    
    while (shiftCheckRs.next()) {
        out.println("<tr>");
        out.println("<td>" + shiftCheckRs.getInt("id") + "</td>");
        out.println("<td>" + (shiftCheckRs.getInt("item_id") != 0 ? shiftCheckRs.getInt("item_id") : "NULL") + "</td>");
        out.println("<td>" + (shiftCheckRs.getString("item_name") != null ? shiftCheckRs.getString("item_name") : "NULL") + "</td>");
        out.println("<td>" + shiftCheckRs.getString("username") + "</td>");
        out.println("<td>" + shiftCheckRs.getString("branch") + "</td>");
        out.println("<td>" + shiftCheckRs.getString("status") + "</td>");
        out.println("</tr>");
    }
    
    out.println("</table>");
    shiftCheckRs.close();
    shiftCheckPs.close();
    
    conn.close();
    
} catch (Exception e) {
    out.println("<p style='color: red;'>ERROR: " + e.getMessage() + "</p>");
    e.printStackTrace(new java.io.PrintWriter(out));
}
%>

<br><br>
<a href="reports.jsp">← Back to Reports</a>

</body>
</html>
