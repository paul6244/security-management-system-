package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import config.SimpleDatabaseConfig;

@WebServlet("/SimpleConnectionTest")
public class SimpleConnectionTest extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Simple Connection Test</title></head><body>");
        out.println("<h2>Simple Database Connection Test</h2>");
        
        try {
            out.println("<p>Testing simple database connection...</p>");
            
            Connection conn = SimpleDatabaseConfig.getSimpleConnection();
            
            if (conn != null) {
                out.println("<p style='color: green; font-weight: bold;'>✅ SUCCESS: Simple connection works!</p>");
                out.println("<p>Connection valid: " + conn.isValid(5) + "</p>");
                out.println("<p>Database metadata: " + conn.getMetaData().getDatabaseProductName() + "</p>");
                out.println("<p>Database version: " + conn.getMetaData().getDatabaseProductVersion() + "</p>");
                conn.close();
                out.println("<p>Connection closed successfully</p>");
            } else {
                out.println("<p style='color: red; font-weight: bold;'>❌ FAILED: Connection is null</p>");
            }
            
        } catch (Exception e) {
            out.println("<p style='color: red; font-weight: bold;'>❌ ERROR: " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }
        
        out.println("<br><br>");
        out.println("<a href='DirectConnectionTest'>← Direct Connection Test</a><br>");
        out.println("<a href='EnvCheck'>← Environment Check</a><br>");
        out.println("<a href='index.jsp'>← Back to Login</a>");
        out.println("</body></html>");
    }
}
