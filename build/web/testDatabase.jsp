<%@ page import="java.sql.*" %>
<%
if(session.getAttribute("username")==null){
    response.sendRedirect("index.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Test Database Structure</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .result { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }
        .btn { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; margin: 5px; text-decoration: none; display: inline-block; }
    </style>
</head>
<body>
    <h1>Test Database Structure</h1>
    
    <div class="result">
        <h3>shift_checks Table Structure</h3>
        <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
            
            // Show table structure
            String structureSql = "DESCRIBE shift_checks";
            PreparedStatement structurePs = con.prepareStatement(structureSql);
            ResultSet structureRs = structurePs.executeQuery();
            
            out.println("<table>");
            out.println("<tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th></tr>");
            
            while(structureRs.next()) {
                out.println("<tr>");
                out.println("<td>" + structureRs.getString("Field") + "</td>");
                out.println("<td>" + structureRs.getString("Type") + "</td>");
                out.println("<td>" + structureRs.getString("Null") + "</td>");
                out.println("<td>" + structureRs.getString("Key") + "</td>");
                out.println("</tr>");
            }
            
            out.println("</table>");
            structureRs.close();
            structurePs.close();
            
            // Test simple insert
            out.println("<h3>Test Simple Insert</h3>");
            String testSql = "INSERT INTO shift_checks(personnel_id,item_id,status,reason,check_time) VALUES(10,1,'OK','Test',NOW())";
            PreparedStatement testPs = con.prepareStatement(testSql);
            
            try {
                testPs.executeUpdate();
                out.println("<div class='success'>✅ Simple insert works! Database structure is correct.</div>");
                
                // Clean up test record
                String deleteSql = "DELETE FROM shift_checks WHERE reason='Test'";
                PreparedStatement deletePs = con.prepareStatement(deleteSql);
                deletePs.executeUpdate();
                deletePs.close();
                
            } catch(Exception e) {
                out.println("<div class='error'>❌ Insert failed: " + e.getMessage() + "</div>");
            }
            
            testPs.close();
            con.close();
            
        } catch(Exception e) {
            out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
        }
        %>
    </div>
    
    <div class="result">
        <h3>Next Steps</h3>
        <p>If the simple insert works above, then:</p>
        <ol>
            <li>Restart your server to load the updated SaveChecklist servlet</li>
            <li>Try submitting the checklist again</li>
            <li>It should work with the fixed SQL (no check_date column)</li>
        </ol>
        
        <div style="margin-top: 20px;">
            <a href="personnelDashboard.jsp" class="btn">👤 Personnel Dashboard</a>
            <a href="reports.jsp" class="btn">📋 Admin Reports</a>
        </div>
    </div>
</body>
</html>
