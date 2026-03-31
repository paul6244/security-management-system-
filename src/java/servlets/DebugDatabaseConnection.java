package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.net.URI;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DebugDatabaseConnection")
public class DebugDatabaseConnection extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Database Connection Debug</title></head><body>");
        out.println("<h2>Database Connection Debug</h2>");
        
        try {
            String databaseUrl = System.getenv("DATABASE_URL");
            out.println("<p><strong>DATABASE_URL found:</strong> " + (databaseUrl != null ? "YES" : "NO") + "</p>");
            
            if (databaseUrl != null) {
                out.println("<p><strong>DATABASE_URL (first 50 chars):</strong> " + databaseUrl.substring(0, Math.min(50, databaseUrl.length())) + "...</p>");
                
                if (databaseUrl.startsWith("postgres://")) {
                    URI uri = new URI(databaseUrl);
                    String username = uri.getUserInfo().split(":")[0];
                    String password = uri.getUserInfo().split(":")[1];
                    String host = uri.getHost();
                    int port = uri.getPort();
                    String database = uri.getPath().substring(1);
                    
                    out.println("<p><strong>Host:</strong> " + host + "</p>");
                    out.println("<p><strong>Port:</strong> " + port + "</p>");
                    out.println("<p><strong>Database:</strong> " + database + "</p>");
                    out.println("<p><strong>Username:</strong> " + username + "</p>");
                    
                    // Test driver loading
                    try {
                        Class.forName("org.postgresql.Driver");
                        out.println("<p><strong>PostgreSQL Driver:</strong> ✅ Loaded</p>");
                    } catch (Exception e) {
                        out.println("<p><strong>PostgreSQL Driver:</strong> ❌ Failed - " + e.getMessage() + "</p>");
                    }
                    
                    // Test connection
                    try {
                        String jdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + database;
                        out.println("<p><strong>JDBC URL:</strong> " + jdbcUrl + "</p>");
                        
                        Connection conn = DriverManager.getConnection(jdbcUrl, username, password);
                        out.println("<p><strong>Connection:</strong> ✅ SUCCESS</p>");
                        conn.close();
                    } catch (Exception e) {
                        out.println("<p><strong>Connection:</strong> ❌ FAILED - " + e.getMessage() + "</p>");
                        out.println("<p><strong>Error Type:</strong> " + e.getClass().getSimpleName() + "</p>");
                    }
                } else {
                    out.println("<p><strong>Format:</strong> ❌ Invalid - doesn't start with postgres://</p>");
                }
            }
            
        } catch (Exception e) {
            out.println("<p><strong>Overall Error:</strong> " + e.getMessage() + "</p>");
            out.println("<p><strong>Error Type:</strong> " + e.getClass().getSimpleName() + "</p>");
        }
        
        out.println("<p><a href='attendance.jsp'>← Back to Attendance</a></p>");
        out.println("</body></html>");
    }
}
