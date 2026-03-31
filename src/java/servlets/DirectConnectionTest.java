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

@WebServlet("/DirectConnectionTest")
public class DirectConnectionTest extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Direct Connection Test</title></head><body>");
        out.println("<h2>Direct PostgreSQL Connection Test</h2>");
        
        try {
            String databaseUrl = System.getenv("DATABASE_URL");
            out.println("<p><strong>DATABASE_URL:</strong> " + escapeHtml(databaseUrl) + "</p>");
            
            if (databaseUrl != null && databaseUrl.startsWith("postgres://")) {
                // Parse the URL manually
                URI uri = new URI(databaseUrl);
                String username = uri.getUserInfo().split(":")[0];
                String password = uri.getUserInfo().split(":")[1];
                String host = uri.getHost();
                int port = uri.getPort();
                String database = uri.getPath().substring(1);
                
                out.println("<h3>Connection Details:</h3>");
                out.println("<p><strong>Host:</strong> " + escapeHtml(host) + "</p>");
                out.println("<p><strong>Port:</strong> " + port + "</p>");
                out.println("<p><strong>Database:</strong> " + escapeHtml(database) + "</p>");
                out.println("<p><strong>Username:</strong> " + escapeHtml(username) + "</p>");
                out.println("<p><strong>Password Length:</strong> " + (password != null ? password.length() : 0) + "</p>");
                
                // Test 1: Basic connection without any properties
                out.println("<h3>Test 1: Basic Connection</h3>");
                try {
                    Class.forName("org.postgresql.Driver");
                    String basicUrl = "jdbc:postgresql://" + host + ":" + port + "/" + database;
                    Connection conn1 = DriverManager.getConnection(basicUrl, username, password);
                    out.println("<p style='color: green;'>✅ Basic connection successful!</p>");
                    out.println("<p>Connection valid: " + conn1.isValid(5) + "</p>");
                    conn1.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>❌ Basic connection failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
                // Test 2: Connection with SSL=false
                out.println("<h3>Test 2: SSL Disabled</h3>");
                try {
                    String sslUrl = "jdbc:postgresql://" + host + ":" + port + "/" + database + "?ssl=false";
                    Connection conn2 = DriverManager.getConnection(sslUrl, username, password);
                    out.println("<p style='color: green;'>✅ SSL disabled connection successful!</p>");
                    out.println("<p>Connection valid: " + conn2.isValid(5) + "</p>");
                    conn2.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>❌ SSL disabled connection failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
                // Test 3: Connection with SSL=true
                out.println("<h3>Test 3: SSL Enabled</h3>");
                try {
                    String sslTrueUrl = "jdbc:postgresql://" + host + ":" + port + "/" + database + "?ssl=true";
                    Connection conn3 = DriverManager.getConnection(sslTrueUrl, username, password);
                    out.println("<p style='color: green;'>✅ SSL enabled connection successful!</p>");
                    out.println("<p>Connection valid: " + conn3.isValid(5) + "</p>");
                    conn3.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>❌ SSL enabled connection failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
                // Test 4: Connection with sslmode=require
                out.println("<h3>Test 4: SSL Mode Require</h3>");
                try {
                    String requireUrl = "jdbc:postgresql://" + host + ":" + port + "/" + database + "?ssl=true&sslmode=require";
                    Connection conn4 = DriverManager.getConnection(requireUrl, username, password);
                    out.println("<p style='color: green;'>✅ SSL require connection successful!</p>");
                    out.println("<p>Connection valid: " + conn4.isValid(5) + "</p>");
                    conn4.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>❌ SSL require connection failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
                // Test 5: Test network connectivity
                out.println("<h3>Test 5: Network Connectivity</h3>");
                try {
                    java.net.Socket socket = new java.net.Socket();
                    socket.connect(new java.net.InetSocketAddress(host, port), 10000);
                    out.println("<p style='color: green;'>✅ Network connection to " + host + ":" + port + " successful!</p>");
                    socket.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>❌ Network connection failed: " + escapeHtml(e.getMessage()) + "</p>");
                }
                
            } else {
                out.println("<p style='color: red;'>❌ DATABASE_URL not found or invalid format</p>");
            }
            
        } catch (Exception e) {
            out.println("<p style='color: red; font-weight: bold;'>❌ GENERAL ERROR: " + escapeHtml(e.getMessage()) + "</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }
        
        out.println("<br><br>");
        out.println("<a href='EnvCheck'>← Environment Check</a><br>");
        out.println("<a href='DatabaseTest'>← Database Test</a><br>");
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
