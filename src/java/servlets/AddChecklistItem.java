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

@WebServlet("/AddChecklistItem")
public class AddChecklistItem extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        java.io.PrintWriter out = response.getWriter();
        
        String itemName = request.getParameter("itemName");
        String branchId = request.getParameter("itemBranch");
        
        if (itemName == null || itemName.trim().isEmpty() || branchId == null || branchId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Item name and branch are required.\"}");
            return;
        }
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // First, get item ID from checklist_items table
            String getItemIdSql = "SELECT id FROM checklist_items WHERE item_name = ?";
            PreparedStatement getItemIdPs = con.prepareStatement(getItemIdSql);
            getItemIdPs.setString(1, itemName);
            ResultSet itemIdRs = getItemIdPs.executeQuery();
            
            if (!itemIdRs.next()) {
                out.print("{\"success\": false, \"message\": \"Checklist item not found in master checklist.\"}");
                itemIdRs.close();
                getItemIdPs.close();
                con.close();
                return;
            }
            
            int itemId = itemIdRs.getInt("id");
            itemIdRs.close();
            getItemIdPs.close();
            
            // Now check if item already exists for this branch
            String checkSql = "SELECT COUNT(*) as count FROM branch_checklist_items WHERE item_id = ? AND branch_id = ?";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setInt(1, itemId);
            checkPs.setInt(2, Integer.parseInt(branchId));
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next() && checkRs.getInt("count") > 0) {
                out.print("{\"success\": false, \"message\": \"This item already exists for the selected branch.\"}");
                checkRs.close();
                checkPs.close();
                con.close();
                return;
            }
            checkRs.close();
            checkPs.close();
            
            // Get item ID from checklist_items table
            String getItemSql = "SELECT id FROM checklist_items WHERE item_name = ?";
            PreparedStatement getItemPs = con.prepareStatement(getItemSql);
            getItemPs.setString(1, itemName);
            ResultSet itemRs = getItemPs.executeQuery();
            
            if (itemRs.next()) {
                int itemId = itemRs.getInt("id");
                
                // Add item to branch-specific checklist
                String insertSql = "INSERT INTO branch_checklist_items (branch_id, item_id) VALUES (?, ?)";
                PreparedStatement insertPs = con.prepareStatement(insertSql);
                insertPs.setInt(1, Integer.parseInt(branchId));
                insertPs.setInt(2, itemId);
                int result = insertPs.executeUpdate();
                insertPs.close();
                
                if (result > 0) {
                    out.print("{\"success\": true, \"message\": \"Checklist item added successfully!\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to add checklist item.\"}");
                }
            } else {
                out.print("{\"success\": false, \"message\": \"Checklist item not found in master checklist.\"}");
            }
            
            itemRs.close();
            getItemPs.close();
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
}
