package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;
import com.google.gson.Gson;
import config.DatabaseConfig;

@WebServlet("/AddChecklistItem")
public class AddChecklistItem extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        // Debug: Log all received parameters
        System.out.println("DEBUG: AddChecklistItem servlet called");
        System.out.println("DEBUG: Content-Type: " + request.getContentType());
        System.out.println("DEBUG: Method: " + request.getMethod());
        
        // Log all parameter names
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        System.out.println("DEBUG: Parameters received:");
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            System.out.println("  " + paramName + " = '" + paramValue + "'");
        }
        
        String itemName = request.getParameter("itemName");
        String branchId = request.getParameter("itemBranch");
        
        System.out.println("DEBUG: itemName = '" + itemName + "'");
        System.out.println("DEBUG: branchId = '" + branchId + "'");
        
        if (itemName == null || itemName.trim().isEmpty() || branchId == null || branchId.trim().isEmpty()) {
            System.out.println("DEBUG: Parameter validation failed");
            out.print("{\"success\": false, \"message\": \"Item name and branch are required. [DEBUG: itemName=" + itemName + ", branchId=" + branchId + "]\"}");
            return;
        }
        
        Connection con = null;
        try {
            con = DatabaseConfig.getConnection();
            
            // First, try to get item ID from checklist_items table
            String getItemIdSql = "SELECT id FROM checklist_items WHERE item_name = ?";
            PreparedStatement getItemIdPs = con.prepareStatement(getItemIdSql);
            getItemIdPs.setString(1, itemName);
            ResultSet itemIdRs = getItemIdPs.executeQuery();
            
            int checklistItemId;
            if (!itemIdRs.next()) {
                // Item doesn't exist, create it in master checklist
                itemIdRs.close();
                getItemIdPs.close();
                
                String insertItemSql = "INSERT INTO checklist_items (item_name) VALUES (?)";
                PreparedStatement insertItemPs = con.prepareStatement(insertItemSql, Statement.RETURN_GENERATED_KEYS);
                insertItemPs.setString(1, itemName);
                insertItemPs.executeUpdate();
                
                ResultSet generatedKeys = insertItemPs.getGeneratedKeys();
                if (generatedKeys.next()) {
                    checklistItemId = generatedKeys.getInt(1);
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to create new checklist item.\"}");
                    generatedKeys.close();
                    insertItemPs.close();
                    return;
                }
                generatedKeys.close();
                insertItemPs.close();
            } else {
                // Item exists, get its ID
                checklistItemId = itemIdRs.getInt("id");
                itemIdRs.close();
                getItemIdPs.close();
            }
            
            // Now check if item already exists for this branch
            String checkSql = "SELECT COUNT(*) as count FROM branch_checklist_items WHERE item_id = ? AND branch_id = ?";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setInt(1, checklistItemId);
            checkPs.setInt(2, Integer.parseInt(branchId));
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next() && checkRs.getInt("count") > 0) {
                out.print("{\"success\": false, \"message\": \"This item already exists for the selected branch.\"}");
                checkRs.close();
                checkPs.close();
                return;
            }
            checkRs.close();
            checkPs.close();
            
            // Add item to branch-specific checklist
            String insertSql = "INSERT INTO branch_checklist_items (branch_id, item_id) VALUES (?, ?)";
            PreparedStatement insertPs = con.prepareStatement(insertSql);
            insertPs.setInt(1, Integer.parseInt(branchId));
            insertPs.setInt(2, checklistItemId);
            int result = insertPs.executeUpdate();
            insertPs.close();
            
            if (result > 0) {
                out.print("{\"success\": true, \"message\": \"Checklist item added successfully!\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to add checklist item.\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        } finally {
            try {
                if (con != null && !con.isClosed()) {
                    con.close();
                }
            } catch (Exception e) {
                // Ignore close errors
            }
        }
    }
}
