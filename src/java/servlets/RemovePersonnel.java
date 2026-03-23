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

@WebServlet("/RemovePersonnel")
public class RemovePersonnel extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        
        try {
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
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/securitymanagementsystem", "root", "");
            
            // First, get the user ID from username
            String getUserIdSql = "SELECT id FROM users WHERE username = ? AND email = ?";
            ps = conn.prepareStatement(getUserIdSql);
            ps.setString(1, username);
            ps.setString(2, email);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                return false; // User not found
            }
            
            int userId = rs.getInt("id");
            rs.close();
            ps.close();
            
            // Delete from security_personnel table first (foreign key constraint)
            String deletePersonnelSql = "DELETE FROM security_personnel WHERE user_id = ?";
            ps = conn.prepareStatement(deletePersonnelSql);
            ps.setInt(1, userId);
            int personnelDeleted = ps.executeUpdate();
            ps.close();
            
            // Delete from users table
            String deleteUserSql = "DELETE FROM users WHERE id = ?";
            ps = conn.prepareStatement(deleteUserSql);
            ps.setInt(1, userId);
            int userDeleted = ps.executeUpdate();
            ps.close();
            
            // Delete related shift_checks if any
            String deleteShiftChecksSql = "DELETE FROM shift_checks WHERE personnel_id IN (SELECT id FROM security_personnel WHERE user_id = ?)";
            ps = conn.prepareStatement(deleteShiftChecksSql);
            ps.setInt(1, userId);
            ps.executeUpdate();
            ps.close();
            
            return (personnelDeleted > 0 && userDeleted > 0);
            
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
