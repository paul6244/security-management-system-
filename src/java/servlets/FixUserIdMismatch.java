package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import config.DatabaseConfig;

@WebServlet("/FixUserIdMismatch")
public class FixUserIdMismatch extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            int personnelId = Integer.parseInt(request.getParameter("personnelId"));
            int correctUserId = Integer.parseInt(request.getParameter("correctUserId"));
            
            Connection conn = DatabaseConfig.getConnection();
            
            if (conn == null) {
                out.println("Error: Database connection is null");
                return;
            }
            
            String sql = "UPDATE security_personnel SET user_id = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, correctUserId);
            ps.setInt(2, personnelId);
            
            int rowsUpdated = ps.executeUpdate();
            
            ps.close();
            conn.close();
            
            if (rowsUpdated > 0) {
                out.println("success: Updated user_id to " + correctUserId + " for personnel " + personnelId);
            } else {
                out.println("error: No rows updated for personnel " + personnelId);
            }
            
        } catch (Exception e) {
            out.println("error: " + e.getMessage());
            e.printStackTrace(out);
        }
    }
}
