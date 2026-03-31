package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import config.SimpleDatabaseConfig;

@WebServlet("/AttendanceDatabaseCheck")
public class AttendanceDatabaseCheck extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Attendance Database Check</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println("table { border-collapse: collapse; width: 100%; margin: 20px 0; }");
        out.println("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        out.println("th { background-color: #f2f2f2; }");
        out.println(".success { color: green; font-weight: bold; }");
        out.println(".error { color: red; font-weight: bold; }");
        out.println(".info { color: blue; }");
        out.println("</style></head><body>");
        
        out.println("<h2>Attendance Database Diagnostic</h2>");
        
        Connection conn = null;
        try {
            out.println("<h3>1. Testing Database Connection</h3>");
            conn = SimpleDatabaseConfig.getSimpleConnection();
            
            if (conn != null) {
                out.println("<p class='success'>✅ Database connection established!</p>");
                out.println("<p>Connection valid: " + conn.isValid(5) + "</p>");
                out.println("<p>Database: " + conn.getMetaData().getDatabaseProductName() + "</p>");
                out.println("<p>Version: " + conn.getMetaData().getDatabaseProductVersion() + "</p>");
                
                // Check database structure
                out.println("<h3>2. Checking Database Structure</h3>");
                DatabaseMetaData metaData = conn.getMetaData();
                
                // Check attendance-related tables
                out.println("<h4>Attendance Related Tables:</h4>");
                String[] attendanceTables = {"attendance", "shifts", "shift_checks", "security_personnel", "users", "branches"};
                
                out.println("<table>");
                out.println("<tr><th>Table Name</th><th>Exists</th><th>Columns</th></tr>");
                
                for (String tableName : attendanceTables) {
                    try {
                        ResultSet tableRs = metaData.getTables(null, null, tableName, new String[]{"TABLE"});
                        boolean tableExists = tableRs.next();
                        
                        out.println("<tr>");
                        out.println("<td>" + tableName + "</td>");
                        out.println("<td class='" + (tableExists ? "success" : "error") + "'>" + (tableExists ? "✅ EXISTS" : "❌ MISSING") + "</td>");
                        
                        if (tableExists) {
                            try {
                                ResultSet columnRs = metaData.getColumns(null, null, tableName, null);
                                int columnCount = 0;
                                while (columnRs.next()) {
                                    columnCount++;
                                }
                                out.println("<td>" + columnCount + " columns</td>");
                                columnRs.close();
                            } catch (Exception e) {
                                out.println("<td class='error'>Error counting columns</td>");
                            }
                        } else {
                            out.println("<td>-</td>");
                        }
                        
                        out.println("</tr>");
                        tableRs.close();
                    } catch (Exception e) {
                        out.println("<tr>");
                        out.println("<td>" + tableName + "</td>");
                        out.println("<td class='error'>❌ ERROR</td>");
                        out.println("<td class='error'>" + escapeHtml(e.getMessage()) + "</td>");
                        out.println("</tr>");
                    }
                }
                
                out.println("</table>");
                
                // Test queries on attendance tables
                out.println("<h3>3. Testing Attendance Queries</h3>");
                Statement stmt = conn.createStatement();
                
                // Test basic attendance query
                try {
                    out.println("<h4>Testing Attendance Query:</h4>");
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM attendance LIMIT 1");
                    if (rs.next()) {
                        out.println("<p class='success'>✅ Attendance table accessible - Records: " + rs.getInt("total") + "</p>");
                    }
                    rs.close();
                } catch (Exception e) {
                    out.println("<p class='error'>❌ Attendance query failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
                // Test shifts query
                try {
                    out.println("<h4>Testing Shifts Query:</h4>");
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM shifts LIMIT 1");
                    if (rs.next()) {
                        out.println("<p class='success'>✅ Shifts table accessible - Records: " + rs.getInt("total") + "</p>");
                    }
                    rs.close();
                } catch (Exception e) {
                    out.println("<p class='error'>❌ Shifts query failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
                // Test shift_checks query
                try {
                    out.println("<h4>Testing Shift Checks Query:</h4>");
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM shift_checks LIMIT 1");
                    if (rs.next()) {
                        out.println("<p class='success'>✅ Shift checks table accessible - Records: " + rs.getInt("total") + "</p>");
                    }
                    rs.close();
                } catch (Exception e) {
                    out.println("<p class='error'>❌ Shift checks query failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
                stmt.close();
                
            } else {
                out.println("<p class='error'>❌ Failed to establish database connection</p>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>❌ DATABASE ERROR: " + escapeHtml(e.getMessage()) + "</p>");
            out.println("<h3>Error Details:</h3>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    out.println("<p class='info'>ℹ️ Database connection closed</p>");
                } catch (Exception e) {
                    out.println("<p class='error'>❌ Error closing connection: " + escapeHtml(e.getMessage()) + "</p>");
                }
            }
        }
        
        out.println("<br><br>");
        out.println("<h3>4. Navigation</h3>");
        out.println("<a href='DirectConnectionTest'>← Direct Connection Test</a><br>");
        out.println("<a href='SimpleConnectionTest'>← Simple Connection Test</a><br>");
        out.println("<a href='EnvCheck'>← Environment Check</a><br>");
        out.println("<a href='attendance.jsp'>← Go to Attendance Page</a><br>");
        out.println("<a href='index.jsp'>← Back to Login</a>");
        out.println("</body></html>");
    }
    
    private String escapeHtml(String input) {
        if (input == null) return "null";
        return input.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#39;");
    }
}
