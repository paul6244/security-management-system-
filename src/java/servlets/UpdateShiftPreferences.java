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

@WebServlet("/UpdateShiftPreferences")
public class UpdateShiftPreferences extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Validate CSRF token
        String sessionToken = (String) request.getSession().getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");
        
        if (sessionToken == null || !sessionToken.equals(requestToken)) {
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Invalid request - please try again");
            return;
        }
        String preferredBranch = request.getParameter("preferredBranch");
        String preferredShift = request.getParameter("preferredShift");
        String autoCheckin = request.getParameter("autoCheckin");
        
        Connection con = null;
        try {
            con = DatabaseConfig.getConnection();
            
            // Update security_personnel table
            String updateSql = "UPDATE security_personnel SET branch_id = ?, shift_time = ? WHERE user_id = (SELECT id FROM users WHERE username = ?)";
            PreparedStatement ps = con.prepareStatement(updateSql);
            
            try {
                if (preferredBranch != null && !preferredBranch.equals("0")) {
                    ps.setInt(1, Integer.parseInt(preferredBranch));
                } else {
                    ps.setNull(1, java.sql.Types.INTEGER);
                }
                
                ps.setString(2, preferredShift);
                ps.setString(3, username);
                
                int rowsUpdated = ps.executeUpdate();
                
                ps.close();
                
                if(rowsUpdated > 0) {
                    response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Shift preferences updated successfully!");
                } else {
                    response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Failed to update shift preferences");
                }
            } catch (NumberFormatException e) {
                ps.close();
                response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Invalid branch ID format");
                return;
            }
            con.close();
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Database error occurred");
        }
    }
}
