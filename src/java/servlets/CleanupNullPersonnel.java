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

@WebServlet("/CleanupNullPersonnel")
public class CleanupNullPersonnel extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // Count null personnel records
            String countSql = "SELECT COUNT(*) as count FROM security_personnel sp " +
                             "LEFT JOIN users u ON sp.user_id = u.id " +
                             "WHERE u.username IS NULL OR u.email IS NULL";
            PreparedStatement countPs = con.prepareStatement(countSql);
            ResultSet countRs = countPs.executeQuery();
            
            int nullCount = 0;
            if (countRs.next()) {
                nullCount = countRs.getInt("count");
            }
            countRs.close();
            countPs.close();
            
            if (nullCount > 0) {
                // Delete personnel records without corresponding users
                String deleteSql = "DELETE sp FROM security_personnel sp " +
                                  "LEFT JOIN users u ON sp.user_id = u.id " +
                                  "WHERE u.username IS NULL OR u.email IS NULL";
                PreparedStatement deletePs = con.prepareStatement(deleteSql);
                int deletedCount = deletePs.executeUpdate();
                deletePs.close();
                
                out.println("<script>alert('Successfully removed " + deletedCount + " null personnel records.'); window.location.href='userManagement.jsp';</script>");
            } else {
                out.println("<script>alert('No null personnel records found.'); window.location.href='userManagement.jsp';</script>");
            }
            
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error cleaning up null personnel: " + e.getMessage() + "'); window.location.href='userManagement.jsp';</script>");
        }
    }
}
