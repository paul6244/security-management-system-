package servlets;

import java.io.IOException;
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

@WebServlet("/SimpleLogin")
public class SimpleLogin extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        HttpSession session = request.getSession();

        // Basic validation
        if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
            session.setAttribute("loginError", "All fields are required.");
            response.sendRedirect("index.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // Get database connection
            conn = DatabaseConfig.getConnection();
            if (conn == null) {
                session.setAttribute("loginError", "Database connection failed. Please try again.");
                response.sendRedirect("index.jsp");
                return;
            }

            // Hash the password
            String hash = universalManager.hashPassword(password);

            // Check user credentials
            String sql = "SELECT id, role FROM users WHERE username=? AND password=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, hash);

            rs = ps.executeQuery();
            
            if (rs.next()) {
                // Login successful
                int userId = rs.getInt("id");
                String role = rs.getString("role");
                
                session.setAttribute("username", username);
                session.setAttribute("userId", userId);
                session.setAttribute("role", role);
                session.setAttribute("loginSuccess", "Login successful!");

                if (role.equals("admin")) {
                    response.sendRedirect("admin.jsp");
                } else if (role.equals("security_officer")) {
                    response.sendRedirect("personnelDashboard.jsp");
                } else {
                    response.sendRedirect("index.jsp");
                }
                
            } else {
                // Login failed
                session.setAttribute("loginError", "Invalid username or password");
                response.sendRedirect("index.jsp");
            }
            
        } catch (Exception e) {
            session.setAttribute("loginError", "Login error: " + e.getMessage());
            response.sendRedirect("index.jsp");
        } finally {
            // Clean up resources
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                // Log cleanup errors if needed
            }
        }
    }
}
