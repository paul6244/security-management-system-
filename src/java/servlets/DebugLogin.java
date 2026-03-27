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
import javax.servlet.http.HttpSession;
import config.DatabaseConfig;
import utility.universalManager;

@WebServlet("/DebugLogin")
public class DebugLogin extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        out.println("<html><body><h2>DEBUG: Login Test</h2>");
        out.println("<p>Username: " + username + "</p>");
        out.println("<p>Password: " + (password != null ? "[HIDDEN]" : "NULL") + "</p>");
        
        try {
            // Test database connection
            out.println("<h3>Step 1: Testing Database Connection</h3>");
            Connection conn = DatabaseConfig.getConnection();
            if (conn == null) {
                out.println("<p style='color: red;'>ERROR: Database connection is null</p>");
                return;
            } else {
                out.println("<p style='color: green;'>SUCCESS: Database connection established</p>");
            }
            
            // Test password hashing
            out.println("<h3>Step 2: Testing Password Hashing</h3>");
            String hash = universalManager.hashPassword(password);
            out.println("<p>Password hashed successfully</p>");
            
            // Test user lookup
            out.println("<h3>Step 3: Testing User Lookup</h3>");
            String sql = "SELECT username, email, role, password FROM users WHERE username=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                out.println("<p style='color: green;'>User found in database</p>");
                out.println("<p>Username: " + rs.getString("username") + "</p>");
                out.println("<p>Email: " + rs.getString("email") + "</p>");
                out.println("<p>Role: " + rs.getString("role") + "</p>");
                out.println("<p>Stored Hash: " + rs.getString("password") + "</p>");
                out.println("<p>Input Hash: " + hash + "</p>");
                
                // Compare hashes
                String storedHash = rs.getString("password");
                if (hash.equals(storedHash)) {
                    out.println("<p style='color: green; font-size: 20px;'>SUCCESS: Passwords match!</p>");
                    out.println("<p style='color: green; font-size: 20px;'>LOGIN WOULD BE SUCCESSFUL!</p>");
                    out.println("<p><a href='index.jsp'>Try actual login here</a></p>");
                } else {
                    out.println("<p style='color: red;'>ERROR: Passwords do not match!</p>");
                    out.println("<p>Stored hash length: " + storedHash.length() + "</p>");
                    out.println("<p>Input hash length: " + hash.length() + "</p>");
                }
            } else {
                out.println("<p style='color: red;'>ERROR: User not found in database</p>");
            }
            
            rs.close();
            ps.close();
            conn.close();
            
        } catch (Exception e) {
            out.println("<p style='color: red;'>ERROR: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }
        
        out.println("</body></html>");
    }
}
