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

@WebServlet("/GetBranchChecklistItems")
public class GetBranchChecklistItems extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String branchId = request.getParameter("branchId");
        
        if (branchId == null || branchId.trim().isEmpty()) {
            out.println("<p>Please select a branch to view checklist items.</p>");
            return;
        }
        
        try {
            Connection con = DatabaseConfig.getConnection();
            
            // Get checklist items for specific branch
            String sql = "SELECT ci.id, ci.item_name, b.name as branch_name " +
                        "FROM checklist_items ci " +
                        "LEFT JOIN branch_checklist_items bci ON ci.id = bci.item_id " +
                        "LEFT JOIN branches b ON bci.branch_id = b.id " +
                        "WHERE bci.branch_id = ? " +
                        "ORDER BY ci.item_name";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(branchId));
            ResultSet rs = ps.executeQuery();
            
            if (!rs.isBeforeFirst()) {
                out.println("<p>No checklist items found for this branch.</p>");
            } else {
                out.println("<div class='checklist-table-container'>");
                out.println("<table border='1' width='100%' cellpadding='10' style='background:white; border-radius:10px;'>");
                out.println("<thead>");
                out.println("<tr style='background:#2c3e50; color:white;'>");
                out.println("<th>Item Name</th>");
                out.println("<th>Actions</th>");
                out.println("</tr>");
                out.println("</thead>");
                out.println("<tbody>");
                
                while (rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("item_name") + "</td>");
                    out.println("<td>");
                    out.println("<button class='btn btn-danger btn-sm' onclick='removeChecklistItem(" + rs.getInt("id") + ", " + branchId + ")'>Remove</button>");
                    out.println("</td>");
                    out.println("</tr>");
                }
                
                out.println("</tbody>");
                out.println("</table>");
                out.println("</div>");
            }
            
            rs.close();
            ps.close();
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Error loading checklist items: " + e.getMessage() + "</p>");
        }
    }
}
