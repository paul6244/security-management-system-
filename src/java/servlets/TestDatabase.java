package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import config.DatabaseConfig;

@WebServlet("/TestDatabase")
public class TestDatabase extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<h2>Database Test Results</h2>");
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            out.println("<h3>✅ Database Connection: SUCCESS</h3>");
            
            // Check users table
            out.println("<h3>Users Table:</h3>");
            String userSql = "SELECT id, username FROM users LIMIT 5";
            PreparedStatement userPs = con.prepareStatement(userSql);
            ResultSet userRs = userPs.executeQuery();
            
            out.println("<table border='1'><tr><th>ID</th><th>Username</th></tr>");
            while(userRs.next()) {
                out.println("<tr><td>" + userRs.getInt("id") + "</td><td>" + userRs.getString("username") + "</td></tr>");
            }
            out.println("</table>");
            userRs.close();
            userPs.close();
            
            // Check security_personnel table
            out.println("<h3>Security Personnel Table:</h3>");
            String personnelSql = "SELECT id, user_id FROM security_personnel LIMIT 5";
            PreparedStatement personnelPs = con.prepareStatement(personnelSql);
            ResultSet personnelRs = personnelPs.executeQuery();
            
            out.println("<table border='1'><tr><th>ID</th><th>User ID</th></tr>");
            while(personnelRs.next()) {
                out.println("<tr><td>" + personnelRs.getInt("id") + "</td><td>" + personnelRs.getInt("user_id") + "</td></tr>");
            }
            out.println("</table>");
            personnelRs.close();
            personnelPs.close();
            
            // Check shift_checks table
            out.println("<h3>Shift Checks Table:</h3>");
            String shiftSql = "SELECT id, personnel_id, status, check_time FROM shift_checks ORDER BY check_time DESC LIMIT 10";
            PreparedStatement shiftPs = con.prepareStatement(shiftSql);
            ResultSet shiftRs = shiftPs.executeQuery();
            
            out.println("<table border='1'><tr><th>ID</th><th>Personnel ID</th><th>Status</th><th>Check Time</th></tr>");
            while(shiftRs.next()) {
                out.println("<tr><td>" + shiftRs.getInt("id") + "</td><td>" + shiftRs.getInt("personnel_id") + "</td><td>" + shiftRs.getString("status") + "</td><td>" + shiftRs.getTimestamp("check_time") + "</td></tr>");
            }
            out.println("</table>");
            shiftRs.close();
            shiftPs.close();
            
            // Test the specific query for performance
            out.println("<h3>Performance Query Test:</h3>");
            String testSql = "SELECT COUNT(*) as total, SUM(CASE WHEN status = 'OK' THEN 1 ELSE 0 END) as ok_checks FROM shift_checks WHERE DATE(check_time) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
            PreparedStatement testPs = con.prepareStatement(testSql);
            ResultSet testRs = testPs.executeQuery();
            
            if(testRs.next()) {
                int total = testRs.getInt("total");
                int okChecks = testRs.getInt("ok_checks");
                out.println("<p><strong>Total checks this week:</strong> " + total + "</p>");
                out.println("<p><strong>OK checks this week:</strong> " + okChecks + "</p>");
                if(total > 0) {
                    int rate = (okChecks * 100) / total;
                    out.println("<p><strong>Success rate:</strong> " + rate + "%</p>");
                } else {
                    out.println("<p><strong>Success rate:</strong> N/A (no data)</p>");
                }
            }
            testRs.close();
            testPs.close();
            
            con.close();
            
        } catch(Exception e) {
            out.println("<h3>❌ Database Error:</h3>");
            out.println("<p><strong>Error:</strong> " + e.getMessage() + "</p>");
            out.println("<p><strong>Stack Trace:</strong></p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }
        
        out.println("<br><br><a href='personnelDashboard.jsp'>Back to Dashboard</a>");
    }
}
