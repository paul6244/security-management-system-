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

@WebServlet("/SimpleSignup")
public class SimpleSignup extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        
        HttpSession session = request.getSession();
        
        try {
            out.println("<html><body><h2>DEBUG: Simple Signup Test</h2>");
            out.println("<p>Username: " + username + "</p>");
            out.println("<p>Email: " + email + "</p>");
            out.println("<p>Role: " + role + "</p>");
            out.println("<p>Password: " + (password != null ? "[HIDDEN]" : "NULL") + "</p>");
            
            // Test database connection
            Connection conn = DatabaseConfig.getConnection();
            if (conn == null) {
                out.println("<p style='color: red;'>ERROR: Database connection is null</p>");
            } else {
                out.println("<p style='color: green;'>SUCCESS: Database connection established</p>");
                
                // Test userExists
                String checkSql = "SELECT COUNT(*) FROM users WHERE username = ?";
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setString(1, username);
                ResultSet checkRs = checkPs.executeQuery();
                
                if (checkRs.next() && checkRs.getInt(1) > 0) {
                    out.println("<p style='color: red;'>ERROR: Username already exists</p>");
                } else {
                    out.println("<p style='color: green;'>SUCCESS: Username is available</p>");
                    
                    // Test password hashing
                    String hashed = universalManager.hashPassword(password);
                    out.println("<p>Password hashed successfully</p>");
                    
                    // Test user insertion
                    String insertSql = "INSERT INTO users(username,email,password,role) VALUES(?,?,?,?)";
                    PreparedStatement insertPs = conn.prepareStatement(insertSql);
                    insertPs.setString(1, username);
                    insertPs.setString(2, email);
                    insertPs.setString(3, hashed);
                    insertPs.setString(4, role);
                    
                    int rows = insertPs.executeUpdate();
                    out.println("<p>User insert result: " + rows + " rows affected</p>");
                    
                    if (rows > 0) {
                        out.println("<p style='color: green; font-size: 20px;'>SUCCESS: User created successfully!</p>");
                        out.println("<p><a href='index.jsp'>Click here to login</a></p>");
                    } else {
                        out.println("<p style='color: red;'>ERROR: Failed to insert user</p>");
                    }
                    
                    insertPs.close();
                }
                
                checkRs.close();
                checkPs.close();
                conn.close();
            }
            
            out.println("</body></html>");
            
        } catch (Exception e) {
            out.println("<p style='color: red;'>ERROR: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }
    }
}
