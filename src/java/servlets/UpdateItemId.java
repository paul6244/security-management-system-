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

@WebServlet("/UpdateItemId")
public class UpdateItemId extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            int shiftCheckId = Integer.parseInt(request.getParameter("shiftCheckId"));
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            
            Connection conn = DatabaseConfig.getConnection();
            
            if (conn == null) {
                out.println("Error: Database connection is null");
                return;
            }
            
            String sql = "UPDATE shift_checks SET item_id = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            ps.setInt(2, shiftCheckId);
            
            int rowsUpdated = ps.executeUpdate();
            
            ps.close();
            conn.close();
            
            if (rowsUpdated > 0) {
                out.println("success: Updated item_id to " + itemId + " for shift check " + shiftCheckId);
            } else {
                out.println("error: No rows updated for shift check " + shiftCheckId);
            }
            
        } catch (Exception e) {
            out.println("error: " + e.getMessage());
            e.printStackTrace(out);
        }
    }
}
