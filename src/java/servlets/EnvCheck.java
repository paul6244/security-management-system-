package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/EnvCheck")
public class EnvCheck extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Environment Check</title></head><body>");
        out.println("<h2>Environment Variables Check</h2>");
        
        // Check DATABASE_URL
        String databaseUrl = System.getenv("DATABASE_URL");
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            out.println("<p><strong>DATABASE_URL:</strong> " + escapeHtml(databaseUrl) + "</p>");
            out.println("<p><strong>Length:</strong> " + databaseUrl.length() + " characters</p>");
            out.println("<p><strong>Starts with postgres://:</strong> " + databaseUrl.startsWith("postgres://") + "</p>");
            
            // Parse and show components
            if (databaseUrl.startsWith("postgres://")) {
                try {
                    java.net.URI uri = new java.net.URI(databaseUrl);
                    out.println("<p><strong>Host:</strong> " + escapeHtml(uri.getHost()) + "</p>");
                    out.println("<p><strong>Port:</strong> " + uri.getPort() + "</p>");
                    out.println("<p><strong>Database:</strong> " + escapeHtml(uri.getPath()) + "</p>");
                    out.println("<p><strong>User Info:</strong> " + escapeHtml(uri.getUserInfo()) + "</p>");
                } catch (Exception e) {
                    out.println("<p style='color: red;'><strong>Error parsing URI:</strong> " + escapeHtml(e.getMessage()) + "</p>");
                }
            }
        } else {
            out.println("<p style='color: red;'><strong>DATABASE_URL:</strong> NOT FOUND OR EMPTY</p>");
        }
        
        // Check other Heroku variables
        out.println("<h3>Other Environment Variables:</h3>");
        String[] envVars = {"JAVA_HOME", "PORT", "DYNO", "HEROKU_APP_ID"};
        for (String envVar : envVars) {
            String value = System.getenv(envVar);
            if (value != null && !value.isEmpty()) {
                out.println("<p><strong>" + envVar + ":</strong> " + escapeHtml(value) + "</p>");
            } else {
                out.println("<p><strong>" + envVar + ":</strong> NOT SET</p>");
            }
        }
        
        out.println("<h3>Java System Properties:</h3>");
        out.println("<p><strong>Java Version:</strong> " + System.getProperty("java.version") + "</p>");
        out.println("<p><strong>Java Vendor:</strong> " + System.getProperty("java.vendor") + "</p>");
        out.println("<p><strong>OS Name:</strong> " + System.getProperty("os.name") + "</p>");
        out.println("<p><strong>OS Version:</strong> " + System.getProperty("os.version") + "</p>");
        
        out.println("<br><br>");
        out.println("<a href='DatabaseTest'>← Test Database Connection</a><br>");
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
