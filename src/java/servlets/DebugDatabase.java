package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import config.DatabaseConfig;

@WebServlet("/DebugDatabase")
public class DebugDatabase extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Database Debug</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println("table { border-collapse: collapse; width: 100%; margin: 20px 0; }");
        out.println("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        out.println("th { background-color: #f2f2f2; }");
        out.println(".success { color: green; }");
        out.println(".error { color: red; }");
        out.println(".info { color: blue; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        
        out.println("<h1>Database Debug Information</h1>");
        
        try {
            Connection conn = DatabaseConfig.getConnection();
            
            if (conn == null) {
                out.println("<p class='error'>ERROR: Database connection is null</p>");
                return;
            }
            
            out.println("<p class='success'>SUCCESS: Database connection established</p>");
            
            // Check checklist items
            out.println("<h2>Checklist Items</h2>");
            String sql = "SELECT id, item_name FROM checklist_items ORDER BY id";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            out.println("<table>");
            out.println("<tr><th>ID</th><th>Item Name</th></tr>");
            
            boolean hasItems = false;
            while (rs.next()) {
                hasItems = true;
                out.println("<tr>");
                out.println("<td>" + rs.getInt("id") + "</td>");
                out.println("<td>" + rs.getString("item_name") + "</td>");
                out.println("</tr>");
            }
            
            if (!hasItems) {
                out.println("<tr><td colspan='2' class='error'>No checklist items found in database</td></tr>");
            }
            
            out.println("</table>");
            rs.close();
            ps.close();
            
            // Check shift_checks (incidents)
            out.println("<h2>Shift Checks (Incidents)</h2>");
            String incidentSql = "SELECT sc.id, sc.status, sc.reason, sc.check_time, u.username, b.name as branch, ci.item_name " +
                               "FROM shift_checks sc " +
                               "JOIN security_personnel sp ON sc.personnel_id = sp.id " +
                               "JOIN users u ON sp.user_id = u.id " +
                               "JOIN branches b ON sp.branch_id = b.id " +
                               "JOIN checklist_items ci ON sc.item_id = ci.id " +
                               "ORDER BY sc.check_time DESC " +
                               "LIMIT 10";
            PreparedStatement incidentPs = conn.prepareStatement(incidentSql);
            ResultSet incidentRs = incidentPs.executeQuery();
            
            out.println("<table>");
            out.println("<tr><th>ID</th><th>Username</th><th>Branch</th><th>Item</th><th>Status</th><th>Reason</th><th>Time</th></tr>");
            
            boolean hasIncidents = false;
            while (incidentRs.next()) {
                hasIncidents = true;
                out.println("<tr>");
                out.println("<td>" + incidentRs.getInt("id") + "</td>");
                out.println("<td>" + incidentRs.getString("username") + "</td>");
                out.println("<td>" + incidentRs.getString("branch") + "</td>");
                out.println("<td>" + incidentRs.getString("item_name") + "</td>");
                out.println("<td>" + incidentRs.getString("status") + "</td>");
                out.println("<td>" + (incidentRs.getString("reason") != null ? incidentRs.getString("reason") : "") + "</td>");
                out.println("<td>" + incidentRs.getTimestamp("check_time") + "</td>");
                out.println("</tr>");
            }
            
            if (!hasIncidents) {
                out.println("<tr><td colspan='7' class='info'>No shift checks (incidents) found in database</td></tr>");
            }
            
            out.println("</table>");
            incidentRs.close();
            incidentPs.close();
            
            // Check users
            out.println("<h2>Users</h2>");
            String userSql = "SELECT id, username, email, role FROM users ORDER BY id";
            PreparedStatement userPs = conn.prepareStatement(userSql);
            ResultSet userRs = userPs.executeQuery();
            
            out.println("<table>");
            out.println("<tr><th>ID</th><th>Username</th><th>Email</th><th>Role</th></tr>");
            
            while (userRs.next()) {
                out.println("<tr>");
                out.println("<td>" + userRs.getInt("id") + "</td>");
                out.println("<td>" + userRs.getString("username") + "</td>");
                out.println("<td>" + userRs.getString("email") + "</td>");
                out.println("<td>" + userRs.getString("role") + "</td>");
                out.println("</tr>");
            }
            
            out.println("</table>");
            userRs.close();
            userPs.close();
            
            conn.close();
            
        } catch (Exception e) {
            out.println("<p class='error'>ERROR: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }
        
        out.println("<br><br>");
        out.println("<a href='personnelDashboard.jsp'>← Back to Personnel Dashboard</a>");
        out.println("<br><br>");
        out.println("<a href='reports.jsp'>← Go to Reports</a>");
        
        out.println("</body>");
        out.println("</html>");
    }
}
