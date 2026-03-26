package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import config.DatabaseConfig;

@WebServlet("/UpdateSecurityOfficerSettings")
public class UpdateSecurityOfficerSettings extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = (String) request.getSession().getAttribute("username");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String emergencyContact = request.getParameter("emergencyContact");
        String notifications = request.getParameter("notifications");
        
        Connection con = null;
        try {
            con = DatabaseConfig.getConnection();
            
            // Update security_personnel table
            String updatePersonnel = "UPDATE security_personnel SET name = ?, email = ? WHERE user_id = (SELECT id FROM users WHERE username = ?)";
            PreparedStatement ps = con.prepareStatement(updatePersonnel);
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, username);
            
            int rowsUpdated = ps.executeUpdate();
            
            if(rowsUpdated > 0) {
                response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Personal settings updated successfully!");
            } else {
                response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Failed to update personal settings");
            }
            
            ps.close();
            con.close();
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Database error occurred");
        }
    }
}
