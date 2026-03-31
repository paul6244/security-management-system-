package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import config.DatabaseConfig;

@WebServlet("/DatabaseTest")
public class DatabaseTest extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Database Connection Test</title></head><body>");
        out.println("<h2>Database Connection Test</h2>");
        
        try {
            out.println("<p>Testing database connection...</p>");
            
            Connection conn = DatabaseConfig.getConnection();
            
            if (conn != null) {
                out.println("<p style='color: green; font-weight: bold;'>✅ SUCCESS: Database connection established!</p>");
                out.println("<p>Connection is valid: " + conn.isValid(5) + "</p>");
                out.println("<p>Database URL: " + conn.getMetaData().getURL() + "</p>");
                out.println("<p>Database Product Name: " + conn.getMetaData().getDatabaseProductName() + "</p>");
                out.println("<p>Database Version: " + conn.getMetaData().getDatabaseProductVersion() + "</p>");
                out.println("<p>Driver Name: " + conn.getMetaData().getDriverName() + "</p>");
                out.println("<p>Driver Version: " + conn.getMetaData().getDriverVersion() + "</p>");
            } else {
                out.println("<p style='color: red; font-weight: bold;'>❌ FAILED: Database connection is null</p>");
            }
            
        } catch (SQLException e) {
            out.println("<p style='color: red; font-weight: bold;'>❌ ERROR: " + e.getMessage() + "</p>");
            out.println("<p>SQL State: " + e.getSQLState() + "</p>");
            out.println("<p>Error Code: " + e.getErrorCode() + "</p>");
            out.println("<p>Stack Trace:</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        } catch (Exception e) {
            out.println("<p style='color: red; font-weight: bold;'>❌ GENERAL ERROR: " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }
        
        out.println("<br><br>");
        out.println("<a href='index.jsp'>← Back to Login</a>");
        out.println("</body></html>");
    }
}
