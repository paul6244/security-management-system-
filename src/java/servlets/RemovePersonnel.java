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
import model.Mymodel;
import config.DatabaseConfig;

@WebServlet("/RemovePersonnel")
public class RemovePersonnel extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            boolean success = removePersonnelFromDatabase(username, email);
            
            if (success) {
                out.print("success: Personnel removed successfully");
            } else {
                out.print("error: Failed to remove personnel");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        } finally {
            out.close();
        }
    }
    
    private boolean removePersonnelFromDatabase(String username, String email) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // Get database connection
            conn = DatabaseConfig.getConnection();
            
            // First, get the user ID and personnel ID
            String getUserInfoSql = "SELECT u.id as user_id, sp.id as personnel_id FROM users u " +
                                   "LEFT JOIN security_personnel sp ON u.id = sp.user_id " +
                                   "WHERE u.username = ? AND u.email = ?";
            ps = conn.prepareStatement(getUserInfoSql);
            ps.setString(1, username);
            ps.setString(2, email);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                return false; // User not found
            }
            
            int userId = rs.getInt("user_id");
            int personnelId = rs.getInt("personnel_id");
            rs.close();
            ps.close();
            
            // Delete from shift_checks first (if personnel_id exists)
            if (personnelId > 0) {
                String deleteShiftChecksSql = "DELETE FROM shift_checks WHERE personnel_id = ?";
                ps = conn.prepareStatement(deleteShiftChecksSql);
                ps.setInt(1, personnelId);
                ps.executeUpdate();
                ps.close();
                
                // Delete from security_personnel table
                String deletePersonnelSql = "DELETE FROM security_personnel WHERE id = ?";
                ps = conn.prepareStatement(deletePersonnelSql);
                ps.setInt(1, personnelId);
                ps.executeUpdate();
                ps.close();
            }
            
            // Delete from users table
            String deleteUserSql = "DELETE FROM users WHERE id = ?";
            ps = conn.prepareStatement(deleteUserSql);
            ps.setInt(1, userId);
            int userDeleted = ps.executeUpdate();
            ps.close();
            
            return userDeleted > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
