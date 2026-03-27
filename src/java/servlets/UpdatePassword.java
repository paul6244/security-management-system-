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
import config.DatabaseConfig;

@WebServlet("/UpdatePassword")
public class UpdatePassword extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // Validate current password
            String checkSql = "SELECT password FROM users WHERE username = ?";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setString(1, username);
            ResultSet rs = checkPs.executeQuery();
            
            if (rs.next()) {
                String storedPassword = rs.getString("password");
                
                // Simple password check (in production, use proper hashing)
                if (currentPassword.equals(storedPassword)) {
                    if (newPassword.equals(confirmPassword)) {
                        // Update password
                        String updateSql = "UPDATE users SET password = ? WHERE username = ?";
                        PreparedStatement updatePs = con.prepareStatement(updateSql);
                        updatePs.setString(1, newPassword);
                        updatePs.setString(2, username);
                        
                        int result = updatePs.executeUpdate();
                        
                        if (result > 0) {
                            out.println("<script>alert('Password updated successfully!'); window.location.href='settings.jsp';</script>");
                        } else {
                            out.println("<script>alert('Error updating password. Please try again.'); window.location.href='settings.jsp';</script>");
                        }
                        updatePs.close();
                    } else {
                        out.println("<script>alert('New passwords do not match.'); window.location.href='settings.jsp';</script>");
                    }
                } else {
                    out.println("<script>alert('Current password is incorrect.'); window.location.href='settings.jsp';</script>");
                }
            }
            
            rs.close();
            checkPs.close();
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Database error: " + e.getMessage() + "'); window.location.href='settings.jsp';</script>");
        }
    }
}
