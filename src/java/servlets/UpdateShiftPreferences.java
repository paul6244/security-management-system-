package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/UpdateShiftPreferences")
public class UpdateShiftPreferences extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = (String) request.getSession().getAttribute("username");
        String preferredBranch = request.getParameter("preferredBranch");
        String preferredShift = request.getParameter("preferredShift");
        String autoCheckin = request.getParameter("autoCheckin");
        
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = java.sql.DriverManager.getConnection("jdbc:mysql://localhost:3306/securitymanagementsystem","root","");
            
            // Update security_personnel table
            String updateSql = "UPDATE security_personnel SET branch_id = ?, shift_time = ? WHERE user_id = (SELECT id FROM users WHERE username = ?)";
            PreparedStatement ps = con.prepareStatement(updateSql);
            ps.setInt(1, Integer.parseInt(preferredBranch));
            ps.setString(2, preferredShift);
            ps.setString(3, username);
            
            int rowsUpdated = ps.executeUpdate();
            
            if(rowsUpdated > 0) {
                response.sendRedirect("securityOfficerSettings.jsp?success=1&message=Shift preferences updated successfully!");
            } else {
                response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Failed to update shift preferences");
            }
            
            ps.close();
            con.close();
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("securityOfficerSettings.jsp?error=1&message=Database error occurred");
        }
    }
}
