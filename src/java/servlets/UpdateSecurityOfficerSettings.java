package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

<<<<<<< HEAD
import config.DatabaseConfig;

=======
>>>>>>> a2ae55f67fdb2960dceeb77213e859a83ba787a0
@WebServlet("/UpdateSecurityOfficerSettings")
public class UpdateSecurityOfficerSettings extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
<<<<<<< HEAD
        // Validate CSRF token
        String sessionToken = (String) request.getSession().getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");
        
        if (sessionToken == null || !sessionToken.equals(requestToken)) {
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Invalid request - please try again");
            return;
        }
        
=======
>>>>>>> a2ae55f67fdb2960dceeb77213e859a83ba787a0
        String username = (String) request.getSession().getAttribute("username");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String emergencyContact = request.getParameter("emergencyContact");
        String notifications = request.getParameter("notifications");
        
        Connection con = null;
        try {
<<<<<<< HEAD
            con = DatabaseConfig.getConnection();
            
            // Update users table for email
            String updateUser = "UPDATE users SET email = ? WHERE username = ?";
            PreparedStatement userPs = con.prepareStatement(updateUser);
            userPs.setString(1, email);
            userPs.setString(2, username);
            userPs.executeUpdate();
            userPs.close();
            
            // Update security_personnel table
            String updatePersonnel = "UPDATE security_personnel SET name = ?, phone = ?, emergency_contact = ? WHERE user_id = (SELECT id FROM users WHERE username = ?)";
            PreparedStatement ps = con.prepareStatement(updatePersonnel);
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, emergencyContact);
            ps.setString(4, username);
=======
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = java.sql.DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
            
            // Update security_personnel table
            String updatePersonnel = "UPDATE security_personnel SET name = ?, email = ? WHERE user_id = (SELECT id FROM users WHERE username = ?)";
            PreparedStatement ps = con.prepareStatement(updatePersonnel);
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, username);
>>>>>>> a2ae55f67fdb2960dceeb77213e859a83ba787a0
            
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
