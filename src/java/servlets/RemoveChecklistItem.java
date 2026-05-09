package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import config.DatabaseConfig;

@WebServlet("/RemoveChecklistItem")
public class RemoveChecklistItem extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        java.io.PrintWriter out = response.getWriter();
        
        String itemId = request.getParameter("itemId");
        String branchId = request.getParameter("branchId");
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // Remove item from branch-specific checklist
            String sql = "DELETE FROM branch_checklist_items WHERE item_id = ? AND branch_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(itemId));
            ps.setInt(2, Integer.parseInt(branchId));
            int result = ps.executeUpdate();
            ps.close();
            con.close();
            
            if (result > 0) {
                out.print("{\"success\": true, \"message\": \"Checklist item removed successfully!\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to remove checklist item.\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
}
