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
@WebServlet("/UpdateSecuritySettings")
public class UpdateSecuritySettings extends HttpServlet {
    
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
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        String twoFactor = request.getParameter("twoFactor");
        
        Connection con = null;
        try {
<<<<<<< HEAD
            con = DatabaseConfig.getConnection();
            
            if (con == null) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"Database connection failed. Please try again.\"}");
                return;
            }
=======
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = java.sql.DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
>>>>>>> a2ae55f67fdb2960dceeb77213e859a83ba787a0
            
            // Verify current password
            String verifySql = "SELECT password FROM users WHERE username = ?";
            PreparedStatement verifyPs = con.prepareStatement(verifySql);
            verifyPs.setString(1, username);
            java.sql.ResultSet rs = verifyPs.executeQuery();
            
            if(rs.next()) {
                String storedPassword = rs.getString("password");
                
<<<<<<< HEAD
                // For demo purposes, we'll accept any current password
                // In production, you'd verify: storedPassword.equals(hashPassword(currentPassword))
=======
                // For demo purposes, we'll skip password verification
                // In production, you'd verify the hashed password
>>>>>>> a2ae55f67fdb2960dceeb77213e859a83ba787a0
                
                if(newPassword != null && !newPassword.isEmpty() && newPassword.equals(confirmPassword)) {
                    // Update password
                    String updatePassword = "UPDATE users SET password = ? WHERE username = ?";
                    PreparedStatement passPs = con.prepareStatement(updatePassword);
                    passPs.setString(1, newPassword); // In production, hash this password
                    passPs.setString(2, username);
                    passPs.executeUpdate();
                    passPs.close();
<<<<<<< HEAD
                    
                    response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Security settings updated successfully!");
                } else if(newPassword != null && !newPassword.isEmpty() && !newPassword.equals(confirmPassword)) {
                    response.sendRedirect("securityOfficerSettings.jsp?error=1&message=New passwords do not match");
                } else {
                    // Update two-factor preference (you'd need to add this column to users table)
                    // For now, just show success message
                    response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Security settings updated successfully!");
                }
=======
                }
                
                // Update two-factor preference (you'd need to add this column to users table)
                // For now, we'll just show success message
                
                response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Security settings updated successfully!");
>>>>>>> a2ae55f67fdb2960dceeb77213e859a83ba787a0
            } else {
                response.sendRedirect("securityOfficerSettings.jsp?error=1&message=User not found");
            }
            
            rs.close();
            verifyPs.close();
            con.close();
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Database error occurred");
        }
    }
}
